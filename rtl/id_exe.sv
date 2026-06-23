`include "id_exe_if.svh"
`include "types_pkg.svh"

module id_exe (
    input logic clk, rst_n,
    id_exe_if.de deif
);
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n || deif.flush) begin
            deif.pred_taken_exe <= 1'b0;
            deif.reg_write_exe  <= 1'b0;
            deif.halt_exe       <= 1'b0;
            deif.mem_to_reg_exe <= 1'b0;
            deif.mem_read_exe   <= 1'b0;
            deif.mem_write_exe  <= 1'b0;
            deif.jump_exe       <= 1'b0;
            deif.branch_exe     <= 1'b0;
            deif.jalr_exe       <= 1'b0;
            deif.auipc_exe      <= 1'b0;
            deif.imm_sel_exe    <= 1'b0;
            deif.alu_op_exe     <= '0;
            deif.mem_data_exe   <= '0;
            deif.opcode_exe     <= '0;
            deif.funct3_exe     <= '0;
            deif.pc_exe         <= '0;
            deif.rd_exe         <= '0;
            deif.rs1_exe        <= '0;
            deif.rs2_exe        <= '0;
            deif.rdata1_exe     <= '0;
            deif.rdata2_exe     <= '0;
            deif.imm_exe        <= '0;
            deif.jumpimm_exe    <= '0;
            deif.prev_ghr_exe   <= '0;
        end
        else if (deif.ihit && !deif.freeze) begin
            deif.pred_taken_exe <= deif.pred_taken_id;
            deif.reg_write_exe  <= deif.reg_write_id;
            deif.halt_exe       <= deif.halt_id;
            deif.mem_to_reg_exe <= deif.mem_to_reg_id;
            deif.mem_read_exe   <= deif.mem_read_id;
            deif.mem_write_exe  <= deif.mem_write_id;
            deif.jump_exe       <= deif.jump_id;
            deif.branch_exe     <= deif.branch_id;
            deif.jalr_exe       <= deif.jalr_id;
            deif.auipc_exe      <= deif.auipc_id;
            deif.imm_sel_exe    <= deif.imm_sel_id;
            deif.alu_op_exe     <= deif.alu_op_id;
            deif.mem_data_exe   <= deif.mem_data_id;
            deif.opcode_exe     <= deif.opcode_id;
            deif.funct3_exe     <= deif.funct3_id;
            deif.pc_exe         <= deif.pc_id;
            deif.rd_exe         <= deif.rd_id;
            deif.rs1_exe        <= deif.rs1_id;
            deif.rs2_exe        <= deif.rs2_id;
            deif.rdata1_exe     <= deif.rdata1_id;
            deif.rdata2_exe     <= deif.rdata2_id;
            deif.imm_exe        <= deif.imm_id;
            deif.jumpimm_exe    <= deif.jumpimm_id;
            deif.prev_ghr_exe   <= deif.prev_ghr_id;
        end
    end
endmodule
