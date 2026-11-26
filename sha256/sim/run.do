# batch run of the supplied self-checking testbench (no waveform window)
# run from the sha256/sim folder:  vsim -c -do run.do
# the transcript (hash compare + cycle count) is saved to sha256-transcript.txt
onerror {quit -code 1 -f}
set sim_dir [pwd]
do [file join $sim_dir compile.do]
transcript file [file join $sim_dir sha256-transcript.txt]
vsim -voptargs=+acc work.tb_simplified_sha256
# Set the completion flag only when the baseline reaches its final $stop.
set completed 0
onbreak {set completed 1; resume}
run 100 us
if {!$completed} {
    puts stderr "SHA testbench timed out before comparison completed"
    quit -code 1 -f
}
set errors [examine -decimal sim:/tb_simplified_sha256/num_errors]
if {$errors ne "0"} {
    puts stderr "SHA digest comparison failed ($errors errors)"
    quit -code 1 -f
}
quit -code 0 -f
