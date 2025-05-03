set project_name [lindex $argv 0]
set project_path [lindex $argv 1]
# Open hardware manager
open_hw_manager

connect_hw_server -allow_non_jtag

# Open hardware target
open_hw_target

# Set the current hardware devce (adjust if necessary based on your FPGA part)
current_hw_device [get_hw_devices xc7z010_1]

# Refresh the hardware device and update hardware probes

# Dynamically retrieve the project name

# Define the paths for the bitstream and LTX files dynamically

set ltx_file  $project_path/$project_name.runs/impl_1/sesenta.ltx
set full_bit_filename "$project_path/$project_name.runs/impl_1/sesenta.bit"
puts "ltx_file: $ltx_file"
puts "full_bit_filename: $full_bit_filename"

set_property PROBES.FILE $ltx_file [get_hw_devices xc7z010_1]
set_property FULL_PROBES.FILE $ltx_file [get_hw_devices xc7z010_1]
refresh_hw_device -update_hw_probes true [lindex [get_hw_devices xc7z010_1] 0]


# Set the probe file path

# Set the bitstream file to be programmed
set_property PROGRAM.FILE $full_bit_filename  [get_hw_devices xc7z010_1]

# Program the FPGA with the specified bitstream
program_hw_devices [get_hw_devices xc7z010_1]

# Refresh the hardware device to ensure the probes are active
refresh_hw_device [lindex [get_hw_devices xc7z010_1] 0]


