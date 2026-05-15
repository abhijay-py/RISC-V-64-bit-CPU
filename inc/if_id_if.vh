`ifndef IF_ID_IF_VH
`define IF_ID_IF_VH

`include "types_pkg.vh"

interface if_id_if;
    import types_pkg::*;

    // Changed format for instr fetch to avoid confusion with interfaces
    word_t if_instr, instr_id;
    logic if_pred_taken, pred_taken_id, flush, freeze, ihit; 
    logic [GHR_W-1:0] if_prev_ghr, prev_ghr_id;
    addr_t if_pc, pc_id; 
    

    //IF_ID Latch ports
    modport fd (
        input if_instr, if_pred_taken, flush, freeze, ihit, if_pc, if_prev_ghr,
        output instr_id, pred_taken_id, pc_id, prev_ghr_id
    );

    //Testbench ports
    modport tb (
        input instr_id, pred_taken_id, pc_id, prev_ghr_id,
        output if_instr, if_pred_taken, flush, freeze, ihit, if_pc, if_prev_ghr
    );

endinterface
`endif 