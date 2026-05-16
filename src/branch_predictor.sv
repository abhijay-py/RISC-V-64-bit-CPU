
`include "branch_predictor_if.vh"
`include "types_pkg.vh"

import types_pkg::*;
//TODO: Update diagram + iron out timing decisions
module branch_predictor (
  input logic CLK, nRST,
  branch_predictor_if.bp bpif
);
    logic next_pred_taken;
    addr_t next_target;

    logic [GHR_W-1:0] ghr, next_ghr; // 12 bit ghr, could expand to 16 if area permits
    
    logic [GHR_W-1:0] pht_index, old_pht_index;
    branchpred_t pht [PHT_ENTRIES-1:0];
    branchpred_t next_pht_entry, pht_entry_check;

    logic btb_entry_found, btb_jump_found;
    btb_pc_t pc_for_btb, oldpc_for_btb;
    btb_frame [BTB_FRAME_ENTRIES-1:0] btb_zero, btb_one;
    logic [BTB_FRAME_ENTRIES-1:0] lru;
    logic next_lru_write_entry, next_lru_read_entry;
    logic [BTB_IDX_W-1:0] btb_read_entry_idx, btb_write_entry_idx;
    btb_frame btbz_result, btbo_result, next_btbz_frame, next_btbo_frame;

    logic pht_en, btbz_en, btbo_en, lru_read_entry_en;
    

    assign pht_index = bpif.pc[GHR_W+1:2] ^ ghr; //ignoring bottom bits as instrs are often byte aligned. (CHANGE if adding compressed instrs)

    always_ff @ (posedge CLK, negedge nRST) begin
        if (!nRST) begin
            ghr <= '0;
            bpif.prev_ghr <= '0;
            btb_zero <= '0;
            btb_one <= '0;
            lru <= 0;
            bpif.pred_taken <= 0;
            bpif.target <= 0;

            for (int i = 0; i < PHT_ENTRIES; i++) begin
                pht[i] <= BP_WNT;
            end
        end
        else begin
            bpif.prev_ghr <= ghr;
            ghr <= next_ghr;

            if (pht_en) begin
                pht[old_pht_index] <= next_pht_entry;
            end
            if (btbz_en) begin
                btb_zero[btb_write_entry_idx] <= next_btbz_frame;
            end
            if (btbo_en) begin
                btb_one[btb_write_entry_idx] <= next_btbo_frame;
            end
            if (btbo_en || btbz_en) begin
                lru[btb_write_entry_idx] <= next_lru_write_entry;
            end
            else if (lru_read_entry_en) begin
                lru[btb_read_entry_idx] <= next_lru_read_entry;
            end

            bpif.pred_taken <= next_pred_taken;
            bpif.target <= next_target;
        end
    end

    always_comb begin
        next_ghr = ghr;
        next_pht_entry = '0;
        next_btbz_frame = '0;
        next_btbo_frame = '0;
        next_lru_read_entry = 0;
        next_lru_write_entry = 0;

        next_pred_taken = 0;
        next_target = bpif.target;

        btb_entry_found = 0;
        btb_jump_found = 0;
        old_pht_index = 0;
        btb_read_entry_idx = 0;
        btb_write_entry_idx = 0;

        lru_read_entry_en = 0;
        pht_en = 0;
        btbz_en = 0;
        btbo_en = 0;

        pht_entry_check = pht[pht_index];
        old_pht_index = bpif.old_pc[GHR_W+1:2] ^ bpif.old_ghr; 

        pc_for_btb = bpif.pc;
        btb_read_entry_idx = pc_for_btb.idx;
        btbz_result = btb_zero[pc_for_btb.idx];
        btbo_result = btb_one[pc_for_btb.idx];
        
        oldpc_for_btb = bpif.old_pc;
        btb_write_entry_idx = oldpc_for_btb.idx;
        next_btbz_frame = btb_zero[oldpc_for_btb.idx];
        next_btbo_frame = btb_one[oldpc_for_btb.idx];

        //BTB UPDATE LOGIC
        if (bpif.old_branch || bpif.old_jump) begin
            if (next_btbz_frame.valid && oldpc_for_btb.tag == next_btbz_frame.tag) begin
                next_lru_write_entry = 1;
                next_btbz_frame.pc = bpif.old_next_pc;
                btbz_en = 1;
            end
            else if (next_btbo_frame.valid && oldpc_for_btb.tag == next_btbo_frame.tag) begin
                next_lru_write_entry = 0;
                next_btbo_frame.pc = bpif.old_next_pc;
                btbo_en = 1;
            end
            else begin
                next_lru_write_entry = ~lru[oldpc_for_btb.idx];

                if (lru[oldpc_for_btb.idx]) begin
                    next_btbo_frame = '{valid: 1'b1, jump: bpif.old_jump, tag: oldpc_for_btb.tag, pc: bpif.old_next_pc};
                    btbo_en = 1;
                end
                else begin
                    next_btbz_frame = '{valid: 1'b1, jump: bpif.old_jump, tag: oldpc_for_btb.tag, pc: bpif.old_next_pc};
                    btbz_en = 1;
                end
            end
        end
        

        //PHT UPDATE LOGIC
        if (bpif.old_branch) begin
            //checks if there will be overflow
            if ((pht[old_pht_index] != BP_ST && bpif.old_jump_taken) || (pht[old_pht_index] != BP_SNT && !bpif.old_jump_taken)) begin
                pht_en = 1;
                next_pht_entry = bpif.old_jump_taken ? pht[old_pht_index] + 1 : pht[old_pht_index] - 1;
            end
        end

        //GHR UPDATE LOGIC
        if (bpif.old_jump_taken != bpif.old_pred_taken && bpif.old_branch) begin
            next_ghr = {bpif.old_ghr[10:0], bpif.old_jump_taken};
        end 
        else if (btb_entry_found) begin
            next_ghr = {ghr[10:0], next_pred_taken};
        end

        //BTB LOOKUP LOGIC
        if (btbz_result.valid && pc_for_btb.tag == btbz_result.tag) begin
            next_target = btbz_result.pc;
            next_lru_read_entry = 1;
            lru_read_entry_en = 1;
            btb_entry_found = 1;
            btb_jump_found = btbz_result.jump;
        end
        else if (btbo_result.valid && pc_for_btb.tag == btbo_result.tag) begin
            next_target = btbo_result.pc;
            next_lru_read_entry = 0;
            lru_read_entry_en = 1;
            btb_read_entry_idx = pc_for_btb.idx;
            btb_entry_found = 1;
            btb_jump_found = btbo_result.jump;
        end
        else if (bpif.pc == bpif.old_pc && (btbo_en || btbz_en)) begin
            next_target = bpif.old_next_pc;
            btb_entry_found = 1;
            btb_jump_found = bpif.old_jump;
        end

        //PHT LOOKUP LOGIC
        if (old_pht_index == pht_index && pht_en) begin
            pht_entry_check = next_pht_entry;
        end
        if (btb_entry_found && (btb_jump_found || pht_entry_check[1] == 1)) begin
            next_pred_taken = 1;
        end
    end

endmodule
