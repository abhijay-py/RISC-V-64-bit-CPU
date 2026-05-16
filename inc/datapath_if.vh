`ifndef DATAPATH_IF_VH
`define DATAPATH_IF_VH

`include "types_pkg.vh"

interface datapath_if;
    import types_pkg::*;

    addr_t daddr, iaddr;
    word_t iload;
    dword_t dload, dstore;
    memdata_t dMemData;
    logic halt, ihit, dhit, iREN, dREN, dWEN;

    modport dp (
        input ihit, dhit, iload, dload,
        output halt, iaddr, daddr, iREN, dREN, dWEN, dMemData, dstore
    );

    modport icache (
        input iREN, iaddr,
        output iload, ihit
    );

    modport dcache (
        input dREN, dWEN, dMemData, daddr, dstore, 
        output dload, dhit
    );

endinterface
`endif 