`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

`include "types_pkg.vh"

interface control_unit_if;
    import types_pkg::*;

    funct3_fence_t funct3_fence;
    funct3_mem_t funct3_mem;
    funct3_ri_t funct3_ri;
    funct3_b_t funct3_b;
    funct7_r_t funct7_r;
    funct7_sr_t funct7_sr; 
    funct12_env_t funct12_env;
    opcode_t opcode;

    aluop_t ALUOp;
    memdata_t MemData;
    immtype_t ImmType;
    logic lui, immSel, auipc, jalr, jump, branch, MemtoReg, MemRead, MemWrite, halt, RegWrite
    
    //Control Unit ports
    modport cu (
        input funct3_fence, funct3_ri, funct3_mem, funct3_b, funct7_r, funct7_sr, funct12_env, opcode,
        output ALUOp, MemData, ImmType, lui, immSel, auipc, jalr, jump, branch, MemtoReg, MemRead, MemWrite, halt, RegWrite
    );

    //Testbench ports
    modport tb (
        input ALUOp, MemData, ImmType, lui, immSel, auipc, jalr, jump, branch, MemtoReg, MemRead, MemWrite, halt, RegWrite,
        output funct3_fence, funct3_ri, funct3_mem, funct3_b, funct7_r, funct7_sr, funct12_env, opcode
    );

endinterface

`endif 



