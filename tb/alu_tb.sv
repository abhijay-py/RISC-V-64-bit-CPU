`include "alu_if.vh"

module alu_tb;
    import types_pkg::*;

    alu_if aluif ();
    alu DUT (.aluif(aluif));

    dword_t aluout;
    assign aluout = aluif.alu_out;

    assert property (@(aluif.alu_out) (aluif.alu_out == '0) |-> (aluif.zero == 1))
    else $error("zero flag mismatch: alu_out = %x, zero = %b", aluif.alu_out, aluif.zero);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, alu_tb);
        $monitor("zero = %b, aluout = %x", aluif.zero, aluout);
        //TODO: write test cases
        $finish;
    end

endmodule
