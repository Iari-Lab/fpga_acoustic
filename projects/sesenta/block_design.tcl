# required TCL dependencies
source $board_path/config/ports.tcl

# Add PS and AXI Interconnect
set board_preset $board_path/config/board_preset.tcl
# set board_preset $board_path/config/board_preset_orig2.tcl
source $sdk_path/fpga/lib/starting_point.tcl

connect_pins FCLK_CLK0 $ps_clk0
connect_pins FCLK_CLK1 $ps_clk0
connect_pins peripheral_aresetn $rst0_name/peripheral_aresetn




# Add control and status registers
source $sdk_path/fpga/lib/ctl_sts.tcl
add_ctl_sts $ps_clk0 $rst0_name/peripheral_aresetn

source $sdk_path/projects/sesenta/amd.tcl
connect_port_pin rst_regs [ctl_pin rst_regs]

connect_pins ps_0/S_AXI_HP0_ACLK $ps_clk0

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
    ACLK $ps_clk0
    S00_ACLK $ps_clk0
    M00_ACLK $ps_clk0
    M00_AXI ps_0/S_AXI_HP0
   
  }

# config interconnect 0
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {3}] [get_bd_cells axi_mem_intercon_0]
connect_pins axi_mem_intercon_0/M02_ACLK    $ps_clk0
connect_pins axi_mem_intercon_0/M02_ARESETN $rst0_name/peripheral_aresetn



#  for {set i 0} {$i < 8} {incr i} {
#     set from [expr 31+$i*32]
#     set to   [expr $i*32]
#   }

cell pavel-demin:user:axis_variable:1.0 mics_0 {
   AXIS_TDATA_WIDTH 256
} {
   aclk $ps_clk0
   aresetn $rst0_name/peripheral_aresetn
   cfg_data mics
}

cell sesenta:user:axis_tlast:1.0 tlast_0 {
  TDATA_WIDTH 256
} {
  enable [get_slice_pin [ctl_pin rst_regs] 3 3 enable_tlast]
  cfg_data [ctl_pin n_samples]
  aclk $ps_clk0
  resetn $rst0_name/peripheral_aresetn
  s_axis mics_0/M_AXIS
}

# cell xilinx.com:ip:system_ila:1.1 ila_axis {
#     C_SLOT_0_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0}
#     C_DATA_DEPTH 4096
#     C_NUM_OF_PROBES 1
#     C_MON_TYPE MIX
#     C_NUM_MONITOR_SLOTS 1
#   } {
#     probe0 enable_tlast/Dout
#     clk $ps_clk0
#     SLOT_0_AXI axi_mem_intercon_1/S00_AXI
#     resetn $rst0_name/peripheral_aresetn
# }

  # LOGIC ANALIZER DEBUG
cell xilinx.com:ip:axi_dma:7.1 axi_dma_0 {
  c_include_sg 0
  c_include_mm2s 0
  c_sg_include_stscntrl_strm 0
  c_sg_length_width 23
  c_s2mm_burst_size 64
} {
  S_AXIS_S2MM tlast_0/m_axis
  S_AXI_LITE axi_mem_intercon_0/M02_AXI
  s_axi_lite_aclk $ps_clk0
  M_AXI_S2MM axi_mem_intercon_1/S00_AXI
  m_axi_s2mm_aclk $ps_clk0
  axi_resetn $rst0_name/peripheral_aresetn
}

set_property -dict [list CONFIG.S00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {1}] [get_bd_cells axi_mem_intercon_1]
set_property -dict [list CONFIG.M00_HAS_REGSLICE {4} CONFIG.M01_HAS_REGSLICE {4} CONFIG.M00_HAS_DATA_FIFO {1} CONFIG.M01_HAS_DATA_FIFO {1}] [get_bd_cells axi_mem_intercon_0]
assign_bd_address [get_bd_addr_segs {axi_dma_0/S_AXI_LITE/Reg }]
set_property range [get_memory_range dma] [get_bd_addr_segs {ps_0/Data/SEG_axi_dma_0_Reg}]
set_property offset [get_memory_offset dma] [get_bd_addr_segs {ps_0/Data/SEG_axi_dma_0_Reg}]


assign_bd_address [get_bd_addr_segs {ps_0/S_AXI_HP0/HP0_DDR_LOWOCM }]
set_property range [get_memory_range ram] [get_bd_addr_segs {axi_dma_0/Data_S2MM/SEG_ps_0_HP0_DDR_LOWOCM}]
set_property offset [get_memory_offset ram] [get_bd_addr_segs {axi_dma_0/Data_S2MM/SEG_ps_0_HP0_DDR_LOWOCM}]

delete_bd_objs [get_bd_addr_segs -excluded axi_dma_0/Data_S2MM/SEG_axi_dma_0_Reg]
delete_bd_objs [get_bd_addr_segs ps_0/Data/SEG_ps_0_HP0_DDR_LOWOCM]


set obj [get_filesets sources_1]
set_property -name "top" -value "sesenta" -objects $obj
