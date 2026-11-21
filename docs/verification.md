# Handshake verification checklist

Use the supplied baseline testbench unchanged. It has no self-checker, timeout, or finish statement. The setup scripts bound the run to 10 us. Add new directed tests in separate files later.

## Reset and startup

- [ ] While source reset is high, sender req_o, ready, data_out_en, and state match the template reset values (0, 0, 0, IDLE).
- [ ] While destination reset is high, ack_o and data_in_en are 0 and receiver state is ACK_REQ_PHASE1.
- [ ] Both synchronizer pipelines clear asynchronously.
- [ ] Source/destination data registers reset as implemented in their own domains.
- [ ] After reset release and the IDLE update, ready becomes 1 and the testbench advances past its initial wait.

## Every transaction

- [ ] A request begins only when the sender is ready and accepts start.
- [ ] ready becomes 0 during the transaction. The supplied testbench then drops start.
- [ ] req_o rises and sync_req_i follows on destination-clock sampling edges.
- [ ] The destination captures the correct 32-bit data with data_in_en.
- [ ] ack_o rises and sync_ack_i follows on source-clock sampling edges.
- [ ] Sender lowers req_o after acknowledgment.
- [ ] Receiver observes the synchronized request low and lowers ack_o.
- [ ] Sender observes synchronized acknowledgment low before returning to ready.
- [ ] The data bus has settled before the destination's enabled capture edge and remains stable while the destination needs it. Do not require stability during the initial latch-opening transition.
- [ ] No word is lost, reordered, or corrupted. A level enable may load the same held word on several destination edges. That alone is not a duplicate transaction.

## Baseline words, in order

| Transfer | Expected data_out | Observed time/value |
|---|---|---|
| 1 | 32'hABAB_CDCD | |
| 2 | 32'h1234_5678 | |
| 3 | 32'hA5A5_A5A5 | |
| 4 | 32'hA1B2_C3D4 | |

The baseline drives some inputs at source rising edges. Inspect settled updates after nonblocking assignments. Keep that baseline unchanged. For extra tests, drive away from the sampling edge to avoid stimulus races.

## Additional checks after implementation

- [ ] Reset during a transfer, with an explicit expected cancellation policy.
- [ ] Reset between transfers and transfer again.
- [ ] Back-to-back requests obey ready.
- [ ] Try other clock ratios/phases in a separate testbench.
- [ ] Compile in Quartus and review unconnected ports, unintended latches, and clock warnings. The specified data-holding latch is intentional.
- [ ] Save readable full-transfer and close-up waveforms, transcript, resource screenshot, tool versions, and source commit.

No functional checks are marked passed by this setup checklist. Digital simulation also does not model analog metastability resolution.
