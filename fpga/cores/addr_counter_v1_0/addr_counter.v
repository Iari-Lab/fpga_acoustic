`timescale 1 ns / 1 ps

module addr_counter #
(
  parameter integer ADDR_WIDTH = 32
)
(
  input  wire enable,
  input wire start,
  input  wire clk,
  output wire [31:0] addr,
  output wire [31:0] addr_debug,
  output wire [3:0] write_en,
  output wire done
);

  localparam max_count = (1 << ADDR_WIDTH) - 1;
  reg write_enable_reg, started, done_count;
  initial write_enable_reg =0;

  reg [ADDR_WIDTH-1:0] addr_count;

  initial addr_count = 0;
  initial started =0;

  always @(posedge clk) begin
    if (start) begin
      addr_count <= 0;
      started <= 1;
      done_count <= 0;
      write_enable_reg <= 0;
    end else if (enable && started) begin
      addr_count <= addr_count + 1;
      write_enable_reg <= 1;
    end else if (addr_count == max_count) begin
      started <= 0;
      done_count <= 1;
      write_enable_reg <= 0;
    end else begin
      write_enable_reg <= 0;
    end
  end
  
  assign done = done_count;
  assign addr = addr_count << 2;
  assign addr_debug = addr_count;
  assign write_en = {4{write_enable_reg}};

endmodule