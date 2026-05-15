`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

`include "types_pkg.vh"

interface control_unit_if;
    import types_pkg::*;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [11:0] funct12;
    opcode_t opcode;

    aluop_t ALUOp;
    memdata_t MemData;
    immtype_t ImmType;
    logic lui, immSel, auipc, jalr, jump, branch, MemToReg, MemRead, MemWrite, halt, RegWrite;


    //Control Unit ports
    modport cu (
        input funct3, funct7, funct12, opcode,
        output ALUOp, MemData, ImmType, lui, immSel, auipc, jalr, jump, branch, MemToReg, MemRead, MemWrite, halt, RegWrite
    );

    //Testbench ports
    modport tb (
        input ALUOp, MemData, ImmType, lui, immSel, auipc, jalr, jump, branch, MemToReg, MemRead, MemWrite, halt, RegWrite,
        output funct3, funct7, funct12, opcode
    );

endinterface

`endif 



