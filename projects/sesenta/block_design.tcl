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

# config interconnect 0
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {3}] [get_bd_cells axi_mem_intercon_0]
connect_pins axi_mem_intercon_0/M02_ACLK    $mics_clk
connect_pins axi_mem_intercon_0/M02_ARESETN proc_sys_reset_adc_clk/peripheral_aresetn

# cell xilinx.com:ip:c_counter_binary:12.0 count_strobe_0 {
#     Output_Width 12
# } {
#       CLK $mics_clk
# }

# for {set i 0} {$i < 8} {incr i} {
#     cell xilinx.com:ip:c_counter_binary:12.0 count_$i {
#         Output_Width 10
#     } {
#       CLK $mics_clk
#       }
# }
# set left_zeros [get_constant_pin 0 22]

# set mics [get_concat_pin [list \
#    [get_concat_pin { [get_constant_pin 0 22 k0] count_0/Q } c1] \
#    [get_concat_pin { [get_constant_pin 0 22 k1] count_1/Q } c2] \
#    [get_concat_pin { [get_constant_pin 0 22 k2] count_2/Q } c3] \
#    [get_concat_pin { [get_constant_pin 0 22 k3] count_3/Q } c4] \
#    [get_concat_pin { [get_constant_pin 0 22 k4] count_4/Q } c5] \
#    [get_concat_pin { [get_constant_pin 0 22 k5] count_5/Q } c6] \
#    [get_concat_pin { [get_constant_pin 0 22 k6] count_6/Q } c7] \
#    [get_concat_pin { [get_constant_pin 0 22 k7] count_7/Q } c8] \
#   ] mics_list 
# ]
# set mics [get_concat_pin [list \
#    [get_concat_pin { count_0/Q [get_constant_pin 0 22 k0] } c1] \
#    [get_concat_pin { count_1/Q [get_constant_pin 0 22 k1] } c2] \
#    [get_concat_pin { count_2/Q [get_constant_pin 0 22 k2] } c3] \
#    [get_concat_pin { count_3/Q [get_constant_pin 0 22 k3] } c4] \
#    [get_concat_pin { count_4/Q [get_constant_pin 0 22 k4] } c5] \
#    [get_concat_pin { count_5/Q [get_constant_pin 0 22 k5] } c6] \
#    [get_concat_pin { count_6/Q [get_constant_pin 0 22 k6] } c7] \
#    [get_concat_pin { count_7/Q [get_constant_pin 0 22 k7] } c8] \
#   ] mics_list 
# ]

# set mics [get_concat_pin [list \
#    [get_concat_pin { $left_zeros count_0/Q }] \
#    [get_concat_pin { $left_zeros count_1/Q }] \
#    [get_concat_pin { $left_zeros count_2/Q }] \
#    [get_concat_pin { $left_zeros count_3/Q }] \
#    [get_concat_pin { $left_zeros count_4/Q }] \
#    [get_concat_pin { $left_zeros count_5/Q }] \
#    [get_concat_pin { $left_zeros count_6/Q }] \
#    [get_concat_pin { $left_zeros count_7/Q }] \
#   ] mics_list 
# ]
# set mics [get_concat_pin [list \
#    [get_concat_pin [list [get_constant_pin 0 22] count_0/Q ]] \
#    [get_concat_pin [list [get_constant_pin 0 22] count_1/Q ]] \
#    [get_concat_pin [list [get_constant_pin 0 22] count_2/Q ]] \
#    [get_concat_pin [list [get_constant_pin 0 22] count_3/Q ]] \
#    [get_concat_pin [list [get_constant_pin 0 22] count_4/Q ]] \
#    [get_concat_pin [list [get_constant_pin 0 22] count_5/Q ]] \
#    [get_concat_pin [list [get_constant_pin 0 22] count_6/Q ]] \
#    [get_concat_pin [list [get_constant_pin 0 22] count_7/Q ]] \
#   ] mics_list 
# ]

# set mics [get_concat_pin [list \
#    [get_constant_pin 2 32]  \
#    [get_constant_pin 4 32]  \
#    [get_constant_pin 6 32]  \
#    [get_constant_pin 8 32]  \
#    [get_constant_pin 10 32]  \
#    [get_constant_pin 12 32]  \
#    [get_constant_pin 14 32]  \
#    [get_constant_pin 16 32]  
#    ]
# ]
# cell pavel-demin:user:axis_constant:1.0 mics_0 {
#     AXIS_TDATA_WIDTH 256
#   } {
#     cfg_data $mics
#     aclk $mics_clk
#   }
#  for {set i 0} {$i < 8} {incr i} {
#     set from [expr 31+$i*32]
#     set to   [expr $i*32]
#   }

# cell quantune:user:pulser pulser_0 {
#   PULSE_WIDTH_WIDTH 12
#   PULSE_PERIOD_WIDTH 12
# } {
#   clk $mics_clk
#   width [get_constant_pin 20 12]
#   period [get_constant_pin 200 12]
#   rst proc_sys_reset_adc_clk/peripheral_aresetn
# }

  #  strobe pulser_0/f1start20
cell pavel-demin:user:axis_var:1.0 lockins_0 {
   AXIS_TDATA_WIDTH 256
} {
   aclk $mics_clk
   strobe mics_data_valid
   aresetn proc_sys_reset_adc_clk/peripheral_aresetn
   cfg_data mics
}


cell koheron:user:tlast_gen_dyn_gated:1.0 tlast_gen_0 {
  TDATA_WIDTH 256
} {
  enable [get_slice_pin [ctl_pin dma_gate] 0 0 enable_tlast]
  cfg_data [ctl_pin n_samples]
  aclk $mics_clk
  resetn proc_sys_reset_adc_clk/peripheral_aresetn
  s_axis lockins_0/m_axis
}


# cell pavel-demin:user:axis_variable:1.0 mics_0 {
#   AXIS_TDATA_WIDTH 256
# } {
#   aclk $mics_clk
#   aresetn proc_sys_reset_adc_clk/peripheral_aresetn
#   cfg_data $mics
# }

# cell sesenta:user:axis_tlast:1.0 tlast_0 {
#   TDATA_WIDTH 256
# } {
#   enable [get_slice_pin [ctl_pin rst_regs] 3 3 enable_tlast]
#   cfg_data [ctl_pin n_samples]
#   aclk $mics_clk
#   resetn proc_sys_reset_adc_clk/peripheral_aresetn
#   s_axis mics_0/M_AXIS
# }

# cell xilinx.com:ip:system_ila:1.1 ila_axis {
#     C_SLOT_0_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0}
#     C_DATA_DEPTH 4096
#     C_NUM_OF_PROBES 1
#     C_MON_TYPE MIX
#     C_NUM_MONITOR_SLOTS 1
#   } {
#     probe0 enable_tlast/Dout
#     clk $mics_clk
#     SLOT_0_AXI axi_mem_intercon_1/S00_AXI
#     resetn proc_sys_reset_adc_clk/peripheral_aresetn
# }

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
