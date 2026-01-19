`timescale 1ns / 1ps
module adder_serial #(
    parameter DATA_WIDTH   = 12,
    parameter SUM_WIDTH    = 18,
    parameter NUM_CHANNELS = 60
)(
    input  wire                              clk,
    input  wire                              rst,
    input  wire                              start,
    input  wire [NUM_CHANNELS*DATA_WIDTH-1:0] din,
    output reg  signed [SUM_WIDTH-1:0]       sum,
    output reg                               valid
);

    // Shift register to hold input data
    reg [NUM_CHANNELS*DATA_WIDTH-1:0] shift_reg;
    
    // Counter
    reg [5:0] cnt;
    reg       running;
    
    // Current value comes from the LSBs of shift register 
    wire signed [DATA_WIDTH-1:0] current_val;
    assign current_val = shift_reg[DATA_WIDTH-1:0];
    
    // Sign-extend
    wire signed [SUM_WIDTH-1:0] current_ext;
    assign current_ext = {{(SUM_WIDTH-DATA_WIDTH){current_val[DATA_WIDTH-1]}}, current_val};
    
    // Accumulator - synthesis will use DSP48
    // (* use_dsp = "yes" *)
    reg signed [SUM_WIDTH-1:0] acc;

    always @(posedge clk) begin
        if (rst) begin
            cnt       <= 0;
            acc       <= 0;
            running   <= 0;
            valid     <= 0;
            sum       <= 0;
            shift_reg <= 0;
        end else if (start) begin
            // Load all data and start processing
            shift_reg <= din >> DATA_WIDTH;  // Pre-shift: din[1..59] in register
            acc       <= current_ext;         // din[0] goes directly to accumulator
            cnt       <= 1;
            running   <= 1;
            valid     <= 0;
        end else if (running) begin
            // Shift and accumulate
            shift_reg <= shift_reg >> DATA_WIDTH;
            
            if (cnt == NUM_CHANNELS - 1) begin
                // Last value
                sum     <= acc + current_ext;
                valid   <= 1;
                running <= 0;
                cnt     <= 0;
            end else begin
                acc   <= acc + current_ext;
                cnt   <= cnt + 1;
                valid <= 0;
            end
        end else begin
            valid <= 0;
        end
    end

endmodule
