`ifndef DATAPATH_IF_VH
`define DATAPATH_IF_VH

`include "types_pkg.vh"

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