set display_name {Signal filter}


set core [ipx::current_core]

set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core
set_property VENDOR {sesenta} $core
set_property VENDOR_DISPLAY_NAME {sesenta} $core
set_property COMPANY_URL {http://www.sesenta.com} $core

# create_ip -name mult_gen -vendor xilinx.com -library ip -version 12.0 -module_name IQ_Multiplier
# report_property [get_ips IQ_Multiplier]

# # set_property -dict [list CONFIG.PortAType {Signed} CONFIG.PortAWidth  {18} CONFIG.PortBType {Signed} CONFIG.PortBWidth  {18}][get_ips IQ_Multiplier]
# set_property -dict [list CONFIG.PortAType Signed CONFIG.PortAWidth 18 CONFIG.PortBType Signed CONFIG.PortBWidth 18] [get_ips IQ_Multiplier]

# # Configure the IP properties
# # set_property -dict [list CONFIG.Component_Name {mult_gen_0} 
# #   PORTATYPE.VALUE_SRC {USER}
# #   PORTAWIDTH.VALUE_SRC {USER}
# #   PORTBTYPE.VALUE_SRC {USER}
# #   PORTBWIDTH.VALUE_SRC {USER}
# #   PORTATYPE {Unsigned}
# #   PORTAWIDTH {40}
# #   PORTBTYPE {Unsigned}
# #   PORTBWIDTH {16}
# #   USE_CUSTOM_OUTPUT_WIDTH {true}
# #   OUTPUTWIDTHHIGH {47}
# #   OUTPUTWIDTHLOW {16}
# #   MULTIPLIER_CONSTRUCTION {Use_Mults}] [get_ips IQ_Multiplier]
# # set_property -dict [list CONFIG.C_USE_DSP48 {1} CONFIG.C_Mult_Mode {0} CONFIG.C_HW {0} CONFIG.C_INPUT_WIDTH {14} CONFIG.C_INPUT2_WIDTH {14} CONFIG.C_OUTPUT_WIDTH {28}] [get_ips IQ_Multiplier]
# generate_target all [get_ips IQ_Multiplier]

# Update hierarchy to propagate the changes
# update_ip_catalog



