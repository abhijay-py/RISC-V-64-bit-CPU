`include "alu_if.vh"

module alu_tb;
    import types_pkg::*;

    alu_if aluif ();
    alu DUT (.aluif(aluif));

    dword_t aluout;
    logic zero_flag;
    assign aluout = aluif.alu_out;
    assign zero_flag = aluif.zero;

    always_comb begin
        if (aluif.alu_out == '0)
            assert (aluif.zero == 1)
            else $error("zero flag mismatch: alu_out = %h, zero = %b", aluif.alu_out, aluif.zero);
    end

    initial begin
        dword_t expected;

        $dumpfile("dump.vcd");
        $dumpvars(0, alu_tb);
        $monitor("zero = %b, aluout = %h", zero_flag, aluout);

        //ADD test cases
        aluif.ALUOp = ALU_ADD;
        $display("\nALU ADD Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a + aluif.port_b;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_ADD: %h + %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //TODO: ADD overflow test cases


        //SUB test cases
        aluif.ALUOp = ALU_SUB;
        $display("\nALU SUB Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a - aluif.port_b;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SUB: %h - %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //TODO: SUB overflow test cases


        //AND test cases
        aluif.ALUOp = ALU_AND;
        $display("\nALU AND Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a & aluif.port_b;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_AND: %h & %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //OR test cases
        aluif.ALUOp = ALU_OR;
        $display("\nALU OR Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a | aluif.port_b;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_OR: %h | %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //XOR test cases
        aluif.ALUOp = ALU_XOR;
        $display("\nALU XOR Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a ^ aluif.port_b;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_XOR: %h ^ %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //SLL test cases
        aluif.ALUOp = ALU_SLL;
        $display("\nALU SLL Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a << aluif.port_b[5:0];
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SLL: %h << %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        end

        //TODO: SLL edge cases

        //SRA test cases
        aluif.ALUOp = ALU_SRA;
        $display("\nALU SRA Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = $signed(aluif.port_a) >>> aluif.port_b[5:0];
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SRA: %h >>> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        end

        //TODO: SRA edge cases

        //SRL test cases
        aluif.ALUOp = ALU_SRL;
        $display("\nALU SRL Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a >> aluif.port_b[5:0];
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SRL: %h >> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        end

        //TODO: SRL edge cases

        //SLT test cases
        aluif.ALUOp = ALU_SLT;
        $display("\nALU SLT Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = $signed(aluif.port_a) < $signed(aluif.port_b) ? 64'd1 : 64'd0;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SLT: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //TODO: SLT edge cases


        //SLTU test cases
        aluif.ALUOp = ALU_SLTU;
        $display("\nALU SLTU Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a < aluif.port_b ? 64'd1 : 64'd0;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SLTU: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //TODO: SLTU edge cases

        //ADDW test cases
        aluif.ALUOp = ALU_ADDW;
        $display("\nALU ADDW Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = 64'($signed(aluif.port_a[31:0] + aluif.port_b[31:0]));
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_ADDW: %h + %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[31:0], aluif.alu_out, expected);
        end

        //TODO: ADDW overflow test cases


        //SUBW test cases
        aluif.ALUOp = ALU_SUBW;
        $display("\nALU SUBW Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = 64'($signed(aluif.port_a[31:0] - aluif.port_b[31:0]));
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SUBW: %h - %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[31:0], aluif.alu_out, expected);
        end

        //TODO: SUBW overflow test cases


        //SLLW test cases
        aluif.ALUOp = ALU_SLLW;
        $display("\nALU SLLW Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = 64'($signed(aluif.port_a[31:0] << aluif.port_b[4:0]));
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SLLW: %h << %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);
        end

        //TODO: SLLW edge cases

        //SRAW test cases
        aluif.ALUOp = ALU_SRAW;
        $display("\nALU SRAW Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = 64'($signed(aluif.port_a[31:0]) >>> aluif.port_b[4:0]);
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SRAW: %h >>> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);
        end

        //TODO: SRAW edge cases

        //SRLW test cases
        aluif.ALUOp = ALU_SRLW;
        $display("\nALU SRLW Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = 64'($signed(aluif.port_a[31:0] >> aluif.port_b[4:0]));
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SRLW: %h >> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);
        end

        //TODO: SRLW edge cases

        $display();
        $finish;
    end

endmodule
