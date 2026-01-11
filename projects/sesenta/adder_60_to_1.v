module adder_60_to_1_v3 #(
    parameter DATA_WIDTH = 12,
    parameter SUM_WIDTH = 18
)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [60*DATA_WIDTH-1:0] din,
    output reg signed [SUM_WIDTH-1:0] sum,
    output reg valid
);

    // Sign-extend inputs
    wire signed [SUM_WIDTH-1:0] x [0:59];
    genvar i;
    generate
        for (i = 0; i < 60; i = i + 1) begin : gen_ext
            wire signed [DATA_WIDTH-1:0] d;
            assign d = din[i*DATA_WIDTH +: DATA_WIDTH];
            assign x[i] = {{(SUM_WIDTH-DATA_WIDTH){d[DATA_WIDTH-1]}}, d};
        end
    endgenerate

    // Level 1: 60 -> 30
    wire signed [SUM_WIDTH-1:0] s1 [0:29];
    generate
        for (i = 0; i < 30; i = i + 1) begin : l1
            assign s1[i] = x[2*i] + x[2*i+1];
        end
    endgenerate

    // Level 2: 30 -> 15
    wire signed [SUM_WIDTH-1:0] s2 [0:14];
    generate
        for (i = 0; i < 15; i = i + 1) begin : l2
            assign s2[i] = s1[2*i] + s1[2*i+1];
        end
    endgenerate

    // Level 3: 15 -> 8 (7 pairs + 1 pass)
    wire signed [SUM_WIDTH-1:0] s3 [0:7];
    generate
        for (i = 0; i < 7; i = i + 1) begin : l3
            assign s3[i] = s2[2*i] + s2[2*i+1];
        end
    endgenerate
    assign s3[7] = s2[14];

    // Level 4: 8 -> 4
    wire signed [SUM_WIDTH-1:0] s4 [0:3];
    generate
        for (i = 0; i < 4; i = i + 1) begin : l4
            assign s4[i] = s3[2*i] + s3[2*i+1];
        end
    endgenerate

    // Level 5: 4 -> 2
    wire signed [SUM_WIDTH-1:0] s5_0, s5_1;
    assign s5_0 = s4[0] + s4[1];
    assign s5_1 = s4[2] + s4[3];

    // Level 6: 2 -> 1
    wire signed [SUM_WIDTH-1:0] total;
    assign total = s5_0 + s5_1;

    // Output register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum <= 0;
            valid <= 0;
        end else if (en) begin
            sum <= total;
            valid <= 1;
        end else begin
            valid <= 0;
        end
    end

endmodule