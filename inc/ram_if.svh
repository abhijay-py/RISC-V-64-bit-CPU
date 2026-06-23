`ifndef RAM_IF_SVH
`define RAM_IF_SVH

`include "types_pkg.svh"

interface ram_if;
    import types_pkg::*;

    logic   ram_wen, ram_ren, data_ready;
    dword_t ram_addr;
    dword_t wdata, rdata;

    modport ram (
        input ram_wen, ram_ren, ram_addr, wdata,
        output rdata, data_ready
    );

    modport cache (
        input rdata, data_ready,
        output ram_wen, ram_ren, ram_addr, wdata
    );

endinterface

`endif
