module cic_int #(
    parameter WIDTH = 23,
    parameter CHANNELS = 30
)(
    input clk,
    input resetn,
    input wr_en,
    input read_en,
    input [$clog2(CHANNELS)-1:0] channel,
    input signed [WIDTH-1:0] data_in,
    output reg signed [WIDTH-1:0] data_out
);

wire signed [WIDTH-1:0] sum;
reg signed [WIDTH-1:0] accumulator [0:CHANNELS-1];

assign sum = data_out + data_in;

always @(posedge clk or negedge resetn) begin
    if (!resetn)
        data_out <= 0;
    else begin
        case({read_en, wr_en})
            2'b10 : data_out <= accumulator[channel];
            2'b01 : begin
                accumulator[channel] <= sum;
                data_out <= data_out;
            end
            default : data_out <= data_out;
        endcase
    end
end

integer i;
initial begin
    for (i = 0; i < CHANNELS; i = i + 1)
        accumulator[i] = 0;
end

endmodule
