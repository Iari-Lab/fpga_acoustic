module annuller
#(
    parameter       WORD_WIDTH          = 0,
    parameter       IMPLEMENTATION      = ""
)
(
    input   wire                        annul,
    input   wire    [WORD_WIDTH-1:0]    data_in,
    output  reg     [WORD_WIDTH-1:0]    data_out
);

    localparam ZERO = {WORD_WIDTH{1'b0}};

    initial begin
        data_out = ZERO;
    end

    generate
        if (IMPLEMENTATION == "MUX") begin : gen_mux
            always @(*) begin
                data_out = (annul == 1'b0) ? data_in : ZERO;
            end
        end
        else
        if (IMPLEMENTATION == "AND") begin : gen_and
            always @(*) begin
                data_out = data_in & {WORD_WIDTH{annul == 1'b0}};
            end
        end
    endgenerate

endmodule