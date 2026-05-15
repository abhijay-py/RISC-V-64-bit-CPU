`include "datapath_if.vh"
`include "branch_predictor_if.vh"
`include "registers_if.vh"
`include "control_unit_if.vh"
`include "forwarding_unit_if.vh"
`include "hazard_unit_if.vh"
`include "if_id_if.vh"
`include "id_exe_if.vh"
`include "exe_mem_if.vh"
`include "mem_wb_if.vh"

`include "types_pkg.vh"

import types_pkg::*;

module datapath (
  input logic CLK, nRST,
  datapath_if.dp dpif
);

    parameter PC_INIT = 0;

    addr_t pc;

    branch_predictor_if bpif();
    registers_if rfif();
    control_unit_if cuif();
    forwarding_unit_if fuif();
    hazard_unit_if huif();
    if_id_if fdif();
    id_exe_if deif();
    exe_mem_if emif();
    mem_wb_if mwif();

    always_comb begin: GLOBAL_LATCH_SIGNALS
        // fdif.flush  =
        // deif.flush  =
        // fdif.freeze =
        // deif.freeze =
        fdif.ihit = dpif.ihit;
        deif.ihit = dpif.ihit;
    end

    always_comb begin: IF_ID_LATCH
        fdif.if_pc         = pc;
        fdif.if_instr      = dpif.iload;
        fdif.if_pred_taken = bpif.pred_taken;
        fdif.if_prev_ghr   = bpif.prev_ghr;
    end

    always_comb begin: ID_CTRL
        cuif.opcode  = opcode_t'(fdif.instr_id[6:0]);
        cuif.funct3  = fdif.instr_id[14:12];
        cuif.funct7  = fdif.instr_id[31:25];
        cuif.funct12 = fdif.instr_id[31:20];
    end

    always_comb begin: ID_REGFILE
        rfif.rs1 = fdif.instr_id[19:15];
        rfif.rs2 = fdif.instr_id[24:20];
        // rfif.rd       =
        // rfif.RegWrite =
        // rfif.wdata    =
    end

    always_comb begin: IMM_GEN
        deif.imm_id     = 64'd4;
        deif.jumpimm_id = '0;

        case (cuif.ImmType)
            IMM_ITYPE:  deif.imm_id     = {{52{fdif.instr_id[31]}}, fdif.instr_id[31:20]};
            IMM_UTYPE:  deif.imm_id     = {{32{fdif.instr_id[31]}}, fdif.instr_id[31:12], 12'b0};
            IMM_STYPE:  deif.imm_id     = {{52{fdif.instr_id[31]}}, fdif.instr_id[31:25], fdif.instr_id[11:7]};
            IMM_BTYPE:  deif.imm_id     = {{52{fdif.instr_id[31]}}, fdif.instr_id[7], fdif.instr_id[30:25], fdif.instr_id[11:8], 1'b0};
            IMM_UJTYPE: deif.jumpimm_id = {{44{fdif.instr_id[31]}}, fdif.instr_id[19:12], fdif.instr_id[20], fdif.instr_id[30:21], 1'b0};
            IMM_IJTYPE: deif.jumpimm_id = {{52{fdif.instr_id[31]}}, fdif.instr_id[31:20]};
            IMM_SHIFT:  deif.imm_id     = {58'b0, fdif.instr_id[25:20]};
            IMM_SHIFTW: deif.imm_id     = {59'b0, fdif.instr_id[24:20]};
        endcase
    end

    always_comb begin: ID_EX_LATCH
        deif.pc_id         = fdif.pc_id;
        deif.prev_ghr_id   = fdif.prev_ghr_id;
        deif.pred_taken_id = fdif.pred_taken_id;

        deif.rd_id         = fdif.instr_id[11:7];
        deif.rs1_id        = fdif.instr_id[19:15];
        deif.rs2_id        = fdif.instr_id[24:20];
        deif.funct3_id     = fdif.instr_id[14:12];

        deif.rdata1_id     = rfif.rdata1;
        deif.rdata2_id     = rfif.rdata2;

        deif.RegWrite_id   = cuif.RegWrite;
        deif.MemToReg_id   = cuif.MemToReg;
        deif.MemRead_id    = cuif.MemRead;
        deif.MemWrite_id   = cuif.MemWrite;
        deif.ALUOp_id      = cuif.ALUOp;
        deif.immSel_id     = cuif.immSel;
        deif.jump_id       = cuif.jump;
        deif.branch_id     = cuif.branch;
        deif.jalr_id       = cuif.jalr;
        deif.auipc_id      = cuif.auipc;
        deif.MemData_id    = cuif.MemData;
        deif.halt_id       = cuif.halt;
    end

endmodule
