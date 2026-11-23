// tb_fpga_top.v - testbench for the FPGA board wrapper
// Uses a tiny clock divider so the simulation is short, runs program 2 and
// checks that the LEDs follow the program counter: straight through the first
// instructions, back to the loop start on each taken branch, and finally
// parked on the halt instruction.
`timescale 1ns/1ps

module tb_fpga_top;

    reg        clk = 0;
    reg        reset;
    wire [7:0] led;

    integer errors = 0;
    integer i;

    // DIV_BITS = 2: the processor clock is the board clock divided by 4
    fpga_top #(.DIV_BITS(2), .MEM_FILE("programs/prog2_loop.hex")) dut (
        .clk(clk), .reset(reset), .led(led)
    );

    always #5 clk = ~clk;

    task step_and_check;
        input [7:0] exp;
        begin
            @(posedge dut.slow_clk); #1;
            if (led !== exp) begin
                $display("FAIL: led = %0d expected %0d", led, exp);
                errors = errors + 1;
            end else
                $display("ok  : led = %0d", led);
        end
    endtask

    initial begin
        $dumpfile("tb_fpga_top.vcd");
        $dumpvars(0, tb_fpga_top);

        reset = 1;
        @(posedge dut.slow_clk); #1;
        if (led !== 8'd0) begin
            $display("FAIL: led = %0d after reset, expected 0", led);
            errors = errors + 1;
        end else
            $display("ok  : led = 0 after reset");
        reset = 0;

        // instructions 0 and 1 run once, then the loop body 2, 3, 4
        step_and_check(8'd1);
        step_and_check(8'd2);
        step_and_check(8'd3);
        step_and_check(8'd4);
        // taken BNE: back to instruction 2, four more times
        for (i = 0; i < 4; i = i + 1) begin
            step_and_check(8'd2);
            step_and_check(8'd3);
            step_and_check(8'd4);
        end
        // loop finished: falls through to instruction 5 and onwards
        step_and_check(8'd5);
        step_and_check(8'd6);

        // run to the end: the halt instruction is number 13
        repeat (12) @(posedge dut.slow_clk);
        #1;
        if (led !== 8'd13) begin
            $display("FAIL: led = %0d at the end, expected 13 (halt)", led);
            errors = errors + 1;
        end else
            $display("ok  : led = 13, parked on halt");

        if (errors == 0) begin
            $display("tb_fpga_top: ALL TESTS PASSED");
            $finish;
        end else begin
            $display("tb_fpga_top: %0d TEST(S) FAILED", errors);
            $fatal(1);
        end
    end

endmodule
