`include "datapath_if.svh"
`include "branch_predictor_if.svh"
`include "registers_if.svh"
`include "control_unit_if.svh"
`include "forwarding_unit_if.svh"
`include "hazard_unit_if.svh"
`include "if_id_if.svh"
`include "id_exe_if.svh"
`include "exe_mem_if.svh"
`include "mem_wb_if.svh"

`include "types_pkg.svh"

module datapath (
    input logic clk, rst_n,
    datapath_if.dp dpif
);
    import types_pkg::*;

    parameter PC_INIT = 0;

    addr_t pc, next_pc, old_next_pc;
    logic  jump_taken;
    logic  d_ren, d_wen, dmem_ready;
    logic  next_d_ren, next_d_wen, next_dmem_ready;

    alu_if aluif();
    branch_predictor_if bpif();
    registers_if rfif();
    control_unit_if cuif();
    forwarding_unit_if fuif();
    hazard_unit_if huif();
    if_id_if fdif();
    id_exe_if deif();
    exe_mem_if emif();
    mem_wb_if mwif();

    alu alu (.aluif(aluif));
    branch_predictor bp (.clk(clk), .rst_n(rst_n), .bpif(bpif));
    control_unit cu (.cuif(cuif));
    registers regs (.clk(clk), .rst_n(rst_n), .rif(rfif));
    forwarding_unit fu (.fuif(fuif));
    hazard_unit hu (.huif(huif));
    if_id fd (.clk(clk), .rst_n(rst_n), .fdif(fdif));
    id_exe de (.clk(clk), .rst_n(rst_n), .deif(deif));
    exe_mem em (.clk(clk), .rst_n(rst_n), .emif(emif));
    mem_wb mw (.clk(clk), .rst_n(rst_n), .mwif(mwif));

    always_ff @(posedge clk, negedge rst_n) begin: PC
      if (!rst_n) begin
        pc <= PC_INIT;
      end
      else if (dpif.ihit) begin
        pc <= next_pc;
      end
    end

    always_comb begin: NEXT_PC_LOGIC
      next_pc = pc + 48'd4;

      if (huif.flush) begin
        next_pc = old_next_pc;
      end
      else if (bpif.pred_taken) begin
        next_pc = bpif.target;
      end
    end

    always_comb begin: MEMORY_SYSTEM
      dpif.iaddr      = pc;
      dpif.daddr      = emif.alu_out_mem;
      dpif.i_ren      = !emif.halt_mem && dmem_ready;
      dpif.d_ren      = d_ren;
      dpif.d_wen      = d_wen;
      dpif.dstore     = emif.rdata2_mem;
      dpif.d_mem_data = emif.mem_data_mem;
    end

    always_ff @(posedge clk, negedge rst_n) begin: HALT
      if (!rst_n) begin
        dpif.halt <= 1'b0;
      end
      else begin
        dpif.halt <= dpif.halt | emif.halt_mem;
      end
    end

    always_comb begin: BRANCH_PREDICTOR
      bpif.pc           = pc;
      bpif.old_pc       = emif.pc_mem;
      bpif.old_pred_taken = emif.pred_taken_mem;
      bpif.old_branch   = emif.branch_mem;
      bpif.old_jump     = emif.jump_mem;
      bpif.old_ghr      = emif.prev_ghr_mem;
      bpif.old_jump_taken = jump_taken;
      bpif.old_next_pc  = old_next_pc;
    end

    always_comb begin: GLOBAL_LATCH_SIGNALS
      fdif.flush = huif.flush;
      deif.flush = huif.flush;
      emif.flush = huif.flush;

      fdif.freeze = huif.freeze;
      deif.freeze = huif.freeze;
      emif.freeze = huif.freeze;

      fdif.ihit = dpif.ihit;
      deif.ihit = dpif.ihit;
      emif.ihit = dpif.ihit;
      mwif.ihit = dpif.ihit;
    end

    always_comb begin: IF_ID_LATCH
      fdif.if_pc         = pc;
      fdif.if_instr      = dpif.iload;
      fdif.if_pred_taken = bpif.pred_taken;
      fdif.if_prev_ghr   = bpif.prev_ghr;
    end

    always_comb begin: CONTROL_UNIT
      cuif.opcode  = opcode_t'(fdif.instr_id[6:0]);
      cuif.funct3  = fdif.instr_id[14:12];
      cuif.funct7  = fdif.instr_id[31:25];
      cuif.funct12 = fdif.instr_id[31:20];
    end

    always_comb begin: REGFILE
      rfif.rs1       = cuif.lui ? '0 : fdif.instr_id[19:15];
      rfif.rs2       = fdif.instr_id[24:20];
      rfif.rd        = mwif.rd_wb;
      rfif.reg_write = mwif.reg_write_wb;
      rfif.wdata     = mwif.mem_to_reg_wb ? mwif.dmem_data_wb : mwif.alu_out_wb;
    end

    always_comb begin: IMM_GEN
      deif.imm_id     = 32'd4;
      deif.jumpimm_id = '0;

      unique case (cuif.imm_type)
        IMM_ITYPE:  deif.imm_id     = {{20{fdif.instr_id[31]}}, fdif.instr_id[31:20]};
        IMM_UTYPE:  deif.imm_id     = {fdif.instr_id[31:12], 12'b0};
        IMM_STYPE:  deif.imm_id     = {{20{fdif.instr_id[31]}},
                                        fdif.instr_id[31:25], fdif.instr_id[11:7]};
        IMM_BTYPE:  deif.imm_id     = {{20{fdif.instr_id[31]}}, fdif.instr_id[7],
                                        fdif.instr_id[30:25], fdif.instr_id[11:8], 1'b0};
        IMM_UJTYPE: deif.jumpimm_id = {{12{fdif.instr_id[31]}}, fdif.instr_id[19:12],
                                        fdif.instr_id[20], fdif.instr_id[30:21], 1'b0};
        IMM_IJTYPE: deif.jumpimm_id = {{20{fdif.instr_id[31]}}, fdif.instr_id[31:20]};
        IMM_SHIFT:  deif.imm_id     = {26'b0, fdif.instr_id[25:20]};
        IMM_SHIFTW: deif.imm_id     = {27'b0, fdif.instr_id[24:20]};
      endcase
    end

    always_comb begin: ID_EX_LATCH
      deif.pc_id         = fdif.pc_id;
      deif.prev_ghr_id   = fdif.prev_ghr_id;
      deif.pred_taken_id = fdif.pred_taken_id;

      deif.rd_id     = fdif.instr_id[11:7];
      deif.rs1_id    = fdif.instr_id[19:15];
      deif.rs2_id    = fdif.instr_id[24:20];
      deif.funct3_id = fdif.instr_id[14:12];

      deif.rdata1_id = rfif.rdata1;
      deif.rdata2_id = rfif.rdata2;

      deif.reg_write_id  = cuif.reg_write;
      deif.mem_to_reg_id = cuif.mem_to_reg;
      deif.mem_read_id   = cuif.mem_read;
      deif.mem_write_id  = cuif.mem_write;
      deif.alu_op_id     = cuif.alu_op;
      deif.imm_sel_id    = cuif.imm_sel;
      deif.jump_id       = cuif.jump;
      deif.branch_id     = cuif.branch;
      deif.jalr_id       = cuif.jalr;
      deif.auipc_id      = cuif.auipc;
      deif.mem_data_id   = cuif.mem_data;
      deif.halt_id       = cuif.halt;
      deif.opcode_id     = opcode_t'(fdif.instr_id[6:0]);
    end

    always_comb begin: ALU
      aluif.port_a = deif.rdata1_exe;
      aluif.port_b = deif.rdata2_exe;
      aluif.alu_op = deif.alu_op_exe;

      if (deif.jump_exe || deif.auipc_exe) begin
        aluif.port_a = deif.pc_exe;
      end
      else if (fuif.forward_one == 2'b01) begin
        aluif.port_a = emif.alu_out_mem;
      end
      else if (fuif.forward_one == 2'b10) begin
        aluif.port_a = rfif.wdata;
      end

      if (deif.imm_sel_exe) begin
        aluif.port_b = deif.imm_exe;
      end
      else if (fuif.forward_two == 2'b01) begin
        aluif.port_b = emif.alu_out_mem;
      end
      else if (fuif.forward_two == 2'b10) begin
        aluif.port_b = rfif.wdata;
      end
    end

    always_comb begin: JUMP_ADDR
      automatic addr_t jumpimm_sext = {{16{deif.jumpimm_exe[31]}}, deif.jumpimm_exe};

      emif.jumpaddr_mem = deif.pc_exe + jumpimm_sext;

      if (deif.jalr_exe) begin
        emif.jumpaddr_mem = (deif.rdata1_exe[ADDR_W-1:0] + jumpimm_sext) & ~48'h1;
        if (fuif.forward_jalr == 2'b01) begin
          emif.jumpaddr_mem = (emif.alu_out_mem[ADDR_W-1:0] + jumpimm_sext) & ~48'h1;
        end
        else if (fuif.forward_jalr == 2'b10) begin
          emif.jumpaddr_mem = (rfif.wdata[ADDR_W-1:0] + jumpimm_sext) & ~48'h1;
        end
      end
    end

    always_comb begin: FORWARDING_UNIT
      fuif.rs1_de       = deif.rs1_exe;
      fuif.rs2_de       = deif.rs2_exe;
      fuif.opcode_de    = deif.opcode_exe;
      fuif.rd_em        = emif.rd_mem;
      fuif.reg_write_em = emif.reg_write_mem;
      fuif.mem_read_em  = emif.mem_read_mem;
      fuif.rd_mw        = mwif.rd_wb;
      fuif.reg_write_mw = mwif.reg_write_wb;
    end

    always_comb begin: HAZARD_UNIT
      huif.ihit        = dpif.ihit;
      huif.dmem_ready  = dmem_ready;
      huif.pred_taken  = emif.pred_taken_mem;
      huif.jump_taken  = jump_taken;
      huif.rs1_de      = deif.rs1_exe;
      huif.rs2_de      = deif.rs2_exe;
      huif.rd_em       = emif.rd_mem;
      huif.mem_read_em = emif.mem_read_mem;
    end

    always_comb begin: EX_MEM_LATCH
      emif.pred_taken_exe = deif.pred_taken_exe;
      emif.prev_ghr_exe   = deif.prev_ghr_exe;
      emif.reg_write_exe  = deif.reg_write_exe;
      emif.halt_exe       = deif.halt_exe;
      emif.mem_to_reg_exe = deif.mem_to_reg_exe;
      emif.mem_read_exe   = deif.mem_read_exe;
      emif.mem_write_exe  = deif.mem_write_exe;
      emif.jump_exe       = deif.jump_exe;
      emif.branch_exe     = deif.branch_exe;
      emif.pc_exe         = deif.pc_exe;
      emif.rd_exe         = deif.rd_exe;
      emif.mem_data_exe   = deif.mem_data_exe;
      emif.funct3_exe     = deif.funct3_exe;
      emif.imm_exe        = deif.imm_exe;
      emif.alu_out_exe    = aluif.alu_out;
      emif.zero_exe       = aluif.zero;

      emif.rdata2_exe = deif.rdata2_exe;
      if (fuif.forward_two == 2'b01)
        emif.rdata2_exe = emif.alu_out_mem;
      else if (fuif.forward_two == 2'b10)
        emif.rdata2_exe = rfif.wdata;
    end

    always_comb begin: JUMP_BRANCH_UNIT
      jump_taken  = 0;
      old_next_pc = emif.pc_mem + 4;

      if (emif.jump_mem) begin
        jump_taken  = 1;
        old_next_pc = emif.jumpaddr_mem;
      end
      else if (emif.branch_mem) begin
        unique0 case (emif.funct3_mem)
          BEQ:  jump_taken = emif.zero_mem ? 1'b1 : 1'b0;
          BNE:  jump_taken = emif.zero_mem ? 1'b0 : 1'b1;
          BLT:  jump_taken = emif.alu_out_mem ? 1'b1 : 1'b0;
          BLTU: jump_taken = emif.alu_out_mem ? 1'b1 : 1'b0;
          BGE:  jump_taken = emif.alu_out_mem ? 1'b0 : 1'b1;
          BGEU: jump_taken = emif.alu_out_mem ? 1'b0 : 1'b1;
        endcase

        if (jump_taken) begin
          old_next_pc = emif.pc_mem + addr_t'(signed'(emif.imm_mem));
        end
      end
    end

    always_ff @(posedge clk, negedge rst_n) begin: DMEM
      if (!rst_n || huif.flush) begin
        d_ren      <= 1'b0;
        d_wen      <= 1'b0;
        dmem_ready <= 1'b1;
      end
      else begin
        d_ren              <= next_d_ren;
        d_wen              <= next_d_wen;
        dmem_ready         <= next_dmem_ready;
        mwif.dmem_data_mem <= dpif.dhit ? dpif.dload : mwif.dmem_data_mem;
      end
    end

    always_comb begin: NEXT_DMEM
      next_d_ren      = d_ren;
      next_d_wen      = d_wen;
      next_dmem_ready = dmem_ready;

      if (dpif.ihit) begin
        next_d_ren      = deif.mem_read_exe;
        next_d_wen      = deif.mem_write_exe;
        next_dmem_ready = !(next_d_ren || next_d_wen);
      end
      else if (dpif.dhit) begin
        next_d_ren      = 1'b0;
        next_d_wen      = 1'b0;
        next_dmem_ready = 1'b1;
      end
    end

    always_comb begin: MEM_WB_LATCH
      mwif.reg_write_mem  = emif.reg_write_mem;
      mwif.mem_to_reg_mem = emif.mem_to_reg_mem;
      mwif.rd_mem         = emif.rd_mem;
      mwif.alu_out_mem    = emif.alu_out_mem;
    end

endmodule
