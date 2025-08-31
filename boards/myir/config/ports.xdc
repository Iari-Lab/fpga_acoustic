# set_property CFGBVS VCCO [current_design]
# set_property CONFIG_VOLTAGE 3.3 [current_design]

# set_property SLEW SLOW [get_ports M1_DATA]
# set_property KEEPER true [get_ports M1_DATA]


# M59 M58 ------------D58

# MCL4 MCLK3
set_property IOSTANDARD LVCMOS33 [get_ports M1_CLK]
set_property PACKAGE_PIN J18 [get_ports M1_CLK]

## MCL0 MCL5
set_property IOSTANDARD LVCMOS33 [get_ports M0_CLK]
set_property PACKAGE_PIN V16 [get_ports M0_CLK]

## MCL1 MCLK2
set_property IOSTANDARD LVCMOS33 [get_ports M2_CLK]
set_property PACKAGE_PIN H18 [get_ports M2_CLK]

set_property IOSTANDARD LVCMOS33 [get_ports LEDS]
set_property PACKAGE_PIN H20 [get_ports LEDS]


set_property IOSTANDARD LVCMOS33 [get_ports {M_DATA[*]}]

# 0 is M0, M1, D0, G19
set_property PACKAGE_PIN G19 [get_ports M_DATA[0]] 
# 1 is M2, M3, D2, Y19 
set_property PACKAGE_PIN Y19 [get_ports M_DATA[1]]
# 2 is M4, M5, D4, J16
set_property PACKAGE_PIN J16 [get_ports M_DATA[2]]
# 3 is M6, M7, D6, F19
set_property PACKAGE_PIN F19 [get_ports M_DATA[3]]
# 4 is M8, M9, D8, P15
set_property PACKAGE_PIN P15 [get_ports M_DATA[4]]
# 5 is M10, M11, D10, W16
set_property PACKAGE_PIN W16 [get_ports M_DATA[5]]
# 6 is M12, M13, D12, Y17
set_property PACKAGE_PIN Y17 [get_ports M_DATA[6]]
# 7 is M14, M15, D14, K16
set_property PACKAGE_PIN K16 [get_ports M_DATA[7]]
# 8 is M16, M17, D16, K19
set_property PACKAGE_PIN K19 [get_ports M_DATA[8]]
# 9 is M18, M19, D18, G17
set_property PACKAGE_PIN G17 [get_ports M_DATA[9]]
# 10 is M20, M21, D20, H16
set_property PACKAGE_PIN H16 [get_ports M_DATA[10]]
# 11 is M22, M23, D22, W18
set_property PACKAGE_PIN W18 [get_ports M_DATA[11]]
# 12 is M24, M25, D24, Y18
set_property PACKAGE_PIN Y18 [get_ports M_DATA[12]]
# 13 is M26, M27, D26, T20
set_property PACKAGE_PIN T20 [get_ports M_DATA[13]]
# 14 is M28, M29, D28, U20
set_property PACKAGE_PIN U20 [get_ports M_DATA[14]]
# 15 is M30, M31, D30, L15
set_property PACKAGE_PIN L15 [get_ports M_DATA[15]]
# 16 is M32, M33, D32, J19
set_property PACKAGE_PIN J19 [get_ports M_DATA[16]]
# 17 is M34, M35, D34, H17
set_property PACKAGE_PIN H17 [get_ports M_DATA[17]]
# 18 is M36, M37, D36, G15
set_property PACKAGE_PIN G15 [get_ports M_DATA[18]]
# 19 is M38, M39, D38, H15
set_property PACKAGE_PIN H15 [get_ports M_DATA[19]]
# 20 is M40, M41, D40, U18
set_property PACKAGE_PIN U18 [get_ports M_DATA[20]]
# 21 is M42, M43, D42, W19
set_property PACKAGE_PIN W19 [get_ports M_DATA[21]]
# 22 is M44, M45, D44, P16
set_property PACKAGE_PIN P16 [get_ports M_DATA[22]]
# 23 is M46, M47, D46, Y16
set_property PACKAGE_PIN Y16 [get_ports M_DATA[23]]
# 24 is M48, M49, D48, V20
set_property PACKAGE_PIN V20 [get_ports M_DATA[24]]
# 25 is M50, M51, D50, W20
set_property PACKAGE_PIN W20 [get_ports M_DATA[25]]
# 26 is M52, M53, D52, L14
set_property PACKAGE_PIN L14 [get_ports M_DATA[26]]
# 27 is M54, M55, D54, G20
set_property PACKAGE_PIN G20 [get_ports M_DATA[27]]
# 28 is M56, M57, D56, F20
set_property PACKAGE_PIN F20 [get_ports M_DATA[28]]
# 29 is M58, M59, D58, G18
set_property PACKAGE_PIN G18 [get_ports M_DATA[29]]


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