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
  localparam integer DATA_WIDTH = 960;  // 30 mics * 21 bits
  localparam integer MICS_DATA_WIDTH = 480;  // 30 mics * 16 bits
  localparam CIC_DATA_WIDTH = 16;
  wire clk, clk_leds, rst, pdm_clk;  //start


  wire clk_rising_mics;
  wire mics_data_valid;
  wire [MICS_DATA_WIDTH-1:0] mics_data;
  wire [DATA_WIDTH-1:0] beam_data;
  // Manual LED control signals
  reg pcm_valid;
  initial begin
    reg_mics_data = 960'b0;
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
    reg_mics_data[21*32+:32] <= {{11{beamformed_sum_21[20]}}, beamformed_sum_21};
    reg_mics_data[22*32+:32] <= {{11{beamformed_sum_22[20]}}, beamformed_sum_22};
    reg_mics_data[23*32+:32] <= {{11{beamformed_sum_23[20]}}, beamformed_sum_23};
    reg_mics_data[24*32+:32] <= {{11{beamformed_sum_24[20]}}, beamformed_sum_24};
    reg_mics_data[25*32+:32] <= {{11{beamformed_sum_25[20]}}, beamformed_sum_25};
    reg_mics_data[26*32+:32] <= {{11{beamformed_sum_26[20]}}, beamformed_sum_26};
    reg_mics_data[27*32+:32] <= {{11{beamformed_sum_27[20]}}, beamformed_sum_27};
    reg_mics_data[28*32+:32] <= {{11{beamformed_sum_28[20]}}, beamformed_sum_28};
    reg_mics_data[29*32+:32] <= {{11{beamformed_sum_29[20]}}, beamformed_sum_29};
    pcm_valid <= mics_data_valid;
  end
//   always @(posedge clk) begin
//     reg_mics_data[0*21+:21] <= beamformed_sum_0;
//     reg_mics_data[1*21+:21] <= beamformed_sum_1;
//     reg_mics_data[2*21+:21] <= beamformed_sum_2;
//     reg_mics_data[3*21+:21] <= beamformed_sum_3;
//     reg_mics_data[4*21+:21] <= beamformed_sum_4;
//     reg_mics_data[5*21+:21] <= beamformed_sum_5;
//     reg_mics_data[6*21+:21] <= beamformed_sum_6;
//     reg_mics_data[7*21+:21] <= beamformed_sum_7;
//     reg_mics_data[8*21+:21] <= beamformed_sum_8;
//     reg_mics_data[9*21+:21] <= beamformed_sum_9;
//     reg_mics_data[10*21+:21] <= beamformed_sum_10;
//     reg_mics_data[11*21+:21] <= beamformed_sum_11;
//     reg_mics_data[12*21+:21] <= beamformed_sum_12;
//     reg_mics_data[13*21+:21] <= beamformed_sum_13;
//     reg_mics_data[14*21+:21] <= beamformed_sum_14;
//     reg_mics_data[15*21+:21] <= beamformed_sum_15;
//     reg_mics_data[16*21+:21] <= beamformed_sum_16;
//     reg_mics_data[17*21+:21] <= beamformed_sum_17;
//     reg_mics_data[18*21+:21] <= beamformed_sum_18;
//     reg_mics_data[19*21+:21] <= beamformed_sum_19;
//     reg_mics_data[20*21+:21] <= beamformed_sum_20;
//     reg_mics_data[21*21+:21] <= beamformed_sum_21;
//     reg_mics_data[22*21+:21] <= beamformed_sum_22;
//     reg_mics_data[23*21+:21] <= beamformed_sum_23;
//     reg_mics_data[24*21+:21] <= beamformed_sum_24;
//     reg_mics_data[25*21+:21] <= beamformed_sum_25;
//     reg_mics_data[26*21+:21] <= beamformed_sum_26;
//     reg_mics_data[27*21+:21] <= beamformed_sum_27;
//     reg_mics_data[28*21+:21] <= beamformed_sum_28;
//     reg_mics_data[29*21+:21] <= beamformed_sum_29;
//   end
  assign beam_data = reg_mics_data;

  wire [20:0] beamformed_sum_0, beamformed_sum_1, beamformed_sum_2, beamformed_sum_3, beamformed_sum_4;
  wire [20:0] beamformed_sum_5, beamformed_sum_6, beamformed_sum_7, beamformed_sum_8, beamformed_sum_9;
  wire [20:0] beamformed_sum_10, beamformed_sum_11, beamformed_sum_12, beamformed_sum_13, beamformed_sum_14;
  wire [20:0] beamformed_sum_15, beamformed_sum_16, beamformed_sum_17, beamformed_sum_18, beamformed_sum_19;
  wire [20:0] beamformed_sum_20, beamformed_sum_21, beamformed_sum_22, beamformed_sum_23, beamformed_sum_24;
  wire [20:0] beamformed_sum_25, beamformed_sum_26, beamformed_sum_27, beamformed_sum_28, beamformed_sum_29;

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

    // ila_1 ila_bram1 (
    //     .clk(clk),  // input wire clk
    //     .probe0(sum_dbg)
    // );
    ila_0 ila_bram (
        .clk(clk),  // input wire clk
        .probe0(led_sel),
        .probe1(sum_dbg),
        .probe2(mics_data_valid)
    );
//   ila_0 ila_bram (
//       .clk(clk),  // input wire clk
//       .probe0(led_sel),
//       .probe1(mics_data_valid),
//       .probe2(mic_dbg),
//       .probe3(mic_sel)
//   );
  
    wire [ 7:0] mic_sel, mic_sel_safe;  // 5 bits to select from 30 cases
    // 2 ff sincronizer for mic_sel
    reg [7:0] mic_sel_ff1, mic_sel_ff2, mic_sel_ff3, mic_sel_ff4;
    always @(posedge clk) begin
      mic_sel_ff1 <= mic_sel;
      mic_sel_ff2 <= mic_sel_ff1;
      mic_sel_ff3 <= mic_sel_ff2;
      mic_sel_ff4 <= mic_sel_ff3;
    end 
    assign mic_sel_safe = mic_sel_ff4;
    // wire [15:0] mic_dbg;
    wire [31:0] sum_dbg;
    // assign mic_dbg = mics_data[16*mic_sel_safe+:16];
    assign sum_dbg = reg_mics_data[32*mic_sel_safe+:32];
    
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
      .beamformed_sum_20(beamformed_sum_20),
      .beamformed_sum_21(beamformed_sum_21),
      .beamformed_sum_22(beamformed_sum_22),
      .beamformed_sum_23(beamformed_sum_23),
      .beamformed_sum_24(beamformed_sum_24),
      .beamformed_sum_25(beamformed_sum_25),
      .beamformed_sum_26(beamformed_sum_26),
      .beamformed_sum_27(beamformed_sum_27),
      .beamformed_sum_28(beamformed_sum_28),
      .beamformed_sum_29(beamformed_sum_29)
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
