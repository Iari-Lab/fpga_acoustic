`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// OPTIMIZED sesenta module for 60 microphones (Version 3)
// Uses shared delay lines with packed arrays for Vivado compatibility
// Target: xc7z020clg400-1
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
    output LEDS,
    output SYNC_IN,
    output SYNC_OUT
);

  // Parameters
  localparam integer INPUT_FREQ = 120_000_000;
  localparam integer PDM_FREQ = 2_400_000;
  localparam integer LED_FREQ = 12_000_000;
  localparam integer NUM_CONFIGS = 60;
  localparam integer NUM_CHANNELS = 60;
  localparam integer CHANNELS_PER_EDGE = 30;
  localparam integer CIC_DATA_WIDTH = 16;
  localparam integer SUM_WIDTH = 21;
  localparam integer MICS_DATA_WIDTH = NUM_CHANNELS * CIC_DATA_WIDTH;
  localparam integer BEAMFORMED_WIDTH = NUM_CONFIGS * SUM_WIDTH;

  // Clocks and resets
  wire clk, clk_leds, rst, pdm_clk;
  wire clk_inv;
  assign clk_inv = ~clk;

  // Microphone data
  wire mics_data_valid_pos, mics_data_valid_neg;
  wire [CHANNELS_PER_EDGE*CIC_DATA_WIDTH-1:0] mics_data_pos;
  wire [CHANNELS_PER_EDGE*CIC_DATA_WIDTH-1:0] mics_data_neg;
  wire [MICS_DATA_WIDTH-1:0] mics_data;
  wire [59:0] cic_overflow;

  // PDM clock outputs
  assign M0_CLK = pdm_clk;
  assign M1_CLK = pdm_clk;
  assign M2_CLK = pdm_clk;

  // LED clock generator
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

  // Sync outputs
  assign SYNC_OUT = pdm_clk;
  assign SYNC_IN  = mics_data_valid;

  // Beamformed output
  wire [BEAMFORMED_WIDTH-1:0] beamformed_sum;
  wire [NUM_CONFIGS-1:0] beamformed_valid;
  // First CIC decimator (index 0 - M18)
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

  genvar j;
  // Generate 18 CIC decimators from 9 M_DATA lines
  // Odd j  (1,3,5,...17): use ~clk, maps to M_DATA[j/2]
  // Even j (0,2,4,...16): use clk,  maps to M_DATA[j/2]
  generate
    for (j = 1; j < NUM_CHANNELS; j = j + 1) begin : pdms_gen
      cic_decimator #(
          .DATA_WIDTH(CIC_DATA_WIDTH),
          .CIC_STAGES(4),
          .CIC_DECIMATION(50)
      ) cic_stage (
          .clk         (j[0] ? clk_inv : clk),    // Odd: ~clk, Even: clk
          .rst         (~rst),
          .pdm_clk     (pdm_clk),
          .pdm_data    (M_DATA[j/2]),          // Integer division: 0,1→0, 2,3→1, etc.
          .pcm_valid   (),
          .pcm_data    (mics_data[j*CIC_DATA_WIDTH +: CIC_DATA_WIDTH]),
          .overflow    (cic_overflow[j]),
          .sample_count()
      );
    end
  endgenerate



  wire mics_data_valid = mics_data_valid_pos;

  beamforming #(
      .NUM_CONFIGS(NUM_CONFIGS),
      .NUM_CHANNELS(NUM_CHANNELS),
      .DATA_WIDTH(CIC_DATA_WIDTH),
      .SUM_WIDTH(SUM_WIDTH),
      .MAX_DELAY(16)
  ) u_beamforming_module (
      .clk(clk),
      .rst(~rst),
      .mics_data(mics_data),
      .mics_data_valid(mics_data_valid),
      .beamformed_sum(beamformed_sum),
      .beamformed_valid(beamformed_valid)
  );

  // System module
  system system_i (
      .led_sel(led_sel),
      .mics(beamformed_sum),
      .beam_valid(beamformed_valid[0]),
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
