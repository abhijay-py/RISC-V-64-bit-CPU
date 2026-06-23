`include "alu_if.svh"
`include "types_pkg.svh"

module alu (
    alu_if.alu aluif
);
    import types_pkg::*;
    logic [31:0] result;

    assign aluif.zero = aluif.alu_out == '0;

    always_comb begin
        aluif.alu_out = '0;
        result        = '0;

        unique0 case (aluif.alu_op)
            ALU_ADD:  aluif.alu_out = aluif.port_a + aluif.port_b;
            ALU_SUB:  aluif.alu_out = aluif.port_a - aluif.port_b;
            ALU_AND:  aluif.alu_out = aluif.port_a & aluif.port_b;
            ALU_OR:   aluif.alu_out = aluif.port_a | aluif.port_b;
            ALU_SLL:  aluif.alu_out = aluif.port_a << aluif.port_b[5:0];
            ALU_SLT:  aluif.alu_out = $signed(aluif.port_a) < $signed(aluif.port_b) ? 64'd1 : 64'd0;
            ALU_SLTU: aluif.alu_out = aluif.port_a < aluif.port_b ? 64'd1 : 64'd0;
            ALU_SRA:  aluif.alu_out = $signed(aluif.port_a) >>> aluif.port_b[5:0];
            ALU_SRL:  aluif.alu_out = aluif.port_a >> aluif.port_b[5:0];
            ALU_XOR:  aluif.alu_out = aluif.port_a ^ aluif.port_b;
            ALU_ADDW: begin
                result        = aluif.port_a[31:0] + aluif.port_b[31:0];
                aluif.alu_out = {{32{result[31]}}, result};
            end
            ALU_SUBW: begin
                result        = aluif.port_a[31:0] - aluif.port_b[31:0];
                aluif.alu_out = {{32{result[31]}}, result};
            end
            ALU_SLLW: begin
                result        = aluif.port_a[31:0] << aluif.port_b[4:0];
                aluif.alu_out = {{32{result[31]}}, result};
            end
            ALU_SRLW: begin
                result        = aluif.port_a[31:0] >> aluif.port_b[4:0];
                aluif.alu_out = {{32{result[31]}}, result};
            end
            ALU_SRAW: begin
                result        = $signed(aluif.port_a[31:0]) >>> aluif.port_b[4:0];
                aluif.alu_out = {{32{result[31]}}, result};
            end
        endcase
    end

endmodule
