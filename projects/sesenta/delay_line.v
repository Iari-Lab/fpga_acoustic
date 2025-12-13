module delay_line (
    input wire clk,
    input wire rst,
    input wire pcm_valid,
    input wire [3:0] delay,
    input wire [15:0] pcm_data,
    output wire [15:0] delayed_pcm_data
);

  parameter MAX_DELAY = 15;
  integer i;
  reg [15:0] buffer[MAX_DELAY:0];
  reg [3:0] delay_reg;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (i = 0; i <= MAX_DELAY; i = i + 1) begin
        buffer[i] <= 16'h0000;
      end
      delay_reg <= 4'h0;
    end else begin
      delay_reg <= delay;
      if (pcm_valid) begin
        for (i = 0; i < MAX_DELAY; i = i + 1) begin
          buffer[i+1] <= buffer[i];
        end
        buffer[0] <= pcm_data;
      end
    end
  end

  assign delayed_pcm_data = buffer[delay_reg];

endmodule
