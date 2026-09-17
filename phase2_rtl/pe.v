`timescale 1ns / 1ps

// Block 3: Processing Element (PE) Core
// Weight-Stationary + Fine-Grained Bit-Split Gated Multiplier

module pe (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               load_w,
    input  wire signed [7:0]  w_in,
    input  wire signed [7:0]  a_in,
    input  wire signed [23:0] acc_in,
    output reg  signed [7:0]  a_out,
    output reg  signed [23:0] acc_out
);

    reg signed [7:0] weight_reg;
    wire [1:0] w_mode;
    wire [1:0] a_mode;

    // Sub-block 1: Operand Analyzers
    operand_analyzer u_ana_w (
        .data_in(weight_reg),
        .mode(w_mode)
    );

    operand_analyzer u_ana_a (
        .data_in(a_in),
        .mode(a_mode)
    );

    // Dynamic gating check: Zero check
    wire pe_active = (w_mode != 2'b00) && (a_mode != 2'b00);

    // Sub-block 2: ICG for multiplier unit
    wire mult_clk;
    sky130_icg u_pe_icg (
        .clk_in(clk),
        .en(pe_active),
        .clk_out(mult_clk)
    );

    // Weight stationary storage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            weight_reg <= 8'sd0;
        end else if (load_w) begin
            weight_reg <= w_in;
        end
    end

    // Sub-block 3: Multiplier Datapath
    reg signed [15:0] prod_reg;
    always @(posedge mult_clk or negedge rst_n) begin
        if (!rst_n) begin
            prod_reg <= 16'sd0;
        end else begin
            prod_reg <= weight_reg * a_in;
        end
    end

    // Systolic streaming registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out   <= 8'sd0;
            acc_out <= 24'sd0;
        end else begin
            a_out   <= a_in;
            acc_out <= acc_in + {{8{prod_reg[15]}}, prod_reg};
        end
    end

endmodule