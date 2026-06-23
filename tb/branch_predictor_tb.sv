`include "branch_predictor_if.svh"
`include "types_pkg.svh"

`ifdef BP_GSHARE
`include "uvm/uvm_clk_rst_if.svh"
`include "uvm/branch_predictor_uvm/branch_predictor_pkg.sv"
`endif

module branch_predictor_tb;
    import types_pkg::*;

    localparam PERIOD = 10;

    branch_predictor_if bpif ();

`ifdef BP_GSHARE
    import uvm_pkg::*;
    import branch_predictor_test_pkg::*;

    uvm_clk_rst_if clk_rst_if ();

    branch_predictor DUT (
        .clk   (clk_rst_if.clk),
        .rst_n (clk_rst_if.rst_n),
        .bpif  (bpif.bp)
    );

    initial clk_rst_if.clk = 0;
    always #(PERIOD/2) clk_rst_if.clk <= ~clk_rst_if.clk;

    initial begin
        clk_rst_if.rst_n = 0;
        repeat (4) @(posedge clk_rst_if.clk);
        clk_rst_if.rst_n = 1;

        // Reset Pulse
        repeat (50) @(posedge clk_rst_if.clk);
        clk_rst_if.rst_n = 0;
        repeat (4) @(posedge clk_rst_if.clk);
        clk_rst_if.rst_n = 1;
    end

    initial begin
        $dumpfile("dump.fst");
        $dumpvars(0, branch_predictor_tb);

        uvm_config_db#(virtual branch_predictor_if.bp)::set(null, "*", "bp_vif",  bpif.bp);
        uvm_config_db#(virtual uvm_clk_rst_if)::set(null, "*", "clk_vif", clk_rst_if);

        run_test("bp_random_test"); // +UVM_TESTNAME=<test> on the command line overrides this default.
    end

`else
    // BP_2BIT / default (NT): hand-written directed testbench
    logic clk = 0;
    logic rst_n;

    always #(PERIOD/2) clk <= ~clk;

    branch_predictor DUT (
        .clk   (clk),
        .rst_n (rst_n),
        .bpif  (bpif.bp)
    );

    initial begin
        $dumpfile("dump.fst");
        $dumpvars(0, branch_predictor_tb);

        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;

        // TODO: hand-written stimulus for this predictor variant
    end
`endif

endmodule
