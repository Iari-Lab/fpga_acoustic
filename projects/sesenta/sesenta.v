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
    input [29:0] M_DATA,
    output LEDS

);

  localparam integer INPUT_FREQ = 125000000;
  localparam integer PDM_FREQ = 2400000;
  localparam integer LED_FREQ = 12000000;
  wire clk, clk_leds, rst;
  wire clk_rising_mics;
  wire mics_data_valid;
  wire [511:0] mics_data, mics_data2, mics_data_dbg, mics_data_dbg2;

  reg [511:0] reg_mics_data, reg_mics_data2;
  assign M0_CLK = pdm_clk;
  assign M2_CLK = pdm_clk;
  assign M1_CLK = pdm_clk;

  clk_gen #(
      .INPUT_FREQ (INPUT_FREQ),
      .OUTPUT_FREQ(LED_FREQ)
  ) led_clk_gen_i (
      .clk(clk),
      .rst(~rst),
      .m_clk(clk_leds)
  );

  leds #() led_i (
      .clk(clk_leds),
      .ws_data(LEDS),
      .reset(~rst)
  );

    always @(posedge clk) begin
        reg_mics_data <= mics_data;
        reg_mics_data2 <= mics_data2;
    end
  assign mics_data_dbg = reg_mics_data;
  assign mics_data_dbg2 = reg_mics_data2;
  wire pdm_clk, write_memory;
  assign M0_CLK = pdm_clk;
    pdm_cic #(
    ) pdm_cic_main (
        .clk(clk),
        .rst(~rst),
        .pdm_data_in(M_DATA[0]),
        .pdm_clock_in_en(1'b0),
        .pdm_clock_in(),
        .pcm_strobe_out(mics_data_valid),
        .pdm_clock_out(pdm_clk),
        .pcm_data_out()
  ); 

  assign mics_data2[0*32+:32] = 32'd0;
  assign mics_data2[1*32+:32] = 32'd1;
  assign mics_data2[2*32+:32] = 32'd2;
  assign mics_data2[3*32+:32] = 32'd3;
  assign mics_data2[4*32+:32] = 32'd4;
  assign mics_data2[5*32+:32] = 32'd5;
  assign mics_data2[6*32+:32] = 32'd6;
  assign mics_data2[7*32+:32] = 32'd7;
  assign mics_data2[8*32+:32] = 32'd8;
  assign mics_data2[9*32+:32] = 32'd9;
  assign mics_data2[10*32+:32] = 32'd10;
  assign mics_data2[11*32+:32] = 32'd11;
  assign mics_data2[12*32+:32] = 32'd12;
  assign mics_data2[13*32+:32] = 32'd13;
  assign mics_data2[14*32+:32] = 32'd14;
  assign mics_data2[15*32+:32] = 32'd15;

assign mics_data[0*32+:32] = 32'd0;
assign mics_data[1*32+:32] = 32'd1;
assign mics_data[2*32+:32] = 32'd2;
assign mics_data[3*32+:32] = 32'd3;
assign mics_data[4*32+:32] = 32'd4;
assign mics_data[5*32+:32] = 32'd5;
assign mics_data[6*32+:32] = 32'd6;
assign mics_data[7*32+:32] = 32'd7;
assign mics_data[8*32+:32] = 32'd8;
assign mics_data[9*32+:32] = 32'd9;
assign mics_data[10*32+:32] = 32'd10;
assign mics_data[11*32+:32] = 32'd11;
assign mics_data[12*32+:32] = 32'd12;
assign mics_data[13*32+:32] = 32'd13;
assign mics_data[14*32+:32] = 32'd14;
assign mics_data[15*32+:32] = 32'd15;

  // genvar i;
  // generate
  //   for (i = 1; i < 8; i = i + 1) begin : pdms_gen_pose
  //       pdm_cic #(
  //   ) pdm_cic_all (
  //           .clk(clk),
  //           .rst(~rst),
  //           .pdm_data_in(M_DATA[i]),
  //           .pdm_clock_in_en(1'b1),
  //           .pdm_clock_in(pdm_clk),
  //           .pcm_strobe_out(1'b0),
  //           .pdm_clock_out(),
  //           .pcm_data_out(mics_data[i*32+:32])
  //   );
  //   end
  // endgenerate
  // genvar j;
  // generate
  //   for (j = 8; j < 16; j = j + 1) begin : pdms_gen_nege
  //       pdm_cic #(
  //   ) pdm_cic_all (
  //           .clk(clk),
  //           .rst(~rst),
  //           .pdm_data_in(M_DATA[j]),
  //           .pdm_clock_in_en(1'b1),
  //           .pdm_clock_in(~pdm_clk),
  //           .pcm_strobe_out(1'b0),
  //           .pcm_data_out(mics_data[j*32+:32])
  //   );
  //   end
  // endgenerate

ila_0 ila_bram (
    .clk(clk),  // input wire clk
    .probe0(pdm_clk),
    .probe1(mics_data_valid)
    // .probe2(mics_data_dbg[32*0+:32]),
    // .probe3(mics_data_dbg[32*1+:32]),
    // .probe4(mics_data_dbg[32*2+:32]),
    // .probe5(mics_data_dbg[32*3+:32]),
    // .probe6(mics_data_dbg[32*4+:32]),
    // .probe7(mics_data_dbg[32*5+:32]),
    // .probe8(mics_data_dbg[32*6+:32]),
    // .probe9(mics_data_dbg[32*7+:32])
);


  system system_i (
      .mics(mics_data_dbg),
      .mics2(mics_data_dbg2),
      .mics_data_valid(mics_data_valid),
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
      .FCLK_CLK0(clk),
      .reset(rst),
      .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
  );




endmodule
