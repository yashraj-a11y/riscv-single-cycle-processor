`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// pc.v - Program Counter
// A 32-bit register that holds the address of the instruction being executed.
// On every rising clock edge it loads pc_next. Reset is synchronous and sends
// the processor back to address 0.
// -----------------------------------------------------------------------------
module pc (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);

    always @(posedge clk) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

endmodule
