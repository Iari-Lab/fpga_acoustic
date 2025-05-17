
# Add PS and AXI Interconnect
# test 1 failed
set board_preset $board_path/board_preset_works.tcl

set board_preset $board_path/board_works.tcl

# set board_preset $board_path/config/board_preset_orig2.tcl
# set board_preset $board_path/config/board_preset_rp2.tcl

# set board_preset $board_path/config/board_preset_orig_60.tcl
source $sdk_path/fpga/lib/starting_point.tcl

# # Add ADCs and DACs
# source $sdk_path/fpga/lib/redp_adc_dac.tcl
# set adc_dac_name adc_dac
# add_redp_adc_dac $adc_dac_name

# # Add processor system reset synchronous to adc clock
set rst_adc_clk_name proc_sys_reset_adc_clk
# 
# # Rename clocks
# set adc_clk $adc_dac_name/adc_clk

# cell xilinx.com:ip:proc_sys_reset:5.0 $rst_adc_clk_name {} {
#   ext_reset_in $ps_name/FCLK_RESET0_N
#   slowest_sync_clk $adc_clk
# }

# # Add control and status registers
# source $sdk_path/fpga/lib/ctl_sts.tcl
# add_ctl_sts $adc_clk $rst_adc_clk_name/peripheral_aresetn

# Add processor system reset synchronous to adc clock

# Rename clocks
 cell xilinx.com:ip:clk_wiz:5.4 pll {
    PRIMITIVE              PLL
    PRIM_IN_FREQ.VALUE_SRC USER
    PRIM_IN_FREQ           125.0
    CLKOUT1_USED true CLKOUT1_REQUESTED_OUT_FREQ 125.0
    CLKOUT2_USED true CLKOUT2_REQUESTED_OUT_FREQ 125.0
    USE_RESET false
  } {
    clk_in1 $ps_clk0
}

set mics_clk pll/clk_out1
set leds_clk pll/clk_out2

cell xilinx.com:ip:proc_sys_reset:5.0 $rst_adc_clk_name {} {
  ext_reset_in $ps_name/FCLK_RESET0_N
  slowest_sync_clk $mics_clk
}

# Add control and status registers
source $sdk_path/fpga/lib/ctl_sts.tcl
add_ctl_sts $mics_clk $rst_adc_clk_name/peripheral_aresetn