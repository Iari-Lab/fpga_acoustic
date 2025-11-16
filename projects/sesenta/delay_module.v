

// based on https://github.com/arghunter/SuperMic.git

module delay_module (
  input wire clk,
  input wire rst,
  input wire [2:0] delay_select,
	input wire pcm_valid,
  input wire [15:0] pcm_data_0,
  input wire [15:0] pcm_data_1,
  input wire [15:0] pcm_data_2,
  input wire [15:0] pcm_data_3,
  input wire [15:0] pcm_data_4,
  input wire [15:0] pcm_data_5,
  output wire [15:0] delayed_pcm_data_0,
  output wire [15:0] delayed_pcm_data_1,
  output wire [15:0] delayed_pcm_data_2,
  output wire [15:0] delayed_pcm_data_3,
  output wire [15:0] delayed_pcm_data_4,
  output wire [15:0] delayed_pcm_data_5
);

    wire [15:0] pcm_data [5:0];
    wire [15:0] delayed_pcm_data [5:0];
    reg [3:0] mic_delays [5:0];  

    integer x;
    initial begin
      for (x = 0; x < 6; x = x + 1) begin
        mic_delays[x] = 0;
       end
    end

    assign pcm_data[0] = pcm_data_0;
    assign pcm_data[1] = pcm_data_1;
    assign pcm_data[2] = pcm_data_2;
    assign pcm_data[3] = pcm_data_3;
    assign pcm_data[4] = pcm_data_4;
    assign pcm_data[5] = pcm_data_5;

    assign delayed_pcm_data_0 = delayed_pcm_data[0];
    assign delayed_pcm_data_1 = delayed_pcm_data[1];
    assign delayed_pcm_data_2 = delayed_pcm_data[2];
    assign delayed_pcm_data_3 = delayed_pcm_data[3];
    assign delayed_pcm_data_4 = delayed_pcm_data[4];
    assign delayed_pcm_data_5 = delayed_pcm_data[5];

    always @(delay_select) begin
        case (delay_select)
          // M31 as source
          0 : begin
                mic_delays[0] = 0;  // M31
                mic_delays[1] = 1;  // M28
                mic_delays[2] = 4;  // M25
                mic_delays[3] = 5;  // M22
                mic_delays[4] = 4;  // M19
                mic_delays[5] = 1;  // M34
            end
          // M28 as source
          1 : begin
                mic_delays[0] = 1;  // M31
                mic_delays[1] = 0;  // M28
                mic_delays[2] = 1;  // M25
                mic_delays[3] = 4;  // M22
                mic_delays[4] = 5;  // M19
                mic_delays[5] = 4;  // M34
            end
          // M25 as source
          2 : begin
                mic_delays[0] = 4;  // M31
                mic_delays[1] = 1;  // M28
                mic_delays[2] = 0;  // M25
                mic_delays[3] = 1;  // M22
                mic_delays[4] = 4;  // M19
                mic_delays[5] = 5;  // M34
            end
          // M22 as source
          3 : begin
                mic_delays[0] = 5;  // M31
                mic_delays[1] = 4;  // M28
                mic_delays[2] = 1;  // M25
                mic_delays[3] = 0;  // M22
                mic_delays[4] = 1;  // M19
                mic_delays[5] = 4;  // M34
            end
          // M19 as source
          4 : begin
                mic_delays[0] = 4;  // M31
                mic_delays[1] = 5;  // M28
                mic_delays[2] = 4;  // M25
                mic_delays[3] = 1;  // M22
                mic_delays[4] = 0;  // M19
                mic_delays[5] = 1;  // M34
            end
          // M34 as source
          5 : begin
                mic_delays[0] = 1;  // M31
                mic_delays[1] = 4;  // M28
                mic_delays[2] = 5;  // M25
                mic_delays[3] = 4;  // M22
                mic_delays[4] = 1;  // M19
                mic_delays[5] = 0;  // M34
            end
          default : begin
                mic_delays[0] = 0;
                mic_delays[1] = 0;
                mic_delays[2] = 0;
                mic_delays[3] = 0;
                mic_delays[4] = 0;
                mic_delays[5] = 0;
            end
    endcase
    end

    genvar j;

    generate
      for (j = 0; j < 6; j = j + 1) begin : delay_line_gen
      delay_line u_delay_line (
        .clk(clk),
        .rst(rst),
        .delay(mic_delays[j]),
        .pcm_valid(pcm_valid),
        .pcm_data(pcm_data[j]),
        .delayed_pcm_data(delayed_pcm_data[j])
      );
      end
    endgenerate

endmodule
