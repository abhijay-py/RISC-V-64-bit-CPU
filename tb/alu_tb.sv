`include "alu_if.vh"

module alu_tb;
    import types_pkg::*;

    alu_if aluif ();
    alu DUT (.aluif(aluif));

    dword_t alu_out;
    logic   zero_flag;
    assign alu_out   = aluif.alu_out;
    assign zero_flag = aluif.zero;

    always_comb begin
        if (aluif.alu_out == '0) begin
            assert (aluif.zero == 1)
            else $error("zero flag mismatch: alu_out = %h, zero = %b", aluif.alu_out, aluif.zero);
        end
        else begin
            assert (aluif.zero == 0)
            else $error("zero flag stuck high: alu_out = %h, zero = %b", aluif.alu_out, aluif.zero);
        end
    end


    initial begin
        dword_t expected;

        aluif.alu_op = ALU_ADD;
        aluif.port_a = '0;
        aluif.port_b = '0;
        #1;

        $dumpfile("dump.vcd");
        $dumpvars(0, alu_tb);
        $monitor("zero = %b, alu_out = %h", zero_flag, alu_out);

        //ADD test cases
        aluif.alu_op = ALU_ADD;
        $display("\nALU ADD Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a + aluif.port_b;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_ADD: %h + %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //ADD overflow test cases
        $display("\nALU ADD Overflow Tests:\n");
        
        aluif.port_a = '1;
        aluif.port_b = 64'd1;
        expected = '0;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_ADD: %h + %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
    
        aluif.port_a = '1;
        aluif.port_b = '1;
        expected = 64'hFFFF_FFFF_FFFF_FFFE;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_ADD: %h + %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);

        aluif.port_a = 64'h7FFF_FFFF_FFFF_FFFF;
        aluif.port_b = 64'd1;
        expected = 64'h8000_0000_0000_0000;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_ADD: %h + %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);

        aluif.port_a = 64'h8000_0000_0000_0000;
        aluif.port_b = 64'hFFFF_FFFF_FFFF_FFFF;
        expected = 64'h7FFF_FFFF_FFFF_FFFF;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_ADD: %h + %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);    

        //SUB test cases
        aluif.alu_op = ALU_SUB;
        $display("\nALU SUB Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a - aluif.port_b;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SUB: %h - %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //SUB overflow test cases
        $display("\nALU SUB Overflow Tests:\n");

        aluif.port_a = '0;
        aluif.port_b = 64'd1;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SUB: %h - %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);

        aluif.port_a = 64'h7FFF_FFFF_FFFF_FFFF;
        aluif.port_b = 64'hFFFF_FFFF_FFFF_FFFF;
        expected = 64'h8000_0000_0000_0000;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SUB: %h - %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);

        aluif.port_a = 64'h8000_0000_0000_0000;
        aluif.port_b = 64'd1;
        expected = 64'h7FFF_FFFF_FFFF_FFFF;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SUB: %h - %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);

        //AND test cases
        aluif.alu_op = ALU_AND;
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
        aluif.alu_op = ALU_OR;
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
        aluif.alu_op = ALU_XOR;
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
        aluif.alu_op = ALU_SLL;
        $display("\nALU SLL Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a << aluif.port_b[5:0];
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SLL: %h << %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        end

        //SLL edge cases
        $display("\nALU SLL Edge Tests:\n");
        
        aluif.port_a = '1;
        aluif.port_b = '1;
        expected = {1'b1, 63'd0};
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLL: %h << %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
      
        aluif.port_a = '1;
        aluif.port_b = 64'b1000000;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLL: %h << %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
    
        aluif.port_a = '1;
        aluif.port_b = '0;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLL: %h << %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
    
        aluif.port_a = 64'd1;
        aluif.port_b = 64'd63;
        expected = {1'b1, 63'd0};  
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLL: %h << %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
    
        //SRA test cases
        aluif.alu_op = ALU_SRA;
        $display("\nALU SRA Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = $signed(aluif.port_a) >>> aluif.port_b[5:0];
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SRA: %h >>> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        end

        //SRA edge cases
        $display("\nALU SRA Edge Tests:\n");
        
        aluif.port_a = '1;
        aluif.port_b = '1;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRA: %h >>> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        
        aluif.port_a = 64'd1;
        aluif.port_b = 64'b1000000;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRA: %h >>> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        
        aluif.port_a = '1;
        aluif.port_b = '0;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRA: %h >>> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        
        aluif.port_a = 64'd1;
        aluif.port_b = '0;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRA: %h >>> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        
        aluif.port_a = {1'd1, 63'd0};
        aluif.port_b = 64'd63;
        expected = '1;  
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRA: %h >>> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        
        aluif.port_a = {1'd0, 1'd1, 62'd0};
        aluif.port_b = 64'd62;
        expected = 64'd1;  
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRA: %h >>> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);        

        //SRL test cases
        aluif.alu_op = ALU_SRL;
        $display("\nALU SRL Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a >> aluif.port_b[5:0];
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SRL: %h >> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
        end

        //SRL edge cases
        $display("\nALU SRL Edge Tests:\n");
        
        aluif.port_a = '1;
        aluif.port_b = '1;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRL: %h >> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
                
        aluif.port_a = 64'd1;
        aluif.port_b = 64'b1000000;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRL: %h >> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
                
        aluif.port_a = '1;
        aluif.port_b = '0;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRL: %h >> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
                
        aluif.port_a = 64'd1;
        aluif.port_b = '0;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRL: %h >> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
                
        aluif.port_a = {1'd1, 63'd0};
        aluif.port_b = 64'd63;
        expected = 64'd1;  
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRL: %h >> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);
                
        aluif.port_a = {1'd0, 1'd1, 62'd0};
        aluif.port_b = 64'd62;
        expected = 64'd1;  
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRL: %h >> %h = %h, expected %h", aluif.port_a, aluif.port_b[5:0], aluif.alu_out, expected);

        //SLT test cases
        aluif.alu_op = ALU_SLT;
        $display("\nALU SLT Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = $signed(aluif.port_a) < $signed(aluif.port_b) ? 64'd1 : 64'd0;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SLT: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //SLT edge cases
        $display("\nALU SLT Edge Tests:\n");

        aluif.port_a = 64'd635;
        aluif.port_b = 64'd635;
        expected = 64'd0;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLT: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        
        aluif.port_a = '1;
        aluif.port_b = '0;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLT: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        
        aluif.port_a = {1'd1, 63'd0};
        aluif.port_b = 64'h7FFFFFFFFFFFFFFF;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLT: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);

        aluif.port_a = 64'h7FFFFFFFFFFFFFFF;
        aluif.port_b = {1'd1, 63'd0};
        expected = 64'd0;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLT: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);

        //SLTU test cases
        aluif.alu_op = ALU_SLTU;
        $display("\nALU SLTU Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = aluif.port_a < aluif.port_b ? 64'd1 : 64'd0;
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SLTU: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        end

        //SLTU edge cases
        $display("\nALU SLTU Edge Tests:\n");
        aluif.port_a = 64'd635;
        aluif.port_b = 64'd635;
        expected = 64'd0;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLTU: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        
        aluif.port_a = '1;
        aluif.port_b = '0;
        expected = 64'd0;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLTU: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);
        
        aluif.port_a = {1'd1, 63'd0};
        aluif.port_b = 64'h7FFFFFFFFFFFFFFF;
        expected = 64'd0;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLTU: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);

        aluif.port_a = 64'h7FFFFFFFFFFFFFFF;
        aluif.port_b = {1'd1, 63'd0};
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLTU: %h < %h = %h, expected %h", aluif.port_a, aluif.port_b, aluif.alu_out, expected);

        //ADDW test cases
        aluif.alu_op = ALU_ADDW;
        $display("\nALU ADDW Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = 64'($signed(aluif.port_a[31:0] + aluif.port_b[31:0]));
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_ADDW: %h + %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[31:0], aluif.alu_out, expected);
        end

        //ADDW overflow test cases
        $display("\nALU ADDW Overflow Tests:\n");

        aluif.port_a = 64'h0000_0000_7FFF_FFFF;
        aluif.port_b = 64'h0000_0000_0000_0001;
        expected = 64'hFFFF_FFFF_8000_0000;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_ADDW: %h + %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[31:0], aluif.alu_out, expected);

        aluif.port_a = 64'h0000_0000_8000_0000;
        aluif.port_b = 64'h0000_0000_FFFF_FFFF;
        expected = 64'h0000_0000_7FFF_FFFF;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_ADDW: %h + %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[31:0], aluif.alu_out, expected);

        aluif.port_a = 64'hDEAD_BEEF_7FFF_FFFF;
        aluif.port_b = 64'hCAFE_BABE_0000_0001;
        expected = 64'hFFFF_FFFF_8000_0000;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_ADDW: %h + %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[31:0], aluif.alu_out, expected);    

        //SUBW test cases
        aluif.alu_op = ALU_SUBW;
        $display("\nALU SUBW Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = 64'($signed(aluif.port_a[31:0] - aluif.port_b[31:0]));
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SUBW: %h - %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[31:0], aluif.alu_out, expected);
        end

        //SUBW overflow test cases
        $display("\nALU SUBW Overflow Tests:\n");

        aluif.port_a = 64'h0000_0000_8000_0000;
        aluif.port_b = 64'h0000_0000_0000_0001;
        expected = 64'h0000_0000_7FFF_FFFF;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SUBW: %h - %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[31:0], aluif.alu_out, expected);

        aluif.port_a = 64'h0000_0000_7FFF_FFFF;
        aluif.port_b = 64'h0000_0000_FFFF_FFFF;
        expected = 64'hFFFF_FFFF_8000_0000;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SUBW: %h - %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[31:0], aluif.alu_out, expected);

        aluif.port_a = 64'hDEAD_BEEF_8000_0000;
        aluif.port_b = 64'hCAFE_BABE_0000_0001;
        expected = 64'h0000_0000_7FFF_FFFF;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SUBW: %h - %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[31:0], aluif.alu_out, expected);

        //SLLW test cases
        aluif.alu_op = ALU_SLLW;
        $display("\nALU SLLW Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = 64'($signed(aluif.port_a[31:0] << aluif.port_b[4:0]));
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SLLW: %h << %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);
        end

        //SLLW edge cases
        $display("\nALU SLLW Edge Tests:\n");

        aluif.port_a = '1;
        aluif.port_b = '1;
        expected = 64'hFFFF_FFFF_8000_0000;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLLW: %h << %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = '1;
        aluif.port_b = 64'b100000;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLLW: %h << %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = '1;
        aluif.port_b = '0;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLLW: %h << %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'd1;
        aluif.port_b = 64'd31;
        expected = 64'hFFFF_FFFF_8000_0000;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLLW: %h << %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'hDEAD_BEEF_0000_0001;
        aluif.port_b = 64'd31;
        expected = 64'hFFFF_FFFF_8000_0000;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SLLW: %h << %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        //SRAW test cases
        aluif.alu_op = ALU_SRAW;
        $display("\nALU SRAW Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = 64'($signed(aluif.port_a[31:0]) >>> aluif.port_b[4:0]);
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SRAW: %h >>> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);
        end

        //SRAW edge cases
        $display("\nALU SRAW Edge Tests:\n");

        aluif.port_a = '1;
        aluif.port_b = '1;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRAW: %h >>> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'd1;
        aluif.port_b = 64'b100000;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRAW: %h >>> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = '1;
        aluif.port_b = '0;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRAW: %h >>> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'd1;
        aluif.port_b = '0;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRAW: %h >>> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'h0000_0000_8000_0000;
        aluif.port_b = 64'd31;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRAW: %h >>> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'h0000_0000_4000_0000;
        aluif.port_b = 64'd30;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRAW: %h >>> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'hDEAD_BEEF_8000_0000;
        aluif.port_b = 64'd31;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRAW: %h >>> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        //SRLW test cases
        aluif.alu_op = ALU_SRLW;
        $display("\nALU SRLW Base Tests:\n");
        repeat (5) begin
            aluif.port_a = {$urandom(), $urandom()};
            aluif.port_b = {$urandom(), $urandom()};
            expected = 64'($signed(aluif.port_a[31:0] >> aluif.port_b[4:0]));
            #1
            assert (aluif.alu_out == expected)
            else $error("ALU_SRLW: %h >> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);
        end

        //SRLW edge cases
        $display("\nALU SRLW Edge Tests:\n");

        aluif.port_a = '1;
        aluif.port_b = '1;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRLW: %h >> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'd1;
        aluif.port_b = 64'b100000;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRLW: %h >> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = '1;
        aluif.port_b = '0;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRLW: %h >> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'd1;
        aluif.port_b = '0;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRLW: %h >> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'h0000_0000_8000_0000;
        aluif.port_b = 64'd31;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRLW: %h >> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'h0000_0000_4000_0000;
        aluif.port_b = 64'd30;
        expected = 64'd1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRLW: %h >> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        aluif.port_a = 64'hDEAD_BEEF_FFFF_FFFF;
        aluif.port_b = '0;
        expected = '1;
        #1
        assert (aluif.alu_out == expected)
        else $error("ALU_SRLW: %h >> %h = %h, expected %h", aluif.port_a[31:0], aluif.port_b[4:0], aluif.alu_out, expected);

        $display();
        $finish;
    end

endmodule
