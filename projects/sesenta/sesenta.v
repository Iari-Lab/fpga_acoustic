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
    input [3:0] M_DATA,
    output LEDS,
    output SYNC_IN,
    output SYNC_OUT

);

  localparam integer INPUT_FREQ = 120_000_000;
  localparam integer PDM_FREQ = 2_400_000;
  localparam integer LED_FREQ = 12000000;
  localparam integer DATA_WIDTH = 256;
  localparam CIC_DATA_WIDTH = 16;
  wire clk, clk_leds, rst, pdm_clk;
  wire clk_rising_mics;
  wire mics_data_valid;
  wire [DATA_WIDTH-1:0] mics_data, mics_data2, mics_data_dbg, mics_data_dbg2;
  // Manual LED control signals
  reg pcm_valid;
  initial begin
    reg_mics_data  = 256'b0;
    reg_mics_data2 = 256'b0;
  end

  reg [DATA_WIDTH-1:0] reg_mics_data, reg_mics_data2;
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
    // Assign delayed PCM data for 4-mic array (M39, M51, M57, M45)
    // Assign delayed PCM data to first 6 positions (M31, M28, M25, M22, M19, M34)
    reg_mics_data[0*32+:32] <= mic01;  // M39
    reg_mics_data[1*32+:32] <= mic23;  // M51
    reg_mics_data[255:64] <= mics_data[255:64];
    reg_mics_data2 <= mics_data2;
    pcm_valid <= mics_data_valid;
  end
  assign mics_data_dbg  = reg_mics_data;
  assign mics_data_dbg2 = reg_mics_data2;

  wire [31:0] mic01, mic23;
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
  ) mic_32_packed (
      .in_1 (delayed_pcm_data_2),
      .in_2(delayed_pcm_data_3),
      .out_1(mic23)
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
    for (j = 1; j < 4; j = j + 1) begin : pdms_gen_nege
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
  ila_0 ila_bram (
      .clk(clk),  // input wire clk
      .probe0(led_sel),
      .probe1(mics_data_valid),
      .probe2(mic_dbg),
      .probe3(mic_sel)
  );
  wire [ 2:0] mic_sel;
  wire [15:0] mic_dbg;
  assign mic_dbg = mics_data_dbg[16*mic_sel+:16];

  // Delay module outputs for 4-mic 
  wire [15:0] delayed_pcm_data_0;
  wire [15:0] delayed_pcm_data_1;
  wire [15:0] delayed_pcm_data_2;
  wire [15:0] delayed_pcm_data_3;

  delay_module u_delay_module (
      .clk(clk),
      .rst(~rst),
      .delay_select(mic_sel),  // Use lower 2 bits of mic_sel to select source mic (0-3)
      .pcm_data_0(mics_data[0*16+:16]),
      .pcm_data_1(mics_data[1*16+:16]),
      .pcm_data_2(mics_data[2*16+:16]),
      .pcm_data_3(mics_data[3*16+:16]),
      .delayed_pcm_data_0(delayed_pcm_data_0),
      .delayed_pcm_data_1(delayed_pcm_data_1),
      .delayed_pcm_data_2(delayed_pcm_data_2),
      .delayed_pcm_data_3(delayed_pcm_data_3),
      .pcm_valid(mics_data_valid)
  );

  system system_i (
      .mic_sel(mic_sel),
      .led_sel(led_sel),
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
