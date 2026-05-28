`include "mem_wb_if.vh"
`include "types_pkg.vh"

module mem_wb (
  input logic CLK, n_rst,
  mem_wb_if.mw mwif
);
  always_ff @(posedge CLK, negedge n_rst) begin
    if (!n_rst) begin
      mwif.reg_write_wb <= 0;
      mwif.mem_to_reg_wb <= 0;
      mwif.rd_wb <= '0;
      mwif.dmem_data_wb <= '0;
      mwif.alu_out_wb <= '0;
    end
    else if (mwif.ihit) begin
      mwif.reg_write_wb <= mwif.reg_write_mem;
      mwif.mem_to_reg_wb <= mwif.mem_to_reg_mem;
      mwif.rd_wb <= mwif.rd_mem;
      mwif.dmem_data_wb <= mwif.dmem_data_mem;
      mwif.alu_out_wb <= mwif.alu_out_mem;
    end
  end
endmodule
