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

    //Latches
    fdif.if_pc = pc;
    fdif.if_instr = dpif.iload
    fdif.if_pred_taken = bpif.pred_taken;
    fdif.if_prev_ghr = bpif.prev_ghr; 

    deif.prev_ghr_id = fdif.if_prev_ghr;
    deif.pred_taken_id = fdif.if_pred_taken;
    deif.pc_id = fdif.if_pc;
    deif.RegWrite_id = cuif.RegWrite;
    deif.halt_id = cuif.halt;
    deif.MemToReg_id = cuif.MemToReg;
    deif.MemRead_id = cuif.MemRead;
    deif.MemWrite_id = cuif.MemWrite;
    deif.jump_id = cuif.jump;
    deif.branch_id = cuif.branch;
    deif.jalr_id = cuif.jalr;
    deif.auipc_id = cuif.auipc;
    deif.immSel_id = cuif.immSel;
    //deif.rd_id = 
    //deif.rs2_id = 
    //deif.rs1_id =
    deif.rdata1_id = rfif.rdata1;
    deif.rdata2_id = rfif.rdata2;
    //deif.imm_id = ;
    //deif.jumpim_id = ;
    deif.ALUOp_id = cuif.ALUOp;
    deif.MemData_id = cuif.MemData;
    //deif.funct3_id = ;

    //Global signals
    // fdif.flush = 
    // deif.flush =
    // fdif.freeze = 
    // deif.freeze = 
    fdif.ihit = dpif.ihit;
    deif.ihit = dpif.ihit;
    

    //Control Unit
    




endmodule