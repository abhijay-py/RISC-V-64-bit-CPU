`include "datapath_if.vh"

`include "types_pkg.vh"

module datapath (
  input logic CLK, nRST,
  datapath_if.dp dpif
);
    import types_pkg.vh::*;

    parameter PC_INIT = 0;

    addr_t pc;
    word_t instr;



endmodule