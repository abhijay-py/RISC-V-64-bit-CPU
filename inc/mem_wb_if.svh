`ifndef MEM_WB_IF_SVH
`define MEM_WB_IF_SVH

`include "types_pkg.svh"

interface mem_wb_if;
    import types_pkg::*;

    logic ihit;

    logic   reg_write_mem, mem_to_reg_mem, reg_write_wb, mem_to_reg_wb;
    reg_t   rd_mem, rd_wb;
    dword_t dmem_data_mem, alu_out_mem, dmem_data_wb, alu_out_wb;

    //MEM_WB Latch ports
    modport mw (
        input  ihit, reg_write_mem, mem_to_reg_mem, rd_mem, dmem_data_mem, alu_out_mem,
        output reg_write_wb, mem_to_reg_wb, rd_wb, dmem_data_wb, alu_out_wb
    );


endinterface
`endif