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
// Description: Updated for 21 microphones (M0, M2, M4, M6, M8, M10, M12, M14, M16, M18, M22, M24, M28, M30, M34, M36, M42, M44, M50, M52, M58)
//
// Dependencies:
//
// Revision:
// Revision 0.04 - Updated for 21 microphones with 21 delay cases
// Revision 0.03 - Updated for 30 microphones with 30 delay cases
// Revision 0.02 - Updated for 30 microphones
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
    input [20:0] M_DATA,  // 21 microphone inputs
    output LEDS,
    output SYNC_IN,
    output SYNC_OUT

);

  localparam integer INPUT_FREQ = 120_000_000;
  localparam integer PDM_FREQ = 2_400_000;
  localparam integer LED_FREQ = 12000000;
  localparam integer DATA_WIDTH = 672;  // 21 mics * 32 bits
  localparam integer MICS_DATA_WIDTH = 336;  // 21 mics * 16 bits
  localparam CIC_DATA_WIDTH = 16;
  wire clk, clk_leds, rst, pdm_clk;  //start


  wire clk_rising_mics;
  wire mics_data_valid;
  wire [MICS_DATA_WIDTH-1:0] mics_data;
  wire [DATA_WIDTH-1:0] beam_data;
  // Manual LED control signals
  reg pcm_valid;
  initial begin
    reg_mics_data = 672'b0;
  end

  reg [DATA_WIDTH-1:0] reg_mics_data;
  assign M0_CLK = pdm_clk;
  assign M2_CLK = pdm_clk;
  assign M1_CLK = pdm_clk;

  clk_gen #(
      .INPUT_FREQ (INPUT_FREQ),
      .OUTPUT_FREQ(LED_FREQ)
  ) led_clk_gen_i (
      .clk  (clk),
      .rst  (~rst),
      .m_clk(clk_leds)
  );
  wire [7:0] led_count, led_sel;

  leds led_controller (
      .clk(clk_leds),
      .led_sel(led_sel),
      .reset(~rst),
      .ws_data(LEDS),
      .led_count(led_count)
  );

  // Clock generator instance
  clk_gen #(
      .INPUT_FREQ (INPUT_FREQ),
      .OUTPUT_FREQ(PDM_FREQ)
  ) pdm_clk_gen_i (
      .clk  (clk),
      .rst  (~rst),
      .m_clk(pdm_clk)
  );

  assign SYNC_OUT = pdm_clk;
  assign SYNC_IN  = pcm_valid;

  wire [20:0] cic_overflow;
  always @(posedge clk) begin
    reg_mics_data[0*32+:32] <= {{11{beamformed_sum_0[20]}}, beamformed_sum_0};
    reg_mics_data[1*32+:32] <= {{11{beamformed_sum_1[20]}}, beamformed_sum_1};
    reg_mics_data[2*32+:32] <= {{11{beamformed_sum_2[20]}}, beamformed_sum_2};
    reg_mics_data[3*32+:32] <= {{11{beamformed_sum_3[20]}}, beamformed_sum_3};
    reg_mics_data[4*32+:32] <= {{11{beamformed_sum_4[20]}}, beamformed_sum_4};
    reg_mics_data[5*32+:32] <= {{11{beamformed_sum_5[20]}}, beamformed_sum_5};
    reg_mics_data[6*32+:32] <= {{11{beamformed_sum_6[20]}}, beamformed_sum_6};
    reg_mics_data[7*32+:32] <= {{11{beamformed_sum_7[20]}}, beamformed_sum_7};
    reg_mics_data[8*32+:32] <= {{11{beamformed_sum_8[20]}}, beamformed_sum_8};
    reg_mics_data[9*32+:32] <= {{11{beamformed_sum_9[20]}}, beamformed_sum_9};
    reg_mics_data[10*32+:32] <= {{11{beamformed_sum_10[20]}}, beamformed_sum_10};
    reg_mics_data[11*32+:32] <= {{11{beamformed_sum_11[20]}}, beamformed_sum_11};
    reg_mics_data[12*32+:32] <= {{11{beamformed_sum_12[20]}}, beamformed_sum_12};
    reg_mics_data[13*32+:32] <= {{11{beamformed_sum_13[20]}}, beamformed_sum_13};
    reg_mics_data[14*32+:32] <= {{11{beamformed_sum_14[20]}}, beamformed_sum_14};
    reg_mics_data[15*32+:32] <= {{11{beamformed_sum_15[20]}}, beamformed_sum_15};
    reg_mics_data[16*32+:32] <= {{11{beamformed_sum_16[20]}}, beamformed_sum_16};
    reg_mics_data[17*32+:32] <= {{11{beamformed_sum_17[20]}}, beamformed_sum_17};
    reg_mics_data[18*32+:32] <= {{11{beamformed_sum_18[20]}}, beamformed_sum_18};
    reg_mics_data[19*32+:32] <= {{11{beamformed_sum_19[20]}}, beamformed_sum_19};
    reg_mics_data[20*32+:32] <= {{11{beamformed_sum_20[20]}}, beamformed_sum_20};
    pcm_valid <= mics_data_valid;
  end

  assign beam_data = reg_mics_data;

  wire [20:0] beamformed_sum_0, beamformed_sum_1, beamformed_sum_2, beamformed_sum_3, beamformed_sum_4;
  wire [20:0] beamformed_sum_5, beamformed_sum_6, beamformed_sum_7, beamformed_sum_8, beamformed_sum_9;
  wire [20:0] beamformed_sum_10, beamformed_sum_11, beamformed_sum_12, beamformed_sum_13, beamformed_sum_14;
  wire [20:0] beamformed_sum_15, beamformed_sum_16, beamformed_sum_17, beamformed_sum_18, beamformed_sum_19;
  wire [20:0] beamformed_sum_20;

  // First CIC decimator (index 0 - M0)
  cic_decimator #(
      .DATA_WIDTH(CIC_DATA_WIDTH),
      .CIC_STAGES(4),
      .CIC_DECIMATION(50)
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

  // Generate remaining 20 CIC decimators (indices 1-20)
  generate
    for (j = 1; j < 21; j = j + 1) begin : pdms_gen_nege
      cic_decimator #(
          .DATA_WIDTH(CIC_DATA_WIDTH),
          .CIC_STAGES(4),
          .CIC_DECIMATION(50)
      ) cic_stage (
          .clk(clk),
          .rst(~rst),
          .pdm_clk(pdm_clk),
          .pdm_data(M_DATA[j]),
          .pcm_valid(),
          .pcm_data(mics_data[j*16+:16]),
          .overflow(cic_overflow[j]),
          .sample_count()
      );
    end
  endgenerate

  wire [7:0] mic_sel;

  beamforming u_beamforming_module (
      .clk(clk),
      .rst(~rst),
      .mics_data(mics_data),
      .mics_data_valid(mics_data_valid),
      .beamformed_sum_0(beamformed_sum_0),
      .beamformed_sum_1(beamformed_sum_1),
      .beamformed_sum_2(beamformed_sum_2),
      .beamformed_sum_3(beamformed_sum_3),
      .beamformed_sum_4(beamformed_sum_4),
      .beamformed_sum_5(beamformed_sum_5),
      .beamformed_sum_6(beamformed_sum_6),
      .beamformed_sum_7(beamformed_sum_7),
      .beamformed_sum_8(beamformed_sum_8),
      .beamformed_sum_9(beamformed_sum_9),
      .beamformed_sum_10(beamformed_sum_10),
      .beamformed_sum_11(beamformed_sum_11),
      .beamformed_sum_12(beamformed_sum_12),
      .beamformed_sum_13(beamformed_sum_13),
      .beamformed_sum_14(beamformed_sum_14),
      .beamformed_sum_15(beamformed_sum_15),
      .beamformed_sum_16(beamformed_sum_16),
      .beamformed_sum_17(beamformed_sum_17),
      .beamformed_sum_18(beamformed_sum_18),
      .beamformed_sum_19(beamformed_sum_19),
      .beamformed_sum_20(beamformed_sum_20)
  );

  system system_i (
      .mic_sel(mic_sel),
      .led_sel(led_sel),
      .mics(beam_data),
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
      .start(start),
      .reset(rst),
      .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
  );



endmodule
