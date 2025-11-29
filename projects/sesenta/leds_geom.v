`timescale 1ns / 1ps
module leds_geom (
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
      if (led_num == NUM_LEDS) begin
        led_num   <= 0;
      end else begin
      // shine the geometry of mics, 45,39,51,57. for recording
      case (led_num)
          8'd14,
          8'd8,
          8'd2,
          8'd20: led_rgb_data <= 24'h00_0f_00;  //red
          default: led_rgb_data <= 24'h00_00_0f; // blue
      endcase
      led_num <= led_num + 1;
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
