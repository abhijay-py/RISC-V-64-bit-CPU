`include "registers_if.vh"
`include "types_pkg.vh"

module registers (
    input logic clk, rst_n,
    registers_if.regs rif
);
    import types_pkg::*;
    dword_t register_data [32];
    
    always_comb begin
        rif.rdata1 = register_data[rif.rs1];
        rif.rdata2 = register_data[rif.rs2];
        if (rif.reg_write && rif.rd != 0 && rst_n) begin
            if (rif.rd == rif.rs1) begin
                rif.rdata1 = rif.wdata;
            end
            if (rif.rd == rif.rs2) begin
                rif.rdata2 = rif.wdata;
            end
        end

    end

    always_ff @(negedge clk, negedge rst_n) begin
        if (!rst_n) begin
            register_data <= '{default: '0}; //replaced for verilator
        end
        else if (rif.reg_write && rif.rd != 0) begin
            register_data[rif.rd] <= rif.wdata;
        end
    end
endmodule
