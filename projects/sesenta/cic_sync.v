module cic_sync #(
    parameter SYS_FREQ_HZ = 120_000_000,
    parameter PDM_FREQ_HZ = 2_400_000,
    parameter CHANNELS = 30,
    parameter DATA_WIDTH = 16,
    parameter PDM_READING_TIME = 28,
    parameter PDM_RATIO = 49,
    parameter COUNTER_WIDTH = $clog2(SYS_FREQ_HZ/PDM_FREQ_HZ),
    parameter CHANNELS_WIDTH = $clog2(CHANNELS)
)(
    input clk,
    input resetn,
    input [DATA_WIDTH-1:0] sample_rate,
    input [$clog2(CHANNELS)-1:0] channel,
    output reg pdm_clk,
    output reg read_enable,
    output reg integrator_enable,
    output comb_enable
);

localparam [2:0] S_IDLE         = 3'd0;
localparam [2:0] S_READING_TIME = 3'd1;
localparam [2:0] S_COMPUTE      = 3'd2;
localparam [2:0] S_HOLD         = 3'd3;

reg [COUNTER_WIDTH:0] sys_count;
reg [DATA_WIDTH-1:0] comb_count;

wire pdm_condition;
wire comb_condition;
wire [COUNTER_WIDTH:0] pdm_half_ratio = PDM_RATIO >> 1;

assign pdm_condition  = (sys_count == PDM_RATIO);
assign comb_condition = (comb_count == sample_rate);
assign comb_enable    = comb_condition;

reg [2:0] state;

always @(*) begin
    case(state)
        S_IDLE         : {integrator_enable, read_enable} = 2'b00;
        S_READING_TIME : {integrator_enable, read_enable} = 2'b01;
        S_COMPUTE      : {integrator_enable, read_enable} = 2'b10;
        S_HOLD         : {integrator_enable, read_enable} = 2'b10;
        default        : {integrator_enable, read_enable} = 2'b00;
    endcase
end

always @(posedge clk or negedge resetn) begin
    if (!resetn)
        state <= S_IDLE;
    else begin
        case(state)
            S_IDLE         : state <= (sys_count == PDM_READING_TIME) ? S_READING_TIME : S_IDLE;
            S_READING_TIME : state <= S_COMPUTE;
            S_COMPUTE      : state <= S_HOLD;
            S_HOLD         : state <= (channel == (CHANNELS-1)) ? S_IDLE : S_COMPUTE;
            default        : state <= S_IDLE;
        endcase
    end
end

// sys_count
always @(posedge clk or negedge resetn) begin
    if (!resetn)
        sys_count <= {COUNTER_WIDTH{1'b0}};
    else
        sys_count <= pdm_condition ? {COUNTER_WIDTH{1'b0}} : sys_count + 1'b1;
end

// pdm_clk generation
always @(posedge clk or negedge resetn) begin
    if (!resetn | pdm_condition)
        pdm_clk <= 1'b1;
    else if (sys_count == pdm_half_ratio)
        pdm_clk <= 1'b0;
end

// comb_count
always @(posedge clk or negedge resetn) begin
    if (!resetn)
        comb_count <= 0;
    else if (pdm_condition)
        comb_count <= comb_condition ? 0 : comb_count + 1;
end

endmodule
