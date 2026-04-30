`include "control_unit_if.vh"
`include "types_pkg.vh"

module control_unit (
  control_unit.cu cuif
);

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
        cuif.MemtoReg = 0;
        cuif.MemRead = 0;
        cuif.MemWrite = 0;
        cuif.halt = 0;
        cuif.RegWrite = 1;

        if (cuif.opcode == R_TYPE || cuif.opcode == I_TYPE) begin
            if (cuif.opcode == I_TYPE) begin
                cuif.immSel = 1'b1;
            end

            if (cuif.funct3_ri == ADD_SUB) begin
                if (cuif.opcode != I_TYPE && cuif.funct7_r == SUB) begin
                    cuif.ALUOp = ALU_SUB;
                end
            end
            else if (cuif.funct3_ri == AND) begin
                cuif.ALUOp = ALU_AND;
            end
            else if (cuif.funct3_ri == OR) begin
                cuif.ALUOp = ALU_OR;
            end
            else if (cuif.funct3_ri == XOR) begin
                cuif.ALUOp = ALU_XOR;
            end
            else if (cuif.funct3_ri == SLL) begin
                cuif.ALUOp = ALU_SLL;
                if (cuif.opcode == I_TYPE) begin
                    cuif.ImmType = IMM_SHIFT;
                end 
            end
            else if (cuif.funct3_ri == SLT) begin
                cuif.ALUOp = SLT;
            end
            else if (cuif.funct3_ri == SLTU) begin
                cuif.ALUOp = SLTU;
            end
            else if (cuif.func3_ri == SRA_SRL) begin
                if (cuif.funct7_sr == SRA) begin
                    cuif.ALUOp = ALU_SRA;
                end
                else begin
                    cuif.ALUOp = ALU_SRL;
                end

                if (cuif.opcode == I_TYPE) begin
                    cuif.ImmType = IMM_SHIFT;
                end 
            end
        end
        else if (cuif.opcode == LOAD) begin
            cuif.MemtoReg = 1;
            cuif.MemRead = 1;
            cuif.immSel = 1;

            if (funct3_mem_t == B) begin
                cuif.MemData = MEM_BYTE;
            end
            else if (funct3_mem_t == BU) begin
                cuif.MemData = MEM_BYTE_U;
            end
            else if (funct3_mem_t == H) begin
                cuif.MemData = MEM_HWORD;
            end
            else if (funct3_mem_t == HU) begin
                cuif.MemData = MEM_HWORD_U;
            end
            else if (funct3_mem_t == WU) begin
                cuif.MemData = MEM_WORD_U;
            end
            else if (funct3_mem_t == D) begin
                cuif.MemData = MEM_DWORD;
            end
        end
        else if (cuif.opcode == S_TYPE) begin
            cuif.MemWrite = 1;
            cuif.RegWrite = 0;
            cuif.immSel = 1;

            if (funct3_mem_t == B) begin
                cuif.MemData = MEM_BYTE;
            end
            else if (funct3_mem_t == H) begin
                cuif.MemData = MEM_HWORD;
            end
            else if (funct3_mem_t == D) begin
                cuif.MemData = MEM_DWORD;
            end
        end
        else if (cuif.opcode == B_TYPE) begin
            cuif.RegWrite = 0;
            cuif.branch = 1;
            cuif.immSel = IMM_BTYPE;
            cuif.ALUOp = ALU_SUB;

            if (funct3_b == BLT || funct3_b == BGE) begin
                cuif.ALUOp = ALU_SLT;
            end
            else if (funct3_b == BLTU || funct3_b == BGEU) begin
                cuif.ALUOp = ALU_SLTU;
            end
        end
        else if (cuif.opcode == RW_TYPE || cuif.opcode == IW_TYPE) begin
            if (cuif.opcode == IW_TYPE) begin
                cuif.immSel = 1'b1;
            end

            if (cuif.funct3_ri == ADD_SUB) begin
                cuif.ALUOp = ALU_ADDW;
                if (cuif.opcode != IW_TYPE && cuif.funct7_r == SUB) begin
                    cuif.ALUOp = ALU_SUBW;
                end
            end
            else if (cuif.funct3_ri == SLL) begin
                cuif.ALUOp = ALU_SLLW;

                if (cuif.opcode == IW_TYPE) begin
                    cuif.ImmType = IMM_SHIFTW;
                end 
            end
            else if (cuif.func3_ri == SRA_SRL) begin
                if (cuif.funct7_sr == SRA) begin
                    cuif.ALUOp = ALU_SRAW;
                end
                else begin
                    cuif.ALUOp = ALU_SRLW;
                end

                if (cuif.opcode == IW_TYPE) begin
                    cuif.ImmType = IMM_SHIFTW;
                end 
            end
        end
        else if (cuif.opcode == HALT) begin
            cuif.RegWrite = 0;
            cuif.halt = 1;
        end
        else if (cuif.opcode == JAL) begin
            cuif.ImmType = IMM_UJTYPE;
            cuif.immSel = 1;
            cuif.jump = 1;
        end
        else if (cuif.opcode == JALR) begin
            cuif.ImmType = IMM_ITYPE;
            cuif.immSel = 1;
            cuif.jump = 1;
            cuif.jalr = 1;
        end
        else if (cuif.opcode == AUIPC) begin
            cuif.ImmType = IMM_UTYPE;
            cuif.auipc = 1;
            cuif.immSel = 1;
        end
        else if (cuif.opcode == LUI) begin
            cuif.ImmType = IMM_UTYPE;
            cuif.lui = 1;
            cuif.immSel = 1;
        end
        //Temporary will build out functionality once CPU as a whole is well built.
        else if (cuif.opcode == FENCE || cuif.opcode == ENV_CSR) begin
            cuif.RegWrite = 1;
        end

        else {
            cuif.RegWrite = 0;
        }
    end

endmodule