`ifndef REGISTERS_IF_VH
`define REGISTERS_IF_VH

`include "types_pkg.vh"

interface registers_if;
    import types_pkg::*;

    reg_t rs1, rs2, rd;
    dword_t wdata, rdata1, rdata2;
    logic RegWrite;

    //Registers ports
    modport regs (
        input rs1, rs2, rd, wdata, RegWrite,
        output rdata1, rdata2
    );

    //Testbench ports
    modport tb (
        input rdata1, rdata2,
        output rs1, rs2, rd, wdata, RegWrite
    );

endinterface

`endif 