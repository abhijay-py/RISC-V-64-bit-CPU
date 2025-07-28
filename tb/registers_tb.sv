`include "registers_if.vh"

parameter PERIOD = 10;

module registers_tb;

    logic CLK = 0;
    logic nRST;

    always #(PERIOD/2) CLK++;
    registers_if rif ();
    registers DUT (.CLK(CLK), .nRST(nRST), .rdata1(rif.rdata1), .rdata2(rif.rdata2), .RegWrite(rif.RegWrite),
             .rs1(rif.rs1), .rs2(rif.rs2), .rd(rif.rd), .wdata(rif.wdata));

    test tb (CLK, nRST, rif);

endmodule

program test (
    input logic CLK, 
    output logic nRST,
    registers_if.tb tbif
);
    //import types_pkg::*;

    initial begin
        $monitor("CLK = %b, rdata1 = %x, rdata2 = %x", CLK, tbif.rdata1, tbif.rdata2);
        nRST = 0;
        tbif.RegWrite = 0;
        tbif.rs1 = 0;
        tbif.rs2 = 0;
        tbif.rd = 0;
        tbif.wdata = 0;
        //NRST Test
        #(PERIOD)
        nRST = 1;
        tbif.rs1 = 0;
        tbif.rs2 = 9;
        #(PERIOD)
        tbif.rs1 = 13;
        tbif.rs2 = 17;
        #(PERIOD)
        tbif.rs1 = 25;
        tbif.rs2 = 31;
        #(PERIOD)
        //Write to reg 0 test
        tbif.RegWrite = 1;
        tbif.wdata = 100;
        tbif.rd = 0;
        #(PERIOD)
        //Write and read from register tests
        tbif.rs1 = 0;
        tbif.rs2 = 0;
        tbif.rd = 7;
        tbif.wdata = 700;
        #(PERIOD)
        tbif.rs1 = 0;
        tbif.rs2 = 7;
        tbif.rd = 15;
        tbif.wdata = 1500;
        #(PERIOD)
        tbif.rs1 = 15;
        tbif.rs2 = 0;
        tbif.rd = 30;
        tbif.wdata = 3000;
        #(PERIOD)
        tbif.rs1 = 15;
        tbif.rs2 = 30;
        tbif.rd = 1;
        tbif.wdata = 100;
        #(PERIOD)
         tbif.rs1 = 1;
        tbif.rs2 = 0;
        tbif.rd = 1;
        tbif.wdata = 101;
        #(PERIOD)
        //Write maximum value
        tbif.rs1 = 0;
        tbif.rs2 = 1;
        tbif.rd = 14;
        tbif.wdata = 32'hffffffff;
        #(PERIOD)
        tbif.rs1 = 0;
        tbif.rs2 = 14;
        tbif.RegWrite = 0;
        #(PERIOD)
        //Check that we aren't writing on the same clock
        tbif.rs2 = 0;
        tbif.rs1 = 5;
        tbif.RegWrite = 1;
        tbif.rd = 5;
        tbif.wdata = 500;
        #(PERIOD)
        $finish;
    end

endprogram