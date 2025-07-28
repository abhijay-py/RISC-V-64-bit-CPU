`ifndef EXE_MEM_IF_VH
`define EXE_MEM_IF_VH

`include "types_pkg.vh"

interface exe_mem_if;
    import types_pkg::*;

    logic flush, freeze, ihit, dhit; 

    logic pred_taken_exe, RegWrite_exe, halt_exe, MemToReg_exe, MemRead_exe, MemWrite_exe, jump_exe, branch_exe, zero_exe;
    logic pred_taken_mem, RegWrite_mem, halt_mem, MemToReg_mem, dWEN_mem, dREN_mem, jump_mem, branch_mem, zero_mem;
    
    word_t imm_exe, imm_mem;
    addr_t pc_mem, jumpaddr_mem, pc_exe, jumpaddr_exe;
    reg_t rd_mem, rd_exe;
    dword_t rdata2_mem, aluout_mem, rdata2_exe, aluout_exe;
    memdata_t MemData_id, MemData_exe;
    opcode_t opcode_mem, opcode_exe;
    funct3_sb_t funct3_mem, funct3_exe;

    //EXE_MEM Latch ports
    modport em (
        input  flush, freeze, ihit, pred_taken_exe, RegWrite_exe, halt_exe, MemToReg_exe, MemRead_exe, MemWrite_exe, jump_exe, branch_exe, zero_exe,
        input  pc_exe, jumpaddr_exe, rd_exe, rdata2_exe, aluout_exe, MemData_exe, opcode_exe, funct3_exe, imm_exe,
        output pred_taken_mem, RegWrite_mem, halt_mem, MemToReg_mem, dWEN_mem, dREN_mem, jump_mem, branch_mem, zero_mem,
        output pc_mem, jumpaddr_mem, rd_mem,rdata2_mem, aluout_mem, MemData_id, opcode_mem, funct3_mem, imm_mem
        
    );

    //Testbench ports
    modport tb (
        input   pred_taken_mem, RegWrite_mem, halt_mem, MemToReg_mem, dWEN_mem, dREN_mem, jump_mem, branch_mem, zero_mem,
        input   pc_mem, jumpaddr_mem, rd_mem,rdata2_mem, aluout_mem, MemData_id, opcode_mem, funct3_mem, imm_mem,
        output  flush, freeze, ihit, pred_taken_exe, RegWrite_exe, halt_exe, MemToReg_exe, MemRead_exe, MemWrite_exe, jump_exe, branch_exe, zero_exe,
        output  pc_exe, jumpaddr_exe, rd_exe, rdata2_exe, aluout_exe, MemData_exe, opcode_exe, funct3_exe, imm_exe
    );

endinterface
`endif 