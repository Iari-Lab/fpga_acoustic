`timescale 1 ns / 1 ps

module addr_counter #
(
  parameter integer ADDR_WIDTH = 32
)
(
  input  wire enable,
  input  wire clk,
  output wire [31:0] addr,
  output wire [31:0] addr_debug,
  output wire [3:0] write_en
);

  localparam max_count = (1 << ADDR_WIDTH) - 1;
  reg write_enable_reg;
  initial write_enable_reg =0;

  reg [ADDR_WIDTH-1:0] addr_count;

  initial addr_count = 0;


  always @(posedge clk) begin
    if (enable) begin
      addr_count <= addr_count + 1;
      write_enable_reg <= 1;
    end else begin
      write_enable_reg <= 0;
    end
  end

  assign addr = addr_count << 2;
  assign addr_debug = addr_count;
  assign write_en = {4{write_enable_reg}};

endmodule