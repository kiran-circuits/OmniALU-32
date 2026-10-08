// My First Project #1
// 32-Bit Verilog ALU with 64-Bit Output & 32-Op Instruction Set

module alu_32bit (
    input  wire [31:0] a,           // 32-bit First Operand
    input  wire [31:0] b,           // 32-bit Second Operand
    input  wire [4:0]  alu_control, // 5-bit Control Signal (Selects 0 to 31)
    output reg  [63:0] result,      // 64-bit Output Result Vector
    output wire        zero,        // High if full 64-bit result is zero
    output wire        carry,       // Carry flag for 32-bit Addition
    output wire        negative,    // High if MSB of result is 1
    output wire        overflow     // High on signed overflow (Add/Sub)
);

    // Internal 33-bit wire for carry calculation
    wire [32:0] add_temp;
    assign add_temp = {1'b0, a} + {1'b0, b};
    
    // Status Flags Logic
    assign carry    = (alu_control == 5'b00000) ? add_temp[32] : 1'b0;
    assign zero     = (result == 64'd0) ? 1'b1 : 1'b0;
    assign negative = result[63];
    assign overflow = (alu_control == 5'b00000) ? ((a[31] == b[31]) && (result[31] != a[31])) :
                      (alu_control == 5'b00001) ? ((a[31] != b[31]) && (result[31] != a[31])) : 1'b0;

  
    integer i;
    reg [31:0] clz_cnt;
    reg [31:0] ctz_cnt;
    reg [31:0] pop_cnt;
    reg [31:0] rev_bits;

    // Execution Block
    always @(*) begin
        // Default initializations for loop-based variables
        clz_cnt  = 32;
        ctz_cnt  = 32;
        pop_cnt  = 0;
        rev_bits = 0;

        case (alu_control)
            // --- Basic & Extended Arithmetic ---
            5'b00000: result = {32'd0, a + b};                                       // 0: Addition
            5'b00001: result = {32'd0, a - b};                                       // 1: Subtraction
            5'b00010: result = a * b;                                                // 2: Unsigned Multiplication
            5'b00011: result = $signed(a) * $signed(b);                              // 3: Signed Multiplication
            5'b00100: result = (b != 0) ? {32'd0, a / b} : 64'd0;                    // 4: Unsigned Division
            5'b00101: result = (b != 0) ? {32'd0, $signed(a) / $signed(b)} : 64'd0;  // 5: Signed Division
            5'b00110: result = (b != 0) ? {32'd0, a % b} : 64'd0;                    // 6: Unsigned Modulo
            5'b00111: result = (b != 0) ? {32'd0, $signed(a) % $signed(b)} : 64'd0;  // 7: Signed Modulo
            5'b01000: result = {32'd0, a + 1'b1};                                    // 8: Increment A
            5'b01001: result = {32'd0, a - 1'b1};                                    // 9: Decrement A
            5'b01010: result = {32'd0, -a};                                          // 10: Negate A (2's complement)
            5'b01011: result = {32'd0, (a[31] ? -a : a)};                            // 11: Absolute Value |A|

            // --- Bitwise Logic ---
            5'b01100: result = {32'd0, a & b};                                       // 12: Bitwise AND
            5'b01101: result = {32'd0, a | b};                                       // 13: Bitwise OR
            5'b01110: result = {32'd0, a ^ b};                                       // 14: Bitwise XOR
            5'b01111: result = {32'd0, ~(a | b)};                                    // 15: Bitwise NOR
            5'b10000: result = {32'd0, ~(a & b)};                                    // 16: Bitwise NAND
            5'b10001: result = {32'd0, ~(a ^ b)};                                    // 17: Bitwise XNOR
            5'b10010: result = {32'd0, ~a};                                          // 18: Bitwise NOT A

            // --- Shifts and Rotations ---
            5'b10011: result = {32'd0, a << b[4:0]};                                 // 19: Logical Shift Left
            5'b10100: result = {32'd0, a >> b[4:0]};                                 // 20: Logical Shift Right
            5'b10101: result = {32'd0, $signed(a) >>> b[4:0]};                       // 21: Arithmetic Shift Right
            5'b10110: result = {32'd0, (a << b[4:0]) | (a >> (32 - b[4:0]))};        // 22: Rotate Left (ROL)
            5'b10111: result = {32'd0, (a >> b[4:0]) | (a << (32 - b[4:0]))};        // 23: Rotate Right (ROR)

            // --- Comparisons ---
            5'b11000: result = ($signed(a) < $signed(b)) ? 64'd1 : 64'd0;            // 24: Set Less Than Signed
            5'b11001: result = (a < b) ? 64'd1 : 64'd0;                              // 25: Set Less Than Unsigned
            5'b11010: result = (a == b) ? 64'd1 : 64'd0;                             // 26: Set Equal
            5'b11011: result = (a != b) ? 64'd1 : 64'd0;                             // 27: Set Not Equal

            // --- Advanced Bit Manipulations ---
            5'b11100: begin // 28: Count Leading Zeros (CLZ)
                clz_cnt = 32;
                for (i = 31; i >= 0; i = i - 1) begin
                    if (a[i] == 1'b1 && clz_cnt == 32)
                        clz_cnt = 31 - i;
                end
                result = {32'd0, clz_cnt};
            end

            5'b11101: begin // 29: Count Trailing Zeros (CTZ)
                ctz_cnt = 32;
                for (i = 0; i <= 31; i = i + 1) begin
                    if (a[i] == 1'b1 && ctz_cnt == 32)
                        ctz_cnt = i;
                end
                result = {32'd0, ctz_cnt};
            end

            5'b11110: begin // 30: Population Count (Count set 1-bits)
                pop_cnt = 0;
                for (i = 0; i < 32; i = i + 1) begin
                    if (a[i] == 1'b1)
                        pop_cnt = pop_cnt + 1;
                end
                result = {32'd0, pop_cnt};
            end

            5'b11111: begin // 31: Reverse Bits of A
                for (i = 0; i < 32; i = i + 1) begin
                    rev_bits[i] = a[31 - i];
                end
                result = {32'd0, rev_bits};
            end

            default: result = 64'd0;
        endcase
    end

endmodule




