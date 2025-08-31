`timescale 1 ns / 1 ps
module tlast_axis #(
    parameter TDATA_WIDTH = 256,
    parameter CFG_WIDTH = 32
) (
    // Clocks and resets
    input wire                   aclk,
    input wire                   resetn,
    input wire [CFG_WIDTH-1:0] cfg_data,
    input wire                   enable,

    // Slave interface
    input  wire                   s_axis_tvalid,
    output wire                   s_axis_tready,
    input  wire [TDATA_WIDTH-1:0] s_axis_tdata,

    // Master interface
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast,
    output wire [TDATA_WIDTH-1:0] m_axis_tdata
);

  // Internal signals
  wire                        new_sample;
  reg  [CFG_WIDTH:0] cnt = 0;
  reg  [CFG_WIDTH-1:0] int_data_reg;


  pipeline_gate #(
    .WORD_WIDTH        (TDATA_WIDTH),
    .IMPLEMENTATION    ("MUX"),
    .GATE_DATA         (1)
  ) gate_control_and_data (
    .enable     (enable),
    .input_ready(s_axis_tready),
    .input_valid(s_axis_tvalid),
    .input_data (s_axis_tdata),
    .output_ready(m_axis_tready),
    .output_valid(m_axis_tvalid),
    .output_data (m_axis_tdata)
  );

  always @(posedge aclk) begin
    if (~resetn) begin
      int_data_reg <= {(CFG_WIDTH) {1'b0}};
    end else begin
      int_data_reg <= cfg_data;
    end
  end

  assign m_axis_tlast = (cnt == int_data_reg - 1);
  assign new_sample = s_axis_tvalid & s_axis_tready ;
  always @(posedge aclk) begin
    if (~resetn | (m_axis_tlast & new_sample)) cnt <= 0;
    else if (new_sample) cnt <= cnt + 1'b1;
  end

endmodule
