/*
 * Optimized 3-Stage CIC Decimator - 3.072 MHz PDM to 192 kHz PCM
 * 3-stage CIC filter with 16x decimation
 * Optimized for Zynq-7 FPGA resources (DSP48E1, LUTs, FFs)
 */

 module cic_decimator #(
    parameter DATA_WIDTH = 18,
    parameter CIC_STAGES = 4,
    parameter CIC_DECIMATION = 16
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     pdm_clk,
    input  wire                     pdm_data,
    output reg                      pcm_valid,
    output reg  [DATA_WIDTH-1:0]    pcm_data
);
    // Calculate bit growth for 3 stages
    localparam CIC_BIT_GROWTH = CIC_STAGES * $clog2(CIC_DECIMATION);  // 3 * 4 = 12 bits
    localparam INTERNAL_WIDTH = DATA_WIDTH + CIC_BIT_GROWTH;  // 18 + 12 = 30 bits
    localparam COUNTER_WIDTH  = $clog2(CIC_DECIMATION);
    
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
    
    // PDM synchronizers
    reg [1:0] pdm_clk_sync;
    reg [1:0] pdm_data_sync;

    // (* ASYNC_REG = "TRUE" *) reg [1:0] pdm_clk_sync;
    // (* ASYNC_REG = "TRUE" *) reg [1:0] pdm_data_sync;
    reg pdm_clk_prev;
    
    always @(posedge clk) begin
        if (rst) begin
            pdm_clk_sync  <= 2'b0;
            pdm_data_sync <= 2'b0;
            pdm_clk_prev  <= 1'b0;
        end else begin
            pdm_clk_sync  <= {pdm_clk_sync[0], pdm_clk};
            pdm_data_sync <= {pdm_data_sync[0], pdm_data};
            pdm_clk_prev  <= pdm_clk_sync[1];
        end
    end
    
    wire pdm_clk_synced  = pdm_clk_sync[1];
    wire pdm_data_synced = pdm_data_sync[1];
    wire pdm_strobe      = pdm_clk_synced & ~pdm_clk_prev;
    
    assign pdm_strobe = pdm_clk_synced & ~pdm_clk_prev;
    
    // Convert PDM to signed: '1' -> +1, '0' -> -1
    wire signed [INTERNAL_WIDTH-1:0] pdm_signed;
    assign pdm_signed = pdm_data_synced ? 
                       {{(INTERNAL_WIDTH-1){1'b0}}, 1'b1} :
                       {1'b1, {(INTERNAL_WIDTH-1){1'b1}}};
    
    assign cic_strobe_in = pdm_strobe; 

    // DECIMATION COUNTER
    always @(posedge clk) begin
        if (rst) begin
            decimation_counter <= {COUNTER_WIDTH{1'b0}};
        end else if (pdm_strobe) begin
            if (decimation_counter == CIC_DECIMATION - 1) begin
                decimation_counter <= {COUNTER_WIDTH{1'b0}};
            end else begin
                decimation_counter <= decimation_counter + 1;
            end
        end
    end
    
    assign cic_strobe_out = pdm_strobe && (decimation_counter == CIC_DECIMATION - 1);
  // Integrator registers with DSP48E1 inference
  

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
    
     always @(posedge clk) begin
        if (rst) begin
            pcm_valid <= 1'b0;
            pcm_data <= {DATA_WIDTH{1'b0}};
        end else begin
            pcm_valid <= cic_strobe_out;
            if (cic_strobe_out) begin
                pcm_data <= comb_output[CIC_STAGES-1][DATA_WIDTH-1:0];
            end
        end
    end
    
endmodule