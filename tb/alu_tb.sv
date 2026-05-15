`include "alu_if.vh"

parameter PERIOD = 10;

module alu_tb;

    logic CLK = 0;

    always #(PERIOD/2) CLK++;
    alu_if aluif ();
    alu DUT (.port_a(aluif.port_a), .port_b(aluif.port_b), .alu_out(aluif.alu_out),
             .zero(aluif.zero), .ALUOp(aluif.ALUOp));

    test tb (.CLK(CLK), .tbif(aluif));

endmodule

program test (
    input logic CLK,
    alu_if.tb tbif
);
    import types_pkg::*;

    initial begin
        $monitor("CLK = %b, zero = %b, aluout = %x", CLK, tbif.zero, tbif.aluout);
        //TODO: write test cases
        $finish;
    end

endprogram