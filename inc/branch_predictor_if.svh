`ifndef BRANCH_PREDICTOR_IF_SVH
`define BRANCH_PREDICTOR_IF_SVH

`include "types_pkg.svh"

interface branch_predictor_if;
    import types_pkg::*;

    addr_t pc, old_next_pc, old_pc, target;
    logic  old_jump_taken;

`ifdef BP_GSHARE
    logic old_branch, old_pred_taken, pred_taken, old_jump;
    logic [GHR_W-1:0] old_ghr, prev_ghr;
`elsif BP_2BIT
    logic old_branch, old_pred_taken, pred_taken, old_jump;
`endif

    //Branch Predictor ports
`ifdef BP_GSHARE
    modport bp (
        input pc, old_next_pc, old_pc, old_jump_taken, old_pred_taken, old_branch, old_jump, old_ghr,
        output target, pred_taken, prev_ghr
    );
`elsif BP_2BIT
    modport bp (
        input pc, old_next_pc, old_pc, old_jump_taken, old_pred_taken, old_branch, old_jump,
        output target, pred_taken
    );
`else 
    modport bp (
        input pc, old_next_pc, old_pc, old_jump_taken,
        output target
    );
`endif


endinterface

`endif
