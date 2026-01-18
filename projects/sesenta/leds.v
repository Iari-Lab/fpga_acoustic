`timescale 1ns / 1ps
module leds (
    input wire clk,
    output wire ws_data,
    input wire reset,
    output wire [7:0] led_count,
    input wire [7:0] led_sel,
    input wire color  // 1 for red, 0 for green
);

  localparam NUM_LEDS = 60;
  reg [23:0] led_rgb_data = 24'h00_00_00;
  reg [7:0] led_num = 0;
  reg [10:0] count = 0;
  reg initialized = 0;

  always @(posedge clk) begin
    count <= count + 1;
    if (&count) begin
      if (led_num == led_sel) begin
        case (led_num)
          8'd58, 8'd55, 8'd11, 8'd19, 8'd59, 8'd7, 8'd3:
          led_rgb_data <= (color) ? 24'h0f_00_00 : 24'h00_0f_00;
          default: led_rgb_data <= 24'h00_0f_00;
        endcase
        led_num <= led_num + 1;
      end else if (led_num == NUM_LEDS) begin
        led_num <= 0;
      end else begin
        led_num <= led_num + 1;
        led_rgb_data <= 24'h00_00_0f;
      end
    end
  end

  assign led_count = led_num;
  wire led_write = &count;

  ws2812 #(
      .NUM_LEDS(NUM_LEDS)
  ) ws2812_inst (
      .data(ws_data),
      .clk(clk),
      .reset(reset),
      .rgb_data(led_rgb_data),
      .led_num(led_num),
      .write(led_write)
  );

endmodule
