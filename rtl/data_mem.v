`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// data_mem.v - Data Memory (RAM)
// Word-addressed memory used by LW and SW. Write is synchronous (happens on
// the clock edge when mem_write = 1); read is combinational, which is what
// lets a load finish inside one clock cycle.
//
// The address from the ALU is in bytes, so the word index is addr[31:2].
// -----------------------------------------------------------------------------
module data_mem #(
    parameter DEPTH = 64          // number of 32-bit words
)(
    input  wire        clk,
    input  wire        mem_write,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);

    reg [31:0] mem [0:DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (mem_write)
            mem[addr[7:2]] <= write_data;
    end

    assign read_data = mem[addr[7:2]];

endmodule
