// Multi-channel CIC Decimator with PDM clock generation
// Processes CHANNELS microphones simultaneously
module cic_decimator_multi #(
    parameter SYS_FREQ_HZ = 120_000_000,
    parameter PDM_FREQ_HZ = 2_400_000,
    parameter CHANNELS = 30,
    parameter DATA_WIDTH = 16,
    parameter CIC_DATA_WIDTH = 23,
    parameter STAGES = 3,
    parameter SAMPLE_RATE = 50,      // Decimation ratio
    parameter PDM_READING_TIME = 28,
    parameter PDM_RATIO = 49
)(
    input wire clk,
    input wire resetn,
    input wire [CHANNELS-1:0] pdm_data,
    output wire pdm_clk,
    output wire [CHANNELS*DATA_WIDTH-1:0] pcm_data,  // Packed output
    output wire pcm_valid,
    output wire [$clog2(CHANNELS)-1:0] channel
);

// Internal signals
wire integrator_enable;
wire comb_enable;
wire pdm_read_enable;
wire write_memory;
wire signed [CIC_DATA_WIDTH-1:0] data_cic;

// CIC sync - generates PDM clock and control signals
cic_sync #(
    .SYS_FREQ_HZ(SYS_FREQ_HZ),
    .PDM_FREQ_HZ(PDM_FREQ_HZ),
    .CHANNELS(CHANNELS),
    .DATA_WIDTH(DATA_WIDTH),
    .PDM_READING_TIME(PDM_READING_TIME),
    .PDM_RATIO(PDM_RATIO)
) cic_sync0 (
    .clk(clk),
    .resetn(resetn),
    .pdm_clk(pdm_clk),
    .channel(channel),
    .sample_rate(SAMPLE_RATE),
    .read_enable(pdm_read_enable),
    .integrator_enable(integrator_enable),
    .comb_enable(comb_enable)
);

// Multi-channel CIC filter
cic_multi #(
    .STAGES(STAGES),
    .WIDTH(CIC_DATA_WIDTH),
    .CHANNELS(CHANNELS)
) cic0 (
    .clk(clk),
    .resetn(resetn),
    .pdm_data(pdm_data),
    .integrator_enable(integrator_enable),
    .comb_enable(comb_enable),
    .data_out(data_cic),
    .channel(channel),
    .pdm_read_enable(pdm_read_enable),
    .write_memory(write_memory)
);

// Output data registers - stores DATA_WIDTH bits per channel
reg [DATA_WIDTH-1:0] pcm_regs [0:CHANNELS-1];
reg pcm_valid_reg;

// Gain and saturation logic
parameter DATA_GAIN = 0;  // Can be adjusted 0-10

// Positive overflow detection
reg pof;
always @(data_cic) begin
    case(DATA_GAIN)
        0  : pof = 1'b0;
        1  : pof = data_cic[CIC_DATA_WIDTH-2];
        2  : pof = |data_cic[(CIC_DATA_WIDTH-2)-:2];
        3  : pof = |data_cic[(CIC_DATA_WIDTH-2)-:3];
        4  : pof = |data_cic[(CIC_DATA_WIDTH-2)-:4];
        5  : pof = |data_cic[(CIC_DATA_WIDTH-2)-:5];
        6  : pof = |data_cic[(CIC_DATA_WIDTH-2)-:6];
        7  : pof = |data_cic[(CIC_DATA_WIDTH-2)-:7];
        8  : pof = |data_cic[(CIC_DATA_WIDTH-2)-:8];
        9  : pof = |data_cic[(CIC_DATA_WIDTH-2)-:9];
        10 : pof = |data_cic[(CIC_DATA_WIDTH-2)-:10];
        default : pof = 1'b1;
    endcase
end

// Negative overflow detection
reg nof;
always @(data_cic) begin
    case(DATA_GAIN)
        0  : nof = 1'b0;
        1  : nof = ~data_cic[CIC_DATA_WIDTH-2];
        2  : nof = ~(&data_cic[(CIC_DATA_WIDTH-2)-:2]);
        3  : nof = ~(&data_cic[(CIC_DATA_WIDTH-2)-:3]);
        4  : nof = ~(&data_cic[(CIC_DATA_WIDTH-2)-:4]);
        5  : nof = ~(&data_cic[(CIC_DATA_WIDTH-2)-:5]);
        6  : nof = ~(&data_cic[(CIC_DATA_WIDTH-2)-:6]);
        7  : nof = ~(&data_cic[(CIC_DATA_WIDTH-2)-:7]);
        8  : nof = ~(&data_cic[(CIC_DATA_WIDTH-2)-:8]);
        9  : nof = ~(&data_cic[(CIC_DATA_WIDTH-2)-:9]);
        10 : nof = ~(&data_cic[(CIC_DATA_WIDTH-2)-:10]);
        default : nof = 1'b1;
    endcase
end

// Bounded data with saturation
reg [DATA_WIDTH-1:0] bounded_data;
always @(data_cic) begin
    case({(data_cic[CIC_DATA_WIDTH-1] & nof), (~data_cic[CIC_DATA_WIDTH-1] & pof)})
        2'b01   : bounded_data = {1'b0, {(DATA_WIDTH-1){1'b1}}};  // Positive max
        2'b10   : bounded_data = {1'b1, {(DATA_WIDTH-1){1'b0}}};  // Negative max
        default : bounded_data = {data_cic[CIC_DATA_WIDTH-1], 
                                  data_cic[(CIC_DATA_WIDTH-2-DATA_GAIN)-:DATA_WIDTH-1]};
    endcase
end

// Store output when write_memory is active
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        pcm_valid_reg <= 1'b0;
    end else begin
        if (write_memory) begin
            pcm_regs[channel] <= bounded_data;
            pcm_valid_reg <= (channel == CHANNELS - 1);
        end else begin
            pcm_valid_reg <= 1'b0;
        end
    end
end

assign pcm_valid = pcm_valid_reg;

// Pack output data
genvar k;
generate
    for (k = 0; k < CHANNELS; k = k + 1) begin : pack_output
        assign pcm_data[k*DATA_WIDTH +: DATA_WIDTH] = pcm_regs[k];
    end
endgenerate

// Initialize registers
integer m;
initial begin
    for (m = 0; m < CHANNELS; m = m + 1)
        pcm_regs[m] = 0;
end

endmodule
