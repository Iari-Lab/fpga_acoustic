module cic_op_fsm #(
    parameter WIDTH = 23,
    parameter CHANNELS = 30
)(
    input clk,
    input resetn,
    input enable,
    output reg read_en,
    output reg wr_en,
    output reg [$clog2(CHANNELS)-1:0] channel
);

always @(posedge clk or negedge resetn) begin
    if (!resetn | ~enable)
        channel <= 0;
    else if (wr_en)
        channel <= channel + 1'b1;
end

localparam [1:0] S_IDLE  = 2'd0;
localparam [1:0] S_READ  = 2'd1;
localparam [1:0] S_STORE = 2'd2;

reg [1:0] state;

always @(*) begin
    case(state)
        S_IDLE  : {read_en, wr_en} = 2'b00;
        S_READ  : {read_en, wr_en} = 2'b10;
        S_STORE : {read_en, wr_en} = 2'b01;
        default : {read_en, wr_en} = 2'b00;
    endcase
end

always @(posedge clk or negedge resetn) begin
    if (!resetn)
        state <= S_IDLE;
    else begin
        case(state)
            S_IDLE  : if (enable) state <= S_READ;
            S_READ  : state <= S_STORE;
            S_STORE : state <= (enable) ? S_READ : S_IDLE;
            default : state <= S_IDLE;
        endcase
    end
end

endmodule
