# Handshake setup

The five .sv files are the official, unmodified starter files. Their original hashes are in [starter-manifest.json](../docs/starter-manifest.json). The sender, receiver, and top module still contain TODOs. The top-level instance port lists are intentionally empty in the supplied template.

## ModelSim

Open ModelSim and change directory to `handshake/sim`. Then use:

```tcl
do wave.do
```

For compilation only, use `do compile.do`. For a bounded batch run from this directory:

```text
vsim -c -do run.do
```

The scripts run for 10 us because the supplied testbench has no finish statement and continuously generates clocks. Its waits can stall indefinitely while the FSMs are incomplete. A zero exit status means the setup ran without a script error, not that the design passed. Review all four words and the protocol in [verification.md](../docs/verification.md).

The waveform script adds both clocks, resets, input/output words, holding data, request/acknowledgment, enables, and FSM states. It uses green traces. Use the normal black ModelSim waveform background. Additional internal signals become meaningful after wiring the instances.

## Quartus

Open `quartus/handshake_synchronizer.qpf`. The project selects top-level `handshake_synchronizer`, Arria II GX EP2AGX45DF29I5, and the four design files. The testbench is simulation-only.

On Lawrence's machine, Quartus 20.1 reported database permission error 297009 inside OneDrive. The identical project opened successfully in a local temporary folder. Use a local working clone outside OneDrive, for example:

```text
git clone https://github.com/LawrenceL05/ece111-final-project.git C:\fpga-work\ece111-final-project
```

Edit and commit in that clone so the files you compile are the files you push. Avoid paths with spaces for older FPGA tools.

After completing the design, compile from `handshake/quartus`:

```text
quartus_sh --flow compile handshake_synchronizer
```

This is a synthesis project, not a board deployment project. No board pins or timing exceptions are assigned. The handout asks for handshake resource usage. Its single-clock SHA timing constraint does not apply to this two-clock module. Add implementation-specific timing constraints when evaluating hardware timing.

Read [interfaces.md](../docs/interfaces.md) before editing. Keep the required holding latch and the supplied module/port names.
