`include "hazard_unit_if.vh"
`include "types_pkg.vh"

module hazard_unit (
  hazard_unit_if.hu huif
);
    import types_pkg::*;

  always_comb begin
    huif.flush = 0;
    huif.freeze = 0;
    if (huif.jump_taken != huif.pred_taken) begin
      huif.flush = 1;
    end 
    if (huif.MemRead_em && !huif.dmemReady && !huif.ihit) begin
      if ((huif.rd_em == huif.rs1_de || huif.rd_em == huif.rs2_de) && huif.rd_em != '0) begin
        huif.freeze = 1;
      end
    end
  end

endmodule
