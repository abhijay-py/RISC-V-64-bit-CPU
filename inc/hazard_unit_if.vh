`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "types_pkg.vh"

interface hazard_unit_if;
    import types_pkg::*;

    logic flush, freeze, dhit, pred_taken, jump_taken; 
    reg_t rs1_de, rs2_de, rd_em;
    opcode_t opcode_em;

    //Hazard Unit ports
    modport hu (
        input dhit, pred_taken, jump_taken, rs1, rs2, rd_em, opcode_em,
        output flush, freeze
    );

    //Testbench ports
    modport tb (
        input flush, freeze,
        output dhit, pred_taken, jump_taken, rs1_de, rs2_de, rd_em, opcode_em
    );

endinterface
`endif 