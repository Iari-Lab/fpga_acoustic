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
# IO Pin: IO_B34_LP12
set_property PACKAGE_PIN U18 [get_ports M_DATA[0]]
# D2 IO_B13_LN18 (BANK 13) need to fix this in csv, the mapping was to bank 34
set_property PACKAGE_PIN Y11 [get_ports M_DATA[1]]
# IO Pin: IO_B34_LN14
set_property PACKAGE_PIN P20 [get_ports M_DATA[2]]
# IO Pin: IO_B34_LP18
set_property PACKAGE_PIN V16 [get_ports M_DATA[3]]
# IO Pin: IO_B13_LN14
set_property PACKAGE_PIN Y8 [get_ports M_DATA[4]]
# IO Pin: IO_B13_0
set_property PACKAGE_PIN V5 [get_ports M_DATA[5]]
# IO Pin: IO_B13_LN20
set_property PACKAGE_PIN Y13 [get_ports M_DATA[6]]
# IO Pin: IO_B34_LP15
set_property PACKAGE_PIN T20 [get_ports M_DATA[7]]
# IO Pin: IO_B34_LN12
set_property PACKAGE_PIN U19 [get_ports M_DATA[8]]
# IO Pin: IO_B34_LP21
set_property PACKAGE_PIN V17 [get_ports M_DATA[9]]
# IO Pin: IO_B13_LN13
set_property PACKAGE_PIN Y6 [get_ports M_DATA[10]]
# IO Pin: IO_B13_LP13
set_property PACKAGE_PIN Y7 [get_ports M_DATA[11]]
# IO Pin: IO_B13_LN16
set_property PACKAGE_PIN W9 [get_ports M_DATA[12]]
# IO Pin: IO_B34_LN15
set_property PACKAGE_PIN U20 [get_ports M_DATA[13]]
# IO Pin: IO_B34_LP24
set_property PACKAGE_PIN P15 [get_ports M_DATA[14]]
# IO Pin: IO_B34_0
set_property PACKAGE_PIN R19 [get_ports M_DATA[15]]
# IO Pin: IO_B13_LP19
set_property PACKAGE_PIN T5 [get_ports M_DATA[16]]
# IO Pin: IO_B13_LN15
set_property PACKAGE_PIN W8 [get_ports M_DATA[17]]
# IO Pin: IO_B13_LP16
set_property PACKAGE_PIN W10 [get_ports M_DATA[18]]
# IO Pin: IO_B34_LP10
set_property PACKAGE_PIN V15 [get_ports M_DATA[19]]
# IO Pin: IO_B34_25
set_property PACKAGE_PIN T19 [get_ports M_DATA[20]]

