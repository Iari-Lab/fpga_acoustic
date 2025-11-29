
// Unused, but made present for IP packaging to allow Vivado IPI to
    // associate a clock with these interfaces, so their FREQ_HZ property can
    // be updated as the main clock frequency changes. Otherwise it defaults
    // to 100 MHz, and if that is not the main clock frequency, it's an error,
    // which cannot be muted or downgraded.

    // NOTE: Verilator will magically ignore "_unused" signals.

    // input wire                          clk_unused, 
    // For Vivado 2022.1, there are some new options in the IP packaging process,
    //     asking to either package for Vitis or for IPI, and optionally ignoring the
    //     FREQ_HZ parameter. This sounds useful as otherwise you cannot package a module
    //     which does not have a clock (so you put in a dummy one). **DO NOT USE THESE!**
    //     The IP will build, but not show up in the .hwh hardware description file, and
    //     not in the bitstream IP hierarchy in a Pynq system. Leave all such options
    //     unselected, even if you are packaging for IPI (which is what we do here). //  //// //  ////  //

module pipeline_gate
#(
    parameter WORD_WIDTH        = 32,
    parameter IMPLEMENTATION    = "AND",
    parameter GATE_DATA         = 0
)
(
    input   wire                        enable,

    output  wire                        input_ready,
    input   wire                        input_valid,
    input   wire    [WORD_WIDTH-1:0]    input_data,

    output  wire                        output_valid,
    input   wire                        output_ready,
    output  wire    [WORD_WIDTH-1:0]    output_data

);

    generate

        if (GATE_DATA != 0) begin : gen_gate_data

            annuller
            #(
                .WORD_WIDTH     (WORD_WIDTH + 1 + 1),
                .IMPLEMENTATION (IMPLEMENTATION)
            )
            gate_control_and_data
            (
                .annul      (enable == 1'b0),
                .data_in    ({input_data,  output_ready, input_valid}),
                .data_out   ({output_data, input_ready,  output_valid})
            );

        end
        else begin : gen_pass_data

            assign output_data = input_data;

            annuller
            #(
                .WORD_WIDTH     (1 + 1),
                .IMPLEMENTATION (IMPLEMENTATION)
            )
            gate_control_only
            (
                .annul      (enable == 1'b0),
                .data_in    ({output_ready, input_valid}),
                .data_out   ({input_ready,  output_valid})
            );

        end

    endgenerate

endmodule