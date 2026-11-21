# ECE111 Final Project

Shared workspace for the Fall 2026 final project. Status: repository setup only. Add the supplied starter code and testbenches before implementation.

## Project scope

Part I contains a handshake synchronizer and a simplified SHA-256 core. The supplied handout lists November 27, 2026 at 11:59 PM as the deadline, with at most two late days. Check Canvas for changes.

- `handshake/`: sender FSM, receiver FSM, synchronizers, and top module.
- `sha256/`: simplified_sha256 and its supplied testbench.
- `docs/`: requirements, team plan, and report outline.
- `evidence/`: selected transcripts, screenshots, fitter/timing reports, and summary spreadsheet.

Each design has `rtl/`, `tb/`, `sim/`, and `quartus/` folders. Put portable ModelSim .do scripts in sim and Quartus .qpf/.qsf/.sdc files in quartus. Generated databases and wave files are ignored.

## Working together

1. Clone this repository and add the official templates and testbenches from Canvas.
2. Claim a task in [the team plan](docs/team-plan.md).
3. Create a branch, for example `feature/sender-fsm` or `feature/sha256-round`.
4. Commit a focused change and open a pull request. Include the test performed and its result.
5. Ask the teammate to review before merging. Pull main before starting the next task.

Keep the provided baseline testbenches unchanged. Put additional tests in separate files. Record tool versions and the exact commit used for report evidence.

## Tools and verification

Use Quartus and ModelSim. The handout specifies Arria II GX EP2AGX45DF29I5 and Slow 900mV 100C timing for the SHA core. See [requirements](docs/requirements.md) for the different handshake and SHA constraints.

No simulations, synthesis runs, or implementations are included yet. Do not treat the empty folders as completed modules.

## Source

Requirements are summarized from ECE111_Final_Project_Part1.pdf, PDF pages 18–22 and 48–55. The source PDF remains in the course folder. Lecture 16 describes later Bitcoin hashing work, but it is not part of this Part I starter workspace.
