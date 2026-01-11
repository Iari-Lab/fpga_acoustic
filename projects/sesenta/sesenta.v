`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Updated for 60 microphones using multi-channel CIC decimator
// 2 instances: one for clk edge, one for ~clk edge
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
    input [29:0] M_DATA,  // 30 microphone data lines (2 mics per line = 60 total)
    output LEDS,
    output SYNC_IN,
    output SYNC_OUT
);

  // Parameters
  localparam integer INPUT_FREQ = 120_000_000;
  localparam integer PDM_FREQ = 2_400_000;
  localparam integer LED_FREQ = 12_000_000;
  localparam integer NUM_CONFIGS = 60;
  localparam integer NUM_CHANNELS = 60;           // Total 60 mics
  localparam integer CHANNELS_PER_EDGE = 30;      // 30 mics per clock edge
  localparam integer CIC_DATA_WIDTH = 12;
  localparam integer SUM_WIDTH = 16;
  localparam integer DATA_WIDTH = NUM_CONFIGS * SUM_WIDTH;
  localparam integer MICS_DATA_WIDTH = NUM_CHANNELS * CIC_DATA_WIDTH;  // 60 * 16 = 960 bits
  localparam integer BEAMFORMED_WIDTH = NUM_CONFIGS * SUM_WIDTH;

  // Clocks and resets
  wire clk, clk_leds, rst, pdm_clk;
  wire clk_inv;
  assign clk_inv = ~clk;

  // Microphone data
  wire mics_data_valid_pos, mics_data_valid_neg;
  wire [CHANNELS_PER_EDGE*CIC_DATA_WIDTH-1:0] mics_data_pos;  // 30 mics on positive edge
  wire [CHANNELS_PER_EDGE*CIC_DATA_WIDTH-1:0] mics_data_neg;  // 30 mics on negative edge
  wire [MICS_DATA_WIDTH-1:0] mics_data;                        // Combined 60 mics

//   reg pcm_valid;
//   reg [DATA_WIDTH-1:0] reg_mics_data;
//   wire [DATA_WIDTH-1:0] beam_data;

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
  assign SYNC_IN  = mics_data_valid_pos;

  // Beamformed output
  wire [BEAMFORMED_WIDTH-1:0] beamformed_sum;
  wire [NUM_CONFIGS-1:0] beamformed_valid;

  // ============================================================
  // CIC Decimator Instance 1: Positive clock edge (channels 0-29)
  // ============================================================
  cic_decimator_multi #(
      .SYS_FREQ_HZ(INPUT_FREQ),
      .PDM_FREQ_HZ(PDM_FREQ),
      .CHANNELS(CHANNELS_PER_EDGE),
      .DATA_WIDTH(CIC_DATA_WIDTH),
      .CIC_DATA_WIDTH(CIC_DATA_WIDTH),
      .STAGES(3),
      .SAMPLE_RATE(50),
      .PDM_READING_TIME(28),
      .PDM_RATIO(49)
  ) cic_pos (
      .clk(clk),
      .resetn(rst),
      .pdm_data(M_DATA),
      .pdm_clk(pdm_clk),
      .pcm_data(mics_data_pos),
      .pcm_valid(mics_data_valid_pos),
      .channel()
  );

  // ============================================================
  // CIC Decimator Instance 2: Negative clock edge (channels 30-59)
  // ============================================================
  cic_decimator_multi #(
      .SYS_FREQ_HZ(INPUT_FREQ),
      .PDM_FREQ_HZ(PDM_FREQ),
      .CHANNELS(CHANNELS_PER_EDGE),
      .DATA_WIDTH(CIC_DATA_WIDTH),
      .CIC_DATA_WIDTH(CIC_DATA_WIDTH),
      .STAGES(3),
      .SAMPLE_RATE(50),
      .PDM_READING_TIME(28),
      .PDM_RATIO(49)
  ) cic_neg (
      .clk(clk_inv),
      .resetn(rst),
      .pdm_data(M_DATA),
      .pdm_clk(),  // Not used, shares pdm_clk from positive instance
      .pcm_data(mics_data_neg),
      .pcm_valid(mics_data_valid_neg),
      .channel()
  );

  // ============================================================
  // Combine positive and negative edge data into packed array
  // Interleaved: [pos_ch0, neg_ch0, pos_ch1, neg_ch1, ...]
  // ============================================================
  genvar i;
  generate
      for (i = 0; i < CHANNELS_PER_EDGE; i = i + 1) begin : pack_mics
          // Even indices (0,2,4,...) = positive edge mics
          assign mics_data[(2*i)*CIC_DATA_WIDTH +: CIC_DATA_WIDTH] = 
                 mics_data_pos[i*CIC_DATA_WIDTH +: CIC_DATA_WIDTH];
          // Odd indices (1,3,5,...) = negative edge mics  
          assign mics_data[(2*i+1)*CIC_DATA_WIDTH +: CIC_DATA_WIDTH] = 
                 mics_data_neg[i*CIC_DATA_WIDTH +: CIC_DATA_WIDTH];
      end
  endgenerate

  // Use positive edge valid as main valid signal
  wire mics_data_valid = mics_data_valid_pos;

//   // Register beamformed data
//   integer k;
//   always @(posedge clk) begin
//     for (k = 0; k < NUM_CONFIGS; k = k + 1) begin
//       reg_mics_data[k*SUM_WIDTH +: SUM_WIDTH] <= beamformed_sum[k*SUM_WIDTH +: SUM_WIDTH];
//     end
//     pcm_valid <= mics_data_valid;
//   end

//   assign beam_data = reg_mics_data;

  // Beamforming module
  beamforming #(
      .NUM_CONFIGS(NUM_CONFIGS),
      .NUM_CHANNELS(NUM_CHANNELS),
      .DATA_WIDTH(CIC_DATA_WIDTH),
      .SUM_WIDTH(SUM_WIDTH)
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
