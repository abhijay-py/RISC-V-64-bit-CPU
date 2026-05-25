`ifndef EXE_MEM_IF_VH
`define EXE_MEM_IF_VH

`include "types_pkg.vh"

interface exe_mem_if;
    import types_pkg::*;

    logic flush, freeze, ihit;

    logic pred_taken_exe, RegWrite_exe, halt_exe, MemToReg_exe, MemRead_exe, MemWrite_exe, jump_exe, branch_exe, zero_exe;
    logic pred_taken_mem, RegWrite_mem, halt_mem, MemToReg_mem, MemRead_mem, jump_mem, branch_mem, zero_mem;
    logic [GHR_W-1:0] prev_ghr_exe, prev_ghr_mem;
    
    word_t imm_exe, imm_mem;
    addr_t pc_mem, jumpaddr_mem, pc_exe, jumpaddr_exe;
    reg_t rd_mem, rd_exe;
    dword_t rdata2_mem, aluout_mem, rdata2_exe, aluout_exe;
    memdata_t MemData_mem, MemData_exe;
    funct3_b_t funct3_mem, funct3_exe;

    //EXE_MEM Latch ports
    modport em (
        input  flush, freeze, ihit, pred_taken_exe, RegWrite_exe, halt_exe, MemToReg_exe, MemRead_exe, MemWrite_exe, jump_exe, branch_exe, zero_exe, prev_ghr_exe,
        input  pc_exe, jumpaddr_exe, rd_exe, rdata2_exe, aluout_exe, MemData_exe, funct3_exe, imm_exe,
        output pred_taken_mem, RegWrite_mem, halt_mem, MemToReg_mem, MemRead_mem, jump_mem, branch_mem, zero_mem, prev_ghr_mem,
        output pc_mem, jumpaddr_mem, rd_mem,rdata2_mem, aluout_mem, MemData_mem, funct3_mem, imm_mem
        
    );


endinterface
`endif 