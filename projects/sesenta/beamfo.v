`timescale 1ns / 1ps

module beamfo #(
    parameter NUM_CONFIGS = 60,
    parameter NUM_CHANNELS = 60,
    parameter DATA_WIDTH = 12,
    parameter SUM_WIDTH = 18,
    parameter MAX_DELAY = 16
) (
    input wire clk,
    input wire rst,
    input wire [NUM_CHANNELS*DATA_WIDTH-1:0] mics_data,
    input wire mics_data_valid,
    output wire [NUM_CONFIGS*SUM_WIDTH-1:0] beamformed_sum,
    output wire [NUM_CONFIGS-1:0] beamformed_valid
);

  //========================================================================
  // SHARED DELAY LINES - 60 total (one per channel)
  // Each outputs all 16 taps as a packed vector
  // Format: [tap15][tap14]...[tap1][tap0] for each channel
  //========================================================================
  wire [MAX_DELAY*DATA_WIDTH-1:0] delay_taps_packed[0:NUM_CHANNELS-1];

  genvar ch;
  generate
    for (ch = 0; ch < NUM_CHANNELS; ch = ch + 1) begin : gen_delay
      tap_delay #(
          .DATA_WIDTH(DATA_WIDTH),
          .MAX_DELAY (MAX_DELAY)
      ) u_delay (
          .clk(clk),
          .en(mics_data_valid),
          .din(mics_data[ch*DATA_WIDTH+:DATA_WIDTH]),
          .taps_packed(delay_taps_packed[ch])
      );
    end
  endgenerate

  genvar cfg, ch_sel;
  generate
    for (cfg = 0; cfg < NUM_CONFIGS; cfg = cfg + 1) begin : gen_beam

      // Wire to hold selected delayed samples for this configuration
      wire [NUM_CHANNELS*DATA_WIDTH-1:0] selected_data;

      // Get delay taps for each channel using the LUT module
      for (ch_sel = 0; ch_sel < NUM_CHANNELS; ch_sel = ch_sel + 1) begin : gen_sel
        wire [3:0] tap_idx;

        // Instantiate delay tap LUT for this config/channel
        delay_tap_lut u_delay_lut (
            .clk(clk),
            .config_idx (cfg[5:0]),
            .channel_idx(ch_sel[5:0]),
            .delay_tap  (tap_idx)
        );
        // delay_tap_lut #(.CONFIG(cfg), .CHANNEL(ch_sel)) delay_lut (.delay_tap(tap_idx));


        // Select from packed delay taps based on LUT output
        // taps_packed format: [tap15][tap14]...[tap1][tap0]
        assign selected_data[ch_sel*DATA_WIDTH +: DATA_WIDTH] = 
                    delay_taps_packed[ch_sel][tap_idx*DATA_WIDTH +: DATA_WIDTH];
      end

      // Adder tree for this configuration
      wire signed [SUM_WIDTH-1:0] beam_sum;
      wire beam_valid;
    //   adder_tree_recursive #(
    //       .NUM_CHANNELS(NUM_CHANNELS),
    //       .DATA_WIDTH(DATA_WIDTH),
    //       .SUM_WIDTH(SUM_WIDTH),
    //       .FANIN(4)
    //   ) u_adder_tree (
    //       .clk(clk),
    //       .rst(rst),
    //       .en(mics_data_valid),
    //       .data_in(selected_data),
    //       .sum(beam_sum),
    //       .valid(beam_valid)
    //   );
      adder60 #(
          .DATA_WIDTH(DATA_WIDTH),
          .NUM_CHANNELS(NUM_CHANNELS),
          .SUM_WIDTH(SUM_WIDTH)
      ) u_adder (
          .clk(clk),
          .rst(rst),
          .en(mics_data_valid),
          .din(selected_data),
          .sum(beam_sum),
          .valid(beam_valid)
      );

      assign beamformed_sum[cfg*SUM_WIDTH+:SUM_WIDTH] = beam_sum;
      assign beamformed_valid[cfg] = beam_valid;
    end
  endgenerate

endmodule



