`ifndef FORWARDING_UNIT_IF_SVH
`define FORWARDING_UNIT_IF_SVH

`include "types_pkg.svh"

interface forwarding_unit_if;
    import types_pkg::*;

    logic [1:0] forward_one, forward_two, forward_jalr;

    reg_t    rs1_de, rs2_de, rd_mw, rd_em;
    logic    reg_write_em, reg_write_mw, mem_read_em;
    opcode_t opcode_de;

    modport fu (
        input rs1_de, rs2_de, rd_mw, rd_em, reg_write_em, reg_write_mw, mem_read_em, opcode_de,
        output forward_one, forward_two, forward_jalr
    );


endinterface
`endif