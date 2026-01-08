module delay_bank #(
    parameter NUM_CONFIGS = 60,   // Number of delay configurations (directions)
    parameter NUM_CHANNELS = 60   // Number of microphone channels
)(
    input wire clk,
    input wire rst,
    input wire pcm_valid,
    input wire [NUM_CHANNELS*16-1:0] pcm_data,                      // Input: NUM_CHANNELS * 16 bits
    output wire [NUM_CONFIGS*NUM_CHANNELS*16-1:0] delayed_data      // Output: NUM_CONFIGS * NUM_CHANNELS * 16 bits
);

  // Each delay_module outputs NUM_CHANNELS*16 bits
  // Total output = NUM_CONFIGS * NUM_CHANNELS * 16 bits
  
  genvar i;
  
  generate
    for (i = 0; i < NUM_CONFIGS; i = i + 1) begin : gen_delay
      delay_module #(
          .DELAY_SELECT(i),
          .NUM_CHANNELS(NUM_CHANNELS)
      ) u_delay (
          .clk(clk),
          .rst(rst),
          .pcm_valid(pcm_valid),
          .pcm_data(pcm_data),
          .delayed_pcm_data(delayed_data[i*NUM_CHANNELS*16 +: NUM_CHANNELS*16])
      );
    end
  endgenerate

endmodule