module full_adder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
  assign sum = a ^ b ^ cin;
  assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module adder_Nbit #(
    parameter WIDTH = 21  
)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] sum,
    output carry_out
);
    wire [WIDTH-1:0] carry;
    full_adder fa0 ( .a(a[0]), .b(b[0]), .cin(1'b0), .sum(sum[0]), .cout(carry[0]) );
    genvar i;
    generate
        for (i = 1; i < WIDTH; i = i + 1) begin: gen_full_adders
            full_adder fa ( .a(a[i]), .b(b[i]), .cin(carry[i-1]), .sum(sum[i]), .cout(carry[i]) );
        end
    endgenerate
    assign carry_out = carry[WIDTH-1];
endmodule

module adder_21bit (
    input [20:0] a,
    input [20:0] b,
    output [20:0] sum,
    output carry_out
);
    adder_Nbit #(.WIDTH(21)) u_adder (
        .a(a),
        .b(b),
        .sum(sum),
        .carry_out(carry_out)
    );
endmodule

module adder_30x16 (
    input [15:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9,
    input [15:0] in10, in11, in12, in13, in14, in15, in16, in17, in18, in19,
    input [15:0] in20, in21, in22, in23, in24, in25, in26, in27, in28, in29,
    output [20:0] sum,  
    output carry_out
);
    // First stage: Add inputs in pairs (15 adders for 30 inputs)
    wire [20:0] stage1_sum [14:0];
    wire [14:0] stage1_carry;
    
    // Extend inputs to 21 bits for addition (sign extension)
    wire [20:0] in0_ext = {{5{in0[15]}}, in0};
    wire [20:0] in1_ext = {{5{in1[15]}}, in1};
    wire [20:0] in2_ext = {{5{in2[15]}}, in2};
    wire [20:0] in3_ext = {{5{in3[15]}}, in3};
    wire [20:0] in4_ext = {{5{in4[15]}}, in4};
    wire [20:0] in5_ext = {{5{in5[15]}}, in5};
    wire [20:0] in6_ext = {{5{in6[15]}}, in6};
    wire [20:0] in7_ext = {{5{in7[15]}}, in7};
    wire [20:0] in8_ext = {{5{in8[15]}}, in8};
    wire [20:0] in9_ext = {{5{in9[15]}}, in9};
    wire [20:0] in10_ext = {{5{in10[15]}}, in10};
    wire [20:0] in11_ext = {{5{in11[15]}}, in11};
    wire [20:0] in12_ext = {{5{in12[15]}}, in12};
    wire [20:0] in13_ext = {{5{in13[15]}}, in13};
    wire [20:0] in14_ext = {{5{in14[15]}}, in14};
    wire [20:0] in15_ext = {{5{in15[15]}}, in15};
    wire [20:0] in16_ext = {{5{in16[15]}}, in16};
    wire [20:0] in17_ext = {{5{in17[15]}}, in17};
    wire [20:0] in18_ext = {{5{in18[15]}}, in18};
    wire [20:0] in19_ext = {{5{in19[15]}}, in19};
    wire [20:0] in20_ext = {{5{in20[15]}}, in20};
    wire [20:0] in21_ext = {{5{in21[15]}}, in21};
    wire [20:0] in22_ext = {{5{in22[15]}}, in22};
    wire [20:0] in23_ext = {{5{in23[15]}}, in23};
    wire [20:0] in24_ext = {{5{in24[15]}}, in24};
    wire [20:0] in25_ext = {{5{in25[15]}}, in25};
    wire [20:0] in26_ext = {{5{in26[15]}}, in26};
    wire [20:0] in27_ext = {{5{in27[15]}}, in27};
    wire [20:0] in28_ext = {{5{in28[15]}}, in28};
    wire [20:0] in29_ext = {{5{in29[15]}}, in29};
    
    // Stage 1: Pairwise addition (15 adders)
    adder_21bit add0 ( .a(in0_ext), .b(in1_ext), .sum(stage1_sum[0]), .carry_out(stage1_carry[0]) );
    adder_21bit add1 ( .a(in2_ext), .b(in3_ext), .sum(stage1_sum[1]), .carry_out(stage1_carry[1]) );
    adder_21bit add2 ( .a(in4_ext), .b(in5_ext), .sum(stage1_sum[2]), .carry_out(stage1_carry[2]) );
    adder_21bit add3 ( .a(in6_ext), .b(in7_ext), .sum(stage1_sum[3]), .carry_out(stage1_carry[3]) );
    adder_21bit add4 ( .a(in8_ext), .b(in9_ext), .sum(stage1_sum[4]), .carry_out(stage1_carry[4]) );
    adder_21bit add5 ( .a(in10_ext), .b(in11_ext), .sum(stage1_sum[5]), .carry_out(stage1_carry[5]) );
    adder_21bit add6 ( .a(in12_ext), .b(in13_ext), .sum(stage1_sum[6]), .carry_out(stage1_carry[6]) );
    adder_21bit add7 ( .a(in14_ext), .b(in15_ext), .sum(stage1_sum[7]), .carry_out(stage1_carry[7]) );
    adder_21bit add8 ( .a(in16_ext), .b(in17_ext), .sum(stage1_sum[8]), .carry_out(stage1_carry[8]) );
    adder_21bit add9 ( .a(in18_ext), .b(in19_ext), .sum(stage1_sum[9]), .carry_out(stage1_carry[9]) );
    adder_21bit add10 ( .a(in20_ext), .b(in21_ext), .sum(stage1_sum[10]), .carry_out(stage1_carry[10]) );
    adder_21bit add11 ( .a(in22_ext), .b(in23_ext), .sum(stage1_sum[11]), .carry_out(stage1_carry[11]) );
    adder_21bit add12 ( .a(in24_ext), .b(in25_ext), .sum(stage1_sum[12]), .carry_out(stage1_carry[12]) );
    adder_21bit add13 ( .a(in26_ext), .b(in27_ext), .sum(stage1_sum[13]), .carry_out(stage1_carry[13]) );
    adder_21bit add14 ( .a(in28_ext), .b(in29_ext), .sum(stage1_sum[14]), .carry_out(stage1_carry[14]) );
    
    // Stage 2: Add results of stage 1 (7 adders)
    wire [20:0] stage2_sum [6:0];
    wire [6:0] stage2_carry;
    
    adder_21bit add15 ( .a(stage1_sum[0]), .b(stage1_sum[1]), .sum(stage2_sum[0]), .carry_out(stage2_carry[0]) );
    adder_21bit add16 ( .a(stage1_sum[2]), .b(stage1_sum[3]), .sum(stage2_sum[1]), .carry_out(stage2_carry[1]) );
    adder_21bit add17 ( .a(stage1_sum[4]), .b(stage1_sum[5]), .sum(stage2_sum[2]), .carry_out(stage2_carry[2]) );
    adder_21bit add18 ( .a(stage1_sum[6]), .b(stage1_sum[7]), .sum(stage2_sum[3]), .carry_out(stage2_carry[3]) );
    adder_21bit add19 ( .a(stage1_sum[8]), .b(stage1_sum[9]), .sum(stage2_sum[4]), .carry_out(stage2_carry[4]) );
    adder_21bit add20 ( .a(stage1_sum[10]), .b(stage1_sum[11]), .sum(stage2_sum[5]), .carry_out(stage2_carry[5]) );
    adder_21bit add21 ( .a(stage1_sum[12]), .b(stage1_sum[13]), .sum(stage2_sum[6]), .carry_out(stage2_carry[6]) );
    
    // Stage 3: Add results of stage 2 (3 adders)
    wire [20:0] stage3_sum [2:0];
    wire [2:0] stage3_carry;
    
    adder_21bit add22 ( .a(stage2_sum[0]), .b(stage2_sum[1]), .sum(stage3_sum[0]), .carry_out(stage3_carry[0]) );
    adder_21bit add23 ( .a(stage2_sum[2]), .b(stage2_sum[3]), .sum(stage3_sum[1]), .carry_out(stage3_carry[1]) );
    adder_21bit add24 ( .a(stage2_sum[4]), .b(stage2_sum[5]), .sum(stage3_sum[2]), .carry_out(stage3_carry[2]) );
    
    // Stage 4: Add results of stage 3 (2 adders)
    wire [20:0] stage4_sum [1:0];
    wire [1:0] stage4_carry;
    
    adder_21bit add25 ( .a(stage3_sum[0]), .b(stage3_sum[1]), .sum(stage4_sum[0]), .carry_out(stage4_carry[0]) );
    adder_21bit add26 ( .a(stage3_sum[2]), .b(stage1_sum[14]), .sum(stage4_sum[1]), .carry_out(stage4_carry[1]) );
    
    // Final stage: Add the last two results
    wire [20:0] final_sum;
    wire final_carry;
    
    adder_21bit add27 ( .a(stage4_sum[0]), .b(stage4_sum[1]), .sum(final_sum), .carry_out(final_carry) );
    
    // Assign final outputs
    assign sum = final_sum;
    assign carry_out = final_carry;
endmodule