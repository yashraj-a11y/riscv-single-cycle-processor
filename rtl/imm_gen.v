`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// imm_gen.v - Immediate Generator
// Extracts the immediate field from the 32-bit instruction and sign-extends it
// to 32 bits.  The bits sit in different positions for each instruction format,
// so we switch on the opcode (instr[6:0]).
//
//   Format   |  Opcode   | Immediate bits (from instruction)
//   ---------+-----------+--------------------------------------------
//   I-type   | 0010011   | {instr[31:20]}                  (12 bits)
//            | 0000011   |  (same as above for LW)
//   S-type   | 0100011   | {instr[31:25], instr[11:7]}     (12 bits)
//   B-type   | 1100011   | {instr[31], instr[7], instr[30:25],
//            |           |  instr[11:8], 1'b0}             (13 bits)
// -----------------------------------------------------------------------------
module imm_gen (
    input  wire [31:0] instr,
    output reg  [31:0] imm
);

    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // I-type: ADDI, LW
            7'b0010011,
            7'b0000011: begin
                imm = {{20{instr[31]}}, instr[31:20]};
            end

            // S-type: SW
            7'b0100011: begin
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            // B-type: BEQ, BNE
            7'b1100011: begin
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            default: begin
                imm = 32'b0;
            end
        endcase
    end

endmodule
