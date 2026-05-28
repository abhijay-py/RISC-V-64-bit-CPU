`include "forwarding_unit_if.vh"
`include "types_pkg.vh"

module forwarding_unit (
  forwarding_unit_if.fu fuif
);
    import types_pkg::*;

  always_comb begin: FORWARD_ONE
    fuif.forward_one = 2'b00;
    fuif.forward_two = 2'b00;
    fuif.forward_jalr = 2'b00;

    if (fuif.opcode_de inside {LUI, JAL, AUIPC}) begin
    end else begin
      if (fuif.reg_write_em && !fuif.mem_read_em && fuif.rd_em != '0 && fuif.rd_em == fuif.rs1_de)
        fuif.forward_one = 2'b01;
      else if (fuif.reg_write_mw && fuif.rd_mw != '0 && fuif.rd_mw == fuif.rs1_de)
        fuif.forward_one = 2'b10;

      if (fuif.reg_write_em && !fuif.mem_read_em && fuif.rd_em != '0 && fuif.rd_em == fuif.rs2_de)
        fuif.forward_two = 2'b01;
      else if (fuif.reg_write_mw && fuif.rd_mw != '0 && fuif.rd_mw == fuif.rs2_de)
        fuif.forward_two = 2'b10;

      if (fuif.reg_write_em && !fuif.mem_read_em && fuif.rd_em != '0 && fuif.rd_em == fuif.rs1_de)
        fuif.forward_jalr = 2'b01;
      else if (fuif.reg_write_mw && fuif.rd_mw != '0 && fuif.rd_mw == fuif.rs1_de)
        fuif.forward_jalr = 2'b10;
    end
  end

endmodule
