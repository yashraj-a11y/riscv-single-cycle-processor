`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// rv32i_top.v - Single-Cycle RV32I Processor (top level)
// Wires all the modules together. Every instruction is fetched, decoded,
// executed and written back within one clock cycle.
//
// Supported instructions: ADD SUB AND OR XOR ADDI LW SW BEQ BNE
//
// The debug outputs are only there so the testbench and waveform viewer can
// see what the processor is doing; they are not needed for it to work.
// -----------------------------------------------------------------------------
module rv32i_top #(
    parameter MEM_FILE = "programs/prog1_arith.hex"
)(
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] dbg_pc,
    output wire [31:0] dbg_instr,
    output wire [31:0] dbg_alu_result,
    output wire [31:0] dbg_write_data
);

    // ---------------- wires ----------------
    wire [31:0] pc_cur, pc_next, pc_plus4, pc_target;
    wire [31:0] instr;
    wire [31:0] imm;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_b, alu_result;
    wire [31:0] mem_read_data;
    wire [31:0] wb_data;
    wire        zero;

    // control signals
    wire        reg_write, alu_src, mem_write, mem_to_reg, branch;
    wire [1:0]  alu_op;
    wire [2:0]  alu_ctrl;
    wire        pc_src;

    // instruction fields
    wire [6:0]  opcode = instr[6:0];
    wire [4:0]  rd     = instr[11:7];
    wire [2:0]  funct3 = instr[14:12];
    wire [4:0]  rs1    = instr[19:15];
    wire [4:0]  rs2    = instr[24:20];

    // ---------------- FETCH ----------------
    pc u_pc (
        .clk     (clk),
        .reset   (reset),
        .pc_next (pc_next),
        .pc      (pc_cur)
    );

    instr_mem #(.MEM_FILE(MEM_FILE)) u_instr_mem (
        .addr  (pc_cur),
        .instr (instr)
    );

    adder u_pc_plus4 (
        .a (pc_cur),
        .b (32'd4),
        .y (pc_plus4)
    );

    // ---------------- DECODE ----------------
    control_unit u_control (
        .opcode     (opcode),
        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .branch     (branch),
        .alu_op     (alu_op)
    );

    reg_file u_reg_file (
        .clk (clk),
        .we  (reg_write),
        .rs1 (rs1),
        .rs2 (rs2),
        .rd  (rd),
        .wd  (wb_data),
        .rd1 (rs1_data),
        .rd2 (rs2_data)
    );

    imm_gen u_imm_gen (
        .instr (instr),
        .imm   (imm)
    );

    // ---------------- EXECUTE ----------------
    alu_control u_alu_control (
        .alu_op   (alu_op),
        .funct3   (funct3),
        .funct7_5 (instr[30]),
        .op_5     (opcode[5]),
        .alu_ctrl (alu_ctrl)
    );

    mux2 u_alu_src_mux (
        .d0  (rs2_data),
        .d1  (imm),
        .sel (alu_src),
        .y   (alu_b)
    );

    alu u_alu (
        .a        (rs1_data),
        .b        (alu_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (zero)
    );

    adder u_branch_adder (
        .a (pc_cur),
        .b (imm),
        .y (pc_target)
    );

    // Branch decision. The ALU subtracts rs1 - rs2, so zero = 1 means equal.
    // funct3[0] is 0 for BEQ and 1 for BNE, so XOR-ing it with zero gives
    // "take the branch" for both instructions.
    assign pc_src = branch & (zero ^ funct3[0]);

    mux2 u_pc_mux (
        .d0  (pc_plus4),
        .d1  (pc_target),
        .sel (pc_src),
        .y   (pc_next)
    );

    // ---------------- MEMORY ----------------
    data_mem u_data_mem (
        .clk        (clk),
        .mem_write  (mem_write),
        .addr       (alu_result),
        .write_data (rs2_data),
        .read_data  (mem_read_data)
    );

    // ---------------- WRITE-BACK ----------------
    mux2 u_wb_mux (
        .d0  (alu_result),
        .d1  (mem_read_data),
        .sel (mem_to_reg),
        .y   (wb_data)
    );

    // ---------------- debug ----------------
    assign dbg_pc         = pc_cur;
    assign dbg_instr      = instr;
    assign dbg_alu_result = alu_result;
    assign dbg_write_data = wb_data;

endmodule
