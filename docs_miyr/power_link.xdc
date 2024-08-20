#///link1

set_property IOSTANDARD LVCMOS18 [get_ports {RGMII_rd[0]}]
set_property PACKAGE_PIN N17 [get_ports {RGMII_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RGMII_rd[1]}]
set_property PACKAGE_PIN R18 [get_ports {RGMII_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RGMII_rd[2]}]
set_property PACKAGE_PIN T17 [get_ports {RGMII_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RGMII_rd[3]}]
set_property PACKAGE_PIN W19 [get_ports {RGMII_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports RGMII_rx_ctl]
set_property PACKAGE_PIN P18 [get_ports RGMII_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports RGMII_rxc]
set_property PACKAGE_PIN N20 [get_ports RGMII_rxc]

set_property IOSTANDARD LVCMOS18 [get_ports {RGMII_td[0]}]
set_property PACKAGE_PIN Y16 [get_ports {RGMII_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RGMII_td[1]}]
set_property PACKAGE_PIN Y17 [get_ports {RGMII_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RGMII_td[2]}]
set_property PACKAGE_PIN Y18 [get_ports {RGMII_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {RGMII_td[3]}]
set_property PACKAGE_PIN Y19 [get_ports {RGMII_td[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports RGMII_tx_ctl]
set_property PACKAGE_PIN P16 [get_ports RGMII_tx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports RGMII_txc]
set_property PACKAGE_PIN P15 [get_ports RGMII_txc]

#set_property IOSTANDARD LVCMOS18 [get_ports link1_clk125]
#set_property PACKAGE_PIN N18 [get_ports link1_clk125]
#set_property PULLUP true [get_ports link1_clk125]

set_property IOSTANDARD LVCMOS18 [get_ports MDIO_PHY_mdc]
set_property PACKAGE_PIN T20 [get_ports MDIO_PHY_mdc]
set_property PULLUP true [get_ports MDIO_PHY_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports mdio_phy_mdio_io]
set_property PACKAGE_PIN U20 [get_ports mdio_phy_mdio_io]
set_property PULLUP true [get_ports mdio_phy_mdio_io]

set_property IDELAY_VALUE 0 [get_cells -hier -filter {name =~ *design_1_gmii_to_rgmii_0_0_core/*delay_rgmii_rx_ctl          }]
set_property IDELAY_VALUE 0 [get_cells -hier -filter {name =~ *design_1_gmii_to_rgmii_0_0_core/*delay_rgmii_rxd*            }]
set_property IODELAY_GROUP gpr1 [get_cells -hier -filter {name =~ *design_1_gmii_to_rgmii_0_0_core/*delay_rgmii_rx_ctl          }]
set_property IODELAY_GROUP gpr1 [get_cells -hier -filter {name =~ *design_1_gmii_to_rgmii_0_0_core/*delay_rgmii_rxd*            }]
set_property IODELAY_GROUP gpr1 [get_cells -hier -filter {name =~ *i_design_1_gmii_to_rgmii_0_0_idelayctrl}]

############################################################

set_property IOSTANDARD LVCMOS18 [get_ports CAN_1_rx]
set_property PACKAGE_PIN W16 [get_ports CAN_1_rx]
set_property IOSTANDARD LVCMOS18 [get_ports CAN_1_tx]
set_property PACKAGE_PIN V16 [get_ports CAN_1_tx]

set_property IOSTANDARD LVCMOS18 [get_ports UART_0_rxd]
set_property PACKAGE_PIN V18 [get_ports UART_0_rxd]
set_property IOSTANDARD LVCMOS18 [get_ports UART_0_txd]
set_property PACKAGE_PIN V17 [get_ports UART_0_txd]

set_property IOSTANDARD LVCMOS18 [get_ports UART_rxd]
set_property PACKAGE_PIN W20 [get_ports UART_rxd]
set_property IOSTANDARD LVCMOS18 [get_ports UART_txd]
set_property PACKAGE_PIN V20 [get_ports UART_txd]
############################################################


set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_1_rd[0]}]
set_property PACKAGE_PIN T14 [get_ports {rgmii_1_rd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_1_rd[1]}]
set_property PACKAGE_PIN R14 [get_ports {rgmii_1_rd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_1_rd[2]}]
set_property PACKAGE_PIN P14 [get_ports {rgmii_1_rd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_1_rd[3]}]
set_property PACKAGE_PIN W15 [get_ports {rgmii_1_rd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_1_rx_ctl]
set_property PACKAGE_PIN T15 [get_ports rgmii_1_rx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_1_rxc]
set_property PACKAGE_PIN U14 [get_ports rgmii_1_rxc]

set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_1_td[0]}]
set_property PACKAGE_PIN V13 [get_ports {rgmii_1_td[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_1_td[1]}]
set_property PACKAGE_PIN U13 [get_ports {rgmii_1_td[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_1_td[2]}]
set_property PACKAGE_PIN W13 [get_ports {rgmii_1_td[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_1_td[3]}]
set_property PACKAGE_PIN V12 [get_ports {rgmii_1_td[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_1_tx_ctl]
set_property PACKAGE_PIN T12 [get_ports rgmii_1_tx_ctl]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_1_txc]
set_property PACKAGE_PIN U12 [get_ports rgmii_1_txc]


#  R33 phy1 mdio_data IO_B34_LP1
set_property IOSTANDARD LVCMOS18 [get_ports mdio_mdio_io]
set_property PACKAGE_PIN T10 [get_ports mdio_mdio_io]
set_property PULLUP true [get_ports mdio_mdio_io]

#  R34 phy1 mdio_data IO_B34_LN1
set_property IOSTANDARD LVCMOS18 [get_ports mdio_mdc]
set_property PACKAGE_PIN T11 [get_ports mdio_mdc]
set_property PULLUP true [get_ports mdio_mdc]

#set_property IOSTANDARD LVCMOS18 [get_ports link2_clk125]
#set_property PACKAGE_PIN U18 [get_ports link2_clk125]

set_property IOSTANDARD LVCMOS18 [get_ports led]
set_property IOSTANDARD LVCMOS18 [get_ports rs485_en]
set_property PACKAGE_PIN U17 [get_ports led]
set_property PACKAGE_PIN R16 [get_ports rs485_en]
