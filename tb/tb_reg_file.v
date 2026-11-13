// tb_reg_file.v - testbench for reg_file
// Tests: write and read back, x0 hardwired to zero, two-port simultaneous
// read, write-enable gating, and all-zero initial state.
`timescale 1ns/1ps

module tb_reg_file;

    reg         clk = 0;
    reg         we;
    reg  [4:0]  rs1, rs2, rd;
    reg  [31:0] wd;
    wire [31:0] rd1, rd2;

    integer errors = 0;

    reg_file dut (
        .clk(clk), .we(we),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .wd(wd),   .rd1(rd1), .rd2(rd2)
    );

    always #5 clk = ~clk;

    task write_reg;
        input [4:0]  addr;
        input [31:0] data;
        begin
            @(negedge clk);
            we = 1; rd = addr; wd = data;
            @(posedge clk); #1;
            we = 0;
        end
    endtask

    task check;
        input [79:0] name;
        input [31:0] got, expected;
        begin
            if (got !== expected) begin
                $display("FAIL: %0s  got=%h  expected=%h", name, got, expected);
                errors = errors + 1;
            end else
                $display("ok  : %0s  = %h", name, got);
        end
    endtask

    initial begin
        $dumpfile("tb_reg_file.vcd");
        $dumpvars(0, tb_reg_file);

        we = 0; rs1 = 0; rs2 = 0; rd = 0; wd = 0;

        // ---- Test 1: initial state - all registers read zero ----
        $display("--- initial state ---");
        rs1 = 5'd1; rs2 = 5'd2; #1;
        check("x1 init  ", rd1, 32'h0);
        check("x2 init  ", rd2, 32'h0);

        // ---- Test 2: write to x1 and read back ----
        $display("--- write x1 = 0xDEADBEEF ---");
        write_reg(5'd1, 32'hDEADBEEF);
        rs1 = 5'd1; #1;
        check("x1 read  ", rd1, 32'hDEADBEEF);

        // ---- Test 3: write to x2 and simultaneous two-port read ----
        $display("--- write x2 = 0x12345678, dual read ---");
        write_reg(5'd2, 32'h12345678);
        rs1 = 5'd1; rs2 = 5'd2; #1;
        check("x1 dual  ", rd1, 32'hDEADBEEF);
        check("x2 dual  ", rd2, 32'h12345678);

        // ---- Test 4: x0 always reads zero even after write attempt ----
        $display("--- x0 hardwired zero ---");
        write_reg(5'd0, 32'hFFFFFFFF);
        rs1 = 5'd0; #1;
        check("x0 read  ", rd1, 32'h0);

        // ---- Test 5: write-enable gating (we = 0 should not write) ----
        $display("--- write-enable gating ---");
        @(negedge clk);
        we = 0; rd = 5'd3; wd = 32'hCAFEBABE;
        @(posedge clk); #1;
        rs1 = 5'd3; #1;
        check("x3 no-wr ", rd1, 32'h0);

        // ---- Test 6: write to x3 with we = 1, confirm ----
        $display("--- write x3 with we=1 ---");
        write_reg(5'd3, 32'hCAFEBABE);
        rs1 = 5'd3; #1;
        check("x3 read  ", rd1, 32'hCAFEBABE);

        // ---- Test 7: overwrite x1 ----
        $display("--- overwrite x1 ---");
        write_reg(5'd1, 32'h00000042);
        rs1 = 5'd1; #1;
        check("x1 new   ", rd1, 32'h00000042);

        // ---- Test 8: write to high register x31 ----
        $display("--- write x31 ---");
        write_reg(5'd31, 32'hABCD1234);
        rs1 = 5'd31; #1;
        check("x31 read ", rd1, 32'hABCD1234);

        // ---- summary ----
        if (errors == 0) begin
            $display("tb_reg_file: ALL TESTS PASSED");
            $finish;
        end else begin
            $display("tb_reg_file: %0d TEST(S) FAILED", errors);
            $fatal(1);
        end
    end

endmodule
