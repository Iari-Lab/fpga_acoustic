# required TCL dependencies
source $board_path/config/ports.tcl
source $board_path/base_system.tcl
# Add PS and AXI Interconnect
source $sdk_path/projects/sesenta/amd.tcl

connect_pins FCLK_CLK0 $mics_clk
connect_port_pin reset proc_sys_reset_adc_clk/peripheral_aresetn




connect_pins ps_0/S_AXI_HP0_ACLK $mics_clk

#config interconnect 1
    # CONFIG.XBAR_DATA_WIDTH 512
    # CONFIG.S00_HAS_DATA_FIFO 2
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

# config interconnect 0
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {3}] [get_bd_cells axi_mem_intercon_0]
connect_pins axi_mem_intercon_0/M02_ACLK    $mics_clk
connect_pins axi_mem_intercon_0/M02_ARESETN proc_sys_reset_adc_clk/peripheral_aresetn

cell pavel-demin:user:axis_var:1.0 mics_0 {
   AXIS_TDATA_WIDTH 512
} {
   aclk $mics_clk
   strobe mics_data_valid
   aresetn proc_sys_reset_adc_clk/peripheral_aresetn
   cfg_data mics
}


cell koheron:user:tlast_gen_dyn_gated:1.0 tlast_gen_0 {
  TDATA_WIDTH 512
} {
  enable [get_slice_pin [ctl_pin dma_gate] 0 0 enable_tlast]
  cfg_data [ctl_pin n_samples]
  aclk $mics_clk
  resetn proc_sys_reset_adc_clk/peripheral_aresetn
  s_axis mics_0/m_axis
}




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
