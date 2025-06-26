`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

`include "types_pkg.vh"

interface control_unit_if;
    import types_pkg::*;

    funct3_load_t funct3_load;
    funct3_fence_t funct3_fence;
    funct3_i_t funct3_i;
    funct3_s_t funct3_s;
    funct3_r_t funct3_r;
    funct3_sb_t funct3_sb;
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
        input funct3_load, funct3_fence, funct3_i, funct3_s, funct3_r, funct3_sb, funct7_r, funct7_sr, funct12_env, opcode,
        output ALUOp, MemData, ImmType, lui, immSel, auipc, jalr, jump, branch, MemtoReg, MemRead, MemWrite, halt, RegWrite
    );

    //Testbench ports
    modport tb (
        input ALUOp, MemData, ImmType, lui, immSel, auipc, jalr, jump, branch, MemtoReg, MemRead, MemWrite, halt, RegWrite,
        output funct3_load, funct3_fence, funct3_i, funct3_s, funct3_r, funct3_sb, funct7_r, funct7_sr, funct12_env, opcode
    )

endinterface

`endif 



