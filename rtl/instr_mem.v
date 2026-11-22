`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// instr_mem.v - Instruction Memory (ROM)
// Holds the program. Read is combinational: give it an address, get the
// 32-bit instruction in the same cycle. The PC counts in bytes, and every
// instruction is 4 bytes, so the word index is addr[31:2].
//
// The program is loaded from a hex file (one 32-bit instruction per line).
// In simulation, unused locations are first filled with 0, which is not a
// valid instruction and makes the control unit assert no write enables.
//
// The zero fill is skipped during synthesis. Yosys applies the fill after
// $readmemh, which wiped the program and left a ROM of all zeros. Synthesis
// tools define SYNTHESIS, so the guard below keeps the fill for simulation
// only. Unused ROM words then default to 0 in the FPGA anyway.
// -----------------------------------------------------------------------------
module instr_mem #(
    parameter DEPTH    = 64,                         // number of instructions
    parameter MEM_FILE = "programs/prog1_arith.hex"
)(
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] mem [0:DEPTH-1];

`ifndef SYNTHESIS
    integer i;
`endif

    initial begin
`ifndef SYNTHESIS
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 32'b0;
`endif
        $readmemh(MEM_FILE, mem);
    end

    assign instr = mem[addr[7:2]];

endmodule
