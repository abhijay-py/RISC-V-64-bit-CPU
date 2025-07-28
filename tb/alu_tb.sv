`include "alu_if.vh"

parameter PERIOD = 10;

module alu_tb;

    logic CLK = 0;

    always #(PERIOD/2) CLK++;
    alu_if aluif ();
    alu DUT (.porta(aluif.porta), .portb(aluif.portb), .aluout(aluif.aluout),
             .zero(aluif.zero), .ALUOp(aluif.ALUOp));

    test tb (.CLK(CLK), .tbif(aluif));

endmodule

program test (
    input logic CLK, 
    alu_if.tb tbif
)
    import types_pkg::*;

    initial begin
        $monitor("CLK = %b, zero = %b, aluout = %x", CLK, tbif.zero, tbif.aluout);
        //TODO: write test cases
        $finish;
    end

endprogram