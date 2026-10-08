// My First Project #1
// 32-Bit Verilog ALU with 64-Bit Output & 32-Op Instruction Set
// Testbench


`timescale 1ns / 1ps

module tb_alu_32bit;

    reg  [31:0] a;
    reg  [31:0] b;
    reg  [4:0]  alu_control;

    wire [63:0] result;
    wire        zero;
    wire        carry;
    wire        negative;
    wire        overflow;

    // Instantiate Unit Under Test (UUT)
    alu_32bit uut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero),
        .carry(carry),
        .negative(negative),
        .overflow(overflow)
    );

    integer k;

    initial begin
        a = 0;
        b = 0;
        alu_control = 0;
        #100;

        // --- Basic Operations Test ---
        a = 32'h0000_000F; b = 32'h0000_0003; 
        
        // Loop through operations 0 to 11 (Arithmetic)
        for (k = 0; k <= 11; k = k + 1) begin
            alu_control = k[4:0];
            #10;
        end

        // --- Bitwise Operations Test ---
        a = 32'hF0F0_AAAA; b = 32'h0F0F_5555;
        for (k = 12; k <= 18; k = k + 1) begin
            alu_control = k[4:0];
            #10;
        end

        // --- Shifts and Rotations Test ---
        a = 32'h8000_0001; b = 32'd4;
        for (k = 19; k <= 23; k = k + 1) begin
            alu_control = k[4:0];
            #10;
        end

        // --- Comparisons Test ---
        a = -32'd10; b = 32'd20;
        for (k = 24; k <= 27; k = k + 1) begin
            alu_control = k[4:0];
            #10;
        end

        // --- Advanced Bit Manipulations Test ---
        a = 32'h000F_0081;
        for (k = 28; k <= 31; k = k + 1) begin
            alu_control = k[4:0];
            #10;
        end

        #20;
        $finish;
    end

endmodule