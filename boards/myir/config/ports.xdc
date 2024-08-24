# set_property CFGBVS VCCO [current_design]
# set_property CONFIG_VOLTAGE 3.3 [current_design]

# set_property SLEW SLOW [get_ports M1_DATA]
# set_property KEEPER true [get_ports M1_DATA]


## M59 M58 ------------D58

## MCL4 MCLK3
set_property IOSTANDARD LVCMOS33 [get_ports M1_CLK]
set_property PACKAGE_PIN J18 [get_ports M1_CLK]

## MCL0 MCL5
set_property IOSTANDARD LVCMOS33 [get_ports M0_CLK]
set_property PACKAGE_PIN V16 [get_ports M0_CLK]

## MCL1 MCLK2
set_property IOSTANDARD LVCMOS33 [get_ports M2_CLK]
set_property PACKAGE_PIN H18 [get_ports M2_CLK]


## Generated
set_property IOSTANDARD LVCMOS33 [get_ports M0_DATA]
set_property PACKAGE_PIN G19 [get_ports M0_DATA]

set_property IOSTANDARD LVCMOS33 [get_ports M1_DATA]
set_property PACKAGE_PIN G18 [get_ports M1_DATA]

set_property IOSTANDARD LVCMOS33 [get_ports M2_DATA]
set_property PACKAGE_PIN Y19 [get_ports M2_DATA]

set_property IOSTANDARD LVCMOS33 [get_ports M4_DATA]
set_property PACKAGE_PIN J16 [get_ports M4_DATA]

set_property IOSTANDARD LVCMOS33 [get_ports M6_DATA]
set_property PACKAGE_PIN F19 [get_ports M6_DATA]

set_property IOSTANDARD LVCMOS33 [get_ports M8_DATA]
set_property PACKAGE_PIN P15 [get_ports M8_DATA]

set_property IOSTANDARD LVCMOS33 [get_ports M10_DATA]
set_property PACKAGE_PIN W16 [get_ports M10_DATA]

set_property IOSTANDARD LVCMOS33 [get_ports M12_DATA]
set_property PACKAGE_PIN Y17 [get_ports M12_DATA]
