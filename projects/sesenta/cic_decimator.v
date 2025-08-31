/*
 * CIC Decimator - 3.072 MHz PDM to 192 kHz PCM
 * 4-stage CIC filter with 16x decimation
 */

module cic_decimator #(
    parameter PDM_CLOCK_FREQ = 3072000,
    parameter DATA_WIDTH = 18,
    parameter CIC_STAGES = 4,
    parameter CIC_DECIMATION = 16
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     pdm_clk,
    input  wire                     pdm_data,
    output reg                      pcm_valid,
    output reg  [DATA_WIDTH-1:0]    pcm_data,
    output reg                      overflow,
    output reg  [15:0]              sample_count
);

    function integer clog2;
        input integer value;
        integer v;
        begin
            v = value - 1;
            clog2 = 0;
            while (v > 0) begin
                v = v >> 1;
                clog2 = clog2 + 1;
            end
        end
    endfunction
    
    localparam CIC_BIT_GROWTH = CIC_STAGES * clog2(CIC_DECIMATION);
    localparam INTERNAL_WIDTH = DATA_WIDTH + CIC_BIT_GROWTH;
    localparam COUNTER_WIDTH = clog2(CIC_DECIMATION);

    // PDM syn
    reg pdm_clk_sync1, pdm_clk_sync2;
    reg pdm_data_sync1, pdm_data_sync2;
    reg pdm_clk_prev;
    wire pdm_strobe;
    
    // CIC filter 
    reg [COUNTER_WIDTH-1:0] decimation_counter;
    wire cic_strobe_in;
    wire cic_strobe_out;
    
    // CIC integrator comb 
    reg signed [INTERNAL_WIDTH-1:0] integrator [0:CIC_STAGES-1];
    reg signed [INTERNAL_WIDTH-1:0] comb_delay [0:CIC_STAGES-1];
    reg signed [INTERNAL_WIDTH-1:0] comb_output [0:CIC_STAGES-1];
    reg signed [INTERNAL_WIDTH-1:0] integrator_out;
    
    integer i;
    
    always @(posedge clk) begin
        if (rst) begin
            pdm_clk_sync1 <= 1'b0;
            pdm_clk_sync2 <= 1'b0;
            pdm_data_sync1 <= 1'b0;
            pdm_data_sync2 <= 1'b0;
            pdm_clk_prev <= 1'b0;
        end else begin
            pdm_clk_sync1 <= pdm_clk;
            pdm_clk_sync2 <= pdm_clk_sync1;
            pdm_data_sync1 <= pdm_data;
            pdm_data_sync2 <= pdm_data_sync1;
            pdm_clk_prev <= pdm_clk_sync2;
        end
    end
    
    assign pdm_strobe = pdm_clk_sync2 & ~pdm_clk_prev;
    
    // Convert PDM to signed: '1' -> +1, '0' -> -1
    wire signed [INTERNAL_WIDTH-1:0] pdm_signed;
    assign pdm_signed = pdm_data_sync2 ? 
                       {{(INTERNAL_WIDTH-1){1'b0}}, 1'b1} :
                       {1'b1, {(INTERNAL_WIDTH-1){1'b1}}};
    
    assign cic_strobe_in = pdm_strobe;
    
    // Decimation counter
    always @(posedge clk) begin
        if (rst) begin
            decimation_counter <= {COUNTER_WIDTH{1'b0}};
        end else if (cic_strobe_in) begin
            if (decimation_counter == CIC_DECIMATION - 1) begin
                decimation_counter <= {COUNTER_WIDTH{1'b0}};
            end else begin
                decimation_counter <= decimation_counter + 1;
            end
        end
    end
    
    assign cic_strobe_out = cic_strobe_in && (decimation_counter == CIC_DECIMATION - 1);
    
    // CIC Integrator section
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < CIC_STAGES; i = i + 1) begin
                integrator[i] <= {INTERNAL_WIDTH{1'b0}};
            end
            integrator_out <= {INTERNAL_WIDTH{1'b0}};
        end else if (cic_strobe_in) begin
            integrator[0] <= integrator[0] + pdm_signed;
            for (i = 1; i < CIC_STAGES; i = i + 1) begin
                integrator[i] <= integrator[i] + integrator[i-1];
            end
            integrator_out <= integrator[CIC_STAGES-1];
        end
    end
    
    // CIC Comb section
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < CIC_STAGES; i = i + 1) begin
                comb_delay[i] <= {INTERNAL_WIDTH{1'b0}};
                comb_output[i] <= {INTERNAL_WIDTH{1'b0}};
            end
        end else if (cic_strobe_out) begin
            comb_output[0] <= integrator_out - comb_delay[0];
            comb_delay[0] <= integrator_out;
            for (i = 1; i < CIC_STAGES; i = i + 1) begin
                comb_output[i] <= comb_output[i-1] - comb_delay[i];
                comb_delay[i] <= comb_output[i-1];
            end
        end
    end
    
    // Output scaling and saturation
    reg signed [INTERNAL_WIDTH-1:0] cic_final_output;
    reg overflow_flag;
    
    always @(posedge clk) begin
        if (rst) begin
            pcm_valid <= 1'b0;
            pcm_data <= {DATA_WIDTH{1'b0}};
            overflow <= 1'b0;
            overflow_flag <= 1'b0;
            sample_count <= 16'h0000;
        end else begin
            pcm_valid <= cic_strobe_out;
            
            if (cic_strobe_out) begin
                cic_final_output = comb_output[CIC_STAGES-1];
                
                if (cic_final_output > $signed({{1'b0}, {(DATA_WIDTH-1){1'b1}}})) begin
                    pcm_data <= {{1'b0}, {(DATA_WIDTH-1){1'b1}}};
                    overflow_flag <= 1'b1;
                end else if (cic_final_output < $signed({{1'b1}, {(DATA_WIDTH-1){1'b0}}})) begin
                    pcm_data <= {{1'b1}, {(DATA_WIDTH-1){1'b0}}};
                    overflow_flag <= 1'b1;
                end else begin
                    pcm_data <= cic_final_output[DATA_WIDTH-1:0];
                    overflow_flag <= 1'b0;
                end
                
                sample_count <= sample_count + 1;
            end
            
            if (overflow_flag) begin
                overflow <= 1'b1;
            end
        end
    end

endmodule

