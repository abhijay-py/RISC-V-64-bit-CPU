`include "registers_if.vh"

module registers (
  input logic CLK, nRST,
  registers_if.regs rif
);
    logic [63:0] register_data [31:0];
    
    assign rif.rdata1 = register_data[rif.rs1];
    assign rif.rdata2 = register_data[rif.rs2];

    always_ff @ (negedge CLK, negedge nRST) begin
        if (!nRST) begin
            register_data <= '0;
        end
        else if (rif.RegWrite && rif.rd != 0) begin
            register_data[rif.rd] <= rif.wdata;
        end
    end
endmodule