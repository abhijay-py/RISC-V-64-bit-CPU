`ifndef FORWARDING_UNIT_IF_VH
`define FORWARDING_UNIT_IF_VH

`include "types_pkg.vh"

interface forwarding_unit_if;
    import types_pkg::*;

    logic forward_one, forward_two; 
    reg_t rs1_de, rs2_de, rd_mw, rd_em;
    logic RegWrite_em, RegWrite_mw;
    opcode_t opcode_de;

    //Hazard Unit ports
    modport hu (
        input rs1_de, rs2_de, rd_mw, rd_em, RegWrite_em, RegWrite_mw, opcode_de,
        output forward_one, forward_two
    );

    //Testbench ports
    modport tb (
        input forward_one, forward_two,
        output rs1_de, rs2_de, rd_mw, rd_em, RegWrite_em, RegWrite_mw, opcode_de
    );

endinterface
`endif 