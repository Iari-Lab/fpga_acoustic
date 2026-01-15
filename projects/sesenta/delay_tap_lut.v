module delay_tap_lut (
    input wire clk,
    input wire [5:0] config_idx,
    input wire [5:0] channel_idx,
    output reg [3:0] delay_tap
);

    (* rom_style = "distributed" *)
    reg [3:0] rom [0:4095];

    initial begin
        $readmemh("delay_tap_lut.mem", rom);
    end

    always @(posedge clk) begin
        delay_tap <= rom[{config_idx, channel_idx}];
    end

endmodule