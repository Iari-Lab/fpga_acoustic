# required TCL dependencies
source $board_path/config/ports.tcl
source $board_path/base_system.tcl
source $sdk_path/fpga/lib/bram.tcl
source $sdk_path/projects/sesenta/amd.tcl
# connect_pins FCLK_CLK0 $mics_clk
# connect_pins FCLK_CLK1 $mics_clk
# connect_pins peripheral_aresetn proc_sys_reset_adc_clk/peripheral_aresetn

connect_pins FCLK_CLK0 $mics_clk
connect_port_pin reset proc_sys_reset_adc_clk/peripheral_aresetn

# Add control and status registers
# source $sdk_path/fpga/lib/ctl_sts.tcl
# add_ctl_sts $mics_clk proc_sys_reset_adc_clk/peripheral_aresetn

# source $sdk_path/projects/sesenta/amd.tcl
# connect_pins mic_sel [get_slice_pin [ctl_pin mic_select] 6 0 mic_sel_pin]
connect_pins led_color [get_slice_pin [ctl_pin led_select] 0 0 led_color_pin]

connect_pins led_sel [get_slice_pin [ctl_pin led_select] 8 1 led_sel_pin]

set mic_width 16
set micsn 8
for {set i 0} {$i < $micsn} {incr i} {
  add_bram mic$i
}

cell iari:user:addr_counter:1.0 addr_counter_0 {
  ADDR_WIDTH 12
} {
  clk $mics_clk
  enable beam_valid
  start [get_slice_pin [ctl_pin start_capture] 0 0 start]
  done [sts_pin done_capture]
}

# cell xilinx.com:ip:system_ila:1.1 sila_3 {
#     C_PROBE0_WIDTH 1
#     C_PROBE1_WIDTH 7
#     C_DATA_DEPTH 16384
#     C_NUM_OF_PROBES 2
#     C_EN_STRG_QUAL 1
#     C_ADV_TRIGGER false
#     ALL_PROBE_SAME_MU_CNT 2
#     C_MON_TYPE NATIVE
#     C_PROBE_WIDTH_PROPAGATION MANUAL
# } {
#     clk $mics_clk
#     probe0 led_color_pin/Dout
#     probe1 led_sel_pin/Dout

# }
# for {set i 0} {$i < $micsn} {incr i} {
#   set from  [expr ($i + 1) * $mic_width - 1]
#   set to    [expr $i * $mic_width]

#   cell xilinx.com:ip:c_accum:12.0 c_accum_$i {
#       INPUT_WIDTH 20
#       OUTPUT_WIDTH 32
#       INPUT_TYPE Signed
#       Input_Type.VALUE_SRC USER
#       LATENCY_CONFIGURATION Automatic
#       CE true
#       BYPASS false
#       SCLR true
#   } {
#       clk $mics_clk
#       B [get_slice_pin mics $from $to]
#       CE beam_valid
#       SCLR start/Dout
#   }

#   connect_cell blk_mem_gen_mic$i {
#     addrb addr_counter_0/addr
#     clkb $mics_clk
#     dinb c_accum_$i/Q
#     enb [get_constant_pin 1 1]
#     rstb [get_constant_pin 0 1]
#     web addr_counter_0/write_en
#   }
# }


# addrb addr_counter_0/addr
for {set i 0} {$i < $micsn} {incr i} {
  set from  [expr ($i + 1) * $mic_width - 1]
  set to    [expr $i * $mic_width]

  cell iari:user:signe:1.0 sign_$i {
    IN_WIDTH $mic_width
    OUT_WIDTH 32
  } {
    in_1 [get_slice_pin mics $from $to]
  }
  connect_cell blk_mem_gen_mic$i {
    addrb addr_counter_0/addr
    clkb $mics_clk
    dinb sign_$i/out_1
    enb [get_constant_pin 1 1]
    rstb [get_constant_pin 0 1]
    web addr_counter_0/write_en
  }
}

import_files -norecurse $sdk_path/projects/sesenta/delay_tap_lut.mem
set obj [get_filesets sources_1]
set_property -name "top" -value "sesenta" -objects $obj
