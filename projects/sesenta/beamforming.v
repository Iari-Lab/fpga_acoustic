
module beamforming (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [479:0] mics_data,
    input wire mics_data_valid,
    output wire [31:0] beamformed_sum_0,
    output wire [31:0] beamformed_sum_1,
    output wire [31:0] beamformed_sum_2,
    output wire [31:0] beamformed_sum_3,
    output wire [31:0] beamformed_sum_4,
    output wire [31:0] beamformed_sum_5,
    output wire [31:0] beamformed_sum_6,
    output wire [31:0] beamformed_sum_7,
    output wire [31:0] beamformed_sum_8,
    output wire [31:0] beamformed_sum_9,
    output wire [31:0] beamformed_sum_10,
    output wire [31:0] beamformed_sum_11,
    output wire [31:0] beamformed_sum_12,
    output wire [31:0] beamformed_sum_13,
    output wire [31:0] beamformed_sum_14,
    output wire [31:0] beamformed_sum_15,
    output wire [31:0] beamformed_sum_16,
    output wire [31:0] beamformed_sum_17,
    output wire [31:0] beamformed_sum_18,
    output wire [31:0] beamformed_sum_19,
    output wire [31:0] beamformed_sum_20,
    output wire [31:0] beamformed_sum_21,
    output wire [31:0] beamformed_sum_22,
    output wire [31:0] beamformed_sum_23,
    output wire [31:0] beamformed_sum_24,
    output wire [31:0] beamformed_sum_25,
    output wire [31:0] beamformed_sum_26,
    output wire [31:0] beamformed_sum_27,
    output wire [31:0] beamformed_sum_28,
    output wire [31:0] beamformed_sum_29
);

  localparam ACCUMULATION_COUNT = 2048;
  localparam COUNTER_WIDTH = 11;

  wire [15:0] delayed_data[29:0][29:0];
  wire [31:0] sum[29:0];
  
  reg [COUNTER_WIDTH-1:0] accumulation_counter;
  reg accumulating;
  
  reg [63:0] accumulated_sum[29:0];
  
  genvar i;
  
  generate
    for (i = 0; i < 30; i = i + 1) begin : delay_module_instances
      delay_module u_delay_module (
          .clk(clk),
          .rst(~rst),
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
    for (i = 0; i < 30; i = i + 1) begin : beamforming_sum
      assign sum[i] = $signed(delayed_data[0][i]) + $signed(delayed_data[1][i]) + 
                      $signed(delayed_data[2][i]) + $signed(delayed_data[3][i]) + 
                      $signed(delayed_data[4][i]) + $signed(delayed_data[5][i]) + 
                      $signed(delayed_data[6][i]) + $signed(delayed_data[7][i]) + 
                      $signed(delayed_data[8][i]) + $signed(delayed_data[9][i]) + 
                      $signed(delayed_data[10][i]) + $signed(delayed_data[11][i]) + 
                      $signed(delayed_data[12][i]) + $signed(delayed_data[13][i]) + 
                      $signed(delayed_data[14][i]) + $signed(delayed_data[15][i]) + 
                      $signed(delayed_data[16][i]) + $signed(delayed_data[17][i]) + 
                      $signed(delayed_data[18][i]) + $signed(delayed_data[19][i]) + 
                      $signed(delayed_data[20][i]) + $signed(delayed_data[21][i]) + 
                      $signed(delayed_data[22][i]) + $signed(delayed_data[23][i]) + 
                      $signed(delayed_data[24][i]) + $signed(delayed_data[25][i]) + 
                      $signed(delayed_data[26][i]) + $signed(delayed_data[27][i]) + 
                      $signed(delayed_data[28][i]) + $signed(delayed_data[29][i]);
    end
  endgenerate

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      accumulation_counter <= 0;
      accumulating <= 1'b0;
      for (int j = 0; j < 30; j = j + 1) begin
        accumulated_sum[j] <= 64'b0;
      end
    end else begin
      if (start) begin
        accumulation_counter <= 0;
        for (int j = 0; j < 30; j = j + 1) begin
          accumulated_sum[j] <= 64'b0;
        end
      end else if (mics_data_valid) begin
        if (accumulation_counter < ACCUMULATION_COUNT - 1) begin
          accumulation_counter <= accumulation_counter + 1;
          for (int j = 0; j < 30; j = j + 1) begin
            accumulated_sum[j] <= accumulated_sum[j] + $signed(sum[j]);
          end
      end
    end
  end

  assign beamformed_sum_0 = accumulated_sum[0][31:0];
  assign beamformed_sum_1 = accumulated_sum[1][31:0];
  assign beamformed_sum_2 = accumulated_sum[2][31:0];
  assign beamformed_sum_3 = accumulated_sum[3][31:0];
  assign beamformed_sum_4 = accumulated_sum[4][31:0];
  assign beamformed_sum_5 = accumulated_sum[5][31:0];
  assign beamformed_sum_6 = accumulated_sum[6][31:0];
  assign beamformed_sum_7 = accumulated_sum[7][31:0];
  assign beamformed_sum_8 = accumulated_sum[8][31:0];
  assign beamformed_sum_9 = accumulated_sum[9][31:0];
  assign beamformed_sum_10 = accumulated_sum[10][31:0];
  assign beamformed_sum_11 = accumulated_sum[11][31:0];
  assign beamformed_sum_12 = accumulated_sum[12][31:0];
  assign beamformed_sum_13 = accumulated_sum[13][31:0];
  assign beamformed_sum_14 = accumulated_sum[14][31:0];
  assign beamformed_sum_15 = accumulated_sum[15][31:0];
  assign beamformed_sum_16 = accumulated_sum[16][31:0];
  assign beamformed_sum_17 = accumulated_sum[17][31:0];
  assign beamformed_sum_18 = accumulated_sum[18][31:0];
  assign beamformed_sum_19 = accumulated_sum[19][31:0];
  assign beamformed_sum_20 = accumulated_sum[20][31:0];
  assign beamformed_sum_21 = accumulated_sum[21][31:0];
  assign beamformed_sum_22 = accumulated_sum[22][31:0];
  assign beamformed_sum_23 = accumulated_sum[23][31:0];
  assign beamformed_sum_24 = accumulated_sum[24][31:0];
  assign beamformed_sum_25 = accumulated_sum[25][31:0];
  assign beamformed_sum_26 = accumulated_sum[26][31:0];
  assign beamformed_sum_27 = accumulated_sum[27][31:0];
  assign beamformed_sum_28 = accumulated_sum[28][31:0];
  assign beamformed_sum_29 = accumulated_sum[29][31:0];

endmodule
