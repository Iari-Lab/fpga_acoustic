
# Add PS and AXI Interconnect
set board_preset $board_path/config/board_preset.tcl
source $sdk_path/fpga/lib/starting_point.tcl

# Add processor system reset synchronous to adc clock

# Rename clocks
 cell xilinx.com:ip:clk_wiz:5.4 pll {
    PRIMITIVE              PLL
    PRIM_IN_FREQ.VALUE_SRC USER
    PRIM_IN_FREQ           125.0
    CLKOUT1_USED true CLKOUT1_REQUESTED_OUT_FREQ 125.0
    USE_RESET false
  } {
    clk_in1 $ps_clk0
}

set eclk pll/clk_out1

cell xilinx.com:ip:proc_sys_reset:5.0 erst {} {
  ext_reset_in $ps_name/FCLK_RESET0_N
  slowest_sync_clk $eclk
}

# Add control and status registers
source $sdk_path/fpga/lib/ctl_sts.tcl
add_ctl_sts $eclk erst/peripheral_aresetn

# Connect LEDs

# Add XADC
# source $sdk_path/fpga/lib/xadc.tcl
# add_xadc xadc
