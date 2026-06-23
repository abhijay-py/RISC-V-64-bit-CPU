`ifndef REGISTERS_IF_SVH
`define REGISTERS_IF_SVH

`include "types_pkg.svh"

interface registers_if;
    import types_pkg::*;

    reg_t   rs1, rs2, rd;
    dword_t wdata, rdata1, rdata2;
    logic   reg_write;

    //Registers ports
    modport regs (
        input rs1, rs2, rd, wdata, reg_write,
        output rdata1, rdata2
    );


endinterface

`endif

