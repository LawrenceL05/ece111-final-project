# SHA-256 starter files

Imported on November 21, 2026 from `ECE111_Final_Project_Part1.zip`, under `Final Project Part 1/simplified_sha256/`.

| File | Purpose |
|---|---|
| `rtl/simplified_sha256.sv` | Official design template |
| `tb/tb_simplified_sha256.sv` | Official testbench with a reference hash and eight-word result comparison |
| `reference/simplified_sha256.xlsx` | Supplied SHA workbook |
| `reference/simplified_sha256_w_values.xlsx` | Supplied word-values workbook |
| `reference/finalsummary.xlsx` | Supplied summary template |

All five files match the archive byte-for-byte. The [starter manifest](../docs/starter-manifest.json) records each source path and SHA-256 checksum. Git preserves the original SystemVerilog line endings.

The design template has been filled in on the `feature/sha256-datapath` branch (round function, word expansion, block count, and the IDLE/READ/BLOCK/COMPUTE/WRITE FSM).

The default testbench uses 20 input words, message address 0, output address 1000, and seed `32'h01234567`. It computes a two-block reference hash and compares all eight output words. It ends with `$stop`.

Keep the supplied testbench unchanged. Put additional tests in separate files.

## ModelSim

Change directory to `sha256/sim`, then:

- `do wave.do` in the GUI compiles, runs the supplied testbench, and opens a labeled waveform.
- `vsim -c -do run.do` runs in batch and saves the transcript to `sha256-transcript.txt`.
- `do compile.do` compiles only.

A pass prints `CONGRATULATIONS! All your hash results are correct!` and the total cycle count.

## Quartus

Open `quartus/simplified_sha256.qpf`. The project targets Arria II GX EP2AGX45DF29I5 with top level `simplified_sha256`. Auto RAM, shift register, and ROM replacement are turned off in the `.qsf` so the fitter report shows 0 block memory bits and no inferred megafunctions (handout pp. 51–52). Read Fmax from the Slow 900mV 100C Model in the timing analyzer, and confirm `clk` is the only clock.
