# required TCL dependencies
source $board_path/config/ports.tcl
source $board_path/base_system.tcl
source $sdk_path/fpga/lib/bram.tcl
source $sdk_path/projects/sesenta/amd.tcl
connect_port_pin trig0 [ctl_pin trig0]
connect_port_pin trig1 [ctl_pin trig1]
connect_port_pin trig2 [ctl_pin trig2]

connect_pins FCLK_CLK0 $mics_clk
connect_pins FCLK_CLK1 $leds_clk
connect_pins peripheral_aresetn $rst0_name/peripheral_aresetn
add_bram mic1
add_bram mic2
add_bram mic3
add_bram mic4
add_bram mic5
add_bram mic6
add_bram mic7
add_bram mic8

for {set i 1} {$i < 9} {incr i} {
  connect_cell blk_mem_gen_mic$i {
    addrb addrb$i
    clkb $mics_clk
    dinb dinb$i
    enb [get_constant_pin 1 1]
    rstb [get_constant_pin 0 1]
    web web$i
  }
}

set obj [get_filesets sources_1]
set_property -name "top" -value "sesenta_top" -objects $obj