# GUI run with a waveform for the report screenshot
# run from the sha256/sim folder in the ModelSim GUI:  do wave.do
onbreak {resume}
set sim_dir [pwd]
do [file join $sim_dir compile.do]
vsim -voptargs=+acc work.tb_simplified_sha256
view wave
# show just the signal name (clk, state, h0...) instead of the full /tb_.../ path
config wave -signalnamewidth 1

set tb  /tb_simplified_sha256
set dut /tb_simplified_sha256/simplified_sha256_inst

# control signals
add wave -divider "control"
add wave $tb/clk
add wave $tb/reset_n
add wave $tb/start
add wave $tb/done
add wave $dut/state

# memory interface
add wave -divider "memory"
add wave -radix unsigned $tb/mem_addr
add wave $tb/mem_we
add wave -radix hex $tb/mem_read_data
add wave -radix hex $tb/mem_write_data

# counters
add wave -divider "counters"
add wave -radix unsigned $dut/offset
add wave -radix unsigned $dut/j
add wave -radix unsigned $dut/i

# working variables and hash values
add wave -divider "A-H"
add wave -radix hex $dut/a $dut/b $dut/c $dut/d $dut/e $dut/f $dut/g $dut/h
add wave -divider "H0-H7"
add wave -radix hex $dut/h0 $dut/h1 $dut/h2 $dut/h3 $dut/h4 $dut/h5 $dut/h6 $dut/h7

run -all
wave zoom full
