`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 13.11.2021 14:32:12
// Design Name:
// Module Name: clk_gen
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Clock divider module
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module clk_gen
#(
  parameter INPUT_FREQ = 125000000,
  parameter OUTPUT_FREQ = 2_500_000 // 2.5M out
)
(
  input  clk,
  input  rst,

  output m_clk
);

reg m_clk_i;

// generate clock

localparam integer DIVIDE = INPUT_FREQ/OUTPUT_FREQ;
localparam integer HALF = DIVIDE / 2;

// count clock samples - properly sized counter
reg [$clog2(DIVIDE)-1:0] clk_counter;

always @(posedge clk) begin
  if (rst) begin
    clk_counter <= 0;
    m_clk_i     <= 0;
  end
  else begin
    if (clk_counter == HALF-1) begin
      clk_counter <= 0;
      m_clk_i     <= ~m_clk_i;
    end
    else begin
      clk_counter <= clk_counter + 1;
    end
  end
end

assign m_clk = m_clk_i;

endmodule
