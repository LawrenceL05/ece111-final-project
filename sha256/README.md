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

The design template is incomplete. It contains empty expressions in `sha256_op`, an empty `determine_num_blocks` function, and unfinished FSM states. This import does not claim a compile or simulation pass. Quartus and ModelSim configuration for SHA remains pending.

The default testbench uses 20 input words, message address 0, output address 1000, and seed `32'h01234567`. It computes a two-block reference hash and compares all eight output words. It ends with `$stop`.

Keep the supplied testbench unchanged. Put additional tests in separate files.
