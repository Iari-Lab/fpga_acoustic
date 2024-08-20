`timescale 1 ns / 1 ps

// Simple counter for BRAM addressing
//
// Write enable is set to 1 for one cycle
// after a rising edge is detected on the trigger

module address_counter #
(
  parameter integer COUNT_WIDTH = 14
)
(
  input  wire rst, // Clock enable
  input  wire clk,
  output wire [31:0] address,
  output wire [31:0] address_dbg,
  output wire [3:0] wen, // Write enable
  output wire [3:0] wen_dbg // Write enable
);

  localparam count_max = (1 << COUNT_WIDTH) - 1;

  reg wen_reg,wen_reg_dbg;

  reg [COUNT_WIDTH-1:0] count;

  initial count = 0;
  initial wen_reg = 0;
  initial wen_reg_dbg = 0;



  always @(posedge clk) begin
    if (rst) begin
        count <= 0;
        wen_reg <=0;
        wen_reg_dbg <= 0;
      end
      else begin
        count <= count + 1;
        wen_reg <= 1;
        wen_reg_dbg <= 1;
      end
    end

  assign address = count << 2;
  assign address_dbg = count;
  assign wen = {4{wen_reg}};
  assign wen_dbg = {4{wen_reg_dbg}};

endmodule
