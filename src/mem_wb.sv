`include "mem_wb_if.vh"
`include "types_pkg.vh"

import types_pkg::*;

module mem_wb (
  input logic CLK, nRST,
  mem_wb_if.mw mwif
);
  always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST) begin
      mwif.RegWrite_wb <= 0;
      mwif.MemToReg_wb <= 0;
      mwif.rd_wb <= '0;
      mwif.dmemdata_wb <= '0;
      mwif.aluout_wb <= '0;
    end
    else if (mwif.ihit) begin
      mwif.RegWrite_wb <= mwif.RegWrite_mem;
      mwif.MemToReg_wb <= mwif.MemToReg_mem;
      mwif.rd_wb <= mwif.rd_mem;
      mwif.dmemdata_wb <= mwif.dmemdata_mem;
      mwif.aluout_wb <= mwif.aluout_mem;
    end
  end
endmodule
