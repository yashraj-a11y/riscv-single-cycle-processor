`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// reg_file.v - 32 x 32-bit Register File
// Two combinational read ports (rs1, rs2) and one synchronous write port (rd).
// Register x0 is hardwired to zero as required by the RISC-V specification:
// reads always return 0 and writes are silently ignored.
// -----------------------------------------------------------------------------
module reg_file (
    input  wire        clk,
    input  wire        we,         // write enable (active high)
    input  wire [4:0]  rs1,        // read address 1  (source register 1)
    input  wire [4:0]  rs2,        // read address 2  (source register 2)
    input  wire [4:0]  rd,         // write address    (destination register)
    input  wire [31:0] wd,         // write data
    output wire [31:0] rd1,        // read data 1
    output wire [31:0] rd2         // read data 2
);

    reg [31:0] regs [0:31];
    integer i;

    // --- initialise all registers to zero (simulation only) ---
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    // --- synchronous write on rising clock edge ---
    always @(posedge clk) begin
        if (we && rd != 5'b0)       // never write to x0
            regs[rd] <= wd;
    end

    // --- combinational reads (x0 forced to 0) ---
    assign rd1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign rd2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

endmodule
