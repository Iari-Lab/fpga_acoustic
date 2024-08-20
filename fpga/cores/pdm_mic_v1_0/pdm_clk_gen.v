`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 13.11.2021 14:32:12
// Design Name:
// Module Name: pdm_microphone
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module pdm_clk_gen
#(
  parameter INPUT_FREQ = 125000000,
  parameter OUTPUT_FREQ = 2_500_000 // 2.5M out
)
(
  input  clk,
  input  rst,

  output M_CLK,
  output m_clk_rising
);

reg    m_clk_rising_i;
reg    m_clk_i;

// generate clock

localparam CLK_DIVIDE = INPUT_FREQ/OUTPUT_FREQ;

// count clock samples
reg [$clog2(CLK_DIVIDE)-1:0] clk_counter;

always @(posedge clk) begin
  if (rst) begin
    clk_counter    <= 0;
    m_clk_i        <= 0;
    m_clk_rising_i <= 0;
  end
  else begin
    m_clk_rising_i <= 0;
    if (clk_counter < (CLK_DIVIDE/2)-1) begin
      clk_counter <= clk_counter + 1;
    end
    else begin
      clk_counter    <= 0;
      m_clk_i        <= ~m_clk_i;
      m_clk_rising_i <= ~m_clk_i;
    end
  end
end

assign M_CLK = m_clk_i;
assign m_clk_rising = m_clk_rising_i;

endmodule
