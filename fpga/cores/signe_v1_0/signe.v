module signe #(
    parameter IN_WIDTH = 16, 
    parameter OUT_WIDTH = 32
    ) (
    input wire [IN_WIDTH-1:0] in_1,
    output wire [OUT_WIDTH-1:0] out_1
  );

  localparam PADDING_WIDTH = OUT_WIDTH - IN_WIDTH;
  assign out_1 = { {PADDING_WIDTH{in_1[IN_WIDTH-1]}}, in_1 };
endmodule
