`timescale 1ns / 1ps

// Block 1: Operand Analyzer
// Mode 00: Full Zero
// Mode 01: Small magnitude (Upper nibble redundant sign bits)
// Mode 10: Full scale precision

module operand_analyzer (
    input  wire signed [7:0] data_in,
    output reg         [1:0] mode
);

    wire [3:0] upper_nibble = data_in[7:4];
    wire is_upper_redundant = (upper_nibble == 4'b0000) || (upper_nibble == 4'b1111);

    always @(*) begin
        if (data_in == 8'sd0) begin
            mode = 2'b00;
        end else if (is_upper_redundant) begin
            mode = 2'b01;
        end else begin
            mode = 2'b10;
        end
    end

endmodule