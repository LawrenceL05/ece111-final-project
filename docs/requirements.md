# Part I requirements checklist

Source: ECE111_Final_Project_Part1.pdf. References below are PDF page numbers. This is a team checklist, not a replacement for the supplied templates or Canvas instructions.

## Handshake synchronizer — pp. 18–22

- [x] Add the provided synchronizer and testbench files.
- [x] Implement sender_fsm: IDLE, REQ_ACK_PHASE1, REQ_ACK_PHASE2.
- [x] Implement receiver_fsm: ACK_REQ_PHASE1, ACK_REQ_PHASE2.
- [ ] Connect handshake_synchronizer and the request/acknowledgment synchronizers.
- [ ] Implement the specified holding latch after the source data register.
- [ ] Transfer 32-bit data using the four-phase request/acknowledgment sequence.
- [ ] Verify every input word appears at the destination without being lost.
- [ ] Capture ModelSim waveforms and the Quartus resource summary.

The testbench periods are 20 ns for source and 124 ns for destination. The source is faster. Page 21 reverses that relationship in one parenthetical statement. Page 21 also says there is no handshake self-checker, so inspect the input/output waveform even though the introductory page broadly mentions expected behavior in testbenches.

The holding latch is explicitly requested in this subpart. The SHA no-latch restriction below applies to the SHA design.

## SHA-256 — pp. 48–55

- [ ] Add the supplied simplified_sha256 template and testbench.
- [ ] Read the 20-word, 640-bit message using word addresses.
- [ ] Pad to two 512-bit blocks and run 64 compression rounds per block.
- [ ] Preserve the digest between blocks, including final feed-forward.
- [ ] Write H0–H7 to output_addr through output_addr + 7.
- [ ] Assert done after the writes complete.
- [ ] Pass the provided self-checking simulation and save its transcript.
- [ ] Compile for Arria II GX EP2AGX45DF29I5.
- [ ] Confirm no inferred megafunctions, no inferred latches, and zero block-memory bits.
- [ ] Use mem_clk = clk and confirm clk is the only clock in the SHA timing report.
- [ ] Record Fmax for Slow 900mV 100C, total cycles, ALUTs, and registers.

## Submission evidence — p. 53

- [ ] Both designs and supplied testbench files, including handshake support modules.
- [ ] ModelSim transcripts for both subparts.
- [ ] SHA fitter and static-timing reports.
- [ ] Final report with required explanations, waveform captures, pass evidence, and resource/timing screenshots.
- [ ] Completed finalsummary spreadsheet using the official template.
- [ ] Package using the team-name filename specified in the handout.

The handshake report needs a brief explanation, simulation interpretation, and resource screenshot. The handout explicitly says an FPGA resource-usage explanation is not required. Use only the explanations requested for each report section.
