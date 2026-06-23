`ifndef CACHES_IF_SVH
`define CACHES_IF_SVH

`include "types_pkg.svh"

interface caches_if;
    import types_pkg::*;

    addr_t    daddr, iaddr;
    word_t    iload;
    dword_t   dload, dstore;
    memdata_t d_mem_data;
    logic     halt, ihit, dhit, i_ren, d_ren, d_wen;

    modport icache (
        input i_ren, iaddr,
        output iload, ihit
    );

    modport dcache (
        input d_ren, d_wen, d_mem_data, daddr, dstore,
        output dload, dhit
    );

endinterface
`endif