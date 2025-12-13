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

# D0 - IO_B34_LP12 (BANK 34)
set_property PACKAGE_PIN U18 [get_ports M_DATA[0]]
# D2 IO_B13_LN18 (BANK 13) need to fix this in csv, the mapping was to bank 34
set_property PACKAGE_PIN Y11 [get_ports M_DATA[1]]
# D4 - IO_B34_LN14 (BANK 34)
set_property PACKAGE_PIN P20 [get_ports M_DATA[2]]
# D6 - IO_B34_LP18 (BANK 34)
set_property PACKAGE_PIN V16 [get_ports M_DATA[3]]
# D8 - IO_B13_LN14 (BANK 13)
set_property PACKAGE_PIN Y8 [get_ports M_DATA[4]]
# D10 - IO_B13_0 (BANK 13)
set_property PACKAGE_PIN V5 [get_ports M_DATA[5]]
# D12 - IO_B13_LN20 (BANK 13)
set_property PACKAGE_PIN Y13 [get_ports M_DATA[6]]
# D14 - IO_B34_LP15 (BANK 34)
set_property PACKAGE_PIN T20 [get_ports M_DATA[7]]
# D16 - IO_B34_LN12 (BANK 34)
set_property PACKAGE_PIN U19 [get_ports M_DATA[8]]
# D18 - IO_B34_LP21 (BANK 34)
set_property PACKAGE_PIN V17 [get_ports M_DATA[9]]
# D20 - IO_B34_LP20 (BANK 34)
set_property PACKAGE_PIN T17 [get_ports M_DATA[10]]
# D22 - IO_B13_LN13 (BANK 13)
set_property PACKAGE_PIN Y6 [get_ports M_DATA[11]]
# D24 - IO_B13_LP13 (BANK 13)
set_property PACKAGE_PIN Y7 [get_ports M_DATA[12]]
# D26 - IO_B13_LP18 (BANK 13)
set_property PACKAGE_PIN W11 [get_ports M_DATA[13]]
# D28 - IO_B13_LN16 (BANK 13)
set_property PACKAGE_PIN W9 [get_ports M_DATA[14]]
# D30 - IO_B34_LN15 (BANK 34)
set_property PACKAGE_PIN U20 [get_ports M_DATA[15]]
# D32 - IO_B34_LN18 (BANK 34)
set_property PACKAGE_PIN R17 [get_ports M_DATA[16]]
# D34 - IO_B34_LP24 (BANK 34)
set_property PACKAGE_PIN P15 [get_ports M_DATA[17]]
# D36 - IO_B34_0 (BANK 34)
set_property PACKAGE_PIN R19 [get_ports M_DATA[18]]
# D38 - IO_B34_LN24 (BANK 34)
set_property PACKAGE_PIN P16 [get_ports M_DATA[19]]
# D40 - IO_B13_LN19 (BANK 13)
set_property PACKAGE_PIN U5 [get_ports M_DATA[20]]
# D42 - IO_B13_LP19 (BANK 13)
set_property PACKAGE_PIN T5 [get_ports M_DATA[21]]
# D44 - IO_B13_LN15 (BANK 13)
set_property PACKAGE_PIN W8 [get_ports M_DATA[22]]
# D46 - IO_B13_LP14 (BANK 13)
set_property PACKAGE_PIN Y9 [get_ports M_DATA[23]]
# 48 - IO_B13_LP20 (BANK 13)
set_property PACKAGE_PIN Y12 [get_ports M_DATA[24]]
# D50 - IO_B13_LP16 (BANK 13)
set_property PACKAGE_PIN W10 [get_ports M_DATA[25]]
# D52 - IO_B34_LP10 (BANK 34)
set_property PACKAGE_PIN V15 [get_ports M_DATA[26]]
# D54 - IO_B34_LN20 (BANK 34)
set_property PACKAGE_PIN R18 [get_ports M_DATA[27]]
# D56 - IO_B34_LN21 (BANK 34)
set_property PACKAGE_PIN V18 [get_ports M_DATA[28]]
# D58 - IO_B34_25 (BANK 34)
set_property PACKAGE_PIN T19 [get_ports M_DATA[29]]