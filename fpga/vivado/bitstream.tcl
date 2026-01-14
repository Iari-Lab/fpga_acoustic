set xpr_filename [lindex $argv 0]
set bit_filename [lindex $argv 1]
set nCPU [lindex $argv 2]
set enable_compress 1
# set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
# set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
# set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE PerformanceOptimized [get_runs synth_1]
open_project $xpr_filename
if {$enable_compress} {
  if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
    set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
    launch_runs impl_1 -to_step write_bitstream -jobs $nCPU
    wait_on_run impl_1
  }

  open_run [get_runs impl_1]

report_utilization
report_timing
report_power

set util [report_utilization -return_string]
set util_lut [exec echo $util | grep LUT | head -n 1 | cut -d| -f3 | tr -d " "]

#set util_lut [llength [get_cells -hier -filter {PRIMITIVE_TYPE =~ *LUT*}]]
set util_ff [llength [get_cells -hier -filter {PRIMITIVE_TYPE =~ *.F*E*}]]
set util_dsp [llength [get_cells -hier -filter {PRIMITIVE_GROUP == DSP}]]
set util_bram [llength [get_cells -hier -filter {PRIMITIVE_TYPE =~ *BRAM*}]]
#set time_wns [get_property STATS.WNS [current_run]]
set time_wns [get_property SLACK [get_timing_paths]]

puts "LUT: $util_lut FF: $util_ff DSP: $util_dsp BRAM: $util_bram"

set fp [open res.txt w]
puts $fp "LUT=$util_lut"
puts $fp "FF=$util_ff"
puts $fp "DSP=$util_dsp"
puts $fp "BRAM=$util_bram"
puts $fp "WNS=$time_wns"
close $fp

  set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
  set_property BITSTREAM.GENERAL.XADCENHANCEDLINEARITY On [current_design]

  write_bitstream -force -file $bit_filename

  close_project
} else {
  if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
    set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
    launch_runs impl_1 -to_step write_bitstream -jobs $nCPU
    wait_on_run impl_1
  }
}
