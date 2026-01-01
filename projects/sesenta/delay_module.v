module delay_module #(
    parameter DELAY_SELECT = 0  // Select delay configuration (0-20)
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
    input wire [15:0] pcm_data_18,
    input wire [15:0] pcm_data_19,
    input wire [15:0] pcm_data_20,
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
    output wire [15:0] delayed_pcm_data_20
);

  // =========================================================================
  // DELAY CONFIGURATION LOOKUP TABLE
  // =========================================================================
  // All 21 delay configurations stored as a packed array.
  // Format: DELAY_TABLE[config_index] contains 21 x 4-bit delays = 84 bits
  // Delays are packed as: {mic20_delay, mic19_delay, ..., mic1_delay, mic0_delay}
  // =========================================================================
  
  // Function to pack 21 4-bit delays into 84 bits
  function [83:0] pack_delays;
    input [3:0] d0, d1, d2, d3, d4, d5, d6, d7, d8, d9;
    input [3:0] d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20;
    begin
      pack_delays = {d20, d19, d18, d17, d16, d15, d14, d13, d12, d11,
                     d10, d9, d8, d7, d6, d5, d4, d3, d2, d1, d0};
    end
  endfunction

  // Delay configurations for all 21 source directions
  // Each row: mic0, mic1, mic2, ... mic20 delays
  localparam [83:0] DELAY_CONFIG_0  = pack_delays(0,1,1,0,0,1,1,1,1,1,1,1,2,2,1,2,2,2,4,4,2);  // Source M0
  localparam [83:0] DELAY_CONFIG_1  = pack_delays(1,0,1,1,1,0,0,1,1,2,1,1,1,1,2,4,2,2,2,2,4);  // Source M2
  localparam [83:0] DELAY_CONFIG_2  = pack_delays(1,1,0,1,1,1,1,0,0,1,2,2,1,1,1,2,4,4,2,2,2);  // Source M4
  localparam [83:0] DELAY_CONFIG_3  = pack_delays(0,1,1,0,1,2,2,2,1,0,1,2,3,3,1,1,2,3,5,4,1);  // Source M6
  localparam [83:0] DELAY_CONFIG_4  = pack_delays(0,1,1,1,0,1,2,2,2,1,0,1,3,3,2,2,1,1,4,5,3);  // Source M8
  localparam [83:0] DELAY_CONFIG_5  = pack_delays(1,0,1,2,1,0,1,2,2,3,1,0,1,2,3,4,1,1,2,3,5);  // Source M10
  localparam [83:0] DELAY_CONFIG_6  = pack_delays(1,0,1,2,2,1,0,1,2,3,2,1,0,1,3,5,3,2,1,1,4);  // Source M12
  localparam [83:0] DELAY_CONFIG_7  = pack_delays(1,1,0,2,2,2,1,0,1,2,3,3,1,0,1,3,5,4,1,1,2);  // Source M14
  localparam [83:0] DELAY_CONFIG_8  = pack_delays(1,1,0,1,2,2,2,1,0,1,3,3,2,1,0,1,4,5,3,2,1);  // Source M16
  localparam [83:0] DELAY_CONFIG_9  = pack_delays(1,2,1,0,1,3,3,2,1,0,2,4,5,4,1,0,3,5,6,5,1);  // Source M18
  localparam [83:0] DELAY_CONFIG_10 = pack_delays(1,1,2,1,0,1,2,3,3,2,0,1,4,5,4,3,0,1,5,6,5);  // Source M22
  localparam [83:0] DELAY_CONFIG_11 = pack_delays(1,1,2,2,1,0,1,3,3,4,1,0,2,4,5,5,1,0,3,5,6);  // Source M24
  localparam [83:0] DELAY_CONFIG_12 = pack_delays(2,1,1,3,3,1,0,1,2,5,4,2,0,1,4,6,5,3,0,1,5);  // Source M28
  localparam [83:0] DELAY_CONFIG_13 = pack_delays(2,1,1,3,3,2,1,0,1,4,5,4,1,0,2,5,6,5,1,0,3);  // Source M30
  localparam [83:0] DELAY_CONFIG_14 = pack_delays(1,2,1,1,2,3,3,1,0,1,4,5,4,2,0,1,5,6,5,3,0);  // Source M34
  localparam [83:0] DELAY_CONFIG_15 = pack_delays(2,4,2,1,2,4,5,3,1,0,3,5,6,5,1,0,5,6,8,6,1);  // Source M36
  localparam [83:0] DELAY_CONFIG_16 = pack_delays(2,2,4,2,1,1,3,5,4,3,0,1,5,6,5,5,0,1,6,8,6);  // Source M42
  localparam [83:0] DELAY_CONFIG_17 = pack_delays(2,2,4,3,1,1,2,4,5,5,1,0,3,5,6,6,1,0,5,6,8);  // Source M44
  localparam [83:0] DELAY_CONFIG_18 = pack_delays(4,2,2,5,4,2,1,1,3,6,5,3,0,1,5,8,6,5,0,1,6);  // Source M50
  localparam [83:0] DELAY_CONFIG_19 = pack_delays(4,2,2,4,5,3,1,1,2,5,6,5,1,0,3,6,8,6,1,0,5);  // Source M52
  localparam [83:0] DELAY_CONFIG_20 = pack_delays(2,4,2,1,3,5,4,2,1,1,5,6,5,3,0,1,6,8,6,5,0);  // Source M58

  // Select the appropriate delay configuration based on parameter
  localparam [83:0] SELECTED_DELAYS = 
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
    (DELAY_SELECT == 18) ? DELAY_CONFIG_18 :
    (DELAY_SELECT == 19) ? DELAY_CONFIG_19 :
    (DELAY_SELECT == 20) ? DELAY_CONFIG_20 :
    84'h0;  // Default: all zeros

  // Extract individual delays from the selected configuration
  wire [3:0] mic_delays [20:0];
  
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
  assign mic_delays[18] = SELECTED_DELAYS[75:72];
  assign mic_delays[19] = SELECTED_DELAYS[79:76];
  assign mic_delays[20] = SELECTED_DELAYS[83:80];

  // Internal wires for array-based connections
  wire [15:0] pcm_data [20:0];
  wire [15:0] delayed_pcm_data [20:0];

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
  assign pcm_data[18] = pcm_data_18;
  assign pcm_data[19] = pcm_data_19;
  assign pcm_data[20] = pcm_data_20;

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
  assign delayed_pcm_data_18 = delayed_pcm_data[18];
  assign delayed_pcm_data_19 = delayed_pcm_data[19];
  assign delayed_pcm_data_20 = delayed_pcm_data[20];

  // =========================================================================
  // DELAY LINE INSTANCES
  // =========================================================================
  // Generate 21 delay_line instances with compile-time constant delays
  // =========================================================================
  
  genvar i;
  generate
    for (i = 0; i < 21; i = i + 1) begin : delay_lines
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
