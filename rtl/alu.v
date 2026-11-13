`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// alu.v - Arithmetic Logic Unit
// Combinational. Performs the operation selected by alu_ctrl on a and b.
// The zero flag is high when the result is 0; branches use it (BEQ/BNE
// subtract the two registers and look at zero).
//
//   alu_ctrl | operation
//   ---------+----------
//     000    | a + b
//     001    | a - b
//     010    | a & b
//     011    | a | b
//     100    | a ^ b
// -----------------------------------------------------------------------------
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);

    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR  = 3'b011;
    localparam ALU_XOR = 3'b100;

    always @(*) begin
        case (alu_ctrl)
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            ALU_XOR: result = a ^ b;
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
