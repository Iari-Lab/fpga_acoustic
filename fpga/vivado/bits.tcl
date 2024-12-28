set xpr_filename [lindex $argv 0]
set bit_filename [lindex $argv 1]
set nCPU [lindex $argv 2]

open_project $xpr_filename


if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
  set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
  set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
  launch_runs impl_1 -to_step write_bitstream -jobs $nCPU
  wait_on_run impl_1
} 


