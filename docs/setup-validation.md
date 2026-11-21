# Setup validation — November 20, 2026

This record checks the development setup, not functional handshake behavior.

- All five handshake .sv files match the official ZIP byte-for-byte. The manifest records their SHA-256 values.
- ModelSim Intel FPGA Edition 2020.1 compiled all four design files and the supplied testbench with zero compilation errors.
- `run.do` elaborated and ran for 10 us. Elaboration produced 24 warnings for the intentionally empty instance port lists. No functional pass is claimed.
- The testbench has no self-checker or finish statement. Its ready wait cannot complete with the untouched templates.
- Quartus Prime Lite 20.1 opened an identical local copy of the project and confirmed top-level handshake_synchronizer, device EP2AGX45DF29I5, and all four source-file assignments.
- Quartus could not create/open the project database in the OneDrive checkout on this machine (error 297009). Use the local-clone workflow in handshake/README.md.
- The GUI wave.do script was opened in ModelSim and visually checked: both clocks, resets, source data, held data, request/acknowledgment, enables, destination data, and FSM states are present with green traces on black. Unknown values are expected from the unfinished design.
- Full synthesis and timing closure are pending implementation. No hardware resource numbers are claimed for these templates.

Interface review covers the supplied reset polarity/event controls, crossing directions, latch, handshake states, four stimulus words, and the stale destination-clock comment. See interfaces.md and verification.md.
