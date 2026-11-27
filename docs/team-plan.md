# Team plan

Fill in owners together before starting. The suggested split is a starting point, not an assignment to either teammate.

| Task | Owner | Status | Evidence / PR |
|---|---|---|---|
| Import handshake templates and testbench | Lawrence | Complete | See starter-manifest.json |
| Import SHA templates and testbench | Lawrence | Complete | See starter-manifest.json and sha256/README.md |
| Sender FSM and receiver FSM | Lawrence | Complete | Each FSM passed a standalone ModelSim test covering reset and two consecutive handshakes. |
| Handshake integration and waveform verification | Lawrence | Complete | [ModelSim waveforms and report](../evidence/README.md) |
| SHA schedule and compression datapath | Al | Complete | [PR #1](https://github.com/LawrenceL05/ece111-final-project/pull/1): supplied testbench passes (185 cycles); Fmax 156.47 MHz, 1,617 ALUTs, 1,751 registers, 0 block memory bits |
| SHA controller, memory timing, and writes | Al | Complete | [PR #1](https://github.com/LawrenceL05/ece111-final-project/pull/1): supplied testbench passes (185 cycles); Fmax 156.47 MHz, 1,617 ALUTs, 1,751 registers, 0 block memory bits |
| Self-checking simulation and synthesis | Unassigned | Not started | |
| Report, spreadsheet, and final package | Both | Not started | |

Agree on module interfaces before coding. Keep the provided names and ports. Review the other person's work at integration points and record failing as well as passing tests in the PR.
