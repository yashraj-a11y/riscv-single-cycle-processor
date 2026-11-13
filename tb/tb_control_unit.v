// tb_control_unit.v - testbench for control_unit + mux2
// Applies the opcode of every supported instruction class and compares all
// control outputs against the control table. Don't-care outputs (mem_to_reg
// for SW and branches) are not checked. Also checks that an unknown opcode
// leaves every write enable off, and that mux2 selects correctly.
`timescale 1ns/1ps

module tb_control_unit;

    reg  [6:0] opcode;
    wire       reg_write, alu_src, mem_write, mem_to_reg, branch;
    wire [1:0] alu_op;

    reg  [31:0] d0, d1;
    reg         sel;
    wire [31:0] y;

    integer errors = 0;

    control_unit dut (
        .opcode(opcode), .reg_write(reg_write), .alu_src(alu_src),
        .mem_write(mem_write), .mem_to_reg(mem_to_reg),
        .branch(branch), .alu_op(alu_op)
    );

    mux2 u_mux (.d0(d0), .d1(d1), .sel(sel), .y(y));

    // check_m2r = 0 skips the mem_to_reg comparison (don't care)
    task check;
        input [79:0] name;
        input [6:0]  op;
        input        e_rw, e_as, e_mw, e_m2r, e_br;
        input [1:0]  e_aop;
        input        check_m2r;
        begin
            opcode = op; #1;
            if (reg_write !== e_rw || alu_src !== e_as || mem_write !== e_mw ||
                branch !== e_br || alu_op !== e_aop ||
                (check_m2r && mem_to_reg !== e_m2r)) begin
                $display("FAIL: %0s reg_write=%b alu_src=%b mem_write=%b mem_to_reg=%b branch=%b alu_op=%b",
                         name, reg_write, alu_src, mem_write, mem_to_reg, branch, alu_op);
                errors = errors + 1;
            end else
                $display("ok  : %0s reg_write=%b alu_src=%b mem_write=%b mem_to_reg=%b branch=%b alu_op=%b",
                         name, reg_write, alu_src, mem_write, mem_to_reg, branch, alu_op);
        end
    endtask

    initial begin
        $dumpfile("tb_control_unit.vcd");
        $dumpvars(0, tb_control_unit);

        $display("--- main decoder ---");
        //     name          opcode       rw    as    mw    m2r   br    alu_op chk
        check("R-type   ", 7'b0110011, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10, 1'b1);
        check("ADDI     ", 7'b0010011, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 2'b10, 1'b1);
        check("LW       ", 7'b0000011, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 2'b00, 1'b1);
        check("SW       ", 7'b0100011, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0);
        check("BEQ/BNE  ", 7'b1100011, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b01, 1'b0);
        // not implemented: must not write anything or branch
        check("unknown 0", 7'b0000000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b1);
        check("JAL (n/a)", 7'b1101111, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b1);

        $display("--- mux2 ---");
        d0 = 32'hAAAA0000; d1 = 32'h0000BBBB;
        sel = 0; #1;
        if (y !== d0) begin $display("FAIL: mux sel=0 y=%h", y); errors = errors + 1; end
        else $display("ok  : sel=0 -> %h", y);
        sel = 1; #1;
        if (y !== d1) begin $display("FAIL: mux sel=1 y=%h", y); errors = errors + 1; end
        else $display("ok  : sel=1 -> %h", y);

        if (errors == 0) $display("tb_control_unit: ALL TESTS PASSED");
        else             $display("tb_control_unit: %0d TEST(S) FAILED", errors);
        $finish;
    end

endmodule
