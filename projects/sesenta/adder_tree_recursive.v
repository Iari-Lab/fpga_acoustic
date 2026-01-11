`timescale 1ns / 1ps

//============================================================================
// Module: adder_tree_recursive (Top-Level)
// Description:
//   Recursive adder tree with DSP block inference support for Vivado.
//   Uses FANIN=4 with explicit 4-input tree pattern for DSP mapping.
//============================================================================
module adder_tree_recursive #(
    parameter NUM_CHANNELS = 18,
    parameter DATA_WIDTH = 16,
    parameter FANIN = 4  // How many inputs to sum per stage (must be 4 for DSP)
)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [NUM_CHANNELS*DATA_WIDTH-1:0] data_in,
    output wire signed [SUM_WIDTH-1:0] sum,
    output wire valid
);

    // 1. Calculate required width for the final sum to avoid overflow
    localparam SUM_WIDTH = DATA_WIDTH + $clog2(NUM_CHANNELS) + 1;

    // 2. Sign-extend inputs to the maximum width immediately
    //    Use flat packed vector instead of unpacked array
    wire [NUM_CHANNELS*SUM_WIDTH-1:0] in_ext_flat;
    
    genvar i;
    generate
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : g_extend
            wire signed [DATA_WIDTH-1:0] ch;
            assign ch = data_in[i*DATA_WIDTH +: DATA_WIDTH];
            // Sign-extend and place into flat vector
            assign in_ext_flat[i*SUM_WIDTH +: SUM_WIDTH] = {{(SUM_WIDTH-DATA_WIDTH){ch[DATA_WIDTH-1]}}, ch};
        end
    endgenerate

    // 3. Instantiate the Root Node of the recursive tree
    adder_tree_node #(
        .NUM_INPUTS(NUM_CHANNELS),
        .DATA_WIDTH(SUM_WIDTH),
        .FANIN(FANIN)
    ) root (
        .clk(clk),
        .rst(rst),
        .en(en),
        .inputs(in_ext_flat),
        .sum(sum),
        .valid_out(valid)
    );

endmodule


//============================================================================
// Module: Adder Tree Node (The Recursive Core with DSP Support)
// Description:
//   - If inputs <= FANIN, it sums them using DSP-friendly pattern (Base Case).
//   - If inputs > FANIN, it groups them, sums the groups, and instantiates ITSELF.
//   - Uses flat packed vectors for all ports (Icarus Verilog compatible)
//   - Implements explicit 4-input adder tree with use_dsp attributes
//============================================================================
module adder_tree_node #(
    parameter NUM_INPUTS = 4,
    parameter DATA_WIDTH = 21,
    parameter FANIN = 4
)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [NUM_INPUTS*DATA_WIDTH-1:0] inputs, // Flat vector input
    (* use_dsp = "yes" *) output reg signed [DATA_WIDTH-1:0] sum,
    output reg valid_out
);

    generate
        //====================================================================
        // BASE CASE: Leaf Node
        // We have few enough inputs to simply add them all in one clock cycle.
        // Uses explicit 4-input tree pattern for DSP inference.
        //====================================================================
        if (NUM_INPUTS <= FANIN) begin : g_leaf
            
            // Extract up to 4 signed operands (pad missing ones with 0)
            wire signed [DATA_WIDTH-1:0] x0 = (NUM_INPUTS > 0) ? $signed(inputs[0*DATA_WIDTH +: DATA_WIDTH]) : {DATA_WIDTH{1'b0}};
            wire signed [DATA_WIDTH-1:0] x1 = (NUM_INPUTS > 1) ? $signed(inputs[1*DATA_WIDTH +: DATA_WIDTH]) : {DATA_WIDTH{1'b0}};
            wire signed [DATA_WIDTH-1:0] x2 = (NUM_INPUTS > 2) ? $signed(inputs[2*DATA_WIDTH +: DATA_WIDTH]) : {DATA_WIDTH{1'b0}};
            wire signed [DATA_WIDTH-1:0] x3 = (NUM_INPUTS > 3) ? $signed(inputs[3*DATA_WIDTH +: DATA_WIDTH]) : {DATA_WIDTH{1'b0}};

            // Hint Vivado to use DSPs for these adds
            // First level: pairwise addition with 1-bit growth
            (* use_dsp = "yes" *) wire signed [DATA_WIDTH:0] s01 = x0 + x1;
            (* use_dsp = "yes" *) wire signed [DATA_WIDTH:0] s23 = x2 + x3;
            
            // Second level: combine pairs with 2-bit growth total
            (* use_dsp = "yes" *) wire signed [DATA_WIDTH+1:0] s0123 = s01 + s23;

            // Register the result
            (* use_dsp = "yes" *) reg signed [DATA_WIDTH-1:0] sum_reg;
            
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    sum_reg   <= {DATA_WIDTH{1'b0}};
                    valid_out <= 1'b0;
                end else if (en) begin
                    sum_reg   <= s0123[DATA_WIDTH-1:0]; // Truncate to DATA_WIDTH
                    valid_out <= 1'b1;
                end else begin
                    valid_out <= 1'b0;
                end
            end
            
            always @(*) begin
                sum = sum_reg;
            end
            
        //====================================================================
        // RECURSIVE CASE: Internal Node
        // Too many inputs. Divide them into groups, sum the groups, then recurse.
        // Uses explicit 4-input tree pattern for DSP inference in each group.
        //====================================================================
        end else begin : g_recurse
            
            // Calculate how many partial sums we will produce
            localparam OUTPUTS = (NUM_INPUTS + FANIN - 1) / FANIN;
            
            // Use flat packed vector instead of unpacked array
            wire [OUTPUTS*DATA_WIDTH-1:0] partial_sums_flat;
            wire [OUTPUTS-1:0] partial_valid;
            
            genvar g;
            for (g = 0; g < OUTPUTS; g = g + 1) begin : g_group
                // Calculate which slice of inputs this group handles
                localparam START = g * FANIN;
                localparam COUNT = (START + FANIN > NUM_INPUTS) ? (NUM_INPUTS - START) : FANIN;
                
                // Extract up to 4 signed operands (pad missing ones with 0)
                wire signed [DATA_WIDTH-1:0] x0 = (COUNT > 0) ? $signed(inputs[(START+0)*DATA_WIDTH +: DATA_WIDTH]) : {DATA_WIDTH{1'b0}};
                wire signed [DATA_WIDTH-1:0] x1 = (COUNT > 1) ? $signed(inputs[(START+1)*DATA_WIDTH +: DATA_WIDTH]) : {DATA_WIDTH{1'b0}};
                wire signed [DATA_WIDTH-1:0] x2 = (COUNT > 2) ? $signed(inputs[(START+2)*DATA_WIDTH +: DATA_WIDTH]) : {DATA_WIDTH{1'b0}};
                wire signed [DATA_WIDTH-1:0] x3 = (COUNT > 3) ? $signed(inputs[(START+3)*DATA_WIDTH +: DATA_WIDTH]) : {DATA_WIDTH{1'b0}};

                // Hint Vivado to use DSPs for these adds
                // First level: pairwise addition with 1-bit growth
                (* use_dsp = "yes" *) wire signed [DATA_WIDTH:0] s01 = x0 + x1;
                (* use_dsp = "yes" *) wire signed [DATA_WIDTH:0] s23 = x2 + x3;
                
                // Second level: combine pairs with 2-bit growth total
                (* use_dsp = "yes" *) wire signed [DATA_WIDTH+1:0] s0123 = s01 + s23;

                // Register the group sum
                (* use_dsp = "yes" *) reg signed [DATA_WIDTH-1:0] group_sum_reg;
                reg group_valid_reg;

                always @(posedge clk or posedge rst) begin
                    if (rst) begin
                        group_sum_reg   <= {DATA_WIDTH{1'b0}};
                        group_valid_reg <= 1'b0;
                    end else if (en) begin
                        group_sum_reg   <= s0123[DATA_WIDTH-1:0]; // Truncate to DATA_WIDTH
                        group_valid_reg <= 1'b1;
                    end else begin
                        group_valid_reg <= 1'b0;
                    end
                end
                
                // Assign to flat vector slice
                assign partial_sums_flat[g*DATA_WIDTH +: DATA_WIDTH] = group_sum_reg;
                assign partial_valid[g] = group_valid_reg;
            end

            // --- RECURSIVE INSTANTIATION ---
            // The "next stage" is just another instance of this same module,
            // but with fewer inputs (OUTPUTS size).
            wire signed [DATA_WIDTH-1:0] next_stage_sum;
            wire next_stage_valid;
            
            adder_tree_node #(
                .NUM_INPUTS(OUTPUTS),
                .DATA_WIDTH(DATA_WIDTH),
                .FANIN(FANIN)
            ) next_stage (
                .clk(clk),
                .rst(rst),
                .en(partial_valid[0]), // Wait for the current group sums to be valid
                .inputs(partial_sums_flat),
                .sum(next_stage_sum),
                .valid_out(next_stage_valid)
            );
            
            // Pass the result from the child up to the parent
            always @(*) begin
                sum = next_stage_sum;
                valid_out = next_stage_valid;
            end
        end
    endgenerate

endmodule
