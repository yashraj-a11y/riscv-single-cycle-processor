`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// fpga_top.v - board wrapper for running the processor on an FPGA
// The processor executes one instruction per clock, far too fast to watch, so
// this wrapper divides the board clock down and shows the program counter on
// eight LEDs. LED value = PC / 4 = index of the instruction being executed.
//
// With DIV_BITS = 24 and a 50 MHz board clock the processor steps about three
// times a second. Reset is synchronous, so hold the reset button for at least
// one slow clock period.
//
// This wrapper is not tied to a particular board: connect clk, reset and
// led[7:0] to pins in the constraint file of the board being used.
// -----------------------------------------------------------------------------
module fpga_top #(
    parameter DIV_BITS = 24,
    parameter MEM_FILE = "programs/prog2_loop.hex"
)(
    input  wire       clk,      // board oscillator
    input  wire       reset,    // push button, active high
    output wire [7:0] led
);

    // free-running counter; its top bit is the slow processor clock
    reg [DIV_BITS-1:0] div = {DIV_BITS{1'b0}};

    always @(posedge clk)
        div <= div + 1'b1;

    wire slow_clk = div[DIV_BITS-1];

    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] alu_result;
    wire [31:0] write_data;

    rv32i_top #(.MEM_FILE(MEM_FILE)) u_cpu (
        .clk            (slow_clk),
        .reset          (reset),
        .dbg_pc         (pc),
        .dbg_instr      (instr),
        .dbg_alu_result (alu_result),
        .dbg_write_data (write_data)
    );

    assign led = pc[9:2];

endmodule
