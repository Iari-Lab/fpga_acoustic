// Delay module for 30 microphones
// 30 delay cases (one for each source microphone M0-M29)
// Each case assigns delays to all 30 microphones
module delay_module (
    input wire clk,
    input wire rst,
    input wire [4:0] delay_select,  // 5 bits to select from 30 cases (1-30)
    input wire pcm_valid,
    input wire [15:0] pcm_data_0,
    input wire [15:0] pcm_data_1,
    input wire [15:0] pcm_data_2,
    input wire [15:0] pcm_data_3,
    input wire [15:0] pcm_data_4,
    input wire [15:0] pcm_data_5,
    input wire [15:0] pcm_data_6,
    input wire [15:0] pcm_data_7,
    input wire [15:0] pcm_data_8,
    input wire [15:0] pcm_data_9,
    input wire [15:0] pcm_data_10,
    input wire [15:0] pcm_data_11,
    input wire [15:0] pcm_data_12,
    input wire [15:0] pcm_data_13,
    input wire [15:0] pcm_data_14,
    input wire [15:0] pcm_data_15,
    input wire [15:0] pcm_data_16,
    input wire [15:0] pcm_data_17,
    input wire [15:0] pcm_data_18,
    input wire [15:0] pcm_data_19,
    input wire [15:0] pcm_data_20,
    input wire [15:0] pcm_data_21,
    input wire [15:0] pcm_data_22,
    input wire [15:0] pcm_data_23,
    input wire [15:0] pcm_data_24,
    input wire [15:0] pcm_data_25,
    input wire [15:0] pcm_data_26,
    input wire [15:0] pcm_data_27,
    input wire [15:0] pcm_data_28,
    input wire [15:0] pcm_data_29,
    output wire [15:0] delayed_pcm_data_0,
    output wire [15:0] delayed_pcm_data_1,
    output wire [15:0] delayed_pcm_data_2,
    output wire [15:0] delayed_pcm_data_3,
    output wire [15:0] delayed_pcm_data_4,
    output wire [15:0] delayed_pcm_data_5,
    output wire [15:0] delayed_pcm_data_6,
    output wire [15:0] delayed_pcm_data_7,
    output wire [15:0] delayed_pcm_data_8,
    output wire [15:0] delayed_pcm_data_9,
    output wire [15:0] delayed_pcm_data_10,
    output wire [15:0] delayed_pcm_data_11,
    output wire [15:0] delayed_pcm_data_12,
    output wire [15:0] delayed_pcm_data_13,
    output wire [15:0] delayed_pcm_data_14,
    output wire [15:0] delayed_pcm_data_15,
    output wire [15:0] delayed_pcm_data_16,
    output wire [15:0] delayed_pcm_data_17,
    output wire [15:0] delayed_pcm_data_18,
    output wire [15:0] delayed_pcm_data_19,
    output wire [15:0] delayed_pcm_data_20,
    output wire [15:0] delayed_pcm_data_21,
    output wire [15:0] delayed_pcm_data_22,
    output wire [15:0] delayed_pcm_data_23,
    output wire [15:0] delayed_pcm_data_24,
    output wire [15:0] delayed_pcm_data_25,
    output wire [15:0] delayed_pcm_data_26,
    output wire [15:0] delayed_pcm_data_27,
    output wire [15:0] delayed_pcm_data_28,
    output wire [15:0] delayed_pcm_data_29
);

  wire [15:0] pcm_data[29:0];
  wire [15:0] delayed_pcm_data[29:0];
  reg [4:0] mic_delays[29:0];
  reg [5:0] x;

  // Initialize delays
  initial begin
    for (x = 0; x < 30; x = x + 1) begin
      mic_delays[x] = 0;
    end
  end

  assign pcm_data[0] = pcm_data_0;
  assign pcm_data[1] = pcm_data_1;
  assign pcm_data[2] = pcm_data_2;
  assign pcm_data[3] = pcm_data_3;
  assign pcm_data[4] = pcm_data_4;
  assign pcm_data[5] = pcm_data_5;
  assign pcm_data[6] = pcm_data_6;
  assign pcm_data[7] = pcm_data_7;
  assign pcm_data[8] = pcm_data_8;
  assign pcm_data[9] = pcm_data_9;
  assign pcm_data[10] = pcm_data_10;
  assign pcm_data[11] = pcm_data_11;
  assign pcm_data[12] = pcm_data_12;
  assign pcm_data[13] = pcm_data_13;
  assign pcm_data[14] = pcm_data_14;
  assign pcm_data[15] = pcm_data_15;
  assign pcm_data[16] = pcm_data_16;
  assign pcm_data[17] = pcm_data_17;
  assign pcm_data[18] = pcm_data_18;
  assign pcm_data[19] = pcm_data_19;
  assign pcm_data[20] = pcm_data_20;
  assign pcm_data[21] = pcm_data_21;
  assign pcm_data[22] = pcm_data_22;
  assign pcm_data[23] = pcm_data_23;
  assign pcm_data[24] = pcm_data_24;
  assign pcm_data[25] = pcm_data_25;
  assign pcm_data[26] = pcm_data_26;
  assign pcm_data[27] = pcm_data_27;
  assign pcm_data[28] = pcm_data_28;
  assign pcm_data[29] = pcm_data_29;

  assign delayed_pcm_data_0 = delayed_pcm_data[0];
  assign delayed_pcm_data_1 = delayed_pcm_data[1];
  assign delayed_pcm_data_2 = delayed_pcm_data[2];
  assign delayed_pcm_data_3 = delayed_pcm_data[3];
  assign delayed_pcm_data_4 = delayed_pcm_data[4];
  assign delayed_pcm_data_5 = delayed_pcm_data[5];
  assign delayed_pcm_data_6 = delayed_pcm_data[6];
  assign delayed_pcm_data_7 = delayed_pcm_data[7];
  assign delayed_pcm_data_8 = delayed_pcm_data[8];
  assign delayed_pcm_data_9 = delayed_pcm_data[9];
  assign delayed_pcm_data_10 = delayed_pcm_data[10];
  assign delayed_pcm_data_11 = delayed_pcm_data[11];
  assign delayed_pcm_data_12 = delayed_pcm_data[12];
  assign delayed_pcm_data_13 = delayed_pcm_data[13];
  assign delayed_pcm_data_14 = delayed_pcm_data[14];
  assign delayed_pcm_data_15 = delayed_pcm_data[15];
  assign delayed_pcm_data_16 = delayed_pcm_data[16];
  assign delayed_pcm_data_17 = delayed_pcm_data[17];
  assign delayed_pcm_data_18 = delayed_pcm_data[18];
  assign delayed_pcm_data_19 = delayed_pcm_data[19];
  assign delayed_pcm_data_20 = delayed_pcm_data[20];
  assign delayed_pcm_data_21 = delayed_pcm_data[21];
  assign delayed_pcm_data_22 = delayed_pcm_data[22];
  assign delayed_pcm_data_23 = delayed_pcm_data[23];
  assign delayed_pcm_data_24 = delayed_pcm_data[24];
  assign delayed_pcm_data_25 = delayed_pcm_data[25];
  assign delayed_pcm_data_26 = delayed_pcm_data[26];
  assign delayed_pcm_data_27 = delayed_pcm_data[27];
  assign delayed_pcm_data_28 = delayed_pcm_data[28];
  assign delayed_pcm_data_29 = delayed_pcm_data[29];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (x = 0; x < 30; x = x + 1) begin
        mic_delays[x] <= 0;
      end
    end else begin
      case (delay_select)
        // Case 0: Source M0
        0: begin
          mic_delays[0] <= 0;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 0;   // M6
          mic_delays[4] <= 0;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 1;   // M18
          mic_delays[10] <= 1;   // M20
          mic_delays[11] <= 1;   // M22
          mic_delays[12] <= 1;   // M24
          mic_delays[13] <= 2;   // M26
          mic_delays[14] <= 2;   // M28
          mic_delays[15] <= 2;   // M30
          mic_delays[16] <= 2;   // M32
          mic_delays[17] <= 1;   // M34
          mic_delays[18] <= 2;   // M36
          mic_delays[19] <= 1;   // M38
          mic_delays[20] <= 1;   // M40
          mic_delays[21] <= 2;   // M42
          mic_delays[22] <= 2;   // M44
          mic_delays[23] <= 3;   // M46
          mic_delays[24] <= 3;   // M48
          mic_delays[25] <= 4;   // M50
          mic_delays[26] <= 4;   // M52
          mic_delays[27] <= 3;   // M54
          mic_delays[28] <= 3;   // M56
          mic_delays[29] <= 2;   // M58
        end

        // Case 1: Source M2
        1: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 0;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 0;   // M10
          mic_delays[6] <= 0;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 2;   // M18
          mic_delays[10] <= 2;   // M20
          mic_delays[11] <= 1;   // M22
          mic_delays[12] <= 1;   // M24
          mic_delays[13] <= 1;   // M26
          mic_delays[14] <= 1;   // M28
          mic_delays[15] <= 1;   // M30
          mic_delays[16] <= 2;   // M32
          mic_delays[17] <= 2;   // M34
          mic_delays[18] <= 4;   // M36
          mic_delays[19] <= 3;   // M38
          mic_delays[20] <= 3;   // M40
          mic_delays[21] <= 2;   // M42
          mic_delays[22] <= 2;   // M44
          mic_delays[23] <= 1;   // M46
          mic_delays[24] <= 1;   // M48
          mic_delays[25] <= 2;   // M50
          mic_delays[26] <= 2;   // M52
          mic_delays[27] <= 3;   // M54
          mic_delays[28] <= 3;   // M56
          mic_delays[29] <= 4;   // M58
        end

        // Case 2: Source M4
        2: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 0;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 0;   // M14
          mic_delays[8] <= 0;   // M16
          mic_delays[9] <= 1;   // M18
          mic_delays[10] <= 2;   // M20
          mic_delays[11] <= 2;   // M22
          mic_delays[12] <= 2;   // M24
          mic_delays[13] <= 2;   // M26
          mic_delays[14] <= 1;   // M28
          mic_delays[15] <= 1;   // M30
          mic_delays[16] <= 1;   // M32
          mic_delays[17] <= 1;   // M34
          mic_delays[18] <= 2;   // M36
          mic_delays[19] <= 3;   // M38
          mic_delays[20] <= 3;   // M40
          mic_delays[21] <= 4;   // M42
          mic_delays[22] <= 4;   // M44
          mic_delays[23] <= 3;   // M46
          mic_delays[24] <= 3;   // M48
          mic_delays[25] <= 2;   // M50
          mic_delays[26] <= 2;   // M52
          mic_delays[27] <= 1;   // M54
          mic_delays[28] <= 1;   // M56
          mic_delays[29] <= 2;   // M58
        end

        // Case 3: Source M6
        3: begin
          mic_delays[0] <= 0;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 0;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 2;   // M10
          mic_delays[6] <= 2;   // M12
          mic_delays[7] <= 2;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 0;   // M18
          mic_delays[10] <= 1;   // M20
          mic_delays[11] <= 1;   // M22
          mic_delays[12] <= 2;   // M24
          mic_delays[13] <= 4;   // M26
          mic_delays[14] <= 3;   // M28
          mic_delays[15] <= 3;   // M30
          mic_delays[16] <= 2;   // M32
          mic_delays[17] <= 1;   // M34
          mic_delays[18] <= 1;   // M36
          mic_delays[19] <= 1;   // M38
          mic_delays[20] <= 1;   // M40
          mic_delays[21] <= 2;   // M42
          mic_delays[22] <= 3;   // M44
          mic_delays[23] <= 4;   // M46
          mic_delays[24] <= 5;   // M48
          mic_delays[25] <= 5;   // M50
          mic_delays[26] <= 4;   // M52
          mic_delays[27] <= 3;   // M54
          mic_delays[28] <= 2;   // M56
          mic_delays[29] <= 1;   // M58
        end

        // Case 4: Source M8
        4: begin
          mic_delays[0] <= 0;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 0;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 2;   // M12
          mic_delays[7] <= 2;   // M14
          mic_delays[8] <= 2;   // M16
          mic_delays[9] <= 1;   // M18
          mic_delays[10] <= 1;   // M20
          mic_delays[11] <= 0;   // M22
          mic_delays[12] <= 1;   // M24
          mic_delays[13] <= 2;   // M26
          mic_delays[14] <= 3;   // M28
          mic_delays[15] <= 3;   // M30
          mic_delays[16] <= 4;   // M32
          mic_delays[17] <= 2;   // M34
          mic_delays[18] <= 2;   // M36
          mic_delays[19] <= 1;   // M38
          mic_delays[20] <= 1;   // M40
          mic_delays[21] <= 1;   // M42
          mic_delays[22] <= 1;   // M44
          mic_delays[23] <= 2;   // M46
          mic_delays[24] <= 3;   // M48
          mic_delays[25] <= 4;   // M50
          mic_delays[26] <= 5;   // M52
          mic_delays[27] <= 5;   // M54
          mic_delays[28] <= 4;   // M56
          mic_delays[29] <= 3;   // M58
        end

        // Case 5: Source M10
        5: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 0;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 2;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 0;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 2;   // M14
          mic_delays[8] <= 2;   // M16
          mic_delays[9] <= 3;   // M18
          mic_delays[10] <= 2;   // M20
          mic_delays[11] <= 1;   // M22
          mic_delays[12] <= 0;   // M24
          mic_delays[13] <= 1;   // M26
          mic_delays[14] <= 1;   // M28
          mic_delays[15] <= 2;   // M30
          mic_delays[16] <= 4;   // M32
          mic_delays[17] <= 3;   // M34
          mic_delays[18] <= 4;   // M36
          mic_delays[19] <= 3;   // M38
          mic_delays[20] <= 2;   // M40
          mic_delays[21] <= 1;   // M42
          mic_delays[22] <= 1;   // M44
          mic_delays[23] <= 1;   // M46
          mic_delays[24] <= 1;   // M48
          mic_delays[25] <= 2;   // M50
          mic_delays[26] <= 3;   // M52
          mic_delays[27] <= 4;   // M54
          mic_delays[28] <= 5;   // M56
          mic_delays[29] <= 5;   // M58
        end

        // Case 6: Source M12
        6: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 0;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 2;   // M6
          mic_delays[4] <= 2;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 0;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 2;   // M16
          mic_delays[9] <= 3;   // M18
          mic_delays[10] <= 4;   // M20
          mic_delays[11] <= 2;   // M22
          mic_delays[12] <= 1;   // M24
          mic_delays[13] <= 1;   // M26
          mic_delays[14] <= 0;   // M28
          mic_delays[15] <= 1;   // M30
          mic_delays[16] <= 2;   // M32
          mic_delays[17] <= 3;   // M34
          mic_delays[18] <= 5;   // M36
          mic_delays[19] <= 5;   // M38
          mic_delays[20] <= 4;   // M40
          mic_delays[21] <= 3;   // M42
          mic_delays[22] <= 2;   // M44
          mic_delays[23] <= 1;   // M46
          mic_delays[24] <= 1;   // M48
          mic_delays[25] <= 1;   // M50
          mic_delays[26] <= 1;   // M52
          mic_delays[27] <= 2;   // M54
          mic_delays[28] <= 3;   // M56
          mic_delays[29] <= 4;   // M58
        end

        // Case 7: Source M14
        7: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 0;   // M4
          mic_delays[3] <= 2;   // M6
          mic_delays[4] <= 2;   // M8
          mic_delays[5] <= 2;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 0;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 2;   // M18
          mic_delays[10] <= 4;   // M20
          mic_delays[11] <= 3;   // M22
          mic_delays[12] <= 3;   // M24
          mic_delays[13] <= 2;   // M26
          mic_delays[14] <= 1;   // M28
          mic_delays[15] <= 0;   // M30
          mic_delays[16] <= 1;   // M32
          mic_delays[17] <= 1;   // M34
          mic_delays[18] <= 3;   // M36
          mic_delays[19] <= 4;   // M38
          mic_delays[20] <= 5;   // M40
          mic_delays[21] <= 5;   // M42
          mic_delays[22] <= 4;   // M44
          mic_delays[23] <= 3;   // M46
          mic_delays[24] <= 2;   // M48
          mic_delays[25] <= 1;   // M50
          mic_delays[26] <= 1;   // M52
          mic_delays[27] <= 1;   // M54
          mic_delays[28] <= 1;   // M56
          mic_delays[29] <= 2;   // M58
        end

        // Case 8: Source M16
        8: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 0;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 2;   // M8
          mic_delays[5] <= 2;   // M10
          mic_delays[6] <= 2;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 0;   // M16
          mic_delays[9] <= 1;   // M18
          mic_delays[10] <= 2;   // M20
          mic_delays[11] <= 3;   // M22
          mic_delays[12] <= 3;   // M24
          mic_delays[13] <= 4;   // M26
          mic_delays[14] <= 2;   // M28
          mic_delays[15] <= 1;   // M30
          mic_delays[16] <= 1;   // M32
          mic_delays[17] <= 0;   // M34
          mic_delays[18] <= 1;   // M36
          mic_delays[19] <= 2;   // M38
          mic_delays[20] <= 3;   // M40
          mic_delays[21] <= 4;   // M42
          mic_delays[22] <= 5;   // M44
          mic_delays[23] <= 5;   // M46
          mic_delays[24] <= 4;   // M48
          mic_delays[25] <= 3;   // M50
          mic_delays[26] <= 2;   // M52
          mic_delays[27] <= 1;   // M54
          mic_delays[28] <= 1;   // M56
          mic_delays[29] <= 1;   // M58
        end

        // Case 9: Source M18
        9: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 2;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 0;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 3;   // M10
          mic_delays[6] <= 3;   // M12
          mic_delays[7] <= 2;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 0;   // M18
          mic_delays[10] <= 1;   // M20
          mic_delays[11] <= 2;   // M22
          mic_delays[12] <= 4;   // M24
          mic_delays[13] <= 5;   // M26
          mic_delays[14] <= 5;   // M28
          mic_delays[15] <= 4;   // M30
          mic_delays[16] <= 2;   // M32
          mic_delays[17] <= 1;   // M34
          mic_delays[18] <= 0;   // M36
          mic_delays[19] <= 1;   // M38
          mic_delays[20] <= 2;   // M40
          mic_delays[21] <= 3;   // M42
          mic_delays[22] <= 5;   // M44
          mic_delays[23] <= 6;   // M46
          mic_delays[24] <= 6;   // M48
          mic_delays[25] <= 6;   // M50
          mic_delays[26] <= 5;   // M52
          mic_delays[27] <= 4;   // M54
          mic_delays[28] <= 2;   // M56
          mic_delays[29] <= 1;   // M58
        end

        // Case 10: Source M20
        10: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 2;   // M2
          mic_delays[2] <= 2;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 2;   // M10
          mic_delays[6] <= 4;   // M12
          mic_delays[7] <= 4;   // M14
          mic_delays[8] <= 2;   // M16
          mic_delays[9] <= 1;   // M18
          mic_delays[10] <= 0;   // M20
          mic_delays[11] <= 1;   // M22
          mic_delays[12] <= 2;   // M24
          mic_delays[13] <= 5;   // M26
          mic_delays[14] <= 5;   // M28
          mic_delays[15] <= 5;   // M30
          mic_delays[16] <= 5;   // M32
          mic_delays[17] <= 2;   // M34
          mic_delays[18] <= 1;   // M36
          mic_delays[19] <= 0;   // M38
          mic_delays[20] <= 0;   // M40
          mic_delays[21] <= 1;   // M42
          mic_delays[22] <= 3;   // M44
          mic_delays[23] <= 5;   // M46
          mic_delays[24] <= 6;   // M48
          mic_delays[25] <= 7;   // M50
          mic_delays[26] <= 7;   // M52
          mic_delays[27] <= 6;   // M54
          mic_delays[28] <= 5;   // M56
          mic_delays[29] <= 3;   // M58
        end

        // Case 11: Source M22
        11: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 2;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 0;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 2;   // M12
          mic_delays[7] <= 3;   // M14
          mic_delays[8] <= 3;   // M16
          mic_delays[9] <= 2;   // M18
          mic_delays[10] <= 1;   // M20
          mic_delays[11] <= 0;   // M22
          mic_delays[12] <= 1;   // M24
          mic_delays[13] <= 2;   // M26
          mic_delays[14] <= 4;   // M28
          mic_delays[15] <= 5;   // M30
          mic_delays[16] <= 5;   // M32
          mic_delays[17] <= 4;   // M34
          mic_delays[18] <= 3;   // M36
          mic_delays[19] <= 2;   // M38
          mic_delays[20] <= 1;   // M40
          mic_delays[21] <= 0;   // M42
          mic_delays[22] <= 1;   // M44
          mic_delays[23] <= 2;   // M46
          mic_delays[24] <= 4;   // M48
          mic_delays[25] <= 5;   // M50
          mic_delays[26] <= 6;   // M52
          mic_delays[27] <= 6;   // M54
          mic_delays[28] <= 6;   // M56
          mic_delays[29] <= 5;   // M58
        end

        // Case 12: Source M24
        12: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 2;   // M4
          mic_delays[3] <= 2;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 0;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 3;   // M14
          mic_delays[8] <= 3;   // M16
          mic_delays[9] <= 4;   // M18
          mic_delays[10] <= 2;   // M20
          mic_delays[11] <= 1;   // M22
          mic_delays[12] <= 0;   // M24
          mic_delays[13] <= 1;   // M26
          mic_delays[14] <= 2;   // M28
          mic_delays[15] <= 4;   // M30
          mic_delays[16] <= 5;   // M32
          mic_delays[17] <= 5;   // M34
          mic_delays[18] <= 5;   // M36
          mic_delays[19] <= 4;   // M38
          mic_delays[20] <= 2;   // M40
          mic_delays[21] <= 1;   // M42
          mic_delays[22] <= 0;   // M44
          mic_delays[23] <= 1;   // M46
          mic_delays[24] <= 2;   // M48
          mic_delays[25] <= 3;   // M50
          mic_delays[26] <= 5;   // M52
          mic_delays[27] <= 6;   // M54
          mic_delays[28] <= 6;   // M56
          mic_delays[29] <= 6;   // M58
        end

        // Case 13: Source M26
        13: begin
          mic_delays[0] <= 2;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 2;   // M4
          mic_delays[3] <= 4;   // M6
          mic_delays[4] <= 2;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 2;   // M14
          mic_delays[8] <= 4;   // M16
          mic_delays[9] <= 5;   // M18
          mic_delays[10] <= 5;   // M20
          mic_delays[11] <= 2;   // M22
          mic_delays[12] <= 1;   // M24
          mic_delays[13] <= 0;   // M26
          mic_delays[14] <= 1;   // M28
          mic_delays[15] <= 2;   // M30
          mic_delays[16] <= 5;   // M32
          mic_delays[17] <= 5;   // M34
          mic_delays[18] <= 7;   // M36
          mic_delays[19] <= 6;   // M38
          mic_delays[20] <= 5;   // M40
          mic_delays[21] <= 3;   // M42
          mic_delays[22] <= 1;   // M44
          mic_delays[23] <= 0;   // M46
          mic_delays[24] <= 0;   // M48
          mic_delays[25] <= 1;   // M50
          mic_delays[26] <= 3;   // M52
          mic_delays[27] <= 5;   // M54
          mic_delays[28] <= 6;   // M56
          mic_delays[29] <= 7;   // M58
        end

        // Case 14: Source M28
        14: begin
          mic_delays[0] <= 2;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 3;   // M6
          mic_delays[4] <= 3;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 0;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 2;   // M16
          mic_delays[9] <= 5;   // M18
          mic_delays[10] <= 5;   // M20
          mic_delays[11] <= 4;   // M22
          mic_delays[12] <= 2;   // M24
          mic_delays[13] <= 1;   // M26
          mic_delays[14] <= 0;   // M28
          mic_delays[15] <= 1;   // M30
          mic_delays[16] <= 2;   // M32
          mic_delays[17] <= 4;   // M34
          mic_delays[18] <= 6;   // M36
          mic_delays[19] <= 6;   // M38
          mic_delays[20] <= 6;   // M40
          mic_delays[21] <= 5;   // M42
          mic_delays[22] <= 3;   // M44
          mic_delays[23] <= 2;   // M46
          mic_delays[24] <= 1;   // M48
          mic_delays[25] <= 0;   // M50
          mic_delays[26] <= 1;   // M52
          mic_delays[27] <= 2;   // M54
          mic_delays[28] <= 4;   // M56
          mic_delays[29] <= 5;   // M58
        end

        // Case 15: Source M30
        15: begin
          mic_delays[0] <= 2;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 3;   // M6
          mic_delays[4] <= 3;   // M8
          mic_delays[5] <= 2;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 0;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 4;   // M18
          mic_delays[10] <= 5;   // M20
          mic_delays[11] <= 5;   // M22
          mic_delays[12] <= 4;   // M24
          mic_delays[13] <= 2;   // M26
          mic_delays[14] <= 1;   // M28
          mic_delays[15] <= 0;   // M30
          mic_delays[16] <= 1;   // M32
          mic_delays[17] <= 2;   // M34
          mic_delays[18] <= 5;   // M36
          mic_delays[19] <= 6;   // M38
          mic_delays[20] <= 6;   // M40
          mic_delays[21] <= 6;   // M42
          mic_delays[22] <= 5;   // M44
          mic_delays[23] <= 4;   // M46
          mic_delays[24] <= 2;   // M48
          mic_delays[25] <= 1;   // M50
          mic_delays[26] <= 0;   // M52
          mic_delays[27] <= 1;   // M54
          mic_delays[28] <= 2;   // M56
          mic_delays[29] <= 3;   // M58
        end

        // Case 16: Source M32
        16: begin
          mic_delays[0] <= 2;   // M0
          mic_delays[1] <= 2;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 2;   // M6
          mic_delays[4] <= 4;   // M8
          mic_delays[5] <= 4;   // M10
          mic_delays[6] <= 2;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 2;   // M18
          mic_delays[10] <= 5;   // M20
          mic_delays[11] <= 5;   // M22
          mic_delays[12] <= 5;   // M24
          mic_delays[13] <= 5;   // M26
          mic_delays[14] <= 2;   // M28
          mic_delays[15] <= 1;   // M30
          mic_delays[16] <= 0;   // M32
          mic_delays[17] <= 1;   // M34
          mic_delays[18] <= 3;   // M36
          mic_delays[19] <= 5;   // M38
          mic_delays[20] <= 6;   // M40
          mic_delays[21] <= 7;   // M42
          mic_delays[22] <= 7;   // M44
          mic_delays[23] <= 6;   // M46
          mic_delays[24] <= 5;   // M48
          mic_delays[25] <= 3;   // M50
          mic_delays[26] <= 1;   // M52
          mic_delays[27] <= 0;   // M54
          mic_delays[28] <= 0;   // M56
          mic_delays[29] <= 1;   // M58
        end

        // Case 17: Source M34
        17: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 2;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 2;   // M8
          mic_delays[5] <= 3;   // M10
          mic_delays[6] <= 3;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 0;   // M16
          mic_delays[9] <= 1;   // M18
          mic_delays[10] <= 2;   // M20
          mic_delays[11] <= 4;   // M22
          mic_delays[12] <= 5;   // M24
          mic_delays[13] <= 5;   // M26
          mic_delays[14] <= 4;   // M28
          mic_delays[15] <= 2;   // M30
          mic_delays[16] <= 1;   // M32
          mic_delays[17] <= 0;   // M34
          mic_delays[18] <= 1;   // M36
          mic_delays[19] <= 2;   // M38
          mic_delays[20] <= 4;   // M40
          mic_delays[21] <= 5;   // M42
          mic_delays[22] <= 6;   // M44
          mic_delays[23] <= 6;   // M46
          mic_delays[24] <= 6;   // M48
          mic_delays[25] <= 5;   // M50
          mic_delays[26] <= 3;   // M52
          mic_delays[27] <= 2;   // M54
          mic_delays[28] <= 1;   // M56
          mic_delays[29] <= 0;   // M58
        end

        // Case 18: Source M36
        18: begin
          mic_delays[0] <= 2;   // M0
          mic_delays[1] <= 4;   // M2
          mic_delays[2] <= 2;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 2;   // M8
          mic_delays[5] <= 4;   // M10
          mic_delays[6] <= 5;   // M12
          mic_delays[7] <= 3;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 0;   // M18
          mic_delays[10] <= 1;   // M20
          mic_delays[11] <= 3;   // M22
          mic_delays[12] <= 5;   // M24
          mic_delays[13] <= 7;   // M26
          mic_delays[14] <= 6;   // M28
          mic_delays[15] <= 5;   // M30
          mic_delays[16] <= 3;   // M32
          mic_delays[17] <= 1;   // M34
          mic_delays[18] <= 0;   // M36
          mic_delays[19] <= 1;   // M38
          mic_delays[20] <= 2;   // M40
          mic_delays[21] <= 5;   // M42
          mic_delays[22] <= 6;   // M44
          mic_delays[23] <= 8;   // M46
          mic_delays[24] <= 8;   // M48
          mic_delays[25] <= 8;   // M50
          mic_delays[26] <= 6;   // M52
          mic_delays[27] <= 4;   // M54
          mic_delays[28] <= 2;   // M56
          mic_delays[29] <= 1;   // M58
        end

        // Case 19: Source M38
        19: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 3;   // M2
          mic_delays[2] <= 3;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 3;   // M10
          mic_delays[6] <= 5;   // M12
          mic_delays[7] <= 4;   // M14
          mic_delays[8] <= 2;   // M16
          mic_delays[9] <= 1;   // M18
          mic_delays[10] <= 0;   // M20
          mic_delays[11] <= 2;   // M22
          mic_delays[12] <= 4;   // M24
          mic_delays[13] <= 6;   // M26
          mic_delays[14] <= 6;   // M28
          mic_delays[15] <= 6;   // M30
          mic_delays[16] <= 5;   // M32
          mic_delays[17] <= 2;   // M34
          mic_delays[18] <= 1;   // M36
          mic_delays[19] <= 0;   // M38
          mic_delays[20] <= 1;   // M40
          mic_delays[21] <= 2;   // M42
          mic_delays[22] <= 4;   // M44
          mic_delays[23] <= 6;   // M46
          mic_delays[24] <= 8;   // M48
          mic_delays[25] <= 8;   // M50
          mic_delays[26] <= 8;   // M52
          mic_delays[27] <= 6;   // M54
          mic_delays[28] <= 5;   // M56
          mic_delays[29] <= 2;   // M58
        end

        // Case 20: Source M40
        20: begin
          mic_delays[0] <= 1;   // M0
          mic_delays[1] <= 3;   // M2
          mic_delays[2] <= 3;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 2;   // M10
          mic_delays[6] <= 4;   // M12
          mic_delays[7] <= 5;   // M14
          mic_delays[8] <= 3;   // M16
          mic_delays[9] <= 2;   // M18
          mic_delays[10] <= 0;   // M20
          mic_delays[11] <= 1;   // M22
          mic_delays[12] <= 2;   // M24
          mic_delays[13] <= 5;   // M26
          mic_delays[14] <= 6;   // M28
          mic_delays[15] <= 6;   // M30
          mic_delays[16] <= 6;   // M32
          mic_delays[17] <= 4;   // M34
          mic_delays[18] <= 2;   // M36
          mic_delays[19] <= 1;   // M38
          mic_delays[20] <= 0;   // M40
          mic_delays[21] <= 1;   // M42
          mic_delays[22] <= 2;   // M44
          mic_delays[23] <= 5;   // M46
          mic_delays[24] <= 6;   // M48
          mic_delays[25] <= 8;   // M50
          mic_delays[26] <= 8;   // M52
          mic_delays[27] <= 8;   // M54
          mic_delays[28] <= 6;   // M56
          mic_delays[29] <= 4;   // M58
        end

        // Case 21: Source M42
        21: begin
          mic_delays[0] <= 2;   // M0
          mic_delays[1] <= 2;   // M2
          mic_delays[2] <= 4;   // M4
          mic_delays[3] <= 2;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 3;   // M12
          mic_delays[7] <= 5;   // M14
          mic_delays[8] <= 4;   // M16
          mic_delays[9] <= 3;   // M18
          mic_delays[10] <= 1;   // M20
          mic_delays[11] <= 0;   // M22
          mic_delays[12] <= 1;   // M24
          mic_delays[13] <= 3;   // M26
          mic_delays[14] <= 5;   // M28
          mic_delays[15] <= 6;   // M30
          mic_delays[16] <= 7;   // M32
          mic_delays[17] <= 5;   // M34
          mic_delays[18] <= 5;   // M36
          mic_delays[19] <= 2;   // M38
          mic_delays[20] <= 1;   // M40
          mic_delays[21] <= 0;   // M42
          mic_delays[22] <= 1;   // M44
          mic_delays[23] <= 2;   // M46
          mic_delays[24] <= 4;   // M48
          mic_delays[25] <= 6;   // M50
          mic_delays[26] <= 8;   // M52
          mic_delays[27] <= 8;   // M54
          mic_delays[28] <= 8;   // M56
          mic_delays[29] <= 6;   // M58
        end

        // Case 22: Source M44
        22: begin
          mic_delays[0] <= 2;   // M0
          mic_delays[1] <= 2;   // M2
          mic_delays[2] <= 4;   // M4
          mic_delays[3] <= 3;   // M6
          mic_delays[4] <= 1;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 2;   // M12
          mic_delays[7] <= 4;   // M14
          mic_delays[8] <= 5;   // M16
          mic_delays[9] <= 5;   // M18
          mic_delays[10] <= 3;   // M20
          mic_delays[11] <= 1;   // M22
          mic_delays[12] <= 0;   // M24
          mic_delays[13] <= 1;   // M26
          mic_delays[14] <= 3;   // M28
          mic_delays[15] <= 5;   // M30
          mic_delays[16] <= 7;   // M32
          mic_delays[17] <= 6;   // M34
          mic_delays[18] <= 6;   // M36
          mic_delays[19] <= 4;   // M38
          mic_delays[20] <= 2;   // M40
          mic_delays[21] <= 1;   // M42
          mic_delays[22] <= 0;   // M44
          mic_delays[23] <= 1;   // M46
          mic_delays[24] <= 2;   // M48
          mic_delays[25] <= 5;   // M50
          mic_delays[26] <= 6;   // M52
          mic_delays[27] <= 8;   // M54
          mic_delays[28] <= 8;   // M56
          mic_delays[29] <= 8;   // M58
        end

        // Case 23: Source M46
        23: begin
          mic_delays[0] <= 3;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 3;   // M4
          mic_delays[3] <= 4;   // M6
          mic_delays[4] <= 2;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 3;   // M14
          mic_delays[8] <= 5;   // M16
          mic_delays[9] <= 6;   // M18
          mic_delays[10] <= 5;   // M20
          mic_delays[11] <= 2;   // M22
          mic_delays[12] <= 1;   // M24
          mic_delays[13] <= 0;   // M26
          mic_delays[14] <= 2;   // M28
          mic_delays[15] <= 4;   // M30
          mic_delays[16] <= 6;   // M32
          mic_delays[17] <= 6;   // M34
          mic_delays[18] <= 8;   // M36
          mic_delays[19] <= 6;   // M38
          mic_delays[20] <= 5;   // M40
          mic_delays[21] <= 2;   // M42
          mic_delays[22] <= 1;   // M44
          mic_delays[23] <= 0;   // M46
          mic_delays[24] <= 1;   // M48
          mic_delays[25] <= 2;   // M50
          mic_delays[26] <= 4;   // M52
          mic_delays[27] <= 6;   // M54
          mic_delays[28] <= 8;   // M56
          mic_delays[29] <= 8;   // M58
        end

        // Case 24: Source M48
        24: begin
          mic_delays[0] <= 3;   // M0
          mic_delays[1] <= 1;   // M2
          mic_delays[2] <= 3;   // M4
          mic_delays[3] <= 5;   // M6
          mic_delays[4] <= 3;   // M8
          mic_delays[5] <= 1;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 2;   // M14
          mic_delays[8] <= 4;   // M16
          mic_delays[9] <= 6;   // M18
          mic_delays[10] <= 6;   // M20
          mic_delays[11] <= 4;   // M22
          mic_delays[12] <= 2;   // M24
          mic_delays[13] <= 0;   // M26
          mic_delays[14] <= 1;   // M28
          mic_delays[15] <= 2;   // M30
          mic_delays[16] <= 5;   // M32
          mic_delays[17] <= 6;   // M34
          mic_delays[18] <= 8;   // M36
          mic_delays[19] <= 8;   // M38
          mic_delays[20] <= 6;   // M40
          mic_delays[21] <= 4;   // M42
          mic_delays[22] <= 2;   // M44
          mic_delays[23] <= 1;   // M46
          mic_delays[24] <= 0;   // M48
          mic_delays[25] <= 1;   // M50
          mic_delays[26] <= 2;   // M52
          mic_delays[27] <= 5;   // M54
          mic_delays[28] <= 6;   // M56
          mic_delays[29] <= 8;   // M58
        end

        // Case 25: Source M50
        25: begin
          mic_delays[0] <= 4;   // M0
          mic_delays[1] <= 2;   // M2
          mic_delays[2] <= 2;   // M4
          mic_delays[3] <= 5;   // M6
          mic_delays[4] <= 4;   // M8
          mic_delays[5] <= 2;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 3;   // M16
          mic_delays[9] <= 6;   // M18
          mic_delays[10] <= 7;   // M20
          mic_delays[11] <= 5;   // M22
          mic_delays[12] <= 3;   // M24
          mic_delays[13] <= 1;   // M26
          mic_delays[14] <= 0;   // M28
          mic_delays[15] <= 1;   // M30
          mic_delays[16] <= 3;   // M32
          mic_delays[17] <= 5;   // M34
          mic_delays[18] <= 8;   // M36
          mic_delays[19] <= 8;   // M38
          mic_delays[20] <= 8;   // M40
          mic_delays[21] <= 6;   // M42
          mic_delays[22] <= 5;   // M44
          mic_delays[23] <= 2;   // M46
          mic_delays[24] <= 1;   // M48
          mic_delays[25] <= 0;   // M50
          mic_delays[26] <= 1;   // M52
          mic_delays[27] <= 2;   // M54
          mic_delays[28] <= 4;   // M56
          mic_delays[29] <= 6;   // M58
        end

        // Case 26: Source M52
        26: begin
          mic_delays[0] <= 4;   // M0
          mic_delays[1] <= 2;   // M2
          mic_delays[2] <= 2;   // M4
          mic_delays[3] <= 4;   // M6
          mic_delays[4] <= 5;   // M8
          mic_delays[5] <= 3;   // M10
          mic_delays[6] <= 1;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 2;   // M16
          mic_delays[9] <= 5;   // M18
          mic_delays[10] <= 7;   // M20
          mic_delays[11] <= 6;   // M22
          mic_delays[12] <= 5;   // M24
          mic_delays[13] <= 3;   // M26
          mic_delays[14] <= 1;   // M28
          mic_delays[15] <= 0;   // M30
          mic_delays[16] <= 1;   // M32
          mic_delays[17] <= 3;   // M34
          mic_delays[18] <= 6;   // M36
          mic_delays[19] <= 8;   // M38
          mic_delays[20] <= 8;   // M40
          mic_delays[21] <= 8;   // M42
          mic_delays[22] <= 6;   // M44
          mic_delays[23] <= 4;   // M46
          mic_delays[24] <= 2;   // M48
          mic_delays[25] <= 1;   // M50
          mic_delays[26] <= 0;   // M52
          mic_delays[27] <= 1;   // M54
          mic_delays[28] <= 2;   // M56
          mic_delays[29] <= 5;   // M58
        end

        // Case 27: Source M54
        27: begin
          mic_delays[0] <= 3;   // M0
          mic_delays[1] <= 3;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 3;   // M6
          mic_delays[4] <= 5;   // M8
          mic_delays[5] <= 4;   // M10
          mic_delays[6] <= 2;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 4;   // M18
          mic_delays[10] <= 6;   // M20
          mic_delays[11] <= 6;   // M22
          mic_delays[12] <= 6;   // M24
          mic_delays[13] <= 5;   // M26
          mic_delays[14] <= 2;   // M28
          mic_delays[15] <= 1;   // M30
          mic_delays[16] <= 0;   // M32
          mic_delays[17] <= 2;   // M34
          mic_delays[18] <= 4;   // M36
          mic_delays[19] <= 6;   // M38
          mic_delays[20] <= 8;   // M40
          mic_delays[21] <= 8;   // M42
          mic_delays[22] <= 8;   // M44
          mic_delays[23] <= 6;   // M46
          mic_delays[24] <= 5;   // M48
          mic_delays[25] <= 2;   // M50
          mic_delays[26] <= 1;   // M52
          mic_delays[27] <= 0;   // M54
          mic_delays[28] <= 1;   // M56
          mic_delays[29] <= 2;   // M58
        end

        // Case 28: Source M56
        28: begin
          mic_delays[0] <= 3;   // M0
          mic_delays[1] <= 3;   // M2
          mic_delays[2] <= 1;   // M4
          mic_delays[3] <= 2;   // M6
          mic_delays[4] <= 4;   // M8
          mic_delays[5] <= 5;   // M10
          mic_delays[6] <= 3;   // M12
          mic_delays[7] <= 1;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 2;   // M18
          mic_delays[10] <= 5;   // M20
          mic_delays[11] <= 6;   // M22
          mic_delays[12] <= 6;   // M24
          mic_delays[13] <= 6;   // M26
          mic_delays[14] <= 4;   // M28
          mic_delays[15] <= 2;   // M30
          mic_delays[16] <= 0;   // M32
          mic_delays[17] <= 1;   // M34
          mic_delays[18] <= 2;   // M36
          mic_delays[19] <= 5;   // M38
          mic_delays[20] <= 6;   // M40
          mic_delays[21] <= 8;   // M42
          mic_delays[22] <= 8;   // M44
          mic_delays[23] <= 8;   // M46
          mic_delays[24] <= 6;   // M48
          mic_delays[25] <= 4;   // M50
          mic_delays[26] <= 2;   // M52
          mic_delays[27] <= 1;   // M54
          mic_delays[28] <= 0;   // M56
          mic_delays[29] <= 1;   // M58
        end

        // Case 29: Source M58
        29: begin
          mic_delays[0] <= 2;   // M0
          mic_delays[1] <= 4;   // M2
          mic_delays[2] <= 2;   // M4
          mic_delays[3] <= 1;   // M6
          mic_delays[4] <= 3;   // M8
          mic_delays[5] <= 5;   // M10
          mic_delays[6] <= 4;   // M12
          mic_delays[7] <= 2;   // M14
          mic_delays[8] <= 1;   // M16
          mic_delays[9] <= 1;   // M18
          mic_delays[10] <= 3;   // M20
          mic_delays[11] <= 5;   // M22
          mic_delays[12] <= 6;   // M24
          mic_delays[13] <= 7;   // M26
          mic_delays[14] <= 5;   // M28
          mic_delays[15] <= 3;   // M30
          mic_delays[16] <= 1;   // M32
          mic_delays[17] <= 0;   // M34
          mic_delays[18] <= 1;   // M36
          mic_delays[19] <= 2;   // M38
          mic_delays[20] <= 4;   // M40
          mic_delays[21] <= 6;   // M42
          mic_delays[22] <= 8;   // M44
          mic_delays[23] <= 8;   // M46
          mic_delays[24] <= 8;   // M48
          mic_delays[25] <= 6;   // M50
          mic_delays[26] <= 5;   // M52
          mic_delays[27] <= 2;   // M54
          mic_delays[28] <= 1;   // M56
          mic_delays[29] <= 0;   // M58
        end

      endcase
    end
  end

  genvar j;

  generate
    for (j = 0; j < 30; j = j + 1) begin : delay_line_gen
      delay_line u_delay_line (
          .clk(clk),
          .rst(rst),
          .pcm_valid(pcm_valid),
          .delay(mic_delays[j]),
          .pcm_data(pcm_data[j]),
          .delayed_pcm_data(delayed_pcm_data[j])
      );
    end
  endgenerate

endmodule
