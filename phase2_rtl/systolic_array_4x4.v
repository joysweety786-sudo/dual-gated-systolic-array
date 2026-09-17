`timescale 1ns / 1ps

// 4x4 Weight-Stationary Systolic Array Top
// Features Coarse-Grained Row Clock Suppression

module systolic_array_4x4 (
    input  wire clk,
    input  wire rst_n,
    input  wire load_w,
    // Flattened 4x4 8-bit weight inputs (16 x 8 = 128 bits)
    input  wire signed [127:0] flat_weights_in,
    // Flattened 4 x 8-bit activation inputs from left boundary (32 bits)
    input  wire signed [31:0]  flat_activations_in,
    // Flattened 4 x 24-bit accumulated outputs from bottom boundary (96 bits)
    output wire signed [95:0]  flat_results_out
);

    // Unpack flattened buses for clean 2D array routing
    wire signed [7:0]  weights [0:3][0:3];
    wire signed [7:0]  activations [0:3];
    wire signed [23:0] results [0:3];

    genvar i, j;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_unpack_in
            assign activations[i] = flat_activations_in[(i*8) +: 8];
            assign flat_results_out[(i*24) +: 24] = results[i];
            for (j = 0; j < 4; j = j + 1) begin : gen_unpack_w
                assign weights[i][j] = flat_weights_in[((i*4 + j)*8) +: 8];
            end
        end
    endgenerate

    // Coarse-Grained Level 2: Row Zero Boundary Detectors
    wire [3:0] row_active;
    wire [3:0] gated_row_clk;

    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_row_gating
            // Suppress entire row clock if all 4 weights in the row are zero
            assign row_active[i] = (weights[i][0] != 8'sd0) ||
                                   (weights[i][1] != 8'sd0) ||
                                   (weights[i][2] != 8'sd0) ||
                                   (weights[i][3] != 8'sd0);

            sky130_icg u_row_icg (
                .clk_in(clk),
                .en(row_active[i]),
                .clk_out(gated_row_clk[i])
            );
        end
    endgenerate

    // Interconnect wires between Processing Elements
    wire signed [7:0]  act_horiz [0:3][0:4];
    wire signed [23:0] acc_vert  [0:4][0:3];

    // Boundary tie-offs and external mappings
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_boundaries
            assign act_horiz[i][0] = activations[i]; // Left inputs
            assign acc_vert[0][i]  = 24'sd0;         // Top accumulators start at 0
            assign results[i]      = acc_vert[4][i]; // Bottom outputs
        end
    endgenerate

    // 4x4 Grid Instantiation of PEs
    generate
        for (i = 0; i < 4; i = i + 1) begin : pe_rows
            for (j = 0; j < 4; j = j + 1) begin : pe_cols
                pe u_pe (
                    .clk     (gated_row_clk[i]),
                    .rst_n   (rst_n),
                    .load_w  (load_w),
                    .w_in    (weights[i][j]),
                    .a_in    (act_horiz[i][j]),
                    .acc_in  (acc_vert[i][j]),
                    .a_out   (act_horiz[i][j+1]),
                    .acc_out (acc_vert[i+1][j])
                );
            end
        end
    endgenerate

endmodule