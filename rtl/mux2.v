`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// mux2.v - 32-bit 2-to-1 multiplexer
// Used three times in the datapath:
//   - ALU source mux   : register rs2  vs immediate
//   - write-back mux   : ALU result    vs data-memory read data
//   - PC source mux    : PC + 4        vs branch target
// -----------------------------------------------------------------------------
module mux2 (
    input  wire [31:0] d0,   // selected when sel = 0
    input  wire [31:0] d1,   // selected when sel = 1
    input  wire        sel,
    output wire [31:0] y
);

    assign y = sel ? d1 : d0;

endmodule
