`ifndef ALU_IF_VH
`define ALU_IF_VH

`include "types_pkg.vh"

interface alu_if;
    import types_pkg::*;

    dword_t porta, portb, aluout;
    logic zero;
    aluop_t ALUOp;

    //ALU ports
    modport alu (
        input porta, portb, ALUOp,
        output aluout, zero
    );

    //Testbench ports
    modport tb (
        input aluout, zero,
        output porta, portb, ALUOp
    );

endinterface

`endif 