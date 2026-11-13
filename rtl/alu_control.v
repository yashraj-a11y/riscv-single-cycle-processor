`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// alu_control.v - ALU Decoder
// Second level of the two-level control scheme. The main control unit only
// says what *kind* of ALU work is needed (alu_op); this block looks at the
// funct fields and picks the exact operation.
//
//   alu_op | meaning                  | ALU does
//   -------+--------------------------+-----------------------------
//     00   | load / store             | add (base + offset)
//     01   | branch                   | subtract (compare)
//     10   | R-type or ADDI           | decided by funct3 / funct7
//
// ADD and SUB share funct3 = 000 and differ only in funct7 bit 5 (instr[30]).
// For ADDI that same bit is part of the immediate, so SUB is selected only
// when the instruction is R-type (opcode bit 5 = 1).
// -----------------------------------------------------------------------------
module alu_control (
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire       funct7_5,   // instr[30]
    input  wire       op_5,       // opcode[5]: 1 for R-type, 0 for I-type
    output reg  [2:0] alu_ctrl
);

    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR  = 3'b011;
    localparam ALU_XOR = 3'b100;

    always @(*) begin
        case (alu_op)
            2'b00:   alu_ctrl = ALU_ADD;
            2'b01:   alu_ctrl = ALU_SUB;
            2'b10: begin
                case (funct3)
                    3'b000:  alu_ctrl = (op_5 & funct7_5) ? ALU_SUB : ALU_ADD;
                    3'b111:  alu_ctrl = ALU_AND;
                    3'b110:  alu_ctrl = ALU_OR;
                    3'b100:  alu_ctrl = ALU_XOR;
                    default: alu_ctrl = ALU_ADD;
                endcase
            end
            default: alu_ctrl = ALU_ADD;
        endcase
    end

endmodule
