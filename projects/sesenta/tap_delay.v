`timescale 1ns / 1ps
module tap_delay #(
    parameter DATA_WIDTH = 12,
    parameter MAX_DELAY = 16
)(
    input wire clk,
    input wire en,
    input wire [DATA_WIDTH-1:0] din,
    output wire [MAX_DELAY*DATA_WIDTH-1:0] taps_packed  // Packed output: [tap15][tap14]...[tap0]
);

    // Shift register - Vivado will infer SRL16E primitives
    (* shreg_extract = "yes" *) reg [DATA_WIDTH-1:0] sr [0:MAX_DELAY-2];
    
    integer i;
    always @(posedge clk) begin
        if (en) begin
            sr[0] <= din;
            for (i = 1; i < MAX_DELAY-1; i = i + 1) begin
                sr[i] <= sr[i-1];
            end
        end
    end
    
    // Tap 0 = current input (no delay)
    assign taps_packed[0*DATA_WIDTH +: DATA_WIDTH] = din;
    
    // Taps 1 to MAX_DELAY-1 = delayed outputs
    genvar t;
    generate
        for (t = 1; t < MAX_DELAY; t = t + 1) begin : gen_tap
            assign taps_packed[t*DATA_WIDTH +: DATA_WIDTH] = sr[t-1];
        end
    endgenerate

endmodule