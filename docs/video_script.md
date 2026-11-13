# Demo video script (target 4:30, hard limit 5:00)

Record the screen with voice-over. Each person speaks over their own part. Put all five names on the title slide and have each person say their name when they start, so the "introduce all 5 members" requirement is clearly met.

Before recording, have these open: the block diagram (`docs/datapath.png`), an editor with the `rtl/` folder, a terminal in the repo root, and GTKWave with `tb_rv32i_top.vcd` loaded and these signals added: `clk`, `dbg_pc`, `dbg_instr`, `dbg_alu_result`, `reg_write`, `mem_write`, `branch`, `pc_src`.

---

## 0:00 to 0:50, Member 1: idea, team, fetch

**Show:** title slide with project name and five names, then the block diagram.

> "This is Project 1, a single-cycle RV32I processor in Verilog. We are [five names]. I'm [name]. Our processor runs ten RISC-V instructions: ADD, SUB, AND, OR, XOR, ADDI, load word, store word, BEQ and BNE. Single-cycle means each instruction is fetched, decoded and executed in one clock cycle."

**Show:** left side of the diagram, then `pc.v` and `instr_mem.v`.

> "I built the fetch stage. The program counter holds the address of the current instruction. Instruction memory is a ROM loaded from a hex file, and an adder computes PC plus 4. I also wrote the two test programs and assembled them into hex by hand."

## 0:50 to 1:40, Member 2: register file and immediate generator

**Show:** `reg_file.v`, then `imm_gen.v`, then run `make reg_file` and `make imm_gen`.

> "I'm [name]. The register file has 32 registers of 32 bits, two read ports and one write port. Register x0 always reads zero, as RISC-V requires. The immediate generator pulls the constant out of the instruction and sign-extends it. The bits sit in different places for I, S and B type instructions, so it switches on the opcode. Both testbenches pass, including negative immediates."

## 1:40 to 2:30, Member 3: ALU

**Show:** ALU on the diagram, `alu.v`, `alu_control.v`, then `make alu`.

> "I'm [name]. The ALU does add, subtract, AND, OR and XOR, and gives a zero flag that the branches use. A small ALU control block picks the operation from funct3 and one bit of funct7. ADD and SUB differ only in that bit. For ADDI that bit is part of the immediate, so we only subtract when the instruction is R-type. The testbench checks every operation and every instruction's decode."

## 2:30 to 3:20, Member 4: control unit

**Show:** control truth table from the report, `control_unit.v`, then `make control_unit`.

> "I'm [name]. The control unit reads the 7-bit opcode and sets six signals: whether to write a register, whether the ALU takes an immediate, whether to write memory, what to write back, whether this is a branch, and the ALU operation class. For a branch, the ALU subtracts the two registers; BEQ jumps if zero is 1 and BNE if zero is 0. Unknown opcodes turn all write enables off, so they can't change any state."

## 3:20 to 4:30, Member 5: integration, full run, wrap-up

**Show:** `rv32i_top.v` briefly, then run `make top` and `make top2` in the terminal.

> "I'm [name]. I built the data memory and connected all modules in the top level. Here is program 1 running. Each line is one clock cycle: the PC, the instruction, and the ALU result. At the end the testbench compares registers and memory with the values we worked out by hand, and everything passes. Program 2 sums 5 down to 1 with a loop. You can see the PC jump back to address 8 five times, and the final sum 15 is stored to memory and read back."

**Show:** GTKWave. Point at `dbg_pc` going 08, 0c, 10, 08 in program 2 and `pc_src` going high on the taken branch.

> "In the waveform, pc_src goes high when the branch is taken and the PC jumps back. So far all modules are written, all seven testbenches pass, and both programs run correctly. In Phase II we will add more test programs, synthesize the design, and report resource usage and timing. Thank you."
