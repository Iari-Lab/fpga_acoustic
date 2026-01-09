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
// Description: Updated for 18 microphones (M18-M35)
//
// Dependencies:
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
    input [29:0] M_DATA,  // 18 microphone inputs (M18-M35)
    output LEDS,
    output SYNC_IN,
    output SYNC_OUT
);

  localparam integer INPUT_FREQ = 120_000_000;
  localparam integer PDM_FREQ = 2_400_000;
  localparam integer LED_FREQ = 12000000;
  localparam integer NUM_CONFIGS = 30;
  localparam integer NUM_CHANNELS = 30;
  localparam integer CIC_DATA_WIDTH = 16;
  // SUM_WIDTH matches adder_tree_recursive: DATA_WIDTH + $clog2(NUM_CHANNELS) + 1
  localparam integer SUM_WIDTH = 20;  // 22 bits
//   localparam integer SUM_WIDTH = CIC_DATA_WIDTH + $clog2(NUM_C1HANNELS) + 1;  // 22 bits
  localparam integer DATA_WIDTH = NUM_CONFIGS * SUM_WIDTH;  // 18 configs * 32 bits = 576
  localparam integer MICS_DATA_WIDTH = NUM_CHANNELS * CIC_DATA_WIDTH;  // 18 mics * 16 bits = 288
  localparam integer BEAMFORMED_WIDTH = NUM_CONFIGS * SUM_WIDTH;  // 18 * 22 = 396

  wire clk, clk_leds, rst, pdm_clk;

  wire clk_rising_mics;
  wire mics_data_valid;
  wire [MICS_DATA_WIDTH-1:0] mics_data;

  reg pcm_valid;
  reg [DATA_WIDTH-1:0] reg_mics_data;
  wire [DATA_WIDTH-1:0] beam_data;

//   initial begin
//     reg_mics_data = {DATA_WIDTH{1'b0}};
//   end

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

  wire [59:0] cic_overflow;

  // Packed beamformed output from new beamforming module
  wire [BEAMFORMED_WIDTH-1:0] beamformed_sum;
  wire [NUM_CONFIGS-1:0] beamformed_valid;

  // Sign-extend each 22-bit beamformed sum to 32 bits and pack into reg_mics_data
  integer k;
  always @(posedge clk) begin
    for (k = 0; k < NUM_CONFIGS; k = k + 1) begin
      reg_mics_data[k*SUM_WIDTH +: SUM_WIDTH] <= beamformed_sum[k*SUM_WIDTH +: SUM_WIDTH];
    end
    pcm_valid <= mics_data_valid;
  end

  assign beam_data = reg_mics_data;

  // First CIC decimator (index 0 - M18)
  cic_decimator #(
      .DATA_WIDTH(CIC_DATA_WIDTH),
      .CIC_STAGES(4),
      .CIC_DECIMATION(50)
  ) cic_stage (
      .clk(~clk),
      .rst(~rst),
      .pdm_clk(pdm_clk),
      .pdm_data(M_DATA[0]),
      .pcm_valid(mics_data_valid),
      .pcm_data(mics_data[0*16+:16]),
      .overflow(cic_overflow[0]),
      .sample_count()
  );

//   genvar j;
//   // Generate 18 CIC decimators from 9 M_DATA lines
//   // Even j (0,2,4,...16): use clk,  maps to M_DATA[j/2]
//   generate
//     for (j = 1; j < NUM_CHANNELS; j = j + 1) begin : pdms_gen
//       cic_decimator #(
//           .DATA_WIDTH(CIC_DATA_WIDTH),
//           .CIC_STAGES(4),
//           .CIC_DECIMATION(50)
//       ) cic_stage (
//           .clk         (clk),    // Odd: ~clk, Even: clk
//           .rst         (~rst),
//           .pdm_clk     (pdm_clk),
//           .pdm_data    (M_DATA[j/2]),          // Integer division: 0,1→0, 2,3→1, etc.
//           .pcm_valid   (),
//           .pcm_data    (mics_data[j*CIC_DATA_WIDTH +: CIC_DATA_WIDTH]),
//           .overflow    (cic_overflow[j]),
//           .sample_count()
//       );
//     end
//   endgenerate
  genvar j;
  // Generate 18 CIC decimators from 9 M_DATA lines
  // Odd j  (1,3,5,...17): use ~clk, maps to M_DATA[j/2]
  generate
    for (j = 1; j < NUM_CHANNELS; j = j + 1) begin : pdms_gen
      cic_decimator #(
          .DATA_WIDTH(CIC_DATA_WIDTH),
          .CIC_STAGES(4),
          .CIC_DECIMATION(50)
      ) cic_stage (
          .clk         (~clk),    // Odd: ~clk, Even: clk
          .rst         (~rst),
          .pdm_clk     (pdm_clk),
          .pdm_data    (M_DATA[j]),          // Integer division: 0,1→0, 2,3→1, etc.
          .pcm_valid   (),
          .pcm_data    (mics_data[j*CIC_DATA_WIDTH +: CIC_DATA_WIDTH]),
          .overflow    (cic_overflow[j]),
          .sample_count()
      );
    end
  endgenerate
//   genvar j;
//   // Generate 18 CIC decimators from 9 M_DATA lines
//   // Odd j  (1,3,5,...17): use ~clk, maps to M_DATA[j/2]
//   // Even j (0,2,4,...16): use clk,  maps to M_DATA[j/2]
//   generate
//     for (j = 1; j < NUM_CHANNELS; j = j + 1) begin : pdms_gen
//       cic_decimator #(
//           .DATA_WIDTH(CIC_DATA_WIDTH),
//           .CIC_STAGES(4),
//           .CIC_DECIMATION(50)
//       ) cic_stage (
//           .clk         (j[0] ? ~clk : clk),    // Odd: ~clk, Even: clk
//           .rst         (~rst),
//           .pdm_clk     (pdm_clk),
//           .pdm_data    (M_DATA[j/2]),          // Integer division: 0,1→0, 2,3→1, etc.
//           .pcm_valid   (),
//           .pcm_data    (mics_data[j*CIC_DATA_WIDTH +: CIC_DATA_WIDTH]),
//           .overflow    (cic_overflow[j]),
//           .sample_count()
//       );
//     end
//   endgenerate


  // New beamforming module with packed array interface
  beamforming #(
      .NUM_CONFIGS(NUM_CONFIGS),
      .NUM_CHANNELS(NUM_CHANNELS),
      .DATA_WIDTH(CIC_DATA_WIDTH)
  ) u_beamforming_module (
      .clk(clk),
      .rst(~rst),
      .mics_data(mics_data),
      .mics_data_valid(mics_data_valid),
      .beamformed_sum(beamformed_sum),
      .beamformed_valid(beamformed_valid)
  );

  system system_i (
      .led_sel(led_sel),
      .mics(beam_data),
      .beam_valid(beamformed_valid),
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
