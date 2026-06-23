`include "exe_mem_if.svh"
`include "types_pkg.svh"

module exe_mem (
    input logic clk, rst_n,
    exe_mem_if.em emif
);
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n || emif.flush) begin
            emif.pred_taken_mem <= 1'b0;
            emif.reg_write_mem  <= 1'b0;
            emif.halt_mem       <= 1'b0;
            emif.mem_to_reg_mem <= 1'b0;
            emif.mem_read_mem   <= 1'b0;
            emif.jump_mem       <= 1'b0;
            emif.branch_mem     <= 1'b0;
            emif.zero_mem       <= 1'b0;
            emif.prev_ghr_mem   <= '0;
            emif.pc_mem         <= '0;
            emif.jumpaddr_mem   <= '0;
            emif.rd_mem         <= '0;
            emif.rdata2_mem     <= '0;
            emif.alu_out_mem    <= '0;
            emif.mem_data_mem   <= '0;
            emif.funct3_mem     <= '0;
            emif.imm_mem        <= '0;
        end
        else if (emif.ihit && !emif.freeze) begin
            emif.pred_taken_mem <= emif.pred_taken_exe;
            emif.reg_write_mem  <= emif.reg_write_exe;
            emif.halt_mem       <= emif.halt_exe;
            emif.mem_to_reg_mem <= emif.mem_to_reg_exe;
            emif.mem_read_mem   <= emif.mem_read_exe;
            emif.jump_mem       <= emif.jump_exe;
            emif.branch_mem     <= emif.branch_exe;
            emif.zero_mem       <= emif.zero_exe;
            emif.prev_ghr_mem   <= emif.prev_ghr_exe;
            emif.pc_mem         <= emif.pc_exe;
            emif.jumpaddr_mem   <= emif.jumpaddr_exe;
            emif.rd_mem         <= emif.rd_exe;
            emif.rdata2_mem     <= emif.rdata2_exe;
            emif.alu_out_mem    <= emif.alu_out_exe;
            emif.mem_data_mem   <= emif.mem_data_exe;
            emif.funct3_mem     <= emif.funct3_exe;
            emif.imm_mem        <= emif.imm_exe;
        end
    end
endmodule
