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


module pdm_mic
#(
  parameter INPUT_FREQ = 125000000,
  parameter PDM_FREQ = 2400000
)
(
  input         clk,
  input         rst,
  output [31:0] mic_data,
  output        mic_data_valid,
  output        M_CLK,
  input         M_DATA,
  output        M_LRSEL
);

reg [2:0]  m_data_q;
wire       m_clk_rising;
wire [31:0] cic_out_data;
wire       cic_out_valid;

// Triple register data into clk domain
always @(posedge clk) begin
  if (rst) begin
    m_data_q <= 0;
  end 
  else begin
    m_data_q[0] <= M_DATA;
    m_data_q[2:1] <= m_data_q[1:0];
  end
end

// Clock generator instance
pdm_clk_gen
  #(
    .INPUT_FREQ(INPUT_FREQ),
    .OUTPUT_FREQ(PDM_FREQ)
  )
pdm_clk_gen_i
  (
    .clk(clk),
    .rst(rst),
    .M_CLK(M_CLK),
    .m_clk_rising(m_clk_rising)
  );

// CIC Compiler instance
cic_compiler_0 cic_compiler
  (
    .aclk(clk),
    .s_axis_data_tdata({7'b0, m_data_q[2]}),
    .s_axis_data_tvalid(m_clk_rising),
    .s_axis_data_tready(), // Not connected
    .m_axis_data_tdata(cic_out_data),
    .m_axis_data_tvalid(cic_out_valid)
  );

// Continuous assignment statements
assign M_LRSEL = 0;
assign mic_data = cic_out_data;
assign mic_data_valid = cic_out_valid;

endmodule

