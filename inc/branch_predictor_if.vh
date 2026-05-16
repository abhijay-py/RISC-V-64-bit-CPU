`ifndef BRANCH_PREDICTOR_IF_VH
`define BRANCH_PREDICTOR_IF_VH

`include "types_pkg.vh"

interface branch_predictor_if;
    import types_pkg::*;

    addr_t pc, old_next_pc, old_pc, target;
    logic old_jump_taken, old_branch, old_pred_taken, pred_taken, old_jump;
    logic [GHR_W-1:0] old_ghr, prev_ghr;

    //Branch Predictor ports
    modport bp (
        input pc, old_next_pc, old_pc, old_jump_taken, old_pred_taken, old_branch, old_jump, old_ghr,
        output target, pred_taken, prev_ghr
    );

    //Testbench ports
    modport tb (
        input target, pred_taken, prev_ghr,
        output pc, old_next_pc, old_pc, old_jump_taken, old_pred_taken, old_branch, old_jump, old_ghr
    );

endinterface

`endif 