`ifndef EXE_MEM_IF_VH
`define EXE_MEM_IF_VH

`include "types_pkg.vh"

interface exe_mem_if;
    import types_pkg::*;

    logic flush, freeze, ihit;

    logic pred_taken_exe, reg_write_exe, halt_exe, mem_to_reg_exe, mem_read_exe, mem_write_exe, jump_exe, branch_exe, zero_exe;
    logic pred_taken_mem, reg_write_mem, halt_mem, mem_to_reg_mem, mem_read_mem, jump_mem, branch_mem, zero_mem;
    logic [GHR_W-1:0] prev_ghr_exe, prev_ghr_mem;

    word_t imm_exe, imm_mem;
    addr_t pc_mem, jumpaddr_mem, pc_exe, jumpaddr_exe;
    reg_t rd_mem, rd_exe;
    dword_t rdata2_mem, alu_out_mem, rdata2_exe, alu_out_exe;
    memdata_t mem_data_mem, mem_data_exe;
    funct3_b_t funct3_mem, funct3_exe;

    //EXE_MEM Latch ports
    modport em (
        input  flush, freeze, ihit, pred_taken_exe, reg_write_exe, halt_exe, mem_to_reg_exe, mem_read_exe, mem_write_exe, jump_exe, branch_exe, zero_exe, prev_ghr_exe,
        input  pc_exe, jumpaddr_exe, rd_exe, rdata2_exe, alu_out_exe, mem_data_exe, funct3_exe, imm_exe,
        output pred_taken_mem, reg_write_mem, halt_mem, mem_to_reg_mem, mem_read_mem, jump_mem, branch_mem, zero_mem, prev_ghr_mem,
        output pc_mem, jumpaddr_mem, rd_mem, rdata2_mem, alu_out_mem, mem_data_mem, funct3_mem, imm_mem
    );


endinterface
`endif