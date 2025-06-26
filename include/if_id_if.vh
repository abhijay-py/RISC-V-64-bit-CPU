`ifndef IF_ID_IF_VH
`define IF_ID_IF_VH

`include "types_pkg.vh"

interface if_id_if;
    import types_pkg::*;

    word_t instr_if, instr_id
    logic pred_taken_if, pred_taken_id, flush, freeze, ihit; 
    addr_t pc_if, pc_id;

    //IF_ID Latch ports
    modport fd (
        input instr_if, pred_taken_if, flush, freeze, ihit, pc_if, 
        output instr_id, pred_taken_id, pc_id
    );

    //Testbench ports
    modport tb (
        input instr_id, pred_taken_id, pc_id,
        output instr_if, pred_taken_if, flush, freeze, ihit, pc_if
    );

endinterface
`endif 