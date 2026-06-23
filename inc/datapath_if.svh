`ifndef DATAPATH_IF_SVH
`define DATAPATH_IF_SVH

`include "types_pkg.svh"

interface datapath_if;
    import types_pkg::*;

    addr_t    daddr, iaddr;
    word_t    iload;
    dword_t   dload, dstore;
    memdata_t d_mem_data;
    logic     halt, ihit, dhit, i_ren, d_ren, d_wen;

    modport dp (
        input ihit, dhit, iload, dload,
        output halt, iaddr, daddr, i_ren, d_ren, d_wen, d_mem_data, dstore
    );

    modport caches (
        input halt, iaddr, daddr, i_ren, d_ren, d_wen, d_mem_data, dstore,
        output ihit, dhit, iload, dload
    );

endinterface
`endif