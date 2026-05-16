`include "if_id_if.vh"
`include "types_pkg.vh"

import types_pkg::*;

module if_id (
  input logic CLK, nRST,
  if_id_if.fd fdif
);
  always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST || fdif.flush) begin
      fdif.instr_id <= 32'h13; //NOOP
      fdif.pred_taken_id <= 0;
      fdif.pc_id <= '0;
      fdif.prev_ghr_id <= '0;
    end
    else if (fdif.ihit && !fdif.freeze) begin
      fdif.instr_id <= fdif.if_instr;
      fdif.pred_taken_id <= fdif.if_pred_taken;
      fdif.pc_id <= fdif.if_pc;
      fdif.prev_ghr_id <= fdif.if_prev_ghr;
    end
  end
endmodule
