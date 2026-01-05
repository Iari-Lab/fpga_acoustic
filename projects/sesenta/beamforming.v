module beamforming #(
    parameter NUM_CONFIGS = 18,
    parameter NUM_CHANNELS = 18,
    parameter DATA_WIDTH = 16,
    parameter FANIN = 4
)(
    input wire clk,
    input wire rst,
    input wire [NUM_CHANNELS*DATA_WIDTH-1:0] mics_data,
    input wire mics_data_valid,
    output wire [NUM_CONFIGS*SUM_WIDTH-1:0] beamformed_sum,
    output wire [NUM_CONFIGS-1:0] beamformed_valid
);

  // SUM_WIDTH matches adder_tree_recursive calculation
  localparam SUM_WIDTH = DATA_WIDTH + $clog2(NUM_CHANNELS) + 1;

  // Packed delayed data from delay_bank
  wire [NUM_CONFIGS*NUM_CHANNELS*DATA_WIDTH-1:0] delayed_data;
  wire [SUM_WIDTH-1:0] sum [0:NUM_CONFIGS-1];
  wire [NUM_CONFIGS-1:0] valid;

  genvar i, j;

  // Single delay_bank instance
  delay_bank #(
      .NUM_CONFIGS(NUM_CONFIGS),
      .NUM_CHANNELS(NUM_CHANNELS)
  ) u_delay_bank (
      .clk(clk),
      .rst(rst),
      .pcm_valid(mics_data_valid),
      .pcm_data(mics_data),
      .delayed_data(delayed_data)
  );

  // Generate NUM_CONFIGS adder_tree_recursive instances (one per output beam)
  generate
    for (i = 0; i < NUM_CONFIGS; i = i + 1) begin : gen_adder
      // Build packed input for adder: collect channel i from each config
      wire [NUM_CHANNELS*DATA_WIDTH-1:0] adder_input;

      for (j = 0; j < NUM_CHANNELS; j = j + 1) begin : collect_channels
        // From delayed_data, get config j, channel i
        assign adder_input[j*DATA_WIDTH +: DATA_WIDTH] =
               delayed_data[(j*NUM_CHANNELS + i)*DATA_WIDTH +: DATA_WIDTH];
      end

      adder_tree_recursive #(
          .NUM_CHANNELS(NUM_CHANNELS),
          .DATA_WIDTH(DATA_WIDTH),
          .FANIN(FANIN)
      ) u_adder_tree (
          .clk(clk),
          .rst(rst),
          .en(mics_data_valid),
          .data_in(adder_input),
          .sum(sum[i]),
          .valid(valid[i])
      );
    end
  endgenerate

  // Pack all sums and valid signals into outputs
  generate
    for (i = 0; i < NUM_CONFIGS; i = i + 1) begin : pack_output
      assign beamformed_sum[i*SUM_WIDTH +: SUM_WIDTH] = sum[i];
      assign beamformed_valid[i] = valid[i];
    end
  endgenerate

endmodule
