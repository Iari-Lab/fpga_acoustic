# set_property CFGBVS VCCO [current_design]
# set_property CONFIG_VOLTAGE 3.3 [current_design]


set_property IOSTANDARD LVCMOS18 [get_ports led]
set_property PACKAGE_PIN U17 [get_ports led]

## M0 and M1
# set_property IOSTANDARD LVCMOS18 [get_ports M1_DATA]
# set_property PACKAGE_PIN G19 [get_ports M1_DATA]
# set_property SLEW SLOW [get_ports M1_DATA]
# set_property KEEPER true [get_ports M1_DATA]


## MCLK2
# set_property IOSTANDARD LVCMOS18 [get_ports M1_CLK]
# set_property PACKAGE_PIN V15 [get_ports M1_CLK]
# set_property SLEW SLOW [get_ports M1_CLK]
# set_property KEEPER true [get_ports M1_CLK]

## M59 M58 ------------D58
set_property IOSTANDARD LVCMOS18 [get_ports M1_DATA]
set_property PACKAGE_PIN G18 [get_ports M1_DATA]
# set_property SLEW SLOW [get_ports M1_DATA]
# set_property KEEPER true [get_ports M1_DATA]
## MCL4 MCLK3
set_property IOSTANDARD LVCMOS18 [get_ports M1_CLK]
set_property PACKAGE_PIN J18 [get_ports M1_CLK]
# set_property SLEW SLOW [get_ports M1_CLK]
# set_property KEEPER true [get_ports M1_CLK]