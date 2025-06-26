`ifndef ID_EXE_IF_VH
`define ID_EXE_IF_VH

`include "types_pkg.vh"

interface id_exe_if;
    import types_pkg::*;

    logic flush, freeze, ihit; 

    logic pred_taken_id, RegWrite_id, halt_id, MemToReg_id, MemRead_id, MemWrite_id, jump_id, branch_id, jalr_id, auipc_id, immSel_id;
    logic pred_taken_exe, RegWrite_exe, halt_exe, MemToReg_exe, MemRead_exe, MemWrite_exe, jump_exe, branch_exe, jalr_exe, auipc_exe, immSel_exe;
    addr_t pc_id, pc_exe;
    reg_t rd_id, rs2_id, rs1_id, rd_exe, rs2_exe, rs1_exe;
    dword_t rdata1_id, rdata2_id, rdata1_exe, rdata2_exe;
    word_t imm_id, jumpimm_id, imm_exe, jumpimm_exe;
    aluop_t ALUOp_id, ALUOp_exe;
    memdata_t MemData_id, MemData_exe;
    opcode_t opcode_id, opcode_exe;
    funct3_sb_t funct3_id, funct3_exe;

    //ID_EXE Latch ports
    modport de (
        input  flush, freeze, ihit, pred_taken_id, RegWrite_id, halt_id, MemToReg_id, MemRead_id, MemWrite_id, jump_id, branch_id, jalr_id, auipc_id, immSel_id, 
        input  pc_id, rd_id, rs2_id, rs1_id, rdata1_id, rdata2_id, imm_id, jumpimm_id, ALUOp_id, MemData_id, funct3_id,
        output pred_taken_exe, RegWrite_exe, halt_exe, MemToReg_exe, MemRead_exe, MemWrite_exe, jump_exe, branch_exe, jalr_exe, auipc_exe, immSel_exe, 
        output rd_exe, rs2_exe, rs1_exe, rdata1_exe, rdata2_exe, imm_exe, jumpimm_exe, pc_exe, ALUOp_exe, MemData_exe, opcode_exe, funct3_exe
    );

    //Testbench ports
    modport tb (
        input   pred_taken_exe, RegWrite_exe, halt_exe, MemToReg_exe, MemRead_exe, MemWrite_exe, jump_exe, branch_exe, jalr_exe, auipc_exe, immSel_exe, 
        input   rd_exe, rs2_exe, rs1_exe, rdata1_exe, rdata2_exe, imm_exe, jumpimm_exe, pc_exe, ALUOp_exe, MemData_exe, opcode_exe, funct3_exe,
        output  flush, freeze, ihit, pred_taken_id, RegWrite_id, halt_id, MemToReg_id, MemRead_id, MemWrite_id, jump_id, branch_id, jalr_id, auipc_id, immSel_id, 
        output  pc_id, rd_id, rs2_id, rs1_id, rdata1_id, rdata2_id, imm_id, jumpimm_id, ALUOp_id, MemData_id, funct3_id
    );

endinterface
`endif 