set project_name [lindex $argv 0]
set project_path [lindex $argv 1]
# Open hardware manager
open_hw_manager

connect_hw_server -allow_non_jtag
set device_name xc7z020_1
open_hw_target
current_hw_device [get_hw_devices $device_name]

# Refresh the hardware device and update hardware probes


# Define the paths for the bitstream and LTX files dynamically

set ltx_file  $project_path/$project_name.runs/impl_1/sesenta.ltx
set full_bit_filename "$project_path/$project_name.runs/impl_1/sesenta.bit"
puts "ltx_file: $ltx_file"
puts "full_bit_filename: $full_bit_filename"


# set_property PROBES.FILE $ltx_file [get_hw_devices $device_name]
# set_property FULL_PROBES.FILE $ltx_file [get_hw_devices $device_name]
# set_property PROBES.FILE $ltx_file [get_hw_devices $device_name]
# set_property FULL_PROBES.FILE $ltx_file [get_hw_devices $device_name]
refresh_hw_device -update_hw_probes true [lindex [get_hw_devices $device_name] 0]
set_property PROGRAM.FILE $full_bit_filename  [get_hw_devices $device_name]
program_hw_devices [get_hw_devices $device_name]
refresh_hw_device [lindex [get_hw_devices $device_name] 0]



