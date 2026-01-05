# set_property CFGBVS VCCO [current_design]
# set_property CONFIG_VOLTAGE 3.3 [current_design]

# set_property SLEW SLOW [get_ports M1_DATA]
# set_property KEEPER true [get_ports M1_DATA]


# M59 M58 ------------D58

# MCLK0 - IO_B13_LP21 (BANK 13)
set_property IOSTANDARD LVCMOS33 [get_ports SYNC_IN]
set_property PACKAGE_PIN U12 [get_ports SYNC_IN]
# MCLK1 - IO_B34_LP14 (BANK 34)
set_property IOSTANDARD LVCMOS33 [get_ports SYNC_OUT]
set_property PACKAGE_PIN T12 [get_ports SYNC_OUT]

# MCLK2 - IO_B34_LP11 (BANK 34)
# MCLK0 - IO_B13_LP21 (BANK 13)
set_property IOSTANDARD LVCMOS33 [get_ports M0_CLK]
set_property PACKAGE_PIN V11 [get_ports M0_CLK]
# MCLK1 - IO_B34_LP14 (BANK 34)
set_property IOSTANDARD LVCMOS33 [get_ports M1_CLK]
set_property PACKAGE_PIN N20 [get_ports M1_CLK]
# MCLK2 - IO_B34_LP11 (BANK 34)
set_property IOSTANDARD LVCMOS33 [get_ports M2_CLK]
set_property PACKAGE_PIN U14 [get_ports M2_CLK]

# LED_DI - IO_B34_LN23 (BANK 34)
set_property IOSTANDARD LVCMOS33 [get_ports LEDS]
set_property PACKAGE_PIN P18 [get_ports LEDS]

set_property IOSTANDARD LVCMOS33 [get_ports {M_DATA[*]}]
# # M18 - D18 -> M_DATA[0]
# # IO Pin: IO_B34_LP21
# set_property PACKAGE_PIN V17 [get_ports M_DATA[0]]

# # M20 - D20 -> M_DATA[2]
# # IO Pin: IO_B34_LP20
# set_property PACKAGE_PIN T17 [get_ports M_DATA[1]]

# # M22 - D22 -> M_DATA[4]
# # IO Pin: IO_B13_LN13
# set_property PACKAGE_PIN Y6 [get_ports M_DATA[2]]


# # M24 - D24 -> M_DATA[6]
# # IO Pin: IO_B13_LP13
# set_property PACKAGE_PIN Y7 [get_ports M_DATA[3]]

# # M26 - D26 -> M_DATA[8]
# # IO Pin: IO_B13_LP18
# set_property PACKAGE_PIN W11 [get_ports M_DATA[4]]


# # M28 - D28 -> M_DATA[10]
# # IO Pin: IO_B13_LN16
# set_property PACKAGE_PIN W9 [get_ports M_DATA[5]]

# # M30 - D30 -> M_DATA[12]
# # IO Pin: IO_B34_LN15
# set_property PACKAGE_PIN U20 [get_ports M_DATA[6]]

# # M32 - D32 -> M_DATA[14]
# # IO Pin: IO_B34_LN18
# set_property PACKAGE_PIN R17 [get_ports M_DATA[7]]

# # M34 - D34 -> M_DATA[16]
# # IO Pin: IO_B34_LP24
# set_property PACKAGE_PIN P15 [get_ports M_DATA[8]]




# M18 - D18 -> M_DATA[0]
# IO Pin: IO_B34_LP21
set_property PACKAGE_PIN V17 [get_ports M_DATA[0]]

# M20 - D20 -> M_DATA[2]
# IO Pin: IO_B34_LP20
set_property PACKAGE_PIN T17 [get_ports M_DATA[1]]

# M22 - D22 -> M_DATA[4]
# IO Pin: IO_B13_LN13
set_property PACKAGE_PIN Y6 [get_ports M_DATA[2]]

# M24 - D24 -> M_DATA[6]
# IO Pin: IO_B13_LP13
set_property PACKAGE_PIN Y7 [get_ports M_DATA[3]]

# M26 - D26 -> M_DATA[8]
# IO Pin: IO_B13_LP18
set_property PACKAGE_PIN W11 [get_ports M_DATA[4]]

# M28 - D28 -> M_DATA[10]
# IO Pin: IO_B13_LN16
set_property PACKAGE_PIN W9 [get_ports M_DATA[5]]

# M30 - D30 -> M_DATA[12]
# IO Pin: IO_B34_LN15
set_property PACKAGE_PIN U20 [get_ports M_DATA[6]]

# M34 - D34 -> M_DATA[14]
# IO Pin: IO_B34_LP24
set_property PACKAGE_PIN P15 [get_ports M_DATA[7]]
