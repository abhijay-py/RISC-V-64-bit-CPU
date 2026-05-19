`include "exe_mem_if.vh"
`include "types_pkg.vh"

import types_pkg::*;

module exe_mem (
  input logic CLK, nRST,
  exe_mem_if.em emif
);
  always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST || emif.flush) begin
      emif.pred_taken_mem <= 0;
      emif.RegWrite_mem <= 0;
      emif.halt_mem <= 0;
      emif.MemToReg_mem <= 0;
      emif.MemRead_mem <= 0;
      emif.jump_mem <= 0;
      emif.branch_mem <= 0;
      emif.zero_mem <= 0;
      emif.prev_ghr_mem <= '0;
      emif.pc_mem <= '0;
      emif.jumpaddr_mem <= '0;
      emif.rd_mem <= '0;
      emif.rdata2_mem <= '0;
      emif.aluout_mem <= '0;
      emif.MemData_mem <= '0;
      emif.funct3_mem <= '0;
      emif.imm_mem <= '0;
    end
    else if (emif.ihit && !emif.freeze) begin
      emif.pred_taken_mem <= emif.pred_taken_exe;
      emif.RegWrite_mem <= emif.RegWrite_exe;
      emif.halt_mem <= emif.halt_exe;
      emif.MemToReg_mem <= emif.MemToReg_exe;
      emif.MemRead_mem <= emif.MemRead_exe;
      emif.jump_mem <= emif.jump_exe;
      emif.branch_mem <= emif.branch_exe;
      emif.zero_mem <= emif.zero_exe;
      emif.prev_ghr_mem <= emif.prev_ghr_exe;
      emif.pc_mem <= emif.pc_exe;
      emif.jumpaddr_mem <= emif.jumpaddr_exe;
      emif.rd_mem <= emif.rd_exe;
      emif.rdata2_mem <= emif.rdata2_exe;
      emif.aluout_mem <= emif.aluout_exe;
      emif.MemData_mem <= emif.MemData_exe;
      emif.funct3_mem <= emif.funct3_exe;
      emif.imm_mem <= emif.imm_exe;
    end
  end
endmodule
