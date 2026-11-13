// tb_alu.v - testbench for alu + alu_control
// Part 1 drives the ALU directly with each operation code.
// Part 2 drives alu_control with (alu_op, funct3, funct7 bit 5, opcode bit 5)
// for every supported instruction and checks it picks the right operation.
`timescale 1ns/1ps

module tb_alu;

    // ALU
    reg  [31:0] a, b;
    reg  [2:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;

    // ALU control
    reg  [1:0]  alu_op;
    reg  [2:0]  funct3;
    reg         funct7_5, op_5;
    wire [2:0]  ctrl_out;

    integer errors = 0;

    localparam ADD = 3'b000, SUB = 3'b001, AND = 3'b010, OR = 3'b011, XOR = 3'b100;

    alu         u_alu  (.a(a), .b(b), .alu_ctrl(alu_ctrl), .result(result), .zero(zero));
    alu_control u_ctrl (.alu_op(alu_op), .funct3(funct3), .funct7_5(funct7_5),
                        .op_5(op_5), .alu_ctrl(ctrl_out));

    task check_alu;
        input [63:0] name;
        input [2:0]  op;
        input [31:0] in_a, in_b, exp;
        input        exp_zero;
        begin
            a = in_a; b = in_b; alu_ctrl = op; #1;
            if (result !== exp || zero !== exp_zero) begin
                $display("FAIL: %0s a=%h b=%h result=%h zero=%b (expected %h, %b)",
                         name, in_a, in_b, result, zero, exp, exp_zero);
                errors = errors + 1;
            end else
                $display("ok  : %0s a=%h b=%h -> %h zero=%b", name, in_a, in_b, result, zero);
        end
    endtask

    task check_ctrl;
        input [79:0] name;
        input [1:0]  op;
        input [2:0]  f3;
        input        f7, o5;
        input [2:0]  exp;
        begin
            alu_op = op; funct3 = f3; funct7_5 = f7; op_5 = o5; #1;
            if (ctrl_out !== exp) begin
                $display("FAIL: %0s alu_ctrl=%b expected=%b", name, ctrl_out, exp);
                errors = errors + 1;
            end else
                $display("ok  : %0s -> alu_ctrl=%b", name, ctrl_out);
        end
    endtask

    initial begin
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        $display("--- ALU operations ---");
        check_alu("ADD", ADD, 32'd10,        32'd6,         32'd16,        1'b0);
        check_alu("ADD", ADD, 32'hFFFFFFFF,  32'd1,         32'd0,         1'b1); // wraps
        check_alu("ADD", ADD, 32'd5,         -32'sd3,       32'd2,         1'b0);
        check_alu("SUB", SUB, 32'd10,        32'd6,         32'd4,         1'b0);
        check_alu("SUB", SUB, 32'd7,         32'd7,         32'd0,         1'b1); // equal
        check_alu("SUB", SUB, 32'd3,         32'd5,         -32'sd2,       1'b0); // negative
        check_alu("AND", AND, 32'hF0F0F0F0,  32'h0FF00FF0,  32'h00F000F0,  1'b0);
        check_alu("AND", AND, 32'hAAAAAAAA,  32'h55555555,  32'h00000000,  1'b1);
        check_alu("OR ", OR,  32'hF0F0F0F0,  32'h0FF00FF0,  32'hFFF0FFF0,  1'b0);
        check_alu("XOR", XOR, 32'hF0F0F0F0,  32'h0FF00FF0,  32'hFF00FF00,  1'b0);
        check_alu("XOR", XOR, 32'h12345678,  32'h12345678,  32'h00000000,  1'b1);

        $display("--- ALU control decode ---");
        //          name          alu_op funct3  f7_5  op_5  expected
        check_ctrl("LW / SW  ", 2'b00, 3'b010, 1'b0, 1'b0, ADD);
        check_ctrl("BEQ      ", 2'b01, 3'b000, 1'b0, 1'b1, SUB);
        check_ctrl("BNE      ", 2'b01, 3'b001, 1'b0, 1'b1, SUB);
        check_ctrl("ADD      ", 2'b10, 3'b000, 1'b0, 1'b1, ADD);
        check_ctrl("SUB      ", 2'b10, 3'b000, 1'b1, 1'b1, SUB);
        check_ctrl("AND      ", 2'b10, 3'b111, 1'b0, 1'b1, AND);
        check_ctrl("OR       ", 2'b10, 3'b110, 1'b0, 1'b1, OR);
        check_ctrl("XOR      ", 2'b10, 3'b100, 1'b0, 1'b1, XOR);
        check_ctrl("ADDI     ", 2'b10, 3'b000, 1'b0, 1'b0, ADD);
        // ADDI with a negative immediate has instr[30] = 1; must still be ADD
        check_ctrl("ADDI neg ", 2'b10, 3'b000, 1'b1, 1'b0, ADD);

        if (errors == 0) $display("tb_alu: ALL TESTS PASSED");
        else             $display("tb_alu: %0d TEST(S) FAILED", errors);
        $finish;
    end

endmodule
