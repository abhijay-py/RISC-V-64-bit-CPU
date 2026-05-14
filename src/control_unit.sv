`include "control_unit_if.vh"
`include "types_pkg.vh"

import types_pkg::*;
//TODO: rewrite only pass the functs and use casts.
module control_unit (
  control_unit.cu cuif
);
    logic decode_error; //Decode Error Flag (will decide what to do later)

    always_comb begin
        cuif.ALUOp = ALU_ADD;
        cuif.MemData = MEM_WORD;
        cuif.ImmType = IMM_ITYPE;
        cuif.lui = 0;
        cuif.immSel = 0;
        cuif.auipc = 0;
        cuif.jalr = 0;
        cuif.jump = 0;
        cuif.branch = 0;
        cuif.MemToReg = 0;
        cuif.MemRead = 0;
        cuif.MemWrite = 0;
        cuif.halt = 0;
        decode_error = 0;
        cuif.RegWrite = 1;
        
        case (cuif.opcode) 
            R_TYPE, I_TYPE: begin
                cuif.immSel = cuif.opcode == I_TYPE ? 1 : 0;
                if (cuif.funct3_ri == SLL || cuif.funct3_ri == SRA_SRL) begin
                    cuif.ImmType = IMM_SHIFT;
                end

                case (cuif.funct3_ri)
                    ADD_SUB: cuif.ALUOp = (cuif.opcode != I_TYPE && cuif.funct7_r == SUB) ? ALU_SUB : ALU_ADD;
                    AND: cuif.ALUOp = ALU_AND;
                    OR: cuif.ALUOp = ALU_OR;
                    XOR: cuif.ALUOp = ALU_XOR;
                    SLL: cuif.ALUOp = ALU_SLL;
                    SLT: cuif.ALUOp = ALU_SLT;
                    SLTU: cuif.ALUOp = ALU_SLTU;
                    SRA_SRL: cuif.ALUOp = cuif.funct7_sr == SRA ? ALU_SRA : ALU_SRL;
                    default: decode_error = 1;
                endcase
            end
            RW_TYPE, IW_TYPE: begin
                cuif.immSel = cuif.opcode == IW_TYPE ? 1 : 0;
                if (cuif.funct3_ri == SLL || cuif.funct3_ri == SRA_SRL) begin
                    cuif.ImmType = IMM_SHIFTW;
                end

                case (cuif.funct3_ri)
                    ADD_SUB: cuif.ALUOp = (cuif.opcode != IW_TYPE && cuif.funct7_r == SUB) ? ALU_SUBW : ALU_ADDW;
                    SLL: cuif.ALUOp = ALU_SLLW;
                    SRA_SRL: cuif.ALUOp = cuif.funct7_sr == SRA ? ALU_SRAW : ALU_SRLW;
                    default: decode_error = 1;
                endcase
            end
            LOAD, S_TYPE: begin
                cuif.MemToReg = 1;
                cuif.MemRead = 1;
                cuif.immSel = 1;

                if (cuif.opcode == S_TYPE) begin
                    cuif.MemToReg = 0;
                    cuif.MemRead = 0;
                    cuif.MemWrite = 1;
                    cuif.RegWrite = 0;
                    '
                    if (cuif.funct3_mem > D) begin
                        decode_error = 1;
                    end
                end

                case (cuif.funct3_mem) 
                    B: cuif.MemData = MEM_BYTE;
                    H: cuif.MemData = MEM_HWORD;
                    W: cuif.MemData = MEM_WORD;
                    D: cuif.MemData = MEM_DWORD;
                    BU: cuif.MemData = MEM_BYTE_U;
                    HU: cuif.MemData = MEM_HWORD_U;
                    WU: cuif.MemData = MEM_WORD_U;
                    default: decode_error = 1;
                endcase
            end
            B_TYPE: begin
                cuif.RegWrite = 0;
                cuif.branch = 1;
                cuif.immSel = IMM_BTYPE;

                case (funct3_b) 
                    BEQ, BNE: cuif.ALUOp = ALU_SUB;
                    BLT, BGE: cuif.ALUOp = ALU_SLT;
                    BLTU, BGEU: cuif.ALUOp = ALU_SLTU;
                    default: decode_error = 1;
                endcase
            end
            JAL: begin
                cuif.ImmType = IMM_UJTYPE;
                cuif.immSel = 1;
                cuif.jump = 1; 
            end
            JALR: begin
                cuif.ImmType = IMM_ITYPE;
                cuif.immSel = 1;
                cuif.jump = 1;
                cuif.jalr = 1;
            end
            LUI: begin
                cuif.ImmType = IMM_UTYPE;
                cuif.lui = 1;
                cuif.immSel = 1;
            end
            AUIPC: begin
                cuif.ImmType = IMM_UTYPE;
                cuif.auipc = 1;
                cuif.immSel = 1;
            end
            FENCE, ENV_CSR: begin //Temporarily NOOP (not officially in terms of instr) till a more complete CPU is made.
                cuif.RegWrite = 0; //Prevents ops
            end
            HALT: begin
                cuif.RegWrite = 0;
                cuif.halt = 1;
            end
            default: decode_error = 1;
        endcase
    end
endmodule