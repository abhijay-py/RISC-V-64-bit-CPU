`ifndef FORWARDING_UNIT_IF_VH
`define FORWARDING_UNIT_IF_VH

`include "types_pkg.vh"

interface forwarding_unit_if;
    import types_pkg::*;

    logic [1:0] forward_one, forward_two, forward_jalr;
    reg_t rs1_de, rs2_de, rd_mw, rd_em;
    logic RegWrite_em, RegWrite_mw, MemRead_em;
    opcode_t opcode_de;

    modport fu (
        input rs1_de, rs2_de, rd_mw, rd_em, RegWrite_em, RegWrite_mw, MemRead_em, opcode_de,
        output forward_one, forward_two, forward_jalr
    );


endinterface
`endif 