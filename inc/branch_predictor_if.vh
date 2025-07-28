`ifndef BRANCH_PREDICTOR_IF_VH
`define BRANCH_PREDICTOR_IF_VH

`include "types_pkg.vh"

interface branch_predictor_if;
    import types_pkg::*;

    addr_t pc, next_pc, old_pc, target;
    logic jump_taken, branch, pred_taken;

    //Branch Predictor ports
    modport bp (
        input pc, next_pc, old_pc, jump_taken, branch,
        output target, pred_taken
    );

    //Testbench ports
    modport tb (
        input target, pred_taken,
        output pc, next_pc, old_pc, jump_taken, branch
    );

endinterface

`endif 