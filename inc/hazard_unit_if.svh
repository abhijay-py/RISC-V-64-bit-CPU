`ifndef HAZARD_UNIT_IF_SVH
`define HAZARD_UNIT_IF_SVH

`include "types_pkg.svh"

interface hazard_unit_if;
    import types_pkg::*;

    logic flush, freeze, dmem_ready, ihit, pred_taken, jump_taken, mem_read_em;
    reg_t rs1_de, rs2_de, rd_em;

    //Hazard Unit ports
    modport hu (
        input dmem_ready, ihit, pred_taken, jump_taken, rs1_de, rs2_de, rd_em, mem_read_em,
        output flush, freeze
    );


endinterface
`endif