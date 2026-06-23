`ifndef ID_EXE_IF_SVH
`define ID_EXE_IF_SVH

`include "types_pkg.svh"

interface id_exe_if;
    import types_pkg::*;

    logic flush, freeze, ihit;

    logic      pred_taken_id, reg_write_id, halt_id, mem_to_reg_id, mem_read_id, mem_write_id, jump_id, branch_id, jalr_id, auipc_id, imm_sel_id;
    logic      pred_taken_exe, reg_write_exe, halt_exe, mem_to_reg_exe, mem_read_exe, mem_write_exe, jump_exe, branch_exe, jalr_exe, auipc_exe, imm_sel_exe;
    addr_t     pc_id, pc_exe;
    word_t     jumpimm_id, jumpimm_exe;
    reg_t      rd_id, rs2_id, rs1_id, rd_exe, rs2_exe, rs1_exe;
    dword_t    rdata1_id, rdata2_id, rdata1_exe, rdata2_exe;
    word_t     imm_id, imm_exe;
    aluop_t    alu_op_id, alu_op_exe;
    memdata_t  mem_data_id, mem_data_exe;
    opcode_t   opcode_id, opcode_exe;
    funct3_b_t funct3_id, funct3_exe;

    logic [GHR_W-1:0] prev_ghr_id, prev_ghr_exe;

    //ID_EXE Latch ports
    modport de (
        input  flush, freeze, ihit, pred_taken_id, reg_write_id, halt_id, mem_to_reg_id, mem_read_id, mem_write_id, jump_id, branch_id, jalr_id, auipc_id, imm_sel_id,
        input  pc_id, rd_id, rs2_id, rs1_id, rdata1_id, rdata2_id, imm_id, jumpimm_id, alu_op_id, mem_data_id, funct3_id, prev_ghr_id, opcode_id,
        output pred_taken_exe, reg_write_exe, halt_exe, mem_to_reg_exe, mem_read_exe, mem_write_exe, jump_exe, branch_exe, jalr_exe, auipc_exe, imm_sel_exe,
        output rd_exe, rs2_exe, rs1_exe, rdata1_exe, rdata2_exe, imm_exe, jumpimm_exe, pc_exe, alu_op_exe, mem_data_exe, opcode_exe, funct3_exe, prev_ghr_exe
    );


endinterface
`endif