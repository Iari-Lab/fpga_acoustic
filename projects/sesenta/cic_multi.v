// Multi-channel CIC filter based on Matrix Creator design
module cic_multi #(
    parameter WIDTH = 23,
    parameter STAGES = 3,
    parameter CHANNELS = 30
)(
    input clk,
    input resetn,
    input [CHANNELS-1:0] pdm_data,
    input integrator_enable,
    input comb_enable,
    input pdm_read_enable,
    output [$clog2(CHANNELS)-1:0] channel,
    output signed [WIDTH-1:0] data_out,
    output write_memory
);

wire wr_en, read_en;
assign write_memory = wr_en & comb_enable;

cic_op_fsm #(
    .WIDTH(WIDTH),
    .CHANNELS(CHANNELS)
) op_fsm0 (
    .clk(clk),
    .resetn(resetn),
    .enable(integrator_enable),
    .read_en(read_en),
    .wr_en(wr_en),
    .channel(channel)
);

// Two's complement: +1 and -1
localparam signed [WIDTH-1:0] HIGH_LEVEL = 1;
localparam signed [WIDTH-1:0] LOW_LEVEL  = ~(HIGH_LEVEL) + 1;

reg [CHANNELS-1:0] pdm_data_reg;
always @(posedge clk or negedge resetn) begin
    if (!resetn)
        pdm_data_reg <= {CHANNELS{1'b0}};
    else if (pdm_read_enable)
        pdm_data_reg <= pdm_data;
end

reg signed [WIDTH-1:0] signed_data;
always @(*) begin
    signed_data = pdm_data_reg[channel] ? HIGH_LEVEL : LOW_LEVEL;
end

wire signed [WIDTH-1:0] data_int  [STAGES:0];
wire signed [WIDTH-1:0] data_comb [STAGES:0];

assign data_int[0] = signed_data;

genvar i;
generate
    for (i = 0; i < STAGES; i = i + 1) begin : int_stage
        cic_int #(
            .WIDTH(WIDTH),
            .CHANNELS(CHANNELS)
        ) int0 (
            .clk(clk),
            .resetn(resetn),
            .wr_en(wr_en),
            .read_en(read_en),
            .channel(channel),
            .data_in(data_int[i]),
            .data_out(data_int[i+1])
        );
    end
endgenerate

assign data_comb[0] = data_int[STAGES];

genvar j;
generate
    for (j = 0; j < STAGES; j = j + 1) begin : comb_stage
        cic_comb #(
            .WIDTH(WIDTH),
            .CHANNELS(CHANNELS)
        ) comb0 (
            .clk(clk),
            .resetn(resetn),
            .read_en(read_en & comb_enable),
            .wr_en(write_memory),
            .channel(channel),
            .data_in(data_comb[j]),
            .data_out(data_comb[j+1])
        );
    end
endgenerate

assign data_out = data_comb[STAGES];

endmodule
