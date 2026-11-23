// tb_rv32i_top.v - testbench for the complete processor
// Loads a program into instruction memory, runs it until it reaches its halt
// instruction (beq x0, x0, 0), prints one trace line per clock cycle, then
// compares the final register and memory contents against the values worked
// out by hand in the .s file. It also reports how many clock cycles the
// program took, which is the number of instructions executed (CPI = 1).
//
// Program 1 (default)        : programs/prog1_arith.hex
// Program 2 (define PROG2)   : programs/prog2_loop.hex
// Program 3 (define PROG3)   : programs/prog3_corner.hex
// Program 4 (define PROG4)   : programs/prog4_branch.hex
//     iverilog -DPROG3 ...
// Add -DQUIET to switch off the per-cycle trace.
`timescale 1ns/1ps

module tb_rv32i_top;

`ifdef PROG4
    localparam MEM_FILE = "programs/prog4_branch.hex";
`elsif PROG3
    localparam MEM_FILE = "programs/prog3_corner.hex";
`elsif PROG2
    localparam MEM_FILE = "programs/prog2_loop.hex";
`else
    localparam MEM_FILE = "programs/prog1_arith.hex";
`endif

    localparam HALT       = 32'h00000063;   // beq x0, x0, 0
    localparam MAX_CYCLES = 1000;           // give up if the program never halts

    reg         clk = 0;
    reg         reset;
    wire [31:0] pc, instr, alu_result, write_data;

    integer errors = 0;
    integer cycle  = 0;

    rv32i_top #(.MEM_FILE(MEM_FILE)) dut (
        .clk(clk), .reset(reset),
        .dbg_pc(pc), .dbg_instr(instr),
        .dbg_alu_result(alu_result), .dbg_write_data(write_data)
    );

    always #5 clk = ~clk;      // 10 ns clock period

    // one trace line per executed instruction
    always @(negedge clk) begin
        if (!reset && instr !== HALT) begin
`ifndef QUIET
            $display("cycle %3d | pc=%h | instr=%h | alu=%h | wb=%h",
                     cycle, pc, instr, alu_result, write_data);
`endif
            cycle = cycle + 1;
        end
    end

    task check_reg;
        input [4:0]  r;
        input [31:0] exp;
        begin
            if (dut.u_reg_file.regs[r] !== exp) begin
                $display("FAIL: x%0d = %h expected %h", r, dut.u_reg_file.regs[r], exp);
                errors = errors + 1;
            end else
                $display("ok  : x%0d = %h (%0d)", r, exp, $signed(exp));
        end
    endtask

    task check_mem;
        input [31:0] byte_addr;
        input [31:0] exp;
        begin
            if (dut.u_data_mem.mem[byte_addr[7:2]] !== exp) begin
                $display("FAIL: mem[%0d] = %h expected %h", byte_addr,
                         dut.u_data_mem.mem[byte_addr[7:2]], exp);
                errors = errors + 1;
            end else
                $display("ok  : mem[%0d] = %h (%0d)", byte_addr, exp, $signed(exp));
        end
    endtask

    task check_pc;
        input [31:0] exp;
        begin
            if (pc !== exp) begin
                $display("FAIL: pc = %h, expected halt at %h", pc, exp);
                errors = errors + 1;
            end else
                $display("ok  : halted at pc = %h", pc);
        end
    endtask

    integer guard;

    initial begin
        $dumpfile("tb_rv32i_top.vcd");
        $dumpvars(0, tb_rv32i_top);

        $display("Running %0s", MEM_FILE);
        reset = 1;
        @(posedge clk); #1;
        reset = 0;

        // run until the halt instruction is being executed
        guard = 0;
        while (instr !== HALT && guard < MAX_CYCLES) begin
            @(posedge clk); #1;
            guard = guard + 1;
        end
        // stay on halt for two more cycles to show the PC no longer moves
        repeat (2) @(posedge clk);
        #1;

        if (instr !== HALT) begin
            $display("FAIL: program did not reach halt within %0d cycles", MAX_CYCLES);
            errors = errors + 1;
        end else
            $display("Program reached halt after %0d cycles (instructions executed)", cycle);

        $display("--- final state ---");
`ifdef PROG4
        check_reg(5'd31, 32'd8);          // all eight branch checks passed
        check_reg(5'd30, 32'd0);          // nothing that should be skipped ran
        check_reg(5'd12, 32'd42);         // 6 * 7 from the nested loop
        check_reg(5'd10, 32'd0);
        check_reg(5'd11, 32'd0);
        check_reg(5'd13, 32'd42);
        check_reg(5'd14, 32'd42);
        check_mem(32'd0, 32'd42);
        check_pc(32'h88);
`elsif PROG3
        check_reg(5'd1,  32'h000007FF);   // 2047
        check_reg(5'd2,  32'hFFFFF800);   // -2048
        check_reg(5'd3,  32'hFFFFFFFF);   // -1
        check_reg(5'd4,  32'h00000000);   // x0 survived two writes
        check_reg(5'd5,  32'h80000000);
        check_reg(5'd6,  32'h00000000);
        check_reg(5'd7,  32'h7FFFFFFF);
        check_reg(5'd8,  32'h80000000);   // overflow wraps
        check_reg(5'd9,  32'hFFFFFFFE);   // -2
        check_reg(5'd10, 32'h80000000);
        check_reg(5'd11, 32'hFFFFF001);   // -4095
        check_reg(5'd12, 32'h00000000);
        check_reg(5'd13, 32'h00000000);
        check_reg(5'd14, 32'hFFFFFFFF);
        check_reg(5'd15, 32'h80000000);
        check_reg(5'd16, 32'd16);
        check_reg(5'd17, 32'h7FFFFFFF);   // negative-offset store and load
        check_reg(5'd18, 32'h80000000);   // last word of memory
        check_reg(5'd19, 32'hFFFFFFFF);   // overwritten word
        check_reg(5'd20, 32'h00000000);   // x0 survived a load
        check_mem(32'd12,  32'h7FFFFFFF);
        check_mem(32'd252, 32'hFFFFFFFF);
        check_pc(32'h74);
`elsif PROG2
        check_reg(5'd1, 32'd0);
        check_reg(5'd2, 32'd15);
        check_reg(5'd4, 32'd15);
        check_reg(5'd5, 32'd15);
        check_reg(5'd6, 32'd1);           // self-check flag set by the program
        check_reg(5'd7, 32'd7);           // not-taken BEQ fell through
        check_mem(32'd0, 32'd15);
        check_pc(32'h34);
`else
        check_reg(5'd1,  32'd10);
        check_reg(5'd2,  32'd6);
        check_reg(5'd3,  32'd16);
        check_reg(5'd4,  32'd4);
        check_reg(5'd5,  32'd2);
        check_reg(5'd6,  32'd14);
        check_reg(5'd7,  32'd12);
        check_reg(5'd8,  32'hFFFFFFFD);   // -3
        check_reg(5'd9,  32'd16);
        check_reg(5'd10, 32'd4);
        check_reg(5'd11, 32'd20);
        check_mem(32'd0, 32'd16);
        check_mem(32'd4, 32'd4);
        check_mem(32'd8, 32'd20);
        check_pc(32'h38);
`endif

        // x0 must read as zero whatever the program did
        if (dut.u_reg_file.regs[0] !== 32'b0) begin
            $display("FAIL: x0 storage = %h, expected 0", dut.u_reg_file.regs[0]);
            errors = errors + 1;
        end

        if (errors == 0) begin
            $display("tb_rv32i_top: ALL TESTS PASSED");
            $finish;
        end else begin
            $display("tb_rv32i_top: %0d TEST(S) FAILED", errors);
            $fatal(1);
        end
    end

endmodule
