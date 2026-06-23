# RISC-V-64-bit-CPU
This reposistory contains the current state of the journey towards creating a 2-core RV64IMF CPU with private and seperate instruction + data L1 caches with a shared inclusive L2 cache, utilizing the MOESI protocol for cache coherence.<br><br>
The current design consists of a standard single core RV64I CPU with a standard 5 stage pipeline and a configurable branch predictor (static not-taken by default, with 2-bit saturating counter + BTB and gshare variants also available). The multiply + floating point extensions will be added on later in addition to out-of-order execution and a modified pipeline to maximize performance. After that, a second core will be added along with cache coherency protocols.<br><br>
Some future ideas being considered to be implemented after implementing the aforementioned ideas include hyperthreading, implementing some processor features to aid running an OS (such as CSR instructions + hint instructions), other RISC-V extensions, or further architectural revisions.

## Dependencies

- [Verilator](https://verilator.org) (5.0+)
- [GTKWave](https://gtkwave.sourceforge.net) (waveform viewer, optional)
- `genhtml` from the `lcov` package (HTML coverage reports, optional)
- g++ with C++20 coroutine support
- Optional: [Vivado](https://www.xilinx.com/products/design-tools/vivado.html) (provides `xvlog`/`xelab`/`xsim`, needed for `SIMULATOR=xsim`

On a fresh Debian/Ubuntu install, run `./scripts/setup.sh` to install Verilator, GTKWave, and lcov via `apt`. Vivado is too large and license-gated to install automatically — install it manually and source its `settings64.sh` if you need `SIMULATOR=xsim`.

## Running Simulations

```bash
make [verilator|xsim] sim|coverage|wave <module> [BP_TYPE=NT|2BIT|GSHARE]
```

The simulator defaults to `verilator` if omitted.

**Examples:**
```bash
make sim registers
make verilator coverage alu
make wave registers
make xsim sim branch_predictor BP_TYPE=GSHARE
```

Logs (`sim.log`, `coverage.log`) and waveforms (`<module>.fst`) are written to `build/`. GTKWave save files go in `wave/<module>.gtkw` in the project root (this directory also holds Vivado/XSIM `.wcfg` waveform configs, if you use those instead).

`wave <module>` does not require `sim <module>` to be run first — if the waveform doesn't exist yet, it's generated automatically by running the sim before opening GTKWave.

Coverage always produces annotated source files at `build/coverage_annotated/` (includes line, toggle, and branch counts, when using Verilator). If `genhtml` is installed, an HTML report is also written to `build/coverage_html/index.html` — note that the HTML report shows **line coverage only**.

A summary percentage is printed to the log in both cases.

Run `make help` for the full usage summary and a list of discovered modules.

## Branch Predictor Variants

The branch predictor (`rtl/branch_predictor.sv`) is built from a single source file with three variants selected via the `BP_TYPE` make variable:

- `NT` (default) — static not-taken, always predicts `pc + 4`
- `2BIT` — single 2-bit saturating counter + BTB, predicts taken only on a BTB hit
- `GSHARE` — gshare PHT (indexed by `pc ^ ghr`) + BTB + global history register

```bash
make sim branch_predictor BP_TYPE=2BIT
```

No reconfigure step is needed — just pass `BP_TYPE=...` on each invocation.

`tb/branch_predictor_tb.sv` is hand-written for `NT`/`2BIT`. `GSHARE` instead drives the DUT through the UVM environment under `inc/uvm/branch_predictor_uvm/`, which requires Vivado's bundled UVM library — use `make xsim sim branch_predictor BP_TYPE=GSHARE` for this variant.

## Adding a New Module

1. Add the source file to `rtl/<module>.sv`
2. Add the testbench to `tb/<module>_tb.sv`
3. If the module instantiates other modules, add `// DEPS: dep1 dep2` on the first line of the testbench
4. Run `make sim <module>` — modules are discovered automatically, no reconfigure step needed

**Example testbench header with deps:**
```systemverilog
// DEPS: alu registers
`include "datapath_if.svh"
...
```

## Cleaning

```bash
make clean
```

Removes all build outputs, waveform (`.fst`) files, and logs.
