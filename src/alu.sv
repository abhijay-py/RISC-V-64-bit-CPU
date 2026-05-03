`include "alu_if.vh"
`include "types_pkg.vh"

import types_pkg::*;

module alu (
  alu_if.alu aluif
);

    logic overflow; // Currently just an inmodule flag, creating for easy utilization later.
    logic alu_error; //error flag for default case;
    logic [64:0] result;

    assign aluif.zero = aluif.alu_out == '0 ? 1 : 0;

    always_comb begin
        aluif.alu_out = '0;
        alu_error = 0;
        overflow = 0;
        result = '0;

        case (aluif.ALUOp) 
            ALU_ADD: begin
                result = aluif.port_a + aluif.port_b;
                aluif.alu_out = result[63:0];
                overflow = result[64];
            end
            ALU_SUB: aluif.aluout = aluif.port_a - aluif.port_b;
            ALU_AND: aluif.aluout = aluif.port_a & aluif.port_b;
            ALU_OR: aluif.aluout = aluif.port_a | aluif.port_b;
            ALU_SLL: aluif.aluout = aluif.port_a << aluif.port_b[5:0];
            ALU_SLT: aluif.aluout = $signed(aluif.port_a) < $signed(aluif.port_b) ? 1 : 0;
            ALU_SLTU: aluif.aluout = aluif.port_a < aluif.port_b;
            ALU_SRA: aluif.aluout = aluif.port_a >>> aluif.port_b[5:0];
            ALU_SRL: aluif.aluout = aluif.port_a >> aluif.port_b[5:0];
            ALU_XOR: aluif.aluout = aluif.port_a ^ aluif.port_b;
            ALU_ADDW: begin
                result = aluif.port_a[31:0] + aluif.port_b[31:0];
                aluif.alu_out = {32{result[31]}, result[31:0]};
            end
            ALU_SUBW: begin
                result = aluif.port_a[31:0] - aluif.port_b[31:0];
                aluif.alu_out = {32{result[31]}, result[31:0]};
            end
            ALU_SLLW: begin
                result = aluif.port_a[31:0] << aluif.port_b[4:0];
                aluif.alu_out = {32{result[31]}, result[31:0]};
            end
            ALU_SRLW: begin
                result = aluif.port_a[31:0] >> aluif.port_b[4:0];
                aluif.alu_out = {32{1'b0}, result[31:0]};
            end
            ALU_SRAW: begin
                result = aluif.port_a[31:0] >>> aluif.port_b[4:0];
                aluif.alu_out = {32{result[31]}, result[31:0]};
            end
            default: alu_error = 1;
        endcase
    end
    
endmodule
