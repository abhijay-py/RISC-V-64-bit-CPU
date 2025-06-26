`ifndef MEM_WB_IF_VH
`define MEM_WB_IF_VH

`include "types_pkg.vh"

interface mem_wb_if;
    import types_pkg::*;

    logic ihit; 

    logic RegWrite_mem, MemToReg_mem, RegWrite_wb, MemToReg_wb;
    reg_t rd_mem, rd_wb;
    dword_t dmemdata_mem, aluout_mem, dmemdata_wb, aluout_wb;

    //MEM_WB Latch ports
    modport mw (
        input  ihit, RegWrite_mem, MemToReg_mem, rd_mem, dmemdata_mem, aluout_mem,
        output RegWrite_wb, MemToReg_wb, rd_wb, dmemdata_wb, aluout_wb
    );

    //Testbench ports
    modport tb (  
        input  RegWrite_wb, MemToReg_wb, rd_wb, dmemdata_wb, aluout_wb,
        output  ihit, RegWrite_mem, MemToReg_mem, rd_mem, dmemdata_mem, aluout_mem
    );

endinterface
`endif 