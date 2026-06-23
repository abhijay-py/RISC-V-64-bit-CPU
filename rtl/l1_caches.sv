`include "datapath_if.svh"
`include "caches_if.svh"
`include "types_pkg.svh"

module l1_caches (
    input logic clk, rst_n,
    datapath_if.caches dpif
);
    import types_pkg::*;

    caches_if cif();

    icache icache (.clk(clk), .rst_n(rst_n), .cif(cif));
    dcache dcache (.clk(clk), .rst_n(rst_n), .cif(cif));

    always_comb begin
        cif.iaddr = dpif.iaddr;
        cif.i_ren = dpif.i_ren;

        cif.daddr      = dpif.daddr;
        cif.dstore     = dpif.dstore;
        cif.d_mem_data = dpif.d_mem_data;
        cif.d_ren      = dpif.d_ren;
        cif.d_wen      = dpif.d_wen;

        dpif.iload = cif.iload;
        dpif.ihit  = cif.ihit;
        dpif.dload = cif.dload;
        dpif.dhit  = cif.dhit;
    end

endmodule
