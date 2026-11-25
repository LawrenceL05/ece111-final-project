# compile the SHA-256 design and the supplied testbench
# run this from the sha256/sim folder:  do compile.do
set sim_dir [pwd]
if {![file isdirectory work]} {vlib work}
vmap work work
vlog -sv [file join $sim_dir .. rtl simplified_sha256.sv]
vlog -sv [file join $sim_dir .. tb tb_simplified_sha256.sv]
