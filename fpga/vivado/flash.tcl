set bit_filename [lindex $argv 0]
open_hw_manager
update_compile_order -fileset sources_1
connect_hw_server -allow_non_jtag
open_hw_target
current_hw_device [get_hw_devices xc7z010_1]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7z010_1] 0]
set_property PROBES.FILE {} [get_hw_devices xc7z010_1]
set_property FULL_PROBES.FILE {} [get_hw_devices xc7z010_1]
set_property PROGRAM.FILE $bit_filename [get_hw_devices xc7z010_1]
program_hw_devices [get_hw_devices xc7z010_1]
refresh_hw_device [lindex [get_hw_devices xc7z010_1] 0]