`include "control_unit_if.vh"
`include "types_pkg.vh"

//TODO: update diagram with funct12
module control_unit (
    control_unit_if.cu cuif
);
    import types_pkg::*;
    logic decode_error; //Decode Error Flag (will decide what to do later)

    funct3_fence_t funct3_fence;
    funct3_mem_t   funct3_mem;
    funct3_ri_t    funct3_ri;
    funct3_b_t     funct3_b;
    funct7_r_t     funct7_r;
    funct7_sr_t    funct7_sr;
    funct12_env_t  funct12_env;

    assign funct3_fence = funct3_fence_t'(cuif.funct3);
    assign funct3_mem   = funct3_mem_t'(cuif.funct3);
    assign funct3_ri    = funct3_ri_t'(cuif.funct3);
    assign funct3_b     = funct3_b_t'(cuif.funct3);
    assign funct7_r     = funct7_r_t'(cuif.funct7);
    assign funct7_sr    = funct7_sr_t'(cuif.funct7[6:1]);
    assign funct12_env  = funct12_env_t'(cuif.funct12);

    always_comb begin
        cuif.alu_op     = ALU_ADD;
        cuif.mem_data   = MEM_WORD;
        cuif.imm_type   = IMM_ITYPE;
        cuif.lui        = 0;
        cuif.imm_sel    = 0;
        cuif.auipc      = 0;
        cuif.jalr       = 0;
        cuif.jump       = 0;
        cuif.branch     = 0;
        cuif.mem_to_reg = 0;
        cuif.mem_read   = 0;
        cuif.mem_write  = 0;
        cuif.halt       = 0;
        decode_error    = 0;
        cuif.reg_write  = 1;

        unique case (cuif.opcode)
            R_TYPE, I_TYPE: begin
                cuif.imm_sel = cuif.opcode == I_TYPE ? 1 : 0;
                if (funct3_ri == SLL || funct3_ri == SRA_SRL) begin
                    cuif.imm_type = IMM_SHIFT;
                end

                unique case (funct3_ri)
                    ADD_SUB: cuif.alu_op = (cuif.opcode != I_TYPE && funct7_r == SUB)
                                           ? ALU_SUB : ALU_ADD;
                    AND:     cuif.alu_op = ALU_AND;
                    OR:      cuif.alu_op = ALU_OR;
                    XOR:     cuif.alu_op = ALU_XOR;
                    SLL:     cuif.alu_op = ALU_SLL;
                    SLT:     cuif.alu_op = ALU_SLT;
                    SLTU:    cuif.alu_op = ALU_SLTU;
                    SRA_SRL: cuif.alu_op = funct7_sr == SRA ? ALU_SRA : ALU_SRL;
                    default: decode_error = 1;
                endcase
            end
            RW_TYPE, IW_TYPE: begin
                cuif.imm_sel = cuif.opcode == IW_TYPE ? 1 : 0;
                if (funct3_ri == SLL || funct3_ri == SRA_SRL) begin
                    cuif.imm_type = IMM_SHIFTW;
                end

                unique case (funct3_ri)
                    ADD_SUB: cuif.alu_op = (cuif.opcode != IW_TYPE && funct7_r == SUB)
                                           ? ALU_SUBW : ALU_ADDW;
                    SLL:     cuif.alu_op = ALU_SLLW;
                    SRA_SRL: cuif.alu_op = funct7_sr == SRA ? ALU_SRAW : ALU_SRLW;
                    default: decode_error = 1;
                endcase
            end
            LOAD, S_TYPE: begin
                cuif.mem_to_reg = 1;
                cuif.mem_read   = 1;
                cuif.imm_sel    = 1;

                if (cuif.opcode == S_TYPE) begin
                    cuif.mem_to_reg = 0;
                    cuif.mem_read   = 0;
                    cuif.mem_write  = 1;
                    cuif.reg_write  = 0;
                    cuif.imm_type   = IMM_STYPE;
                    if (funct3_mem > D) begin
                        decode_error = 1;
                    end
                end

                unique case (funct3_mem)
                    B:       cuif.mem_data = MEM_BYTE;
                    H:       cuif.mem_data = MEM_HWORD;
                    W:       cuif.mem_data = MEM_WORD;
                    D:       cuif.mem_data = MEM_DWORD;
                    BU:      cuif.mem_data = MEM_BYTE_U;
                    HU:      cuif.mem_data = MEM_HWORD_U;
                    WU:      cuif.mem_data = MEM_WORD_U;
                    default: decode_error  = 1;
                endcase
            end
            B_TYPE: begin
                cuif.reg_write = 0;
                cuif.branch    = 1;
                cuif.imm_type  = IMM_BTYPE;

                unique case (funct3_b)
                    BEQ, BNE:   cuif.alu_op = ALU_SUB;
                    BLT, BGE:   cuif.alu_op = ALU_SLT;
                    BLTU, BGEU: cuif.alu_op = ALU_SLTU;
                    default:    decode_error = 1;
                endcase
            end
            JAL: begin
                cuif.imm_type = IMM_UJTYPE;
                cuif.imm_sel  = 1;
                cuif.jump     = 1;
            end
            JALR: begin
                cuif.imm_type = IMM_IJTYPE;
                cuif.imm_sel  = 1;
                cuif.jump     = 1;
                cuif.jalr     = 1;
            end
            LUI: begin
                cuif.imm_type = IMM_UTYPE;
                cuif.lui      = 1;
                cuif.imm_sel  = 1;
            end
            AUIPC: begin
                cuif.imm_type = IMM_UTYPE;
                cuif.auipc    = 1;
                cuif.imm_sel  = 1;
            end
            // TODO: Temporarily NOOP (not officially in terms of instr) till a more complete CPU is made.
            FENCE, ENV_CSR: begin
                cuif.reg_write = 0; //Prevents ops
            end
            HALT: begin
                cuif.reg_write = 0;
                cuif.halt      = 1;
            end
            default: decode_error = 1;
        endcase
    end
endmodule
