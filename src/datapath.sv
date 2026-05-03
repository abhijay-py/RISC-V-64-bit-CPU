`include "datapath_if.vh"

`include "types_pkg.vh"

import types_pkg::*;

module datapath (
  input logic CLK, nRST,
  datapath_if.dp dpif
);


    parameter PC_INIT = 0;

    addr_t pc;
    word_t instr;



endmodule