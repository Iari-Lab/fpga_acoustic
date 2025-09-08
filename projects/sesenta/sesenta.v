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
    input [5:0] M_DATA,
    output LEDS

);

  localparam integer INPUT_FREQ = 125000000;
  localparam integer PDM_FREQ = 2400000;
  localparam integer LED_FREQ = 12000000;
  wire clk, clk_leds, rst;
  wire clk_rising_mics;
  wire mics_data_valid;
  wire [511:0] mics_data, mics_data2, mics_data_dbg, mics_data_dbg2;
  // initial begin
  //   reg_mics_data = 512'b0;
  //   reg_mics_data2 = 512'b0;
  // end

  reg [511:0] reg_mics_data, reg_mics_data2;
  assign M0_CLK = pdm_clk;
  assign M2_CLK = pdm_clk;
  assign M1_CLK = pdm_clk;

    // clk_gen #(
    //     .INPUT_FREQ (INPUT_FREQ),
    //     .OUTPUT_FREQ(LED_FREQ)
    // ) led_clk_gen_i (
    //     .clk(clk),
    //     .rst(~rst),
    //     .m_clk(clk_leds)
    // );

    // leds #() led_i (
    //     .clk(clk_leds),
    //     .ws_data(LEDS),
    //     .reset(~rst)
    // );

  localparam PDM_CLOCK_FREQ = 3072000;
  localparam CIC_DATA_WIDTH = 16;
  clk_divider #() clk_div (
      .clk(clk),
      .rst(~rst),
      .clock_enable_in(1'b1),  // Always enabled
      .clock_out(pdm_clk)
  );

  wire [29:0] cic_overflow, cic_overflow2;


  always @(posedge clk) begin
    reg_mics_data  <= mics_data;
    reg_mics_data2 <= mics_data2;
  end
  assign mics_data_dbg  = reg_mics_data;
  assign mics_data_dbg2 = reg_mics_data2;
  wire pdm_clk, write_memory, pdm_clk_neg;

  cic_decimator #(
      .PDM_CLOCK_FREQ(PDM_CLOCK_FREQ),
      .DATA_WIDTH(CIC_DATA_WIDTH),
      .CIC_STAGES(4),
      .CIC_DECIMATION(64)
  ) cic_stage (
      .clk(clk),
      .rst(~rst),
      .pdm_clk(pdm_clk),
      .pdm_data(M_DATA[0]),
      .pcm_valid(mics_data_valid),
      .pcm_data(mics_data[0*16+:16]),
      .overflow(cic_overflow[0]),
      .sample_count()
  );

  genvar i;
  genvar j, idx;
  generate
    for (i = 1; i < 6; i = i + 1) begin : pdms_gen_pose
      cic_decimator #(
          .PDM_CLOCK_FREQ(PDM_CLOCK_FREQ),
          .DATA_WIDTH(CIC_DATA_WIDTH),
          .CIC_STAGES(4),
          .CIC_DECIMATION(64)
      ) cic_stage (
          .clk(clk),
          .rst(~rst),
          .pdm_clk(pdm_clk),
          .pdm_data(M_DATA[i]),
          .pcm_valid(),
          .pcm_data(mics_data[i*16+:16]),
          .overflow(cic_overflow[i]),
          .sample_count()
      );
    end
  endgenerate
  generate
    for (j = 0; j < 6; j = j + 1) begin : pdms_gen_nege
      cic_decimator #(
          .PDM_CLOCK_FREQ(PDM_CLOCK_FREQ),
          .DATA_WIDTH(CIC_DATA_WIDTH),
          .CIC_STAGES(4),
          .CIC_DECIMATION(64)
      ) cic_stage (
          .clk(clk),
          .rst(~rst),
          .pdm_clk(~pdm_clk),
          .pdm_data(M_DATA[j]),
          .pcm_valid(),
          .pcm_data(mics_data2[j*16+:16]),
          .overflow(cic_overflow2[j]),
          .sample_count()
      );
    end
  endgenerate

  ila_0 ila_bram (
      .clk(clk),  // input wire clk
      .probe0(pdm_clk),
      .probe1(mics_data_valid),
      .probe2(mic_dbg),
      .probe3(mic_sel)
  );
  wire [7:0] mic_sel;
  wire [15:0] mic_dbg;
  wire mic_valid;
  assign mic_dbg = (mic_sel < 30) ? mics_data[16*mic_sel+:16] : mics_data2[16*(mic_sel-30)+:16];
  //   assign mic_valid = (mic_sel < 30)? mics_data[16*mic_sel+:16]: mics_data2[16*(mic_sel)+:16];


  system system_i (
      .mic_sel(mic_sel),
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
