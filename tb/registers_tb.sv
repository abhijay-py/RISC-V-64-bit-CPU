`include "registers_if.vh"

parameter PERIOD = 10;

module registers_tb;
    import types_pkg::*;
    localparam dword_t ALL_ONES = '1;

    logic clk = 0;
    logic rst_n;

    always #(PERIOD/2) clk <= ~clk;

    registers_if rif ();
    registers DUT (.clk(clk), .rst_n(rst_n), .rif(rif));

    dword_t rdata1, rdata2;
    assign rdata1 = rif.rdata1;
    assign rdata2 = rif.rdata2;

    assert property (@(posedge clk)
        (rif.rs1 == 5'd0) |-> (rif.rdata1 == '0))
    else $error("r0 non-zero on rs1: %h", rif.rdata1);

    assert property (@(posedge clk)
        (rif.rs2 == 5'd0) |-> (rif.rdata2 == '0))
    else $error("r0 non-zero on rs2: %h", rif.rdata2);

    initial begin
        dword_t fwd_data;
        
        rif.reg_write = 0;
        rif.rs1 = 0;
        rif.rs2 = 0;
        rif.rd = 0;
        rif.wdata = 0;
        rst_n = 1;
        #1;

        $dumpfile("dump.vcd");
        $dumpvars(0, registers_tb);
        $monitor("clk = %b, rst_n = %b, rdata1 = %h, rdata2 = %h", clk, rst_n, rdata1, rdata2);
        
        //Initial rst_n test
        $display("\nrst_n Test:\n");
        rst_n = 0;
        #(PERIOD)
        rst_n = 1;
        for (int i = 0; i < 32; i++) begin
            rif.rs1 = reg_t'(i);
            #1;
            assert (rif.rdata1 == '0)
            else $error("Initial rst_n Test (r%0d): got %h, expected %h", i, rif.rdata1, 0);
        end
        
        //Writing to registers (all should be filled w 1s except 0)
       
        rst_n = 1;
        for (int i = 0; i < 32; i++) begin
             $display("\nWriting to Registers Test %0d:\n", i + 1);
            rif.reg_write = 1;
            rif.rd = reg_t'(i);
            rif.rs1 = 0;
            rif.wdata = '1;
            #(PERIOD)
            rif.reg_write = 0;
            rif.rs1 = reg_t'(i);
            #1;
            if (i != 0) begin
                assert (rif.rdata1 == '1)
                else $error("Register Write Test (r%0d): got %h, expected %h", i, rif.rdata1, ALL_ONES);
            end else begin
                assert (rif.rdata1 == '0)
                else $error("Register Write Test (r0): got %h, expected 0", rif.rdata1);
            end
        end

        //RESET WHILE WRITING
        $display("\nReset While Writing Test 1:\n");
        rif.reg_write = 1;
        rif.rd = 5'd10;
        rif.rs1 = 5'd10;
        rif.wdata = {$urandom(), $urandom()};
        rst_n = 0;
        #1;
        assert (rif.rdata1 == '0)
        else $error("Forwarding during rst_n: got %h, expected %h", rif.rdata1, 64'h0);
        #(PERIOD)
        rif.reg_write = 0;
        #1
        assert (rif.rdata1 == '0)
        else $error("rst_n Write Test: got %h, expected %h", rif.rdata1, 64'hFA);
        
        $display("\nReset While Writing Test 2:\n");
        rif.reg_write = 1;
        rst_n = 1;
        rif.rd = 5'd15;
        rif.wdata = {$urandom(), $urandom()};
        #(PERIOD)
        rst_n = 0;
        rif.reg_write = 0;
        rif.rs1 = 5'd15;
        #1;
        assert (rif.rdata1 == '0)
        else $error("rst_n Write Test: got %h, expected %h", rif.rdata1, 64'hFA);
        #(PERIOD)
        
        //Forwarding tests
        $display("\nForwarding Test 1:\n");
        rst_n = 1;
        fwd_data = {$urandom(), $urandom()};
        rif.reg_write = 1;
        rif.rd = 5'd31;
        rif.rs1 = 5'd31;
        rif.rs2 = 5'd31;
        rif.wdata = fwd_data;
        #1;
        assert (rif.rdata1 == fwd_data)
        else $error("Forwarding Write Test (rs1): got %h, expected %h", rif.rdata1, fwd_data);
        assert (rif.rdata2 == fwd_data)
        else $error("Forwarding Write Test (rs2): got %h, expected %h", rif.rdata2, fwd_data);
        #(PERIOD)

        $display("\nForwarding Test 2:\n");
        rst_n = 1;
        fwd_data = {$urandom(), $urandom()};
        rif.reg_write = 1;
        rif.rd = 5'd0;
        rif.rs1 = 5'd0;
        rif.rs2 = 5'd0;
        rif.wdata = fwd_data;
        #1;
        assert (rif.rdata1 == '0)
        else $error("Forwarding Write Test (rs1): got %h, expected 0", rif.rdata1);
        assert (rif.rdata2 == '0)
        else $error("Forwarding Write Test (rs2): got %h, expected 0", rif.rdata2);
        #(PERIOD)

        $display("\nForwarding Test 3:\n");
        rst_n = 1;
        fwd_data = {$urandom(), $urandom()};
        rif.reg_write = 1;
        rif.rd = 5'd1;
        rif.rs1 = 5'd1;
        rif.rs2 = 5'd3;
        rif.wdata = fwd_data;
        #1;
        assert (rif.rdata1 == fwd_data)
        else $error("Forwarding Write Test (rs1): got %h, expected %h", rif.rdata1, fwd_data);
        assert (rif.rdata2 == '0)
        else $error("Forwarding Write Test (rs2 no-fwd): got %h, expected 0", rif.rdata2);
        #(PERIOD)

        $display("\nForwarding Test 4:\n");
        rst_n = 1;
        fwd_data = {$urandom(), $urandom()};
        rif.reg_write = 1;
        rif.rd = 5'd2;
        rif.rs1 = 5'd3;
        rif.rs2 = 5'd2;
        rif.wdata = fwd_data;
        #1;
        assert (rif.rdata1 == '0)
        else $error("Forwarding Write Test (rs1 no-fwd): got %h, expected 0", rif.rdata1);
        assert (rif.rdata2 == fwd_data)
        else $error("Forwarding Write Test (rs2): got %h, expected %h", rif.rdata2, fwd_data);
        #(PERIOD)
        $display();
        $finish;
    end

endmodule
