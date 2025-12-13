module p16_32 #(
    parameter IN_WIDTH = 16, 
    parameter OUT_WIDTH = 32
    ) (
    input wire [IN_WIDTH-1:0] in_1,
    input wire [IN_WIDTH-1:0] in_2,
    output wire [OUT_WIDTH-1:0] out_1
  );

  assign out_1 = { in_2, in_1 };
endmodule
