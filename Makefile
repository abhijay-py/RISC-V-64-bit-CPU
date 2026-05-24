# CANNOT RUN FULL CPU SIMULATIONS AS OF NOW.
SRC_DIR  := src
INC_DIR  := inc
TB_DIR   := tb
OUT_DIR  := out
GTKW_DIR := gtkw

THREADS ?= $(shell nproc)
VLT_FLAGS     := --binary --timing -sv --assert -Wall -O2 \
                 --threads $(THREADS) --clk CLK \
                 -I$(INC_DIR)
VLT_SIM_FLAGS := --trace

# Capture: make sim <mod> [deps...]  /  make coverage <mod> [deps...]  /  make wave <mod>
CMD := $(firstword $(MAKECMDGOALS))
ifneq ($(filter sim coverage wave, $(CMD)),)
  ARGS := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  MOD  := $(firstword $(ARGS))
  DEPS := $(wordlist 2, $(words $(ARGS)), $(ARGS))
  $(foreach t, $(ARGS), $(eval $(t):;@:))
endif

DEP_SRCS := $(foreach d, $(DEPS), $(SRC_DIR)/$(d).sv)

VCD  := $(if $(MOD),$(MOD).vcd,wave.vcd)
GTKW := $(if $(MOD),$(GTKW_DIR)/$(MOD).gtkw,$(GTKW_DIR)/signals.gtkw)

.DEFAULT_GOAL := help
.PHONY: sim coverage wave clean help

# -- guards shared by sim and coverage ------------------------------------
define CHECK_MOD
	@[ -n "$(MOD)" ] || { \
	  echo "ERROR: no module specified"; \
	  echo ""; \
	  echo "  usage: make $@ <module> [deps...]"; \
	  echo "    <module>    module under test — must have src/<module>.sv and tb/<module>_tb.sv"; \
	  echo "    [deps...]   additional src/ files to compile alongside it"; \
	  echo ""; \
	  echo "  examples:"; \
	  echo "    make $@ alu"; \
	  echo "    make $@ datapath alu forwarding_unit hazard_unit"; \
	  exit 1; \
	}
	@[ -f "$(SRC_DIR)/$(MOD).sv" ] || { \
	  echo "ERROR: src/$(MOD).sv not found"; \
	  echo "  available modules: $$(ls $(SRC_DIR)/*.sv | xargs -n1 basename | sed 's/\.sv//')"; \
	  exit 1; \
	}
	@[ -f "$(TB_DIR)/$(MOD)_tb.sv" ] || { \
	  echo "ERROR: tb/$(MOD)_tb.sv not found"; \
	  echo "  available testbenches: $$(ls $(TB_DIR)/*_tb.sv | xargs -n1 basename | sed 's/_tb\.sv//')"; \
	  exit 1; \
	}
	@$(foreach d, $(DEPS), \
	  [ -f "$(SRC_DIR)/$(d).sv" ] || { echo "ERROR: dep src/$(d).sv not found"; exit 1; };)
endef

# -------------------------------------------------------------------------

sim: | $(OUT_DIR)
	$(CHECK_MOD)
	verilator $(VLT_FLAGS) $(VLT_SIM_FLAGS) \
	  $(SRC_DIR)/$(MOD).sv $(DEP_SRCS) $(TB_DIR)/$(MOD)_tb.sv \
	  --top $(MOD)_tb --Mdir $(OUT_DIR) -o $(MOD)_sim \
	  2>&1 | tee sim.log
	$(OUT_DIR)/$(MOD)_sim 2>&1 | tee -a sim.log
	mv -f dump.vcd $(VCD)

coverage: | $(OUT_DIR)
	$(CHECK_MOD)
	verilator $(VLT_FLAGS) --coverage \
	  $(SRC_DIR)/$(MOD).sv $(DEP_SRCS) $(TB_DIR)/$(MOD)_tb.sv \
	  --top $(MOD)_tb --Mdir $(OUT_DIR) -o $(MOD)_cov \
	  2>&1 | tee coverage.log
	$(OUT_DIR)/$(MOD)_cov 2>&1 | tee -a coverage.log
	verilator_coverage coverage.dat 2>&1 | tee -a coverage.log

wave:
	@[ -f "$(VCD)" ] || { \
	  echo "ERROR: $(VCD) not found" | tee wave.log; \
	  echo "  run 'make sim $(MOD)' first to generate a waveform" | tee -a wave.log; \
	  echo "  available waveforms: $$(ls *.vcd 2>/dev/null | tr '\n' ' ' || echo none)"; \
	  exit 1; \
	}
	gtkwave -f $(VCD) $(if $(wildcard $(GTKW)),-a $(wildcard $(GTKW))) 2>&1 | tee wave.log

$(OUT_DIR):
	mkdir -p $@

clean:
	rm -rf $(OUT_DIR) coverage.dat sim.log coverage.log wave.log *.vcd

help:
	@echo ""
	@echo "Usage:"
	@echo "  make sim      <module> [deps...]   compile + run testbench"
	@echo "  make coverage <module> [deps...]   compile + run with coverage report"
	@echo "  make wave     [module]             open GTKWave waveform viewer"
	@echo "  make clean                         remove all build artifacts"
	@echo "  make help                          show this message"
	@echo ""
	@echo "Arguments:"
	@echo "  <module>    name of the module under test"
	@echo "              requires src/<module>.sv and tb/<module>_tb.sv"
	@echo "  [deps...]   extra modules from src/ to compile alongside the DUT"
	@echo "              does not affect which tb or top is used"
	@echo ""
	@echo "Examples:"
	@echo "  make sim alu"
	@echo "  make sim datapath alu forwarding_unit hazard_unit"
	@echo "  make coverage alu"
	@echo "  make wave alu"
	@echo "  make wave               (opens wave.vcd with gtkw/signals.gtkw)"
	@echo ""
	@echo "Output:"
	@echo "  sim.log / coverage.log / wave.log   logs in project root"
	@echo "  <module>.vcd                         waveform in project root"
	@echo "  gtkw/<module>.gtkw                   GTKWave save file (create manually)"
	@echo "  out/                                 binaries + verilator build files"
	@echo ""
