`timescale 1ns / 1ps

// Block 2: Integrated Clock Gating (ICG) Cell Wrapper
// Glitch-free clock enable using negative-edge latch

module sky130_icg (
    input  wire clk_in,
    input  wire en,
    output wire clk_out
);

    reg latch_en;

    // Latch is transparent only when clk is LOW
    always @(clk_in or en) begin
        if (!clk_in) begin
            latch_en <= en;
        end
    end

    assign clk_out = clk_in & latch_en;

endmodule