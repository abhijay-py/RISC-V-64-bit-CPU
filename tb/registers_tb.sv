`include "registers_if.vh"

parameter PERIOD = 10;

module registers_tb;
    import types_pkg::*;
    localparam dword_t ALL_ONES = '1;

    logic CLK = 0;
    logic nRST;

    always #(PERIOD/2) CLK <= ~CLK;

    registers_if rif ();
    registers DUT (.CLK(CLK), .nRST(nRST), .rif(rif));

    dword_t rdata1, rdata2;
    assign rdata1 = rif.rdata1;
    assign rdata2 = rif.rdata2;

    assert property (@(posedge CLK)
        (rif.rs1 == 5'd0) |-> (rif.rdata1 == '0))
    else $error("r0 non-zero on rs1: %h", rif.rdata1);

    assert property (@(posedge CLK)
        (rif.rs2 == 5'd0) |-> (rif.rdata2 == '0))
    else $error("r0 non-zero on rs2: %h", rif.rdata2);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, registers_tb);
        $monitor("CLK = %b, rdata1 = %x, rdata2 = %x", CLK, rdata1, rdata2);
        
        //Initial nRST test
        rif.RegWrite = 0;
        rif.rs1 = 0;
        rif.rs2 = 0;
        rif.rd = 0;
        rif.wdata = 0;
        nRST = 1;
        #1
        nRST = 0;

        nRST = 1;
        for (int i = 0; i < 32; i++) begin
            rif.rs1 = i;
            #1;
            assert (rif.rdata1 == '0)
            else $error("Initial nRST Test (r%d): got %h, expected %h", i, rif.rdata1, 0);
        end
        
        //Writing to registers (all should be filled w 1s except 0)
        nRST = 1;
        for (int i = 0; i < 32; i++) begin
            rif.RegWrite = 1;
            rif.rd = i;
            rif.wdata = '1;
            #(PERIOD)
            rif.RegWrite = 0;
            rif.rs1 = i;
            #1;
            if (i != 0) begin
                assert (rif.rdata1 == '1)
                else $error("Register Write Test (r%d): got %h, expected %h", i, rif.rdata1, ALL_ONES);
            end
        end

        //RESET WHILE WRITING
        rif.RegWrite = 1;
        rif.rd = 5'd10;
        rif.rs1 = 5'd10;
        rif.wdata = 64'hFA;
        nRST = 0;
        #1;
        assert (rif.rdata1 == 64'hFA)
        else $error("Forwarding during nRST: got %h, expected %h", rif.rdata1, 64'hFA);
        #(PERIOD)
        rif.RegWrite = 0;
        #1
        assert (rif.rdata1 == '0)
        else $error("nRST Write Test: got %h, expected %h", rif.rdata1, 64'hFA);
        
        rif.RegWrite = 1;
        nRST = 1;
        rif.rd = 5'd15;
        rif.wdata = 64'hFA;
        #(PERIOD)
        nRST = 0;
        rif.RegWrite = 0;
        rif.rs1 = 5'd15;
        #1;
        assert (rif.rdata1 == '0)
        else $error("nRST Write Test: got %h, expected %h", rif.rdata1, 64'hFA);
        #(PERIOD)
        
        //Forwarding tests
        nRST = 1;
        rif.RegWrite = 1;
        rif.rd = 5'd31;
        rif.rs1 = 5'd31;
        rif.rs2 = 5'd31;
        rif.wdata = 64'hAB;
        #1;
        assert (rif.rdata1 == 64'hAB)
        else $error("Forwarding Write Test (rs1): got %h, expected %h", rif.rdata1, 64'hAB);
        assert (rif.rdata2 == 64'hAB)
        else $error("Forwarding Write Test (rs2): got %h, expected %h", rif.rdata2, 64'hAB);
        #(PERIOD)

        nRST = 1;
        rif.RegWrite = 1;
        rif.rd = 5'd0;
        rif.rs1 = 5'd0;
        rif.rs2 = 5'd0;
        rif.wdata = 64'hAB;
        #1;
        assert (rif.rdata1 == '0)
        else $error("Forwarding Write Test (rs1): got %h, expected %h", rif.rdata1, 64'h0);
        assert (rif.rdata2 == '0)
        else $error("Forwarding Write Test (rs2): got %h, expected %h", rif.rdata2, 64'h0);
        #(PERIOD)
        $finish;
    end

endmodule
