module beamforming (
    input wire clk,
    input wire rst,
    input wire [479:0] mics_data,
    input wire mics_data_valid,
    output wire [20:0] beamformed_sum_0,
    output wire [20:0] beamformed_sum_1,
    output wire [20:0] beamformed_sum_2,
    output wire [20:0] beamformed_sum_3,
    output wire [20:0] beamformed_sum_4,
    output wire [20:0] beamformed_sum_5,
    output wire [20:0] beamformed_sum_6,
    output wire [20:0] beamformed_sum_7,
    output wire [20:0] beamformed_sum_8,
    output wire [20:0] beamformed_sum_9,
    output wire [20:0] beamformed_sum_10,
    output wire [20:0] beamformed_sum_11,
    output wire [20:0] beamformed_sum_12,
    output wire [20:0] beamformed_sum_13,
    output wire [20:0] beamformed_sum_14,
    output wire [20:0] beamformed_sum_15,
    output wire [20:0] beamformed_sum_16,
    output wire [20:0] beamformed_sum_17,
    output wire [20:0] beamformed_sum_18,
    output wire [20:0] beamformed_sum_19,
    output wire [20:0] beamformed_sum_20,
    output wire [20:0] beamformed_sum_21,
    output wire [20:0] beamformed_sum_22,
    output wire [20:0] beamformed_sum_23,
    output wire [20:0] beamformed_sum_24,
    output wire [20:0] beamformed_sum_25,
    output wire [20:0] beamformed_sum_26,
    output wire [20:0] beamformed_sum_27,
    output wire [20:0] beamformed_sum_28,
    output wire [20:0] beamformed_sum_29
);

  wire [15:0] delayed_data[29:0][29:0];
  wire [20:0] sum[29:0];  
  
  genvar i;
  
  generate
    for (i = 0; i < 30; i = i + 1) begin : gen_delay_module_instances
      delay_module u_delay_module (
          .clk(clk),
          .rst(rst),
          .delay_select(i + 1),
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
          .delayed_pcm_data_0(delayed_data[i][0]),
          .delayed_pcm_data_1(delayed_data[i][1]),
          .delayed_pcm_data_2(delayed_data[i][2]),
          .delayed_pcm_data_3(delayed_data[i][3]),
          .delayed_pcm_data_4(delayed_data[i][4]),
          .delayed_pcm_data_5(delayed_data[i][5]),
          .delayed_pcm_data_6(delayed_data[i][6]),
          .delayed_pcm_data_7(delayed_data[i][7]),
          .delayed_pcm_data_8(delayed_data[i][8]),
          .delayed_pcm_data_9(delayed_data[i][9]),
          .delayed_pcm_data_10(delayed_data[i][10]),
          .delayed_pcm_data_11(delayed_data[i][11]),
          .delayed_pcm_data_12(delayed_data[i][12]),
          .delayed_pcm_data_13(delayed_data[i][13]),
          .delayed_pcm_data_14(delayed_data[i][14]),
          .delayed_pcm_data_15(delayed_data[i][15]),
          .delayed_pcm_data_16(delayed_data[i][16]),
          .delayed_pcm_data_17(delayed_data[i][17]),
          .delayed_pcm_data_18(delayed_data[i][18]),
          .delayed_pcm_data_19(delayed_data[i][19]),
          .delayed_pcm_data_20(delayed_data[i][20]),
          .delayed_pcm_data_21(delayed_data[i][21]),
          .delayed_pcm_data_22(delayed_data[i][22]),
          .delayed_pcm_data_23(delayed_data[i][23]),
          .delayed_pcm_data_24(delayed_data[i][24]),
          .delayed_pcm_data_25(delayed_data[i][25]),
          .delayed_pcm_data_26(delayed_data[i][26]),
          .delayed_pcm_data_27(delayed_data[i][27]),
          .delayed_pcm_data_28(delayed_data[i][28]),
          .delayed_pcm_data_29(delayed_data[i][29]),
          .pcm_valid(mics_data_valid)
      );
    end
  endgenerate

  generate
    for (i = 0; i < 30; i = i + 1) begin : gen_beamforming_sum_advanced
      adder_30x16 u_adder_30x (
          .in0(delayed_data[0][i]),
          .in1(delayed_data[1][i]),
          .in2(delayed_data[2][i]),
          .in3(delayed_data[3][i]),
          .in4(delayed_data[4][i]),
          .in5(delayed_data[5][i]),
          .in6(delayed_data[6][i]),
          .in7(delayed_data[7][i]),
          .in8(delayed_data[8][i]),
          .in9(delayed_data[9][i]),
          .in10(delayed_data[10][i]),
          .in11(delayed_data[11][i]),
          .in12(delayed_data[12][i]),
          .in13(delayed_data[13][i]),
          .in14(delayed_data[14][i]),
          .in15(delayed_data[15][i]),
          .in16(delayed_data[16][i]),
          .in17(delayed_data[17][i]),
          .in18(delayed_data[18][i]),
          .in19(delayed_data[19][i]),
          .in20(delayed_data[20][i]),
          .in21(delayed_data[21][i]),
          .in22(delayed_data[22][i]),
          .in23(delayed_data[23][i]),
          .in24(delayed_data[24][i]),
          .in25(delayed_data[25][i]),
          .in26(delayed_data[26][i]),
          .in27(delayed_data[27][i]),
          .in28(delayed_data[28][i]),
          .in29(delayed_data[29][i]),
          .sum(sum[i])
      );
    end
  endgenerate

  assign beamformed_sum_0 = sum[0];
  assign beamformed_sum_1 = sum[1];
  assign beamformed_sum_2 = sum[2];
  assign beamformed_sum_3 = sum[3];
  assign beamformed_sum_4 = sum[4];
  assign beamformed_sum_5 = sum[5];
  assign beamformed_sum_6 = sum[6];
  assign beamformed_sum_7 = sum[7];
  assign beamformed_sum_8 = sum[8];
  assign beamformed_sum_9 = sum[9];
  assign beamformed_sum_10 =sum[10];
  assign beamformed_sum_11 =sum[11];
  assign beamformed_sum_12 =sum[12];
  assign beamformed_sum_13 =sum[13];
  assign beamformed_sum_14 =sum[14];
  assign beamformed_sum_15 =sum[15];
  assign beamformed_sum_16 =sum[16];
  assign beamformed_sum_17 =sum[17];
  assign beamformed_sum_18 =sum[18];
  assign beamformed_sum_19 =sum[19];
  assign beamformed_sum_20 =sum[20];
  assign beamformed_sum_21 =sum[21];
  assign beamformed_sum_22 =sum[22];
  assign beamformed_sum_23 =sum[23];
  assign beamformed_sum_24 =sum[24];
  assign beamformed_sum_25 =sum[25];
  assign beamformed_sum_26 =sum[26];
  assign beamformed_sum_27 =sum[27];
  assign beamformed_sum_28 =sum[28];
  assign beamformed_sum_29 =sum[29];

endmodule