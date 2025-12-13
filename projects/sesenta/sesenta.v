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
// Description: Updated for 30 microphones (M0-M29)
//
// Dependencies:
//
// Revision:
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
    input [29:0] M_DATA,  // 30 microphone inputs (M0-M29)
    output LEDS,
    output SYNC_IN,
    output SYNC_OUT

);

  localparam integer INPUT_FREQ = 120_000_000;
  localparam integer PDM_FREQ = 2_400_000;
  localparam integer LED_FREQ = 12000000;
  localparam integer DATA_WIDTH = 480;  // 30 mics * 16 bits
  localparam CIC_DATA_WIDTH = 16;
  wire clk, clk_leds, rst, pdm_clk;
  wire clk_rising_mics;
  wire mics_data_valid;
  wire [DATA_WIDTH-1:0] mics_data, mics_data_dbg;
  // Manual LED control signals
  reg pcm_valid;
  initial begin
    reg_mics_data  = 480'b0;
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

  wire [29:0] cic_overflow, cic_overflow2;

  always @(posedge clk) begin
    // Assign delayed PCM data for 30-mic array (M0-M29)
    reg_mics_data[0*32+:32] <= mic01;   // M0, M1
    reg_mics_data[1*32+:32] <= mic23;   // M2, M3
    reg_mics_data[2*32+:32] <= mic45;   // M4, M5
    reg_mics_data[3*32+:32] <= mic67;   // M6, M7
    reg_mics_data[4*32+:32] <= mic89;   // M8, M9
    reg_mics_data[5*32+:32] <= mic1011; // M10, M11
    reg_mics_data[6*32+:32] <= mic1213; // M12, M13
    reg_mics_data[7*32+:32] <= mic1415; // M14, M15
    reg_mics_data[8*32+:32] <= mic1617; // M16, M17
    reg_mics_data[9*32+:32] <= mic1819; // M18, M19
    reg_mics_data[10*32+:32] <= mic2021; // M20, M21
    reg_mics_data[11*32+:32] <= mic2223; // M22, M23
    reg_mics_data[12*32+:32] <= mic2425; // M24, M25
    reg_mics_data[13*32+:32] <= mic2627; // M26, M27
    reg_mics_data[14*32+:32] <= mic2829; // M28, M29
    pcm_valid <= mics_data_valid;
  end
  assign mics_data_dbg  = reg_mics_data;

  wire [31:0] mic01, mic23, mic45, mic67, mic89, mic1011, mic1213, mic1415, mic1617, mic1819, mic2021, mic2223, mic2425, mic2627, mic2829;
  
  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_01_packed (
      .in_1 (delayed_pcm_data_0),
      .in_2(delayed_pcm_data_1),
      .out_1(mic01)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_23_packed (
      .in_1 (delayed_pcm_data_2),
      .in_2(delayed_pcm_data_3),
      .out_1(mic23)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_45_packed (
      .in_1 (delayed_pcm_data_4),
      .in_2(delayed_pcm_data_5),
      .out_1(mic45)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_67_packed (
      .in_1 (delayed_pcm_data_6),
      .in_2(delayed_pcm_data_7),
      .out_1(mic67)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_89_packed (
      .in_1 (delayed_pcm_data_8),
      .in_2(delayed_pcm_data_9),
      .out_1(mic89)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_1011_packed (
      .in_1 (delayed_pcm_data_10),
      .in_2(delayed_pcm_data_11),
      .out_1(mic1011)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_1213_packed (
      .in_1 (delayed_pcm_data_12),
      .in_2(delayed_pcm_data_13),
      .out_1(mic1213)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_1415_packed (
      .in_1 (delayed_pcm_data_14),
      .in_2(delayed_pcm_data_15),
      .out_1(mic1415)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_1617_packed (
      .in_1 (delayed_pcm_data_16),
      .in_2(delayed_pcm_data_17),
      .out_1(mic1617)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_1819_packed (
      .in_1 (delayed_pcm_data_18),
      .in_2(delayed_pcm_data_19),
      .out_1(mic1819)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_2021_packed (
      .in_1 (delayed_pcm_data_20),
      .in_2(delayed_pcm_data_21),
      .out_1(mic2021)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_2223_packed (
      .in_1 (delayed_pcm_data_22),
      .in_2(delayed_pcm_data_23),
      .out_1(mic2223)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_2425_packed (
      .in_1 (delayed_pcm_data_24),
      .in_2(delayed_pcm_data_25),
      .out_1(mic2425)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_2627_packed (
      .in_1 (delayed_pcm_data_26),
      .in_2(delayed_pcm_data_27),
      .out_1(mic2627)
  );

  p16_32 #(
      .IN_WIDTH (CIC_DATA_WIDTH),
      .OUT_WIDTH(32)
  ) mic_2829_packed (
      .in_1 (delayed_pcm_data_28),
      .in_2(delayed_pcm_data_29),
      .out_1(mic2829)
  );

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

  generate
    for (j = 1; j < 30; j = j + 1) begin : pdms_gen_nege
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
  
//   ila_0 ila_bram (
//       .clk(clk),  // input wire clk
//       .probe0(led_sel),
//       .probe1(mics_data_valid),
//       .probe2(mic_dbg),
//       .probe3(mic_sel)
//   );
  
  wire [ 4:0] mic_sel;  // 5 bits to select from 30 cases
//   wire [15:0] mic_dbg;
//   assign mic_dbg = mics_data_dbg[16*mic_sel+:16];

  // Delay module outputs for 30-mic array
  wire [15:0] delayed_pcm_data_0;
  wire [15:0] delayed_pcm_data_1;
  wire [15:0] delayed_pcm_data_2;
  wire [15:0] delayed_pcm_data_3;
  wire [15:0] delayed_pcm_data_4;
  wire [15:0] delayed_pcm_data_5;
  wire [15:0] delayed_pcm_data_6;
  wire [15:0] delayed_pcm_data_7;
  wire [15:0] delayed_pcm_data_8;
  wire [15:0] delayed_pcm_data_9;
  wire [15:0] delayed_pcm_data_10;
  wire [15:0] delayed_pcm_data_11;
  wire [15:0] delayed_pcm_data_12;
  wire [15:0] delayed_pcm_data_13;
  wire [15:0] delayed_pcm_data_14;
  wire [15:0] delayed_pcm_data_15;
  wire [15:0] delayed_pcm_data_16;
  wire [15:0] delayed_pcm_data_17;
  wire [15:0] delayed_pcm_data_18;
  wire [15:0] delayed_pcm_data_19;
  wire [15:0] delayed_pcm_data_20;
  wire [15:0] delayed_pcm_data_21;
  wire [15:0] delayed_pcm_data_22;
  wire [15:0] delayed_pcm_data_23;
  wire [15:0] delayed_pcm_data_24;
  wire [15:0] delayed_pcm_data_25;
  wire [15:0] delayed_pcm_data_26;
  wire [15:0] delayed_pcm_data_27;
  wire [15:0] delayed_pcm_data_28;
  wire [15:0] delayed_pcm_data_29;

  delay_module u_delay_module (
      .clk(clk),
      .rst(~rst),
      .delay_select(mic_sel),  // Use 5 bits of mic_sel to select source mic (1-30)
      .pcm_data_0(mics_data[0*16+:16]),
      .pcm_data_1(mics_data[1*16+:16]),
      .pcm_data_2(mics_data[2*16+:16]),
      .pcm_data_3(mics_data[3*16+:16]),
      .pcm_data_4(mics_data[4*16+:16]),
      .pcm_data_5(mics_data[5*16+:16]),
      .pcm_data_6(mics_data[6*16+:16]),
      .pcm_data_7(mics_data[7*16+:16]),
      .pcm_data_8(mics_data[8*16+:16]),
      .pcm_data_9(mics_data[9*16+:16]),
      .pcm_data_10(mics_data[10*16+:16]),
      .pcm_data_11(mics_data[11*16+:16]),
      .pcm_data_12(mics_data[12*16+:16]),
      .pcm_data_13(mics_data[13*16+:16]),
      .pcm_data_14(mics_data[14*16+:16]),
      .pcm_data_15(mics_data[15*16+:16]),
      .pcm_data_16(mics_data[16*16+:16]),
      .pcm_data_17(mics_data[17*16+:16]),
      .pcm_data_18(mics_data[18*16+:16]),
      .pcm_data_19(mics_data[19*16+:16]),
      .pcm_data_20(mics_data[20*16+:16]),
      .pcm_data_21(mics_data[21*16+:16]),
      .pcm_data_22(mics_data[22*16+:16]),
      .pcm_data_23(mics_data[23*16+:16]),
      .pcm_data_24(mics_data[24*16+:16]),
      .pcm_data_25(mics_data[25*16+:16]),
      .pcm_data_26(mics_data[26*16+:16]),
      .pcm_data_27(mics_data[27*16+:16]),
      .pcm_data_28(mics_data[28*16+:16]),
      .pcm_data_29(mics_data[29*16+:16]),
      .delayed_pcm_data_0(delayed_pcm_data_0),
      .delayed_pcm_data_1(delayed_pcm_data_1),
      .delayed_pcm_data_2(delayed_pcm_data_2),
      .delayed_pcm_data_3(delayed_pcm_data_3),
      .delayed_pcm_data_4(delayed_pcm_data_4),
      .delayed_pcm_data_5(delayed_pcm_data_5),
      .delayed_pcm_data_6(delayed_pcm_data_6),
      .delayed_pcm_data_7(delayed_pcm_data_7),
      .delayed_pcm_data_8(delayed_pcm_data_8),
      .delayed_pcm_data_9(delayed_pcm_data_9),
      .delayed_pcm_data_10(delayed_pcm_data_10),
      .delayed_pcm_data_11(delayed_pcm_data_11),
      .delayed_pcm_data_12(delayed_pcm_data_12),
      .delayed_pcm_data_13(delayed_pcm_data_13),
      .delayed_pcm_data_14(delayed_pcm_data_14),
      .delayed_pcm_data_15(delayed_pcm_data_15),
      .delayed_pcm_data_16(delayed_pcm_data_16),
      .delayed_pcm_data_17(delayed_pcm_data_17),
      .delayed_pcm_data_18(delayed_pcm_data_18),
      .delayed_pcm_data_19(delayed_pcm_data_19),
      .delayed_pcm_data_20(delayed_pcm_data_20),
      .delayed_pcm_data_21(delayed_pcm_data_21),
      .delayed_pcm_data_22(delayed_pcm_data_22),
      .delayed_pcm_data_23(delayed_pcm_data_23),
      .delayed_pcm_data_24(delayed_pcm_data_24),
      .delayed_pcm_data_25(delayed_pcm_data_25),
      .delayed_pcm_data_26(delayed_pcm_data_26),
      .delayed_pcm_data_27(delayed_pcm_data_27),
      .delayed_pcm_data_28(delayed_pcm_data_28),
      .delayed_pcm_data_29(delayed_pcm_data_29),
      .pcm_valid(mics_data_valid)
  );

  system system_i (
      .mic_sel(mic_sel),
      .led_sel(led_sel),
      .mics(mics_data_dbg),
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
