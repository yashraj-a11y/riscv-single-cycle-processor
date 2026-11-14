// tb_data_mem.v - testbench for the data memory
// Checks: write then read back, different words don't disturb each other,
// nothing is written when mem_write = 0, and the read is combinational.
`timescale 1ns/1ps

module tb_data_mem;

    reg         clk = 0;
    reg         mem_write;
    reg  [31:0] addr, write_data;
    wire [31:0] read_data;

    integer errors = 0;

    data_mem dut (
        .clk(clk), .mem_write(mem_write),
        .addr(addr), .write_data(write_data), .read_data(read_data)
    );

    always #5 clk = ~clk;

    task write_word;
        input [31:0] a;
        input [31:0] d;
        begin
            addr = a; write_data = d; mem_write = 1;
            @(posedge clk); #1;
            mem_write = 0;
        end
    endtask

    task check_word;
        input [31:0] a;
        input [31:0] exp;
        begin
            addr = a; #1;
            if (read_data !== exp) begin
                $display("FAIL: mem[%0d] = %h expected %h", a, read_data, exp);
                errors = errors + 1;
            end else
                $display("ok  : mem[%0d] = %h", a, read_data);
        end
    endtask

    initial begin
        $dumpfile("tb_data_mem.vcd");
        $dumpvars(0, tb_data_mem);

        mem_write = 0; addr = 0; write_data = 0;

        // memory starts cleared
        check_word(32'd0, 32'h00000000);

        // write three words at byte addresses 0, 4, 8
        write_word(32'd0, 32'h11111111);
        write_word(32'd4, 32'h22222222);
        write_word(32'd8, 32'hCAFEBABE);
        check_word(32'd0, 32'h11111111);
        check_word(32'd4, 32'h22222222);
        check_word(32'd8, 32'hCAFEBABE);

        // overwrite one word, neighbours stay the same
        write_word(32'd4, 32'h33333333);
        check_word(32'd0, 32'h11111111);
        check_word(32'd4, 32'h33333333);
        check_word(32'd8, 32'hCAFEBABE);

        // mem_write = 0: data on the bus must not be stored
        addr = 32'd8; write_data = 32'hFFFFFFFF; mem_write = 0;
        @(posedge clk); #1;
        check_word(32'd8, 32'hCAFEBABE);

        // last word in the memory
        write_word(32'd252, 32'h0000FFFF);
        check_word(32'd252, 32'h0000FFFF);

        if (errors == 0) $display("tb_data_mem: ALL TESTS PASSED");
        else             $display("tb_data_mem: %0d TEST(S) FAILED", errors);
        $finish;
    end

endmodule
