module delay_module #(
    parameter DELAY_SELECT = 0,
    parameter NUM_CHANNELS = 30
)(
    input wire clk,
    input wire rst,
    input wire pcm_valid,
    input wire [NUM_CHANNELS*16-1:0] pcm_data,
    output wire [NUM_CHANNELS*16-1:0] delayed_pcm_data
);

  // Get delays from config module
  wire [119:0] selected_delays;
  
  delay_config #(
    .DELAY_SELECT(DELAY_SELECT)
  ) config_inst (
    .delays(selected_delays)
  );

  // Generate delay lines
  genvar i;
  generate
    for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : delay_lines
      delay_line #(
        .MAX_DELAY(16)
      ) dl (
          .clk(clk),
          .rst(rst),
          .pcm_valid(pcm_valid),
          .delay(selected_delays[i*4 +: 4]),
          .pcm_data(pcm_data[i*16 +: 16]),
          .delayed_pcm_data(delayed_pcm_data[i*16 +: 16])
      );
    end
  endgenerate

endmodule