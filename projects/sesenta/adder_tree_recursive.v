`timescale 1ns / 1ps

module adder_tree_recursive #(
    parameter NUM_CHANNELS = 18,
    parameter DATA_WIDTH = 16,
    parameter FANIN = 4  // How many inputs to sum per stage (e.g., 4)
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


// ============================================================================
// Module: Adder Tree Node (The Recursive Core)
// Description:
//   - If inputs <= FANIN, it sums them (Base Case).
//   - If inputs > FANIN, it groups them, sums the groups, and instantiates ITSELF.
//   - Uses flat packed vectors for all ports (Icarus Verilog compatible)
// ============================================================================
module adder_tree_node #(
    parameter NUM_INPUTS = 4,
    parameter DATA_WIDTH = 21,
    parameter FANIN = 4
)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [NUM_INPUTS*DATA_WIDTH-1:0] inputs, // Flat vector input
    output reg signed [DATA_WIDTH-1:0] sum,
    output reg valid_out
);

    generate
        // ====================================================================
        // BASE CASE: Leaf Node
        // We have few enough inputs to simply add them all in one clock cycle.
        // ====================================================================
        if (NUM_INPUTS <= FANIN) begin : g_leaf
            
            integer i;
            reg signed [DATA_WIDTH-1:0] temp_sum; // Variable for immediate math

            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    sum <= 0;
                    valid_out <= 0;
                end else if (en) begin
                    // 1. Calculate Logic (Blocking =)
                    temp_sum = 0;
                    for (i = 0; i < NUM_INPUTS; i = i + 1) begin
                        temp_sum = temp_sum + $signed(inputs[i*DATA_WIDTH +: DATA_WIDTH]);
                    end
                    
                    // 2. Update Register (Non-Blocking <=)
                    sum <= temp_sum;
                    valid_out <= 1'b1;
                end else begin
                    valid_out <= 0;
                end
            end
            
        // ====================================================================
        // RECURSIVE CASE: Internal Node
        // Too many inputs. Divide them into groups, sum the groups, then recurse.
        // ====================================================================
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
                
                reg signed [DATA_WIDTH-1:0] group_sum_reg;
                reg group_valid_reg;
                integer k;
                reg signed [DATA_WIDTH-1:0] group_temp; // Variable for immediate math

                always @(posedge clk or posedge rst) begin
                    if (rst) begin
                        group_sum_reg <= 0;
                        group_valid_reg <= 0;
                    end else if (en) begin
                        // 1. Calculate Logic (Blocking =)
                        group_temp = 0;
                        for (k = 0; k < COUNT; k = k + 1) begin
                            group_temp = group_temp + $signed(inputs[(START+k)*DATA_WIDTH +: DATA_WIDTH]);
                        end
                        
                        // 2. Update Register (Non-Blocking <=)
                        group_sum_reg <= group_temp;
                        group_valid_reg <= 1'b1;
                    end else begin
                        group_valid_reg <= 0;
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
