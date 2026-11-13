`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// control_unit.v - Main Control Unit (instruction decoder)
// Looks only at the 7-bit opcode and produces the control signals that steer
// the datapath for that instruction class.
//
//   Instruction    | opcode  | reg_write alu_src mem_write mem_to_reg branch alu_op
//   ---------------+---------+------------------------------------------------------
//   R-type         | 0110011 |     1        0        0          0        0     10
//   ADDI           | 0010011 |     1        1        0          0        0     10
//   LW             | 0000011 |     1        1        0          1        0     00
//   SW             | 0100011 |     0        1        1          x        0     00
//   BEQ / BNE      | 1100011 |     0        0        0          x        1     01
//
// Any other opcode turns every write enable off, so an unknown instruction
// cannot change registers or memory.
// -----------------------------------------------------------------------------
module control_unit (
    input  wire [6:0] opcode,
    output reg        reg_write,   // write result into the register file
    output reg        alu_src,     // 0: ALU b = rs2,  1: ALU b = immediate
    output reg        mem_write,   // write rs2 into data memory
    output reg        mem_to_reg,  // 0: write back ALU result, 1: memory data
    output reg        branch,      // instruction is a conditional branch
    output reg  [1:0] alu_op       // passed on to alu_control
);

    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_IMM    = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;

    always @(*) begin
        // safe defaults
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        alu_op     = 2'b00;

        case (opcode)
            OP_RTYPE: begin
                reg_write = 1'b1;
                alu_op    = 2'b10;
            end
            OP_IMM: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b10;
            end
            OP_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
            end
            OP_STORE: begin
                alu_src   = 1'b1;
                mem_write = 1'b1;
            end
            OP_BRANCH: begin
                branch = 1'b1;
                alu_op = 2'b01;
            end
            default: ; // keep defaults
        endcase
    end

endmodule
