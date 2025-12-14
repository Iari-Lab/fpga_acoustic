module adder_30x16 (
    input wire clk,
    input wire rst,
    input wire [15:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9,
    input wire [15:0] in10, in11, in12, in13, in14, in15, in16, in17, in18, in19,
    input wire [15:0] in20, in21, in22, in23, in24, in25, in26, in27, in28, in29,
    output reg [20:0] sum
);

    wire signed [20:0] in0_ext  = {{5{in0[15]}}, in0};
    wire signed [20:0] in1_ext  = {{5{in1[15]}}, in1};
    wire signed [20:0] in2_ext  = {{5{in2[15]}}, in2};
    wire signed [20:0] in3_ext  = {{5{in3[15]}}, in3};
    wire signed [20:0] in4_ext  = {{5{in4[15]}}, in4};
    wire signed [20:0] in5_ext  = {{5{in5[15]}}, in5};
    wire signed [20:0] in6_ext  = {{5{in6[15]}}, in6};
    wire signed [20:0] in7_ext  = {{5{in7[15]}}, in7};
    wire signed [20:0] in8_ext  = {{5{in8[15]}}, in8};
    wire signed [20:0] in9_ext  = {{5{in9[15]}}, in9};
    wire signed [20:0] in10_ext = {{5{in10[15]}}, in10};
    wire signed [20:0] in11_ext = {{5{in11[15]}}, in11};
    wire signed [20:0] in12_ext = {{5{in12[15]}}, in12};
    wire signed [20:0] in13_ext = {{5{in13[15]}}, in13};
    wire signed [20:0] in14_ext = {{5{in14[15]}}, in14};
    wire signed [20:0] in15_ext = {{5{in15[15]}}, in15};
    wire signed [20:0] in16_ext = {{5{in16[15]}}, in16};
    wire signed [20:0] in17_ext = {{5{in17[15]}}, in17};
    wire signed [20:0] in18_ext = {{5{in18[15]}}, in18};
    wire signed [20:0] in19_ext = {{5{in19[15]}}, in19};
    wire signed [20:0] in20_ext = {{5{in20[15]}}, in20};
    wire signed [20:0] in21_ext = {{5{in21[15]}}, in21};
    wire signed [20:0] in22_ext = {{5{in22[15]}}, in22};
    wire signed [20:0] in23_ext = {{5{in23[15]}}, in23};
    wire signed [20:0] in24_ext = {{5{in24[15]}}, in24};
    wire signed [20:0] in25_ext = {{5{in25[15]}}, in25};
    wire signed [20:0] in26_ext = {{5{in26[15]}}, in26};
    wire signed [20:0] in27_ext = {{5{in27[15]}}, in27};
    wire signed [20:0] in28_ext = {{5{in28[15]}}, in28};
    wire signed [20:0] in29_ext = {{5{in29[15]}}, in29};

    reg signed [20:0] s1_sum0, s1_sum1, s1_sum2, s1_sum3, s1_sum4, s1_sum5;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s1_sum0 <= 0; s1_sum1 <= 0; s1_sum2 <= 0;
            s1_sum3 <= 0; s1_sum4 <= 0; s1_sum5 <= 0;
        end else begin
            s1_sum0 <= in0_ext + in1_ext + in2_ext + in3_ext + in4_ext;
            s1_sum1 <= in5_ext + in6_ext + in7_ext + in8_ext + in9_ext;
            s1_sum2 <= in10_ext + in11_ext + in12_ext + in13_ext + in14_ext;
            s1_sum3 <= in15_ext + in16_ext + in17_ext + in18_ext + in19_ext;
            s1_sum4 <= in20_ext + in21_ext + in22_ext + in23_ext + in24_ext;
            s1_sum5 <= in25_ext + in26_ext + in27_ext + in28_ext + in29_ext;
        end
    end

    reg signed [20:0] s2_sum0, s2_sum1, s2_sum2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s2_sum0 <= 0; s2_sum1 <= 0; s2_sum2 <= 0;
        end else begin
            s2_sum0 <= s1_sum0 + s1_sum1;
            s2_sum1 <= s1_sum2 + s1_sum3;
            s2_sum2 <= s1_sum4 + s1_sum5;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum <= 0;
        end else begin
            sum <= s2_sum0 + s2_sum1 + s2_sum2;
        end
    end

endmodule