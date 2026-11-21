# Run from handshake/sim. Use Tcl path objects so spaces work.
set sim_dir [pwd]
cd $sim_dir
if {![file isdirectory work]} {vlib work}
vmap work work
foreach name {flipflop_synchronizer sender_fsm receiver_fsm handshake_synchronizer} {
    vlog -sv [file join $sim_dir .. rtl ${name}.sv]
}
vlog -sv [file join $sim_dir .. tb handshake_synchronizer_testbench.sv]
