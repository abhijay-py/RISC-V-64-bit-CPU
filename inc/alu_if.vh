`ifndef ALU_IF_VH
`define ALU_IF_VH

`include "types_pkg.vh"

interface alu_if;
    import types_pkg::*;

    dword_t port_a, port_b, alu_out;
    aluop_t alu_op;
    logic zero;

    //ALU ports
    modport alu (
        input port_a, port_b, alu_op,
        output alu_out, zero
    );


endinterface

`endif

