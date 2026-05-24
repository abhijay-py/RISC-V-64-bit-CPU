`include "registers_if.vh"

parameter PERIOD = 10;

module registers_tb;
    import types_pkg::*;

    logic CLK = 0;
    logic nRST;

    always #(PERIOD/2) CLK <= ~CLK;

    registers_if rif ();
    registers DUT (.CLK(CLK), .nRST(nRST), .rif(rif));

    dword_t rdata1, rdata2;
    assign rdata1 = rif.rdata1;
    assign rdata2 = rif.rdata2;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, registers_tb);
        $monitor("CLK = %b, rdata1 = %x, rdata2 = %x", CLK, rdata1, rdata2);
        nRST = 0;
        rif.RegWrite = 0;
        rif.rs1 = 0;
        rif.rs2 = 0;
        rif.rd = 0;
        rif.wdata = 0;
        //NRST Test
        #(PERIOD)
        nRST = 1;
        rif.rs1 = 0;
        rif.rs2 = 9;
        #(PERIOD)
        rif.rs1 = 13;
        rif.rs2 = 17;
        #(PERIOD)
        rif.rs1 = 25;
        rif.rs2 = 31;
        #(PERIOD)
        //Write to reg 0 test
        rif.RegWrite = 1;
        rif.wdata = 100;
        rif.rd = 0;
        #(PERIOD)
        //Write and read from register tests
        rif.rs1 = 0;
        rif.rs2 = 0;
        rif.rd = 7;
        rif.wdata = 700;
        #(PERIOD)
        rif.rs1 = 0;
        rif.rs2 = 7;
        rif.rd = 15;
        rif.wdata = 1500;
        #(PERIOD)
        rif.rs1 = 15;
        rif.rs2 = 0;
        rif.rd = 30;
        rif.wdata = 3000;
        #(PERIOD)
        rif.rs1 = 15;
        rif.rs2 = 30;
        rif.rd = 1;
        rif.wdata = 100;
        #(PERIOD)
        rif.rs1 = 1;
        rif.rs2 = 0;
        rif.rd = 1;
        rif.wdata = 101;
        #(PERIOD)
        //Write maximum value
        rif.rs1 = 0;
        rif.rs2 = 1;
        rif.rd = 14;
        rif.wdata = 64'hffffffffffffffff;
        #(PERIOD)
        rif.rs1 = 0;
        rif.rs2 = 14;
        rif.RegWrite = 0;
        #(PERIOD)
        //Check that we aren't writing on the same clock
        rif.rs2 = 0;
        rif.rs1 = 5;
        rif.RegWrite = 1;
        rif.rd = 5;
        rif.wdata = 500;
        #(PERIOD)
        $finish;
    end

endmodule
