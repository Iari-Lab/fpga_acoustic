`timescale 1ns / 1ps
module leds (
    input  wire clk,
    output wire ws_data,
    input  wire reset, 
    output wire [7:0] led_count,
    input wire [7:0] led_sel
);
  assign led_count = led_num;

  localparam NUM_LEDS = 60;


  reg [10:0] count = 0;
  reg [ 1:0] color_ind = 0;
  always @(posedge clk) begin
    count <= count + 1;
    if (&count) begin
      if (led_num == led_sel) begin
          led_rgb_data <= 24'h00_0f_00;
          led_num   <= led_num + 1;
      end
      else if (led_num == NUM_LEDS) begin
        led_num   <= 0;
      end else begin
        led_num <= led_num + 1;
        led_rgb_data <= 24'h00_00_0f;
      end
    end
  end

  reg [23:0] led_rgb_data = 24'h00_00_00;
  reg [7:0] led_num = 0;
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
