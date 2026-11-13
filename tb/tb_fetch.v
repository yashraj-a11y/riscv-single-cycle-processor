// tb_fetch.v - testbench for the fetch stage: pc + adder + instr_mem
// Checks reset, sequential PC + 4 stepping, loading a branch target, and that
// the instruction memory returns the right word of prog1_arith.hex.
`timescale 1ns/1ps

module tb_fetch;

    reg         clk = 0;
    reg         reset;
    reg         take_target;          // stands in for the branch decision
    reg  [31:0] target;
    wire [31:0] pc_cur, pc_plus4, pc_next, instr;

    integer errors = 0;

    pc        u_pc    (.clk(clk), .reset(reset), .pc_next(pc_next), .pc(pc_cur));
    adder     u_add   (.a(pc_cur), .b(32'd4), .y(pc_plus4));
    instr_mem #(.MEM_FILE("programs/prog1_arith.hex"))
              u_imem  (.addr(pc_cur), .instr(instr));

    assign pc_next = take_target ? target : pc_plus4;

    always #5 clk = ~clk;

    task check;
        input [31:0] exp_pc;
        input [31:0] exp_instr;
        begin
            if (pc_cur !== exp_pc || instr !== exp_instr) begin
                $display("FAIL: pc=%h instr=%h (expected pc=%h instr=%h)",
                         pc_cur, instr, exp_pc, exp_instr);
                errors = errors + 1;
            end else
                $display("ok  : pc=%h instr=%h", pc_cur, instr);
        end
    endtask

    initial begin
        $dumpfile("tb_fetch.vcd");
        $dumpvars(0, tb_fetch);

        reset = 1; take_target = 0; target = 32'h0;
        @(posedge clk); #1;
        check(32'h00, 32'h00a00093);          // reset -> first instruction

        reset = 0;
        @(posedge clk); #1; check(32'h04, 32'h00600113);
        @(posedge clk); #1; check(32'h08, 32'h002081b3);
        @(posedge clk); #1; check(32'h0c, 32'h40208233);

        // jump to the last instruction of the program
        take_target = 1; target = 32'h38;
        @(posedge clk); #1; check(32'h38, 32'h00000063);

        // carry on sequentially from there (empty memory reads as 0)
        take_target = 0;
        @(posedge clk); #1; check(32'h3c, 32'h00000000);

        // reset in the middle of running
        reset = 1;
        @(posedge clk); #1; check(32'h00, 32'h00a00093);

        if (errors == 0) $display("tb_fetch: ALL TESTS PASSED");
        else             $display("tb_fetch: %0d TEST(S) FAILED", errors);
        $finish;
    end

endmodule
