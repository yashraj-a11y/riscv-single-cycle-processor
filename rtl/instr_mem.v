`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// instr_mem.v - Instruction Memory (ROM)
// Holds the program. Read is combinational: give it an address, get the
// 32-bit instruction in the same cycle. The PC counts in bytes, and every
// instruction is 4 bytes, so the word index is addr[31:2].
//
// The program is loaded from a hex file (one 32-bit instruction per line).
// Unused locations are filled with 0, which is not a valid instruction and
// makes the control unit assert no write enables.
// -----------------------------------------------------------------------------
module instr_mem #(
    parameter DEPTH    = 64,                         // number of instructions
    parameter MEM_FILE = "programs/prog1_arith.hex"
)(
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] mem [0:DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 32'b0;
        $readmemh(MEM_FILE, mem);
    end

    assign instr = mem[addr[7:2]];

endmodule
