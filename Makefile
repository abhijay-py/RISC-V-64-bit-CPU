# Build system for RISC-V-64-bit-CPU
#
# Usage:
#   make [verilator|xsim] sim|coverage|wave <module> [<module> ...] [BP_TYPE=NT|2BIT|GSHARE]
#   make clean
#   make help
#
# <module> is any module with both rtl/<module>.sv and tb/<module>_tb.sv.
# The simulator defaults to verilator if not given.
#
# Examples:
#   make verilator sim alu
#   make sim alu
#   make xsim coverage registers
#   make wave branch_predictor BP_TYPE=GSHARE
#
# First time on a fresh machine? Run scripts/setup.sh to install the
# required tools (Verilator, GTKWave, lcov).

SHELL := /bin/bash

SRC_DIR   := rtl
INC_DIR   := inc
TB_DIR    := tb
WAVE_DIR  := wave
BUILD_DIR := build
OUT_DIR   := $(BUILD_DIR)/out

NPROC := $(shell nproc 2>/dev/null || echo 1)

GTKWAVE := $(shell command -v gtkwave 2>/dev/null)
GENHTML := $(shell command -v genhtml 2>/dev/null)

# ---------------------------------------------------------------------------
# Module discovery: every tb/<mod>_tb.sv with a matching rtl/<mod>.sv
# ---------------------------------------------------------------------------
ALL_MODULES := $(foreach m,$(patsubst $(TB_DIR)/%_tb.sv,%,$(wildcard $(TB_DIR)/*_tb.sv)),$(if $(wildcard $(SRC_DIR)/$(m).sv),$(m)))

# ---------------------------------------------------------------------------
# Parse "make [verilator|xsim] sim|coverage|wave <module...>" from MAKECMDGOALS
# ---------------------------------------------------------------------------
ifneq (,$(filter xsim,$(MAKECMDGOALS)))
SIMULATOR := XSIM
else
SIMULATOR := VERILATOR
endif

ACTIONS := sim coverage wave
ACTION  := $(firstword $(filter $(ACTIONS),$(MAKECMDGOALS)))
MODULES := $(filter-out verilator xsim $(ACTIONS) clean help,$(MAKECMDGOALS))

# ---------------------------------------------------------------------------
# Branch predictor variant: NT (default, static not-taken), 2BIT (2-bit
# saturating counter + BTB), or GSHARE (gshare PHT + BTB + GHR).
# ---------------------------------------------------------------------------
BP_TYPE ?= NT
ifeq (,$(filter $(BP_TYPE),NT 2BIT GSHARE))
$(error BP_TYPE must be NT, 2BIT, or GSHARE (got '$(BP_TYPE)'))
endif

BP_DEFINE :=
ifneq ($(BP_TYPE),NT)
BP_DEFINE := BP_$(BP_TYPE)
endif

# ---------------------------------------------------------------------------
# Simulator backend: VERILATOR (default, open-source, compiled sim -- used
# for day-to-day testbenches/coverage/CI) or XSIM (Vivado simulator -- needed
# when a testbench depends on Vivado's bundled UVM library, e.g. BP_TYPE=GSHARE).
# ---------------------------------------------------------------------------
ifeq ($(SIMULATOR),VERILATOR)
VERILATOR          := verilator
VERILATOR_COVERAGE := verilator_coverage

VLT_FLAGS := --binary --timing -sv --assert -Wall -O2 --threads $(NPROC) --clk CLK -I$(INC_DIR)
ifneq ($(BP_DEFINE),)
VLT_FLAGS += +define+$(BP_DEFINE)
endif
else # XSIM
XVLOG := xvlog
XELAB := xelab
XSIM  := xsim
XCRG  := $(shell command -v xcrg 2>/dev/null)

XVLOG_FLAGS := -sv -i $(INC_DIR)
ifneq ($(BP_DEFINE),)
XVLOG_FLAGS += -d $(BP_DEFINE)
endif

XELAB_FLAGS := --timescale 1ns/1ps -debug typical
ifeq ($(BP_TYPE),GSHARE)
# Vivado bundles UVM 1.2; -L uvm links the testbench against it.
XELAB_FLAGS += -L uvm
endif
endif

# ---------------------------------------------------------------------------
# Parse "// DEPS: dep1 dep2 ..." from the first 10 lines of a TB file.
# rtl/<module>.sv and all .svh files are always included automatically.
# ---------------------------------------------------------------------------
GET_DEPS     = $(shell ./scripts/get_deps.sh $(1) $(SRC_DIR))
GET_DEPS_ABS = $(shell ./scripts/get_deps.sh $(1) $(CURDIR)/$(SRC_DIR))

.PHONY: verilator xsim sim coverage wave clean help $(MODULES)

.DEFAULT_GOAL := help

# No-op placeholder goals -- they only exist so MAKECMDGOALS parsing above works.
verilator xsim sim coverage wave:
	@:

# ---------------------------------------------------------------------------
# sim / coverage / wave for each module named on the command line
# ---------------------------------------------------------------------------
ifneq ($(MODULES),)
ifeq ($(ACTION),)
$(error No action given. Usage: make [verilator|xsim] sim|coverage|wave $(MODULES))
endif
$(MODULES): %: _$(ACTION)_%
	@:
endif

# ---------------------------------------------------------------------------
# sim
# ---------------------------------------------------------------------------
_sim_%:
	@mkdir -p $(OUT_DIR)/$* $(BUILD_DIR)
	@touch $(BUILD_DIR)/sim.log
ifeq ($(SIMULATOR),VERILATOR)
	$(VERILATOR) $(VLT_FLAGS) --trace-fst --trace-structs \
	    $(SRC_DIR)/$*.sv $(call GET_DEPS,$*) $(TB_DIR)/$*_tb.sv \
	    --top $*_tb --Mdir $(OUT_DIR)/$* -o $*_sim 2>&1 | tee $(BUILD_DIR)/sim.log
	cd $(BUILD_DIR) && $(CURDIR)/$(OUT_DIR)/$*/$*_sim 2>&1 | tee -a sim.log
	mv -f $(BUILD_DIR)/dump.fst $(BUILD_DIR)/$*.fst
else
	cd $(OUT_DIR)/$* && $(XVLOG) $(XVLOG_FLAGS) $(CURDIR)/$(SRC_DIR)/$*.sv $(call GET_DEPS_ABS,$*) $(CURDIR)/$(TB_DIR)/$*_tb.sv 2>&1 | tee $(CURDIR)/$(BUILD_DIR)/sim.log
	cd $(OUT_DIR)/$* && $(XELAB) $*_tb -s $*_sim $(XELAB_FLAGS) 2>&1 | tee -a $(CURDIR)/$(BUILD_DIR)/sim.log
	cd $(OUT_DIR)/$* && $(XSIM) $*_sim -R 2>&1 | tee -a $(CURDIR)/$(BUILD_DIR)/sim.log
	mv -f $(OUT_DIR)/$*/dump.fst $(BUILD_DIR)/$*.fst
endif

# ---------------------------------------------------------------------------
# coverage
# ---------------------------------------------------------------------------
_coverage_%:
	@mkdir -p $(OUT_DIR)/$* $(BUILD_DIR)
	@touch $(BUILD_DIR)/coverage.log
ifeq ($(SIMULATOR),VERILATOR)
	$(VERILATOR) $(VLT_FLAGS) --coverage \
	    $(SRC_DIR)/$*.sv $(call GET_DEPS,$*) $(TB_DIR)/$*_tb.sv \
	    --top $*_tb --Mdir $(OUT_DIR)/$* -o $*_cov 2>&1 | tee $(BUILD_DIR)/coverage.log
	cd $(BUILD_DIR) && $(CURDIR)/$(OUT_DIR)/$*/$*_cov 2>&1 | tee -a coverage.log
	$(VERILATOR_COVERAGE) $(BUILD_DIR)/coverage.dat 2>&1 | tee -a $(BUILD_DIR)/coverage.log
	$(VERILATOR_COVERAGE) --annotate $(BUILD_DIR)/coverage_annotated $(BUILD_DIR)/coverage.dat 2>&1 | tee -a $(BUILD_DIR)/coverage.log
	@echo "[coverage] Annotated source: $(BUILD_DIR)/coverage_annotated/"
ifneq ($(GENHTML),)
	$(VERILATOR_COVERAGE) --write-info $(BUILD_DIR)/coverage.info $(BUILD_DIR)/coverage.dat 2>&1 | tee -a $(BUILD_DIR)/coverage.log
	$(GENHTML) $(BUILD_DIR)/coverage.info --output-directory $(BUILD_DIR)/coverage_html 2>&1 | tee -a $(BUILD_DIR)/coverage.log
	@echo "[coverage] HTML report (line coverage only): $(BUILD_DIR)/coverage_html/index.html"
endif
else
	cd $(OUT_DIR)/$* && $(XVLOG) $(XVLOG_FLAGS) $(CURDIR)/$(SRC_DIR)/$*.sv $(call GET_DEPS_ABS,$*) $(CURDIR)/$(TB_DIR)/$*_tb.sv 2>&1 | tee $(CURDIR)/$(BUILD_DIR)/coverage.log
	cd $(OUT_DIR)/$* && $(XELAB) $*_tb -s $*_cov $(XELAB_FLAGS) -cov all 2>&1 | tee -a $(CURDIR)/$(BUILD_DIR)/coverage.log
	cd $(OUT_DIR)/$* && $(XSIM) $*_cov -R 2>&1 | tee -a $(CURDIR)/$(BUILD_DIR)/coverage.log
ifneq ($(XCRG),)
	$(XCRG) -dir $(OUT_DIR)/$*/xsim.covdb -report_format html -output_dir $(BUILD_DIR)/coverage_html/$* 2>&1 | tee -a $(BUILD_DIR)/coverage.log
	@echo "[coverage] HTML report: $(BUILD_DIR)/coverage_html/$*/dashboard.html"
endif
endif

# ---------------------------------------------------------------------------
# wave -- does not require sim to be run first; generated automatically if
# the waveform doesn't exist yet.
# ---------------------------------------------------------------------------
_wave_%:
	@if [ ! -f $(BUILD_DIR)/$*.fst ]; then \
	    echo "Waveform not found: $(BUILD_DIR)/$*.fst -- running sim"; \
	    $(MAKE) --no-print-directory $(if $(filter XSIM,$(SIMULATOR)),xsim,verilator) sim $* BP_TYPE=$(BP_TYPE) || exit 1; \
	fi
	@if [ -z "$(GTKWAVE)" ]; then echo "error: gtkwave not found in PATH" >&2; exit 1; fi
	@if [ -f $(WAVE_DIR)/$*.gtkw ]; then \
	    $(GTKWAVE) -f $(BUILD_DIR)/$*.fst -a $(WAVE_DIR)/$*.gtkw; \
	else \
	    $(GTKWAVE) -f $(BUILD_DIR)/$*.fst; \
	fi

# ---------------------------------------------------------------------------
clean:
	rm -rf $(BUILD_DIR) dump.fst coverage.dat

# ---------------------------------------------------------------------------
help:
	@echo ""
	@echo "Usage:"
	@echo "  make [verilator|xsim] sim|coverage|wave <module> [BP_TYPE=NT|2BIT|GSHARE]"
	@echo "  make clean"
	@echo ""
	@echo "Examples:"
	@echo "  make verilator sim alu"
	@echo "  make sim alu                              (simulator defaults to verilator)"
	@echo "  make xsim coverage registers"
	@echo "  make wave branch_predictor BP_TYPE=GSHARE"
	@echo ""
	@echo "Deps:"
	@echo "  Add '// DEPS: mod1 mod2' on the first line of tb/<module>_tb.sv"
	@echo "  to pull in extra rtl/*.sv files the DUT instantiates."
	@echo "  rtl/<module>.sv and all .svh files are always included automatically."
	@echo ""
	@echo "Output (all under build/):"
	@echo "  sim.log / coverage.log        simulation and coverage logs"
	@echo "  <module>.fst                  waveform for GTKWave"
	@echo "  out/<module>/                 simulator build output"
	@echo "  coverage_annotated/           annotated source (verilator: line + toggle + branch)"
	@echo "  coverage_html/                HTML coverage report"
	@echo ""
	@echo "Discovered modules: $(ALL_MODULES)"
	@echo ""
