# batch run of the supplied self-checking testbench (no waveform window)
# run from the sha256/sim folder:  vsim -c -do run.do
# the transcript (hash compare + cycle count) is saved to sha256-transcript.txt
onbreak {resume}
onerror {quit -code 1 -f}
set sim_dir [pwd]
do [file join $sim_dir compile.do]
transcript file [file join $sim_dir sha256-transcript.txt]
vsim -voptargs=+acc work.tb_simplified_sha256
# the testbench ends with $stop after it compares all 8 hash words
run -all
quit -f
