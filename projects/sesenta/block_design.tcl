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
# add_bram mic1
# add_bram mic2
# add_bram mic3
# add_bram mic4
# add_bram mic5
# add_bram mic6
# add_bram mic7
# add_bram mic8

# for {set i 1} {$i < 9} {incr i} {
#   connect_cell blk_mem_gen_mic$i {
#     addrb addrb$i
#     clkb $mics_clk
#     dinb dinb$i
#     enb [get_constant_pin 1 1]
#     rstb [get_constant_pin 0 1]
#     web web$i
#   }
# }
connect_pins ps_0/S_AXI_HP0_ACLK pll/clk_out1

#config interconnect 1
 cell xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon_1 {
    NUM_MI 1
    NUM_SI 1
    ENABLE_ADVANCED_OPTIONS 1
    SYNCHRONIZATION_STAGES 4
    CONFIG.STRATEGY 1
  } {
    ARESETN $rst0_name/peripheral_aresetn
    S00_ARESETN $rst0_name/peripheral_aresetn
    M00_ARESETN $rst0_name/peripheral_aresetn
    ACLK $mics_clk
    S00_ACLK $mics_clk
    M00_ACLK $mics_clk
    M00_AXI ps_0/S_AXI_HP0
   
  }

# config interconnect 0
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {3}] [get_bd_cells axi_mem_intercon_0]
# set_property -dict [list CONFIG.STRATEGY {0} CONFIG.M02_HAS_DATA_FIFO {0}] [get_bd_cells axi_mem_intercon_1]
connect_pins axi_mem_intercon_0/M02_ACLK    $mics_clk
connect_pins axi_mem_intercon_0/M02_ARESETN $rst0_name/peripheral_aresetn


 cell quantune:user:buffer_simple:1.0 buff_locks_0 {
  BRAM_DATA_WIDTH 256
  } {
    aresetn $rst0_name/peripheral_aresetn
    aclk $mics_clk
    input_signal mics
  }

cell pavel-demin:user:axis_variable:1.0 lockins_0 {
   AXIS_TDATA_WIDTH 256
} {
   aclk $mics_clk
   aresetn $rst0_name/peripheral_aresetn
   cfg_data buff_locks_0/output_signal1
}

cell koheron:user:tlast_gen_dyn:1.0 tlast_gen_0 {
  TDATA_WIDTH 256
} {
  cfg_data [ctl_pin n_samples]
  aclk $mics_clk
  resetn $rst0_name/peripheral_aresetn
  s_axis lockins_0/M_AXIS
}
  # LOGIC ANALIZER DEBUG
cell xilinx.com:ip:axi_dma:7.1 axi_dma_0 {
  c_include_sg 0
  c_include_mm2s 0
  c_sg_include_stscntrl_strm 0
  c_sg_length_width 23
  c_s2mm_burst_size 16
} {
  S_AXIS_S2MM tlast_gen_0/m_axis
  S_AXI_LITE axi_mem_intercon_0/M02_AXI
  s_axi_lite_aclk $mics_clk
  M_AXI_S2MM axi_mem_intercon_1/S00_AXI
  m_axi_s2mm_aclk $mics_clk
  axi_resetn $rst0_name/peripheral_aresetn
}
# set props_axi1 [list CONFIG.M00_HAS_REGSLICE {4}]
# set_property -dict $props_axi1 [get_bd_cells axi_mem_intercon_1]

# assign_bd_address [get_bd_addr_segs {axi_dma_0/S_AXI_LITE/Reg }]
# set_property range [get_memory_range dma] [get_bd_addr_segs {ps_0/Data/SEG_axi_dma_0_Reg}]
# set_property offset [get_memory_offset dma] [get_bd_addr_segs {ps_0/Data/SEG_axi_dma_0_Reg}]

# # delete_bd_objs [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_axi_ps_control_register_reg0]


# assign_bd_address [get_bd_addr_segs {ps_0/S_AXI_HP0/HP0_DDR_LOWOCM }]
# set_property range [get_memory_range ram] [get_bd_addr_segs {axi_dma_0/Data_S2MM/SEG_ps_0_HP0_DDR_LOWOCM}]
# set_property offset [get_memory_offset ram] [get_bd_addr_segs {axi_dma_0/Data_S2MM/SEG_ps_0_HP0_DDR_LOWOCM}]

# delete_bd_objs [get_bd_addr_segs -excluded axi_dma_0/Data_S2MM/SEG_axi_dma_0_Reg]
# delete_bd_objs [get_bd_addr_segs ps_0/Data/SEG_ps_0_HP0_DDR_LOWOCM]

set obj [get_filesets sources_1]
set_property -name "top" -value "sesenta_top" -objects $obj