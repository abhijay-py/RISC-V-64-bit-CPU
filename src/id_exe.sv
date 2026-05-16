`include "id_exe_if.vh"
`include "types_pkg.vh"

import types_pkg::*;

module id_exe (
  input logic CLK, nRST,
  id_exe_if.de deif
);
  always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST || deif.flush) begin
      deif.pred_taken_exe <= 0;
      deif.RegWrite_exe <= 0;
      deif.halt_exe <= 0;
      deif.MemToReg_exe <= 0;
      deif.MemRead_exe <= 0;
      deif.MemWrite_exe <= 0;
      deif.jump_exe <= 0;
      deif.branch_exe <= 0;
      deif.jalr_exe <= 0;
      deif.auipc_exe <= 0;
      deif.immSel_exe <= 0;
      deif.ALUOp_exe <= '0;
      deif.MemData_exe <= '0;
      deif.opcode_exe <= '0;
      deif.funct3_exe <= '0;
      deif.pc_exe <= '0;
      deif.rd_exe <= '0;
      deif.rs1_exe <= '0;
      deif.rs2_exe <= '0;
      deif.rdata1_exe <= '0;
      deif.rdata2_exe <= '0;
      deif.imm_exe <= '0;
      deif.jumpimm_exe <= '0;
      deif.prev_ghr_exe <= '0;
    end
    else if (deif.ihit && !deif.freeze) begin
      deif.pred_taken_exe <= deif.pred_taken_id;
      deif.RegWrite_exe <= deif.RegWrite_id;
      deif.halt_exe <= deif.halt_id;
      deif.MemToReg_exe <= deif.MemToReg_id;
      deif.MemRead_exe <= deif.MemRead_id;
      deif.MemWrite_exe <= deif.MemWrite_id;
      deif.jump_exe <= deif.jump_id;
      deif.branch_exe <= deif.branch_id;
      deif.jalr_exe <= deif.jalr_id;
      deif.auipc_exe <= deif.auipc_id;
      deif.immSel_exe <= deif.immSel_id;
      deif.ALUOp_exe <= deif.ALUOp_id;
      deif.MemData_exe <= deif.MemData_id;
      deif.opcode_exe <= deif.opcode_id;
      deif.funct3_exe <= deif.funct3_id;
      deif.pc_exe <= deif.pc_id;
      deif.rd_exe <= deif.rd_id;
      deif.rs1_exe <= deif.rs1_id;
      deif.rs2_exe <= deif.rs2_id;
      deif.rdata1_exe <= deif.rdata1_id;
      deif.rdata2_exe <= deif.rdata2_id;
      deif.imm_exe <= deif.imm_id;
      deif.jumpimm_exe <= deif.jumpimm_id;
      deif.prev_ghr_exe <= deif.prev_ghr_id;
    end
  end
endmodule
