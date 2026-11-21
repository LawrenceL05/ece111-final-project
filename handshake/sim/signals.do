# Run after elaboration. Internal top-level names are in the official template.
set tb sim:/handshake_synchronizer_testbench
add wave -divider {Clocks and resets}
foreach s {src_clk dest_clk src_reset dest_reset} {
    add wave -color Green -label $s $tb/$s
}
add wave -divider {Source transaction}
foreach s {start ready} {add wave -color Green -label $s $tb/$s}
add wave -color Green -radix hexadecimal -label data_in $tb/data_in
add wave -color Green -radix hexadecimal -label data_in_reg $tb/DUT/data_in_reg
add wave -color Green -radix hexadecimal -label held_data $tb/DUT/data
add wave -divider {Four-phase handshake}
foreach s {req_o sync_req_i ack_o sync_ack_i data_out_en data_in_en} {
    add wave -color Green -label $s $tb/DUT/$s
}
add wave -divider {Destination and states}
add wave -color Green -radix hexadecimal -label data_out $tb/data_out
add wave -color Green -label sender_state $tb/DUT/sender_fsm_inst/state
add wave -color Green -label receiver_state $tb/DUT/receiver_fsm_inst/state
configure wave -namecolwidth 185 -valuecolwidth 110 -timelineunits ns
