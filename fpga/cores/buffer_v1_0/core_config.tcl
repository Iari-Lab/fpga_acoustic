set display_name {Buffer debug}

set core [ipx::current_core]

# set_property DISPLAY_NAME $display_name $core
# set_property DESCRIPTION $display_name $core
set_property VENDOR {sesenta} $core
set_property VENDOR_DISPLAY_NAME {Q} $core
set_property COMPANY_URL {http://www.sesenta.com} $core






#  // BUFF BRAM NO AXI PORT A
#          .BRAMBUFF_PORTB_0_clk(BRAM_clk),
#          .BRAMBUFF_PORTB_0_rst(BRAM_rst),
#          .BRAMBUFF_PORTB_0_addr(BRAM_addr),
#          .BRAMBUFF_PORTB_0_din(BRAM_cosx_din),
#          .BRAMBUFF_PORTB_0_dout(32'b0),
#          .BRAMBUFF_PORTB_0_en(1'b1),
#          .BRAMBUFF_PORTB_0_we(BRAM_wen),


#  // BUFF BRAM NO AXI PORT B
#  .BRAMBUFF_PORTA_0_clk(BRAM_clk),
#  .BRAMBUFF_PORTA_0_rst(BRAM_rst),
#  .BRAMBUFF_PORTA_0_addr(BRAMR_addr),
#  .BRAMBUFF_PORTA_0_din(32'b0),
#  .BRAMBUFF_PORTA_0_dout(BRAMR_dout),
#  .BRAMBUFF_PORTA_0_en(1'b1),
  #  .BRAMBUFF_PORTA_0_we(4'b0),