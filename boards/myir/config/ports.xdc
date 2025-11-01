# set_property CFGBVS VCCO [current_design]
# set_property CONFIG_VOLTAGE 3.3 [current_design]

# set_property SLEW SLOW [get_ports M1_DATA]
# set_property KEEPER true [get_ports M1_DATA]


# M59 M58 ------------D58

# MCL4 MCLK3
set_property IOSTANDARD LVCMOS33 [get_ports M1_CLK]
## MCL0 MCL5
set_property IOSTANDARD LVCMOS33 [get_ports M0_CLK]
## MCL1 MCLK2
set_property IOSTANDARD LVCMOS33 [get_ports M2_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports LEDS]


# LED_DI - IO_B34_LN23 (BANK 34)
set_property PACKAGE_PIN P18 [get_ports LEDS]
# MCLK2 - IO_B34_LP11 (BANK 34)
set_property PACKAGE_PIN U14 [get_ports M2_CLK]
# MCLK0 - IO_B34_LP11 (BANK 34)
set_property PACKAGE_PIN V11 [get_ports M0_CLK]
# MCLK1 - IO_B34_LP14 (BANK 34)
set_property PACKAGE_PIN N20 [get_ports M1_CLK]

set_property IOSTANDARD LVCMOS33 [get_ports {M_DATA[*]}]

# # 3 is M6, M7, D6, F19
# set_property PACKAGE_PIN F19 [get_ports M_DATA[0]]
# # 4 is M8, M9, D8, P15
# set_property PACKAGE_PIN P15 [get_ports M_DATA[1]]
# # 5 is M10, M11, D10, W16
# set_property PACKAGE_PIN W16 [get_ports M_DATA[2]]
# # 6 is M12, M13, D12, Y17
# set_property PACKAGE_PIN Y17 [get_ports M_DATA[3]]
# # 7 is M14, M15, D14, K16
# set_property PACKAGE_PIN K16 [get_ports M_DATA[4]]
# # 8 is M16, M17, D16, K19
# set_property PACKAGE_PIN K19 [get_ports M_DATA[5]]

# D0 - IO_B34_LP12 (BANK 34)
set_property PACKAGE_PIN U18 [get_ports M_DATA[0]]
# D2 IO_B34_LN18 (BANK 34)
set_property PACKAGE_PIN R17 [get_ports M_DATA[1]]
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



# 6 30.000000 17.3205 F19
# 7 40.000000 0.0000 F19
# 8 30.000000 -17.3205 P15
# 9 20.000000 -34.6410 P15
# 10 0.000000 -34.6410 W16
# 11 -20.000000 -34.6410 W16
# 12 -30.000000 -17.3205 Y17
# 13 -40.000000 -0.0000 Y17
# 14 -30.000000 17.3205 K16
# 15 -20.000000 34.6410 K16
# 16 -0.000000 34.6410  K19
# 17 20.000000 34.6410 K19

# set_property PACKAGE_PIN G19 [get_ports M_DATA[0]]
# set_property PACKAGE_PIN G18 [get_ports M_DATA[1]]
# set_property PACKAGE_PIN Y19 [get_ports M_DATA[2]]
# set_property PACKAGE_PIN J16 [get_ports M_DATA[3]]
# set_property PACKAGE_PIN F19 [get_ports M_DATA[4]]
# set_property PACKAGE_PIN P15 [get_ports M_DATA[5]]
# set_property PACKAGE_PIN W16 [get_ports M_DATA[6]]
# set_property PACKAGE_PIN Y17 [get_ports M_DATA[7]]


# set_property IOSTANDARD LVCMOS33 [get_ports M0_DATA]
# set_property PACKAGE_PIN G19 [get_ports M0_DATA]
# set_property SLEW SLOW [get_ports M0_DATA]
# set_property KEEPER true [get_ports M0_DATA]


# set_property IOSTANDARD LVCMOS33 [get_ports M2_DATA]
# set_property PACKAGE_PIN Y19 [get_ports M2_DATA]
# set_property SLEW SLOW [get_ports M2_DATA]
# set_property KEEPER true [get_ports M2_DATA]


# set_property IOSTANDARD LVCMOS33 [get_ports M4_DATA]
# set_property PACKAGE_PIN J16 [get_ports M4_DATA]
# set_property SLEW SLOW [get_ports M4_DATA]
# set_property KEEPER true [get_ports M4_DATA]

# # 0 is M0, M1, D0, G19
# set_property PACKAGE_PIN G19 [get_ports M_DATA[0]] 
# IO_B34_LP123.3VO U18
# # 1 is M2, M3, D2, Y19 
# IO_B34_LN183.3VO R17
# set_property PACKAGE_PIN Y19 [get_ports M_DATA[1]]
# IO_B34_LN143.3VO P20
# # 2 is M4, M5, D4, J16
# set_property PACKAGE_PIN J16 [get_ports M_DATA[2]]
# IO_B34_LP183.3VO V16
# # 3 is M6, M7, D6, F19
# set_property PACKAGE_PIN F19 [get_ports M_DATA[3]]
# IO_B34_LN143.3VO P20
# # 4 is M8, M9, D8, P15
# set_property PACKAGE_PIN P15 [get_ports M_DATA[4]]
# IO_B13_03.3VIO V5
# # 5 is M10, M11, D10, W16
# set_property PACKAGE_PIN W16 [get_ports M_DATA[5]]
# Y13
# # 6 is M12, M13, D12, Y17
# set_property PACKAGE_PIN Y17 [get_ports M_DATA[6]]
# T20
# # 7 is M14, M15, D14, K16
# set_property PACKAGE_PIN K16 [get_ports M_DATA[7]]
# U19
# # 8 is M16, M17, D16, K19
# set_property PACKAGE_PIN K19 [get_ports M_DATA[8]]
# V17
# # 9 is M18, M19, D18, G17
# set_property PACKAGE_PIN G17 [get_ports M_DATA[9]]
# # 10 is M20, M21, D20, H16
# set_property PACKAGE_PIN H16 [get_ports M_DATA[10]]
# # 11 is M22, M23, D22, W18
# set_property PACKAGE_PIN W18 [get_ports M_DATA[11]]
# # 12 is M24, M25, D24, Y18
# set_property PACKAGE_PIN Y18 [get_ports M_DATA[12]]
# # 13 is M26, M27, D26, T20
# set_property PACKAGE_PIN T20 [get_ports M_DATA[13]]
# # 14 is M28, M29, D28, U20
# set_property PACKAGE_PIN U20 [get_ports M_DATA[14]]
# # 15 is M30, M31, D30, L15
# set_property PACKAGE_PIN L15 [get_ports M_DATA[15]]
# # 16 is M32, M33, D32, J19
# set_property PACKAGE_PIN J19 [get_ports M_DATA[16]]
# # 17 is M34, M35, D34, H17
# set_property PACKAGE_PIN H17 [get_ports M_DATA[17]]
# # 18 is M36, M37, D36, G15
# set_property PACKAGE_PIN G15 [get_ports M_DATA[18]]
# # 19 is M38, M39, D38, H15
# set_property PACKAGE_PIN H15 [get_ports M_DATA[19]]
# # 20 is M40, M41, D40, U18
# set_property PACKAGE_PIN U18 [get_ports M_DATA[20]]
# # 21 is M42, M43, D42, W19
# set_property PACKAGE_PIN W19 [get_ports M_DATA[21]]
# # 22 is M44, M45, D44, P16
# set_property PACKAGE_PIN P16 [get_ports M_DATA[22]]
# # 23 is M46, M47, D46, Y16
# set_property PACKAGE_PIN Y16 [get_ports M_DATA[23]]
# # 24 is M48, M49, D48, V20
# set_property PACKAGE_PIN V20 [get_ports M_DATA[24]]
# # 25 is M50, M51, D50, W20
# set_property PACKAGE_PIN W20 [get_ports M_DATA[25]]
# # 26 is M52, M53, D52, L14
# set_property PACKAGE_PIN L14 [get_ports M_DATA[26]]
# # 27 is M54, M55, D54, G20
# set_property PACKAGE_PIN G20 [get_ports M_DATA[27]]
# # 28 is M56, M57, D56, F20
# set_property PACKAGE_PIN F20 [get_ports M_DATA[28]]
# # 29 is M58, M59, D58, G18
# set_property PACKAGE_PIN G18 [get_ports M_DATA[29]]

# _B34_LP213.3VOV17
# _B34_LP213.3VOV17

# IO_B34_LN18
# IO_B34_LP2
# IO_B13_0
# IO_B34_LN12
# IO_B34_LP18
# IO_B13_LP13
# IO_B13_LP18
# IO_B13_LP21
# IO_B13_LN20
# IO_B13_LP19
# IO_B13_LN16
# IO_B34_LN23
# IO_B13_LP20
# IO_B34_LN24
# IO_B34_LP24
# IO_B34_LN2
# IO_B34_LP14
# IO_B34_LN14
# IO_B34_LP10
# IO_B13_LP16
# IO_B13_LN19
# IO_B34_LN15
# IO_B34_LP20
# IO_B34_LP15
# IO_B35_LN23
# IO_B13_LN18
# VDDIO_34_PL
# IO_B34_LP11
# IO_B34_25
# IO_B13_LN15
# IO_B13_LP14
# IO_B13_LN14
# IO_B34_0
# IO_B34_LP12
# IO_B34_LP21
# IO_B34_LN20
# IO_B34_LN21
# IO_B13_LN13