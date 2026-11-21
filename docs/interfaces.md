# Handshake interface contract

Checked against the official starter ZIP and Final Project Part I PDF pp. 18–22. This documents the intended connections. The starter top module is not wired yet.

## Top-level interface

`handshake_synchronizer` inputs: `start`, `data_in[31:0]`, `src_clk`, `dest_clk`, `src_reset`, `dest_reset`. Outputs: `ready`, `data_out[31:0]`.

Source logic uses rising `src_clk` edges and active-high asynchronous `src_reset`. Destination logic uses rising `dest_clk` edges and active-high asynchronous `dest_reset`. These are not HW5's synchronous active-low resets.

| Instance | Port | Connect to |
|---|---|---|
| sender_fsm_inst | src_clk, src_reset, start | Same-named top inputs |
| sender_fsm_inst | ready, data_out_en, req_o | Same-named top signals |
| sender_fsm_inst | ack_i | sync_ack_i |
| receiver_fsm_inst | dest_clk, dest_reset | Same-named top inputs |
| receiver_fsm_inst | req_i | sync_req_i |
| receiver_fsm_inst | ack_o, data_in_en | Same-named top signals |
| ack_2ff_sync_inst | clock, reset | src_clk, src_reset |
| ack_2ff_sync_inst | d, q | ack_o, sync_ack_i |
| req_2ff_sync_inst | clock, reset | dest_clk, dest_reset |
| req_2ff_sync_inst | d, q | req_o, sync_req_i |

Both synchronizer instances use WIDTH=1 and NUM_OF_STAGES=2. Always clock a crossing control's synchronizer in the receiving domain.

## Data path

The source-clock register produces `data_in_reg`. The supplied holding-latch expression drives `data` from `data_in_reg` while `data_out_en` is high and holds the value when it is low. The destination-clock register loads `data` when `data_in_en` is asserted and drives `data_out`. Reset the source and destination registers in their respective reset domains when completing the TODOs.

The request/acknowledgment protocol holds data available for the slower domain. Do not add a separate two-flop synchronizer to each of the 32 data bits. The handout explicitly requires the data-holding latch for this subpart.

## Source inconsistencies to resolve while implementing

- The sender enum comment says ready=1 in REQ_ACK_PHASE1. The state's detailed comments and PDF p. 18 say ready=0. Use ready=0 while a transfer is in progress.
- The top-template request-synchronizer comment mentions receiver ack_i. The receiver has no ack_i port. Connect sync_req_i to receiver req_i.
- The testbench destination-clock comment says 80 ns. Its actual delays are 2+60 ns per toggle, giving a 124 ns period. Source period is 20 ns.
- The PDF receiver-state prose has an inconsistent return-state name. The supplied receiver enum and p. 19 diagram return to ACK_REQ_PHASE1.
- Both FSM templates use one clocked always_ff block. Outputs update from the pre-edge state, so trace register timing rather than assuming a combinational state decode.
