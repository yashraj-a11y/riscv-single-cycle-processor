// tb_imm_gen.v - testbench for imm_gen
// Tests I-type, S-type, and B-type immediate extraction and sign extension,
// including positive and negative immediates.
`timescale 1ns/1ps

module tb_imm_gen;

    reg  [31:0] instr;
    wire [31:0] imm;

    integer errors = 0;

    imm_gen dut (.instr(instr), .imm(imm));

    task check;
        input [127:0] name;
        input [31:0]  instruction;
        input [31:0]  expected;
        begin
            instr = instruction; #1;
            if (imm !== expected) begin
                $display("FAIL: %0s  instr=%h  imm=%h  expected=%h",
                         name, instruction, imm, expected);
                errors = errors + 1;
            end else
                $display("ok  : %0s  instr=%h  imm=%h",
                         name, instruction, imm);
        end
    endtask

    initial begin
        $dumpfile("tb_imm_gen.vcd");
        $dumpvars(0, tb_imm_gen);

        // ================================================================
        // I-type:  imm[11:0] = instr[31:20]
        // ================================================================
        $display("--- I-type (ADDI / LW) ---");

        // addi x1, x0, 10  =>  00a00093
        // imm = 0x00A = 10
        check("addi +10     ", 32'h00a00093, 32'h0000000A);

        // addi x2, x0, 6   =>  00600113
        // imm = 0x006 = 6
        check("addi +6      ", 32'h00600113, 32'h00000006);

        // addi x8, x0, -3  =>  ffd00413
        // imm = 0xFFD => sign-extended = 0xFFFFFFFD (-3)
        check("addi -3      ", 32'hffd00413, 32'hFFFFFFFD);

        // addi x1, x1, -1  =>  fff08093
        // imm = 0xFFF => sign-extended = 0xFFFFFFFF (-1)
        check("addi -1      ", 32'hfff08093, 32'hFFFFFFFF);

        // lw x9, 0(x0)     =>  00002483
        // imm = 0x000 = 0
        check("lw offset 0  ", 32'h00002483, 32'h00000000);

        // lw x10, 4(x0)    =>  00402503
        // imm = 0x004 = 4
        check("lw offset 4  ", 32'h00402503, 32'h00000004);

        // ================================================================
        // S-type:  imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
        // ================================================================
        $display("--- S-type (SW) ---");

        // sw x3, 0(x0)  =>  00302023
        // imm = 0
        check("sw offset 0  ", 32'h00302023, 32'h00000000);

        // sw x4, 4(x0)  =>  00402223
        // imm = 4
        check("sw offset 4  ", 32'h00402223, 32'h00000004);

        // sw x11, 8(x0) =>  00b02423
        // imm = 8
        check("sw offset 8  ", 32'h00b02423, 32'h00000008);

        // ================================================================
        // B-type:  imm = {instr[31], instr[7], instr[30:25], instr[11:8], 0}
        // ================================================================
        $display("--- B-type (BEQ / BNE) ---");

        // beq x0, x0, 0    =>  00000063   (halt: branch to self, offset = 0)
        check("beq offset 0 ", 32'h00000063, 32'h00000000);

        // bne x1, x0, -8   =>  fe009ce3   (back to loop, offset = -8)
        check("bne -8       ", 32'hfe009ce3, 32'hFFFFFFF8);

        // beq x1, x2, +8   =>  00208463   (skip, offset = +8)
        check("beq +8       ", 32'h00208463, 32'h00000008);

        // beq x4, x5, +8   =>  00520463   (taken, offset = +8)
        check("beq +8 (2)   ", 32'h00520463, 32'h00000008);

        // ================================================================
        // Default: unknown opcode should produce 0
        // ================================================================
        $display("--- default (unknown opcode) ---");
        check("R-type (0)   ", 32'h002081b3, 32'h00000000);  // R-type add

        // ---- summary ----
        if (errors == 0) begin
            $display("tb_imm_gen: ALL TESTS PASSED");
            $finish;
        end else begin
            $display("tb_imm_gen: %0d TEST(S) FAILED", errors);
            $fatal(1);
        end
    end

endmodule
