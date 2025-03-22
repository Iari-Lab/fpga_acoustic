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

## array of mics
# set_property IOSTANDARD LVCMOS33 [get_ports {M_DATA[*]}]
# set_property PACKAGE_PIN G19 [get_ports M_DATA[0]]
# set_property PACKAGE_PIN P15 [get_ports M_DATA[1]]
# set_property PACKAGE_PIN K19 [get_ports M_DATA[2]]
# set_property PACKAGE_PIN Y18 [get_ports M_DATA[3]]
# set_property PACKAGE_PIN J19 [get_ports M_DATA[4]]
# set_property PACKAGE_PIN U18 [get_ports M_DATA[5]]
# set_property PACKAGE_PIN V20 [get_ports M_DATA[6]]
# set_property PACKAGE_PIN F20 [get_ports M_DATA[7]]

set_property IOSTANDARD LVCMOS33 [get_ports {M_DATA[*]}]

set_property PACKAGE_PIN G19 [get_ports M_DATA[0]]
set_property PACKAGE_PIN Y19 [get_ports M_DATA[1]]
set_property PACKAGE_PIN J16 [get_ports M_DATA[2]]
set_property PACKAGE_PIN F19 [get_ports M_DATA[3]]
set_property PACKAGE_PIN P15 [get_ports M_DATA[4]]
set_property PACKAGE_PIN W16 [get_ports M_DATA[5]]
set_property PACKAGE_PIN Y17 [get_ports M_DATA[6]]
set_property PACKAGE_PIN K16 [get_ports M_DATA[7]]
set_property PACKAGE_PIN K19 [get_ports M_DATA[8]]
set_property PACKAGE_PIN G17 [get_ports M_DATA[9]]
set_property PACKAGE_PIN H16 [get_ports M_DATA[10]]
set_property PACKAGE_PIN W18 [get_ports M_DATA[11]]
set_property PACKAGE_PIN Y18 [get_ports M_DATA[12]]
set_property PACKAGE_PIN T20 [get_ports M_DATA[13]]
set_property PACKAGE_PIN U20 [get_ports M_DATA[14]]
set_property PACKAGE_PIN L15 [get_ports M_DATA[15]]
set_property PACKAGE_PIN J19 [get_ports M_DATA[16]]
set_property PACKAGE_PIN H17 [get_ports M_DATA[17]]
set_property PACKAGE_PIN G15 [get_ports M_DATA[18]]
set_property PACKAGE_PIN H15 [get_ports M_DATA[19]]
set_property PACKAGE_PIN U18 [get_ports M_DATA[20]]
set_property PACKAGE_PIN W19 [get_ports M_DATA[21]]
set_property PACKAGE_PIN P16 [get_ports M_DATA[22]]
set_property PACKAGE_PIN Y16 [get_ports M_DATA[23]]
set_property PACKAGE_PIN V20 [get_ports M_DATA[24]]
set_property PACKAGE_PIN W20 [get_ports M_DATA[25]]
set_property PACKAGE_PIN L14 [get_ports M_DATA[26]]
set_property PACKAGE_PIN G20 [get_ports M_DATA[27]]
set_property PACKAGE_PIN F20 [get_ports M_DATA[28]]
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