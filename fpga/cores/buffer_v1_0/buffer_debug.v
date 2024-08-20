`timescale 1 ns / 1 ps

module buffer_debug #
(
  parameter integer BRAM_DATA_WIDTH = 32,
  parameter integer BRAM_ADDR_WIDTH = 32
)
(
  // System signals
  input  wire                        clk,
  input wire [BRAM_DATA_WIDTH-1:0]   input_signal1,
  input wire  input_signal2,
  output wire [BRAM_DATA_WIDTH-1:0]  output_signal1,
  output wire output_signal2,
  output wire [BRAM_DATA_WIDTH-1:0]  output_signal3,
  output wire output_signal4
);



  reg [BRAM_DATA_WIDTH-1:0] tmp_input_a, tmp_input_a2;
  reg tmp_input_b, tmp_input_b2;
  initial begin
      tmp_input_a = 0;
      tmp_input_b = 0;
      tmp_input_a2 = 0;
      tmp_input_b2 = 0;
  end

  always @(posedge clk ) begin
      tmp_input_a <= input_signal1;
      tmp_input_a2 <= input_signal1;
      tmp_input_b <= input_signal2;
      tmp_input_b2 <= input_signal2;
  end
  assign output_signal1 = tmp_input_a;
  assign output_signal2 = tmp_input_b;
  assign output_signal3 = tmp_input_a2;
  assign output_signal4 = tmp_input_b2;

endmodule
