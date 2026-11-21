# Batch use: vsim -c -do run.do
onerror {quit -code 1 -f}
set sim_dir [pwd]
do [file join $sim_dir compile.do]
transcript file [file join $sim_dir batch-transcript.txt]
vsim -voptargs=+acc work.handshake_synchronizer_testbench
log -r /*
# The supplied testbench has neither $finish nor a self-checker.
run 10 us
puts "SETUP RUN COMPLETE: 10 us elapsed. This is NOT a functional pass."
puts "Compare all four destination words and the verification checklist."
quit -code 0 -f
