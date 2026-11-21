# GUI use: do wave.do
onerror {abort}
set sim_dir [pwd]
do [file join $sim_dir compile.do]
vsim -voptargs=+acc work.handshake_synchronizer_testbench
log -r /*
view wave
do [file join $sim_dir signals.do]
run 10 us
wave zoom full
puts "Inspect transfers manually. A completed run is not a passing test."
