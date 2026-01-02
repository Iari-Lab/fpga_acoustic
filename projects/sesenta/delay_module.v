
module delay_module #(
    parameter DELAY_SELECT = 0  // Select delay configuration (0-17)
)(
    input wire clk,
    input wire rst,
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
    output wire [15:0] delayed_pcm_data_17
);

  // =========================================================================
  // LOOKUP TABLE
  // =========================================================================
  // All 18 delay configurations stored as a packed array.
  // Format: DELAY_CONFIG_X contains 18 x 4-bit delays = 72 bits
  // Delays are packed as: {mic17_delay, mic16_delay, ..., mic1_delay, mic0_delay}
  // Mics: M18  M19  M20  M21  M22  M23  M24  M25  M26  M27  M28  M29  M30  M31  M32  M33  M34  M35
  // =========================================================================
  
  // Function to pack 18 4-bit delays into 72 bits
  function [71:0] pack_delays;
    input [3:0] d0, d1, d2, d3, d4, d5, d6, d7, d8;
    input [3:0] d9, d10, d11, d12, d13, d14, d15, d16, d17;
    begin
      pack_delays = {d17, d16, d15, d14, d13, d12, d11, d10, d9,
                     d8, d7, d6, d5, d4, d3, d2, d1, d0};
    end
  endfunction

  // Delay configurations for all 18 source directions
  // Each row: M18, M19, M20, M21, M22, M23, M24, M25, M26, M27, M28, M29, M30, M31, M32, M33, M34, M35
  localparam [71:0] DELAY_CONFIG_0  = pack_delays(0,0,1,1,2,3,4,4,5,5,5,5,4,3,2,1,1,0);  // Source M18
  localparam [71:0] DELAY_CONFIG_1  = pack_delays(0,0,0,1,1,2,3,4,5,5,5,5,4,4,3,2,1,1);  // Source M19
  localparam [71:0] DELAY_CONFIG_2  = pack_delays(1,0,0,0,1,2,2,3,5,5,5,6,5,5,5,3,2,2);  // Source M20
  localparam [71:0] DELAY_CONFIG_3  = pack_delays(1,1,0,0,0,1,1,2,3,4,4,5,5,5,5,4,3,2);  // Source M21
  localparam [71:0] DELAY_CONFIG_4  = pack_delays(2,1,1,0,0,0,1,1,2,3,4,5,5,5,5,4,4,3);  // Source M22
  localparam [71:0] DELAY_CONFIG_5  = pack_delays(3,2,2,1,0,0,0,1,2,2,3,5,5,5,6,5,5,5);  // Source M23
  localparam [71:0] DELAY_CONFIG_6  = pack_delays(4,3,2,1,1,0,0,0,1,1,2,3,4,4,5,5,5,5);  // Source M24
  localparam [71:0] DELAY_CONFIG_7  = pack_delays(4,4,3,2,1,1,0,0,0,1,1,2,3,4,5,5,5,5);  // Source M25
  localparam [71:0] DELAY_CONFIG_8  = pack_delays(5,5,5,3,2,2,1,0,0,0,1,2,2,3,5,5,5,6);  // Source M26
  localparam [71:0] DELAY_CONFIG_9  = pack_delays(5,5,5,4,3,2,1,1,0,0,0,1,1,2,3,4,4,5);  // Source M27
  localparam [71:0] DELAY_CONFIG_10 = pack_delays(5,5,5,4,4,3,2,1,1,0,0,0,1,1,2,3,4,5);  // Source M28
  localparam [71:0] DELAY_CONFIG_11 = pack_delays(5,5,6,5,5,5,3,2,2,1,0,0,0,1,2,2,3,5);  // Source M29
  localparam [71:0] DELAY_CONFIG_12 = pack_delays(4,4,5,5,5,5,4,3,2,1,1,0,0,0,1,1,2,3);  // Source M30
  localparam [71:0] DELAY_CONFIG_13 = pack_delays(3,4,5,5,5,5,4,4,3,2,1,1,0,0,0,1,1,2);  // Source M31
  localparam [71:0] DELAY_CONFIG_14 = pack_delays(2,3,5,5,5,6,5,5,5,3,2,2,1,0,0,0,1,2);  // Source M32
  localparam [71:0] DELAY_CONFIG_15 = pack_delays(1,2,3,4,4,5,5,5,5,4,3,2,1,1,0,0,0,1);  // Source M33
  localparam [71:0] DELAY_CONFIG_16 = pack_delays(1,1,2,3,4,5,5,5,5,4,4,3,2,1,1,0,0,0);  // Source M34
  localparam [71:0] DELAY_CONFIG_17 = pack_delays(0,1,2,2,3,5,5,5,6,5,5,5,3,2,2,1,0,0);  // Source M35

  // Select the appropriate delay configuration based on parameter
  localparam [71:0] SELECTED_DELAYS = 
    (DELAY_SELECT == 0)  ? DELAY_CONFIG_0  :
    (DELAY_SELECT == 1)  ? DELAY_CONFIG_1  :
    (DELAY_SELECT == 2)  ? DELAY_CONFIG_2  :
    (DELAY_SELECT == 3)  ? DELAY_CONFIG_3  :
    (DELAY_SELECT == 4)  ? DELAY_CONFIG_4  :
    (DELAY_SELECT == 5)  ? DELAY_CONFIG_5  :
    (DELAY_SELECT == 6)  ? DELAY_CONFIG_6  :
    (DELAY_SELECT == 7)  ? DELAY_CONFIG_7  :
    (DELAY_SELECT == 8)  ? DELAY_CONFIG_8  :
    (DELAY_SELECT == 9)  ? DELAY_CONFIG_9  :
    (DELAY_SELECT == 10) ? DELAY_CONFIG_10 :
    (DELAY_SELECT == 11) ? DELAY_CONFIG_11 :
    (DELAY_SELECT == 12) ? DELAY_CONFIG_12 :
    (DELAY_SELECT == 13) ? DELAY_CONFIG_13 :
    (DELAY_SELECT == 14) ? DELAY_CONFIG_14 :
    (DELAY_SELECT == 15) ? DELAY_CONFIG_15 :
    (DELAY_SELECT == 16) ? DELAY_CONFIG_16 :
    (DELAY_SELECT == 17) ? DELAY_CONFIG_17 :
    72'h0;  // Default: all zeros

  // Extract individual delays from the selected configuration
  wire [3:0] mic_delays [17:0];
  
  assign mic_delays[0]  = SELECTED_DELAYS[3:0];
  assign mic_delays[1]  = SELECTED_DELAYS[7:4];
  assign mic_delays[2]  = SELECTED_DELAYS[11:8];
  assign mic_delays[3]  = SELECTED_DELAYS[15:12];
  assign mic_delays[4]  = SELECTED_DELAYS[19:16];
  assign mic_delays[5]  = SELECTED_DELAYS[23:20];
  assign mic_delays[6]  = SELECTED_DELAYS[27:24];
  assign mic_delays[7]  = SELECTED_DELAYS[31:28];
  assign mic_delays[8]  = SELECTED_DELAYS[35:32];
  assign mic_delays[9]  = SELECTED_DELAYS[39:36];
  assign mic_delays[10] = SELECTED_DELAYS[43:40];
  assign mic_delays[11] = SELECTED_DELAYS[47:44];
  assign mic_delays[12] = SELECTED_DELAYS[51:48];
  assign mic_delays[13] = SELECTED_DELAYS[55:52];
  assign mic_delays[14] = SELECTED_DELAYS[59:56];
  assign mic_delays[15] = SELECTED_DELAYS[63:60];
  assign mic_delays[16] = SELECTED_DELAYS[67:64];
  assign mic_delays[17] = SELECTED_DELAYS[71:68];

  // Internal wires for array-based connections
  wire [15:0] pcm_data [17:0];
  wire [15:0] delayed_pcm_data [17:0];

  // Map individual inputs to array
  assign pcm_data[0]  = pcm_data_0;
  assign pcm_data[1]  = pcm_data_1;
  assign pcm_data[2]  = pcm_data_2;
  assign pcm_data[3]  = pcm_data_3;
  assign pcm_data[4]  = pcm_data_4;
  assign pcm_data[5]  = pcm_data_5;
  assign pcm_data[6]  = pcm_data_6;
  assign pcm_data[7]  = pcm_data_7;
  assign pcm_data[8]  = pcm_data_8;
  assign pcm_data[9]  = pcm_data_9;
  assign pcm_data[10] = pcm_data_10;
  assign pcm_data[11] = pcm_data_11;
  assign pcm_data[12] = pcm_data_12;
  assign pcm_data[13] = pcm_data_13;
  assign pcm_data[14] = pcm_data_14;
  assign pcm_data[15] = pcm_data_15;
  assign pcm_data[16] = pcm_data_16;
  assign pcm_data[17] = pcm_data_17;

  // Map array to individual outputs
  assign delayed_pcm_data_0  = delayed_pcm_data[0];
  assign delayed_pcm_data_1  = delayed_pcm_data[1];
  assign delayed_pcm_data_2  = delayed_pcm_data[2];
  assign delayed_pcm_data_3  = delayed_pcm_data[3];
  assign delayed_pcm_data_4  = delayed_pcm_data[4];
  assign delayed_pcm_data_5  = delayed_pcm_data[5];
  assign delayed_pcm_data_6  = delayed_pcm_data[6];
  assign delayed_pcm_data_7  = delayed_pcm_data[7];
  assign delayed_pcm_data_8  = delayed_pcm_data[8];
  assign delayed_pcm_data_9  = delayed_pcm_data[9];
  assign delayed_pcm_data_10 = delayed_pcm_data[10];
  assign delayed_pcm_data_11 = delayed_pcm_data[11];
  assign delayed_pcm_data_12 = delayed_pcm_data[12];
  assign delayed_pcm_data_13 = delayed_pcm_data[13];
  assign delayed_pcm_data_14 = delayed_pcm_data[14];
  assign delayed_pcm_data_15 = delayed_pcm_data[15];
  assign delayed_pcm_data_16 = delayed_pcm_data[16];
  assign delayed_pcm_data_17 = delayed_pcm_data[17];

  // =========================================================================
  // =========================================================================
  
  genvar i;
  generate
    for (i = 0; i < 18; i = i + 1) begin : delay_lines
      delay_line dl (
          .clk(clk),
          .rst(rst),
          .pcm_valid(pcm_valid),
          .delay(mic_delays[i]),
          .pcm_data(pcm_data[i]),
          .delayed_pcm_data(delayed_pcm_data[i])
      );
    end
  endgenerate

endmodule
