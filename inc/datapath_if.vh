`ifndef DATAPATH_IF_VH
`define DATAPATH_IF_VH

`include "types_pkg.vh"

interface datapath_if;
    import types_pkg::*;

    addr_t daddr, iaddr;
    word_t iload;
    dword_t dload, dstore;
    logic halt, ihit, dhit, iREN, dREN, dWEN;

    modport dp (
        input ihit, dhit, iload, dload,
        output halt, iaddr, daddr, iREN, dREN, dWEN, dstore
    );


endinterface
`endif 