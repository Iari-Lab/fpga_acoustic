// Improved delay module using the timing-corrected delay_line
module delay_module (
    input wire clk,
    input wire rst,
    input wire [2:0] delay_select,
    input wire pcm_valid,
    input wire [15:0] pcm_data_0,
    input wire [15:0] pcm_data_1,
    input wire [15:0] pcm_data_2,
    input wire [15:0] pcm_data_3,
    output wire [15:0] delayed_pcm_data_0,
    output wire [15:0] delayed_pcm_data_1,
    output wire [15:0] delayed_pcm_data_2,
    output wire [15:0] delayed_pcm_data_3
);

  wire [15:0] pcm_data[3:0];
  wire [15:0] delayed_pcm_data[3:0];
  reg [3:0] mic_delays[3:0];
  reg [3:0] x;

  // Initialize delays
  initial begin
    for (x = 0; x < 4; x = x + 1) begin
      mic_delays[x] = 0;
    end
  end

  assign pcm_data[0] = pcm_data_0;
  assign pcm_data[1] = pcm_data_1;
  assign pcm_data[2] = pcm_data_2;
  assign pcm_data[3] = pcm_data_3;

  assign delayed_pcm_data_0 = delayed_pcm_data[0];
  assign delayed_pcm_data_1 = delayed_pcm_data[1];
  assign delayed_pcm_data_2 = delayed_pcm_data[2];
  assign delayed_pcm_data_3 = delayed_pcm_data[3];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (x = 0; x < 4; x = x + 1) begin
        mic_delays[x] <= 0;
      end
    end else begin
      case (delay_select)
        // M40 as source
        1: begin
          mic_delays[0] <= 0;  // M39
          mic_delays[1] <= 5;  // M51
          mic_delays[2] <= 8;  // M57
          mic_delays[3] <= 4;  // M45
        end
        // M46 as source
        2: begin
          mic_delays[0] <= 5;  // M39
          mic_delays[1] <= 0;  // M51
          mic_delays[2] <= 4;  // M57
          mic_delays[3] <= 8;  // M45
        end
        // M52 as source
        3: begin
          mic_delays[0] <= 8;  // M39
          mic_delays[1] <= 4;  // M51
          mic_delays[2] <= 0;  // M57
          mic_delays[3] <= 5;  // M45
        end
        // M58 as source
        4: begin
          mic_delays[0] <= 4;  // M39
          mic_delays[1] <= 8;  // M51
          mic_delays[2] <= 5;  // M57
          mic_delays[3] <= 0;  // M45
        end
        default: begin
          mic_delays[0] <= 0;
          mic_delays[1] <= 0;
          mic_delays[2] <= 0;
          mic_delays[3] <= 0;
        end
      endcase
    end
  end

  genvar j;

  generate
    for (j = 0; j < 4; j = j + 1) begin : delay_line_gen
      delay_line u_delay_line (
          .clk(clk),
          .rst(rst),
          .pcm_valid(pcm_valid),
          .delay(mic_delays[j]),
          .pcm_data(pcm_data[j]),
          .delayed_pcm_data(delayed_pcm_data[j])
      );
    end
  endgenerate

endmodule
