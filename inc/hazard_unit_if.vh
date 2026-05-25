`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "types_pkg.vh"

interface hazard_unit_if;
    import types_pkg::*;

    logic flush, freeze, dmemReady, ihit, pred_taken, jump_taken, MemRead_em;
    reg_t rs1_de, rs2_de, rd_em;

    //Hazard Unit ports
    modport hu (
        input dmemReady, ihit, pred_taken, jump_taken, rs1_de, rs2_de, rd_em, MemRead_em,
        output flush, freeze
    );


endinterface
`endif 