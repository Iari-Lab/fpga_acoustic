`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Camilo Soto
//
// Create Date: 08/12/2023 10:50:04 AM
// Design Name:
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module sesenta (
    inout [14:0] DDR_addr,
    inout [2:0] DDR_ba,
    inout DDR_cas_n,
    inout DDR_ck_n,
    inout DDR_ck_p,
    inout DDR_cke,
    inout DDR_cs_n,
    inout [3:0] DDR_dm,
    inout [31:0] DDR_dq,
    inout [3:0] DDR_dqs_n,
    inout [3:0] DDR_dqs_p,
    inout DDR_odt,
    inout DDR_ras_n,
    inout DDR_reset_n,
    inout DDR_we_n,
    inout FIXED_IO_ddr_vrn,
    inout FIXED_IO_ddr_vrp,
    inout [53:0] FIXED_IO_mio,
    inout FIXED_IO_ps_clk,
    inout FIXED_IO_ps_porb,
    inout FIXED_IO_ps_srstb,
    output M0_CLK,
    output M1_CLK,
    output M2_CLK,
    input [7:0] M_DATA,
    output LEDS

);

  localparam integer INPUT_FREQ = 125000000;
  localparam integer PDM_FREQ = 2400000;
  localparam integer LED_FREQ = 12000000;
  wire rst_clk_mics, rst_leds, rst_clk_leds;
  wire [31:0] rst_regs;
  wire [ 7:0] rst_mics;
  // Clocks for mics and leds
  wire clk_mics, clk_leds, clk_led;
  wire clk_rising_mics;
  wire [7:0] mics_data_valid;
  // Flattened 32x8 mic data to 256 bits
  // reg [255:0] reg_mics_data;
  // reg [255:0] reg_mics_data;

  // initial begin
  //   integer j;
  //   for (j = 0; j < 8; j = j + 1) begin
  //     reg_mics_data[j*32 +: 32] = j;
  //   end
  // end
  reg [255:0] reg_mics_data = {
    32'd15,  // Bits [255:224] = 7
    32'd14,  // Bits [223:192] = 6
    32'd13,  // Bits [191:160] = 5
    32'd12,  // Bits [159:128] = 4
    32'd11,  // Bits [127:96]   = 3
    32'd10,  // Bits [95:64]    = 2
    32'd9,  // Bits [63:32]    = 1
    32'd8   // Bits [31:0]     = 0
};

  
  // reg [255:0] reg_mics_data = {32'h00000008, 32'h00000007, 32'h00000006, 32'h00000005, 32'h00000004, 32'h00000003, 32'h00000002, 32'h00000001};
  // reg [255:0] reg_mics_data = {32'h00000008, 32'h00000007, 32'h00000006, 32'h00000005, 32'h00000004, 32'h00000003, 32'h00000002, 32'h00000001};
  wire [255:0] mics_data, mics_data_dbg;
  //Reset signals
  assign rst_clk_mics = rst_regs[0:0];
  assign rst_clk_leds = rst_regs[1:1];
  assign rst_leds = rst_regs[2:2];
  assign rst_mics = rst_regs[10:3];
  assign M0_CLK = clk_mics;
  assign M2_CLK = clk_mics;
  assign M1_CLK = clk_mics;

  // Clock generator instance
  clk_gen #(
      .INPUT_FREQ (INPUT_FREQ),
      .OUTPUT_FREQ(PDM_FREQ)
  ) pdm_clk_gen_i (
      .clk(clk),
      .rst(rst_clk_mics),
      .m_clk(clk_mics),
      .m_clk_rising(clk_rising_mics)
  );

  clk_gen #(
      .INPUT_FREQ (INPUT_FREQ),
      .OUTPUT_FREQ(LED_FREQ)
  ) led_clk_gen_i (
      .clk(clk_led),
      .rst(rst_clk_leds),
      .m_clk(clk_leds)
  );

  leds #() led_i (
      .clk(clk_leds),
      .ws_data(LEDS),
      .reset(rst_leds)
  );
  // genvar i;
  // generate
  //   for (i = 0; i < 8; i = i + 1) begin : safe_gen
  //     always @(posedge clk) begin
  //       // if (mics_data_valid[i]) begin
  //         reg_mics_data[i*32+:32] <= i;
  //       // end
  //     end
  //     // assign mics_data_dbg[i*32+:32] = reg_mics_data[i*32+:32];
  //   end
  // endgenerate

  // genvar i;
  // generate
  //   for (i = 0; i < 8; i = i + 1) begin : safe_gen
  //     always @(posedge clk) begin
  //       reg_mics_data[(7 - i)*32 +: 32] <= reg_mics_data[(7 - i)*32 +: 32] + 1;
  //     end
  //     // assign mics_data_dbg[(7 - i)*32 +: 32] = reg_mics_data[(7 - i)*32 +: 32];
  //   end
  // endgenerate

  assign mics_data_dbg = reg_mics_data;
  // generate
  //   for (i = 0; i < 8; i = i + 1) begin : pdms_gen
  //     pdm_mic #() mic (
  //         .clk(clk),
  //         .rst(rst_mics[i]),
  //         .mic_data(mics_data[i*32+:32]),
  //         .m_clk_rising(clk_rising_mics),
  //         .mic_data_valid(mics_data_valid[i]),
  //         .m_data(M_DATA[i])
  //     );
  //   end
  // endgenerate


  // ila_0 ila_bram (
  //     .clk(clk),  // input wire clk
  //     .probe0(clk_mics),
  //     .probe1(mics_data_dbg[32*0+:32]),
  //     .probe2(mics_data_dbg[32*1+:32]),
  //     .probe3(mics_data_dbg[32*2+:32]),
  //     .probe4(mics_data_dbg[32*3+:32]),
  //     .probe5(mics_data_dbg[32*4+:32]),
  //     .probe6(mics_data_dbg[32*5+:32]),
  //     .probe7(mics_data_dbg[32*6+:32]),
  //     .probe8(mics_data_dbg[32*7+:32]),
  //     .probe9(mics_data_valid)
  // );

//  ila_0 ila_bram (
//      .clk(clk),  // input wire clk
//      .probe0(clk_mics),
//      .probe1(mics_data_dbg[32*0+:32])
//  );

  system system_i (
      .rst_regs(rst_regs),
      .mics(mics_data_dbg),
      .DDR_addr(DDR_addr),
      .DDR_ba(DDR_ba),
      .DDR_cas_n(DDR_cas_n),
      .DDR_ck_n(DDR_ck_n),
      .DDR_ck_p(DDR_ck_p),
      .DDR_cke(DDR_cke),
      .DDR_cs_n(DDR_cs_n),
      .DDR_dm(DDR_dm),
      .DDR_dq(DDR_dq),
      .DDR_dqs_n(DDR_dqs_n),
      .DDR_dqs_p(DDR_dqs_p),
      .DDR_odt(DDR_odt),
      .DDR_ras_n(DDR_ras_n),
      .DDR_reset_n(DDR_reset_n),
      .DDR_we_n(DDR_we_n),
      .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
      .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
      .FIXED_IO_mio(FIXED_IO_mio),
      .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
      .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
      .peripheral_aresetn(rstn),
      .FCLK_CLK0(clk),
      .FCLK_CLK1(clk_led),
      .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
  );




endmodule
