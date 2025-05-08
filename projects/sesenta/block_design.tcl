# required TCL dependencies
source $board_path/config/ports.tcl
source $board_path/base_system.tcl
# Add PS and AXI Interconnect
# set board_preset $board_path/config/board_preset.tcl
# set board_preset $board_path/config/board_preset_old_current_commit.tcl
# set board_preset $board_path/config/board_preset_rp2.tcl
# set board_preset $board_path/config/board_preset_orig_60.tcl
# set board_preset $board_path/config/board_preset_orig.tcl
# set board_preset $board_path/config/board_preset.tcl
# source $sdk_path/fpga/lib/starting_point.tcl
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
# connect_port_pin rst_regs [ctl_pin rst_regs]

connect_pins ps_0/S_AXI_HP0_ACLK $mics_clk
connect_pins ps_0/S_AXI_HP1_ACLK $mics_clk

#config interconnect 1
 cell xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon_1 {
    NUM_MI 1
    NUM_SI 1
    ENABLE_ADVANCED_OPTIONS 1
    SYNCHRONIZATION_STAGES 4
    CONFIG.STRATEGY 1
  } {
    ARESETN proc_sys_reset_adc_clk/peripheral_aresetn
    S00_ARESETN proc_sys_reset_adc_clk/peripheral_aresetn
    M00_ARESETN proc_sys_reset_adc_clk/peripheral_aresetn
    ACLK $mics_clk
    S00_ACLK $mics_clk
    M00_ACLK $mics_clk
    M00_AXI ps_0/S_AXI_HP0
   
  }
cell xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon_2 {
  NUM_MI 1
  NUM_SI 1
  ENABLE_ADVANCED_OPTIONS 1
  SYNCHRONIZATION_STAGES 4
  CONFIG.STRATEGY 1
} {
  ARESETN proc_sys_reset_adc_clk/peripheral_aresetn
  S00_ARESETN proc_sys_reset_adc_clk/peripheral_aresetn
  M00_ARESETN proc_sys_reset_adc_clk/peripheral_aresetn
  ACLK $mics_clk
  S00_ACLK $mics_clk
  M00_ACLK $mics_clk
  M00_AXI ps_0/S_AXI_HP1

}

# config interconnect 0
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {4}] [get_bd_cells axi_mem_intercon_0]
connect_pins axi_mem_intercon_0/M02_ACLK    $mics_clk
connect_pins axi_mem_intercon_0/M02_ARESETN proc_sys_reset_adc_clk/peripheral_aresetn
connect_pins axi_mem_intercon_0/M03_ACLK    $mics_clk
connect_pins axi_mem_intercon_0/M03_ARESETN proc_sys_reset_adc_clk/peripheral_aresetn
# set_property -dict [list CONFIG.XBAR_DATA_WIDTH {64} CONFIG.S00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {1}] [get_bd_cells axi_mem_intercon_1]

  #  strobe pulser_0/f1start20
cell pavel-demin:user:axis_var:1.0 lockins_0 {
   AXIS_TDATA_WIDTH 512
} {
   aclk $mics_clk
   strobe mics_data_valid
   aresetn proc_sys_reset_adc_clk/peripheral_aresetn
   cfg_data mics
}
cell pavel-demin:user:axis_var:1.0 lockins_1 {
   AXIS_TDATA_WIDTH 512
} {
   aclk $mics_clk
   strobe mics_data_valid
   aresetn proc_sys_reset_adc_clk/peripheral_aresetn
   cfg_data mics2
}


cell koheron:user:tlast_gen_dyn_gated:1.0 tlast_gen_0 {
  TDATA_WIDTH 512
} {
  enable [get_slice_pin [ctl_pin dma_gate] 0 0 enable_tlast]
  cfg_data [ctl_pin n_samples]
  aclk $mics_clk
  resetn proc_sys_reset_adc_clk/peripheral_aresetn
  s_axis lockins_0/m_axis
}

cell koheron:user:tlast_gen_dyn_gated:1.0 tlast_gen_1 {
  TDATA_WIDTH 512
} {
  enable [get_slice_pin [ctl_pin dma_gate] 0 0 enable_tlast]
  cfg_data [ctl_pin n_samples]
  aclk $mics_clk
  resetn proc_sys_reset_adc_clk/peripheral_aresetn
  s_axis lockins_1/m_axis
}

  # LOGIC ANALIZER DEBUG
cell xilinx.com:ip:axi_dma:7.1 axi_dma_0 {
  c_include_sg 0
  c_include_mm2s 0
  c_sg_include_stscntrl_strm 0
  c_sg_length_width 23
  c_s2mm_burst_size 64
} {
  S_AXIS_S2MM tlast_gen_0/m_axis
  S_AXI_LITE axi_mem_intercon_0/M02_AXI
  s_axi_lite_aclk $mics_clk
  M_AXI_S2MM axi_mem_intercon_1/S00_AXI
  m_axi_s2mm_aclk $mics_clk
  axi_resetn proc_sys_reset_adc_clk/peripheral_aresetn
}
cell xilinx.com:ip:axi_dma:7.1 axi_dma_1 {
  c_include_sg 0
  c_include_mm2s 0
  c_sg_include_stscntrl_strm 0
  c_sg_length_width 23
  c_s2mm_burst_size 64
} {
  S_AXIS_S2MM tlast_gen_1/m_axis
  S_AXI_LITE axi_mem_intercon_0/M03_AXI
  s_axi_lite_aclk $mics_clk
  M_AXI_S2MM axi_mem_intercon_2/S00_AXI
  m_axi_s2mm_aclk $mics_clk
  axi_resetn proc_sys_reset_adc_clk/peripheral_aresetn
}

# set_property -dict [list CONFIG.S00_HAS_REGSLICE {4} CONFIG.S00_HAS_DATA_FIFO {1}] [get_bd_cells axi_mem_intercon_1]
# set_property -dict [list CONFIG.M00_HAS_REGSLICE {4} CONFIG.M01_HAS_REGSLICE {4} CONFIG.M00_HAS_DATA_FIFO {1} CONFIG.M01_HAS_DATA_FIFO {1}] [get_bd_cells axi_mem_intercon_0]
assign_bd_address [get_bd_addr_segs {axi_dma_0/S_AXI_LITE/Reg }]
set_property range [get_memory_range dma] [get_bd_addr_segs {ps_0/Data/SEG_axi_dma_0_Reg}]
set_property offset [get_memory_offset dma] [get_bd_addr_segs {ps_0/Data/SEG_axi_dma_0_Reg}]

assign_bd_address [get_bd_addr_segs {axi_dma_1/S_AXI_LITE/Reg }]
set_property range [get_memory_range dma1] [get_bd_addr_segs {ps_0/Data/SEG_axi_dma_1_Reg}]
set_property offset [get_memory_offset dma1] [get_bd_addr_segs {ps_0/Data/SEG_axi_dma_1_Reg}]

assign_bd_address [get_bd_addr_segs {ps_0/S_AXI_HP0/HP0_DDR_LOWOCM }]
set_property range [get_memory_range ram] [get_bd_addr_segs {axi_dma_0/Data_S2MM/SEG_ps_0_HP0_DDR_LOWOCM}]
set_property offset [get_memory_offset ram] [get_bd_addr_segs {axi_dma_0/Data_S2MM/SEG_ps_0_HP0_DDR_LOWOCM}]

assign_bd_address [get_bd_addr_segs {ps_0/S_AXI_HP1/HP1_DDR_LOWOCM }]
set_property range [get_memory_range ram2] [get_bd_addr_segs {axi_dma_1/Data_S2MM/SEG_ps_0_HP1_DDR_LOWOCM}]
set_property offset [get_memory_offset ram2] [get_bd_addr_segs {axi_dma_1/Data_S2MM/SEG_ps_0_HP1_DDR_LOWOCM}]

delete_bd_objs [get_bd_addr_segs -excluded axi_dma_0/Data_S2MM/SEG_axi_dma_0_Reg]
delete_bd_objs [get_bd_addr_segs ps_0/Data/SEG_ps_0_HP0_DDR_LOWOCM]

delete_bd_objs [get_bd_addr_segs -excluded axi_dma_1/Data_S2MM/SEG_axi_dma_1_Reg]
delete_bd_objs [get_bd_addr_segs ps_0/Data/SEG_ps_0_HP1_DDR_LOWOCM]


set obj [get_filesets sources_1]
set_property -name "top" -value "sesenta" -objects $obj
