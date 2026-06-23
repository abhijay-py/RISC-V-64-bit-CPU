`ifndef ALU_IF_SVH
`define ALU_IF_SVH

`include "types_pkg.svh"

interface alu_if;
    import types_pkg::*;

    dword_t port_a, port_b, alu_out;
    aluop_t alu_op;
    logic   zero;

    //ALU ports
    modport alu (
        input port_a, port_b, alu_op,
        output alu_out, zero
    );


endinterface

`endif

