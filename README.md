# RISC-V-64-bit-CPU
This reposistory contains the current state of the journey towards creating a 2-core RV64IMF CPU with private and seperate instruction + data L1 caches with a shared inclusive L2 cache, utilizing the MOESI protocol for cache coherence.<br><br>
The current design consists of a standard single core RV64I CPU with a standard 5 stage pipeline and a configurable branch predictor (static not-taken by default, with 2-bit saturating counter + BTB and gshare variants also available). The multiply + floating point extensions will be added on later in addition to out-of-order execution and a modified pipeline to maximize performance. After that, a second core will be added along with cache coherency protocols.<br><br>
Some future ideas being considered to be implemented after implementing the aforementioned ideas include hyperthreading, implementing some processor features to aid running an OS (such as CSR instructions + hint instructions), other RISC-V extensions, or further architectural revisions.

## Dependencies

- [Verilator](https://verilator.org) (5.0+)
- [GTKWave](https://gtkwave.sourceforge.net) (waveform viewer, optional)
- `genhtml` from the `lcov` package (HTML coverage reports, optional)
- CMake 3.20+
- g++ with C++20 coroutine support

## Building

Configure the build directory once from the project root:

```bash
cmake -B build
```

Re-run this if you add new source or testbench files — CMake auto-discovers modules but needs to reconfigure to pick up new ones.

## Running Simulations

```bash
cmake --build build --target sim_<module>
cmake --build build --target coverage_<module>
cmake --build build --target wave_<module>
```

**Examples:**
```bash
cmake --build build --target sim_registers
cmake --build build --target coverage_alu
cmake --build build --target wave_registers
```

Logs (`sim.log`, `coverage.log`) and waveforms (`<module>.fst`) are written to the build directory. GTKWave save files go in `gtkw/<module>.gtkw` in the project root.

`wave_<module>` does not require `sim_<module>` to be run first — if the waveform doesn't exist yet, it's generated automatically by running the sim before opening GTKWave.

Coverage always produces annotated source files at `build/coverage_annotated/` (includes line, toggle, and branch counts). If `genhtml` is installed, an HTML report is also written to `build/coverage_html/index.html` — note that the HTML report shows **line coverage only**.

A summary percentage is printed to the log in both cases.

## Branch Predictor Variants

The branch predictor (`src/branch_predictor.sv`) is built from a single source file with three variants selected at configure time via the `BP_TYPE` CMake cache variable:

- `NT` (default) — static not-taken, always predicts `pc + 4`
- `2BIT` — single 2-bit saturating counter + BTB, predicts taken only on a BTB hit
- `GSHARE` — gshare PHT (indexed by `pc ^ ghr`) + BTB + global history register

```bash
cmake -B build -DBP_TYPE=2BIT
cmake --build build --target sim_branch_predictor
```

Re-run `cmake -B build -DBP_TYPE=...` and rebuild to switch variants.

`tb/branch_predictor_tb.sv` is hand-written for `NT`/`2BIT`. `GSHARE` instead drives the DUT through the UVM environment under `inc/uvm/branch_predictor_uvm/` — **this UVM testbench currently does not build**, since verilator can't find `uvm_macros.svh`/`` `uvm_error`` (the UVM library include path isn't wired into `VLT_FLAGS` yet).

## Adding a New Module

1. Add the source file to `src/<module>.sv`
2. Add the testbench to `tb/<module>_tb.sv`
3. If the module instantiates other modules, add `// DEPS: dep1 dep2` on the first line of the testbench
4. Re-run `cmake -B build` to register the new targets

**Example testbench header with deps:**
```systemverilog
// DEPS: alu registers
`include "datapath_if.vh"
...
```

## Cleaning

```bash
cmake --build build --target clean
```

Removes all build outputs, waveform (`.fst`) files, and logs.
