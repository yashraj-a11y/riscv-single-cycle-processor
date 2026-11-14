// tb_rv32i_top.v - testbench for the complete processor
// Loads a program into instruction memory, runs it, prints one trace line per
// clock cycle, then compares the final register and memory contents against
// the values worked out by hand in the .s file.
//
// Program 1 (default)        : programs/prog1_arith.hex
// Program 2 (define PROG2)   : programs/prog2_loop.hex
//     iverilog -DPROG2 ...
`timescale 1ns/1ps

module tb_rv32i_top;

`ifdef PROG2
    localparam MEM_FILE = "programs/prog2_loop.hex";
    localparam CYCLES   = 27;
`else
    localparam MEM_FILE = "programs/prog1_arith.hex";
    localparam CYCLES   = 17;
`endif

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
        if (!reset) begin
            $display("cycle %2d | pc=%h | instr=%h | alu=%h | wb=%h",
                     cycle, pc, instr, alu_result, write_data);
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

    initial begin
        $dumpfile("tb_rv32i_top.vcd");
        $dumpvars(0, tb_rv32i_top);

        $display("Running %0s", MEM_FILE);
        reset = 1;
        @(posedge clk); #1;
        reset = 0;

        repeat (CYCLES) @(posedge clk);
        #1;

        $display("--- final state ---");
`ifdef PROG2
        check_reg(5'd1, 32'd0);
        check_reg(5'd2, 32'd15);
        check_reg(5'd4, 32'd15);
        check_reg(5'd5, 32'd15);
        check_reg(5'd6, 32'd1);          // self-check flag set by the program
        check_reg(5'd7, 32'd7);          // not-taken BEQ fell through
        check_mem(32'd0, 32'd15);
        // program must be parked on its halt instruction
        if (pc !== 32'h34) begin
            $display("FAIL: pc = %h, expected halt at 00000034", pc);
            errors = errors + 1;
        end else
            $display("ok  : halted at pc = %h", pc);
`else
        check_reg(5'd1,  32'd10);
        check_reg(5'd2,  32'd6);
        check_reg(5'd3,  32'd16);
        check_reg(5'd4,  32'd4);
        check_reg(5'd5,  32'd2);
        check_reg(5'd6,  32'd14);
        check_reg(5'd7,  32'd12);
        check_reg(5'd8,  32'hFFFFFFFD);  // -3
        check_reg(5'd9,  32'd16);
        check_reg(5'd10, 32'd4);
        check_reg(5'd11, 32'd20);
        check_mem(32'd0, 32'd16);
        check_mem(32'd4, 32'd4);
        check_mem(32'd8, 32'd20);
        if (pc !== 32'h38) begin
            $display("FAIL: pc = %h, expected halt at 00000038", pc);
            errors = errors + 1;
        end else
            $display("ok  : halted at pc = %h", pc);
`endif

        if (errors == 0) $display("tb_rv32i_top: ALL TESTS PASSED");
        else             $display("tb_rv32i_top: %0d TEST(S) FAILED", errors);
        $finish;
    end

endmodule
