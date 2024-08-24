# required TCL dependencies
source $board_path/config/ports.tcl
source $board_path/base_system.tcl
source $sdk_path/fpga/lib/bram.tcl
source $sdk_path/projects/sesenta/amd.tcl
connect_port_pin trig0 [ctl_pin trig0]
connect_port_pin trig1 [ctl_pin trig1]

connect_pins FCLK_CLK0 $ps_name/FCLK_CLK0
connect_pins peripheral_aresetn $rst0_name/peripheral_aresetn
add_bram mic1
add_bram mic2
add_bram mic3
add_bram mic4
add_bram mic5
add_bram mic6
add_bram mic7
add_bram mic8

# # Add a counter for BRAM addressing
# cell koheron:user:address_counter:1.0 address_counter_0 {
#   COUNT_WIDTH [get_memory_addr_width mic]
# } {
#   rst [get_slice_pin [ctl_pin trig0] 0 0]
#   clk $eclk
# }
# cell sesenta:user:pdm_mic:1.0 mic_0 {} {
#     clk $eclk
#     rst [get_slice_pin [ctl_pin trig1] 0 0]
#     M_DATA M1_DATA
# }

# cell sesenta:user:buffer:1.0 buff_0 {
# } {
#     clk $eclk
#     input_signal2 mic_0/M_CLK
#     input_signal1 mic_0/mic_data
#     output_signal2 M1_CLK
# }


# cell xilinx.com:ip:system_ila:1.1 sila_2 {
#     C_PROBE0_WIDTH 32 
#     C_PROBE1_WIDTH 1
#     C_PROBE2_WIDTH 32 
#     C_PROBE3_WIDTH 4
#     C_DATA_DEPTH 4096
#     C_NUM_OF_PROBES 4
#     C_EN_STRG_QUAL 1 
#     C_ADV_TRIGGER true
#     ALL_PROBE_SAME_MU_CNT 2 
#     C_MON_TYPE NATIVE 
#     C_PROBE_WIDTH_PROPAGATION MANUAL 
# } {
#     clk $ps_name/FCLK_CLK0
#     probe0 buff_0/output_signal3
#     probe1 buff_0/output_signal4
#     probe2 address_counter_0/address_dbg
#     probe3 address_counter_0/wen_dbg
# }

connect_cell blk_mem_gen_mic1 {
  addrb addrb
  clkb $eclk
  dinb dinb1
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web web
}
connect_cell blk_mem_gen_mic2 {
  addrb addrb
  clkb $eclk
  dinb dinb2
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web web
}

connect_cell blk_mem_gen_mic3 {
  addrb addrb
  clkb $eclk
  dinb dinb3
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web web
}

connect_cell blk_mem_gen_mic4 {
  addrb addrb
  clkb $eclk
  dinb dinb4
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web web
}

connect_cell blk_mem_gen_mic5 {
  addrb addrb
  clkb $eclk
  dinb dinb5
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web web
}

connect_cell blk_mem_gen_mic6 {
  addrb addrb
  clkb $eclk
  dinb dinb6
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web web
}

connect_cell blk_mem_gen_mic7 {
  addrb addrb
  clkb $eclk
  dinb dinb7
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web web
}

connect_cell blk_mem_gen_mic8 {
  addrb addrb
  clkb $eclk
  dinb dinb8
  enb [get_constant_pin 1 1]
  rstb [get_constant_pin 0 1]
  web web
}
# create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 BRAMBUFF_PORTB_0
# connect_bd_intf_net [get_bd_intf_ports BRAMBUFF_PORTB_0] [get_bd_intf_pins blk_mem_gen_mic/BRAM_PORTB]




set obj [get_filesets sources_1]
set_property -name "top" -value "sesenta_top" -objects $obj