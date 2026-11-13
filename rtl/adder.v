`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// adder.v - 32-bit adder
// Used twice in the datapath: PC + 4 (next sequential instruction) and
// PC + immediate (branch target).
// -----------------------------------------------------------------------------
module adder (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] y
);

    assign y = a + b;

endmodule
