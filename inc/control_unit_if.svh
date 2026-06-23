`ifndef CONTROL_UNIT_IF_SVH
`define CONTROL_UNIT_IF_SVH

`include "types_pkg.svh"

interface control_unit_if;
    import types_pkg::*;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [11:0] funct12;
    opcode_t     opcode;

    aluop_t   alu_op;
    memdata_t mem_data;
    immtype_t imm_type;
    logic     lui, imm_sel, auipc, jalr, jump, branch, mem_to_reg, mem_read, mem_write, halt, reg_write;


    //Control Unit ports
    modport cu (
        input funct3, funct7, funct12, opcode,
        output alu_op, mem_data, imm_type, lui, imm_sel, auipc, jalr, jump, branch, mem_to_reg, mem_read, mem_write, halt, reg_write
    );


endinterface

`endif



