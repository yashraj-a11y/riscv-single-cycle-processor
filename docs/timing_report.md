# Timing report: critical path and clock frequency

Tool: nextpnr-ecp5 0.6, static timing analysis after place and route.
Target: Lattice ECP5 LFE5U-25F, speed grade 6.
Reproduce with `make pnr`. The full tool output is `synth/reports/nextpnr_ecp5.log`; the critical path is listed near the end.

These are results of static analysis, not measurements. The design has not been run on a board.

## Maximum clock frequency

| | |
|---|---|
| Maximum frequency (seed 1) | 52.8 MHz |
| Minimum clock period | 18.9 ns |
| Logic delay on the critical path | 7.0 ns (37%) |
| Routing delay on the critical path | 11.9 ns (63%) |
| Range over five placement seeds | 51.5 to 52.8 MHz |

Nearly two thirds of the clock period is spent in wires, not in gates. Placement changes the result by a few percent from run to run, which is why a range is given.

## The critical path is a conditional branch

The path starts at the PC register, goes once through the whole datapath, and ends back at the PC register.

| Stage | Delay (ns) | Arrival (ns) |
|---|---|---|
| PC register, clock to output | 0.5 | 0.5 |
| Instruction memory | 2.0 | 2.5 |
| Register file read | 3.2 | 5.7 |
| ALU source multiplexer | 1.7 | 7.4 |
| ALU subtract | 5.0 | 12.4 |
| Zero detection | 3.5 | 15.9 |
| Branch decision (`pc_src`) | 1.4 | 17.3 |
| PC multiplexer | 1.5 | 18.8 |
| PC register setup | 0.1 | 18.9 |

The two biggest contributions are the 32-bit subtraction, where the carry has to travel through all 32 bits, and the zero detection, which combines all 32 result bits into one.

## The load path

Textbooks give the load (`LW`) as the slowest instruction in a single-cycle processor, because it is the only one that uses the instruction memory, register file, ALU, data memory and register file write all in one cycle. The timing tool only reports the single longest path, so to measure the load path we made a scratch copy of the top level with the branch select tied to zero (`assign pc_src = 1'b0;`) and ran the same flow. That copy is not part of the repository.

| Stage | Delay (ns) | Arrival (ns) |
|---|---|---|
| PC register, clock to output | 0.5 | 0.5 |
| Instruction memory | 1.9 | 2.4 |
| Register file read | 4.0 | 6.4 |
| ALU source multiplexer | 1.3 | 7.7 |
| ALU add | 3.9 | 11.6 |
| Data memory read | 3.6 | 15.2 |
| Write-back multiplexer | 1.5 | 16.7 |
| Register file write port, including setup | 1.2 | 17.9 |

The load path is 17.9 ns (55.5 to 57.1 MHz over three seeds). The stage delays differ slightly from the first table because the placement is different.

## Why the branch is slower than the load here

Both paths are the same up to the ALU. After the ALU:

- the branch needs zero detection, the branch decision and the PC multiplexer: about 6.5 ns
- the load needs the data memory read, the write-back multiplexer and the register write: about 6.3 ns

They are almost equal, and the branch comes out about 1 ns longer. The reason is that our data memory is very small. Sixty-four words built from look-up tables are read in 3.6 ns. A realistic data memory of many kilobytes would take much longer to read, and then the load would be the critical path as the textbooks say. Which instruction is slowest depends on the implementation, not only on the architecture.

## What this means for performance

Every instruction takes one clock cycle, so CPI = 1 and

    execution time = instructions executed x clock period

| Program | Instructions executed | Time at 18.9 ns |
|---|---|---|
| `prog1_arith` | 14 | 0.26 us |
| `prog2_loop` | 24 | 0.45 us |
| `prog3_corner` | 119 | 2.25 us |
| `prog4_branch` | 169 | 3.19 us |

The clock period is set by the slowest path, and every instruction pays for it. An `ADD` does not use the data memory or the branch logic. As a rough estimate, taking the load path without the 3.6 ns data memory read, an `ADD` is finished after about 14 ns and then waits for the rest of the cycle. That estimate is not a separate measurement.

This is the main weakness of a single-cycle design: there is one clock, so there is no way to give simple instructions less time. A pipelined design puts registers between the stages, and the clock period is then set by the slowest stage instead of the whole path. From the tables above the slowest stage would be execute, at roughly 7 to 9 ns, which suggests about twice the clock frequency before the cost of hazards. We did not build a pipeline; this is an estimate from the stage delays.
