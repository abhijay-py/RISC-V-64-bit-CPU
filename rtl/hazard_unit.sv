`include "hazard_unit_if.svh"
`include "types_pkg.svh"

module hazard_unit (
    hazard_unit_if.hu huif
);
    import types_pkg::*;

    always_comb begin
        huif.flush  = 1'b0;
        huif.freeze = 1'b0;
        if (huif.jump_taken != huif.pred_taken) begin
            huif.flush = 1'b1;
        end
        if (huif.mem_read_em && !huif.dmem_ready && !huif.ihit) begin
            if ((huif.rd_em == huif.rs1_de || huif.rd_em == huif.rs2_de) && huif.rd_em != '0) begin
                huif.freeze = 1'b1;
            end
        end
    end

endmodule
