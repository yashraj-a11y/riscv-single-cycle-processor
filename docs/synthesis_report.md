# Synthesis and resource report

Tools: Yosys 0.33 for synthesis, nextpnr-ecp5 0.6 for place and route.
Target: Lattice ECP5 LFE5U-25F, CABGA381 package, speed grade 6.
Reproduce with `make synth` and `make pnr` from the repository root. The raw tool output is in `synth/reports/`.

## How the design was synthesized

The top module is `rv32i_top`, unchanged from simulation. Two things are specific to synthesis.

**Random ROM contents.** The instruction memory is a ROM, so its contents are constants. A real program leaves many instruction bits the same in every word (for example, it may never write to most registers), and the tool then deletes the logic that those bits drive. The resource numbers would describe one program, not the processor. For synthesis the ROM is filled with 64 random words (`synth/rom_random.hex`), which keeps every part of the design.

**Hierarchy kept.** The script runs `synth_ecp5 -noflatten` first so that resources can be reported per module, then flattens the design for place and route.

## Totals after place and route

| Resource | Used | Available | Share |
|---|---|---|---|
| LUT4 total | 1772 | 24288 | 7% |
| of which logic | 1260 | | |
| of which carry chains | 128 | | |
| of which distributed RAM (read + write ports) | 384 | | |
| Flip-flops | 32 | 24288 | under 1% |
| Block RAM | 0 | 56 | 0% |
| I/O pins | 130 | 197 | 65% |

The I/O count is high only because the four 32-bit debug buses are brought out to pins. On a board they would go to a few LEDs.

Only 32 flip-flops are used, all for the PC. The register file (32 x 32 bits) and the data memory (64 x 32 bits) are mapped to distributed RAM, which stores bits inside look-up tables. Block RAM cannot be used because both memories are read combinationally, and block RAM on this device has a registered read.

## Logic by module

| Module | Logic LUT4 | Other cells |
|---|---|---|
| `reg_file` | 517 | 32 distributed RAM cells |
| `alu` | 283 | 32 carry cells |
| `data_mem` | 132 | 32 distributed RAM cells |
| `instr_mem` | 128 | |
| `mux2` (three instances) | 96 | |
| `control_unit` | 52 | |
| `imm_gen` | 40 | |
| `alu_control` | 11 | |
| `adder` (two instances) | 0 | 32 carry cells |
| `pc` | 0 | 32 flip-flops |
| top-level glue | 1 | |
| **Total** | **1260** | |

## Observations

**The register file is the largest block (41% of the logic), and the cost is in reading, not storing.** Each of the 64 read output bits picks between the two 16-word halves of the memory and is forced to zero when the address is `x0`. That is a function of seven inputs. The default mapper builds each seven-input function from eight LUT4s and a tree of multiplexers, so the read logic alone is about 512 LUT4s.

**The mapper matters as much as the RTL.** Re-running synthesis with `synth_ecp5 -abc9` brought the logic down from 1260 to 877 LUT4s with a similar clock frequency. The numbers in this report use the default flow.

**The ALU is second.** It holds a 32-bit add/subtract on a carry chain, three bitwise operations, a five-way result multiplexer per bit, and a 32-input zero detector.

**The control logic is tiny.** The main decoder and the ALU decoder together use 63 LUT4s, about 5% of the logic. In a single-cycle processor almost all the hardware is datapath.

## A fault found by synthesis

In the first synthesis run `instr_mem` came out with zero cells. The RTL cleared the memory in a `for` loop and then called `$readmemh`:

```verilog
initial begin
    for (i = 0; i < DEPTH; i = i + 1)
        mem[i] = 32'b0;
    $readmemh(MEM_FILE, mem);
end
```

A simulator runs these two steps in order, so the program overwrites the zeros. Yosys applied the clearing loop after the file load and produced a ROM of all zeros. Every testbench passed, but on hardware the processor would have executed nothing.

The fix was to compile the clearing loop only in simulation, using the `SYNTHESIS` macro that synthesis tools define:

```verilog
initial begin
`ifndef SYNTHESIS
    for (i = 0; i < DEPTH; i = i + 1)
        mem[i] = 32'b0;
`endif
    $readmemh(MEM_FILE, mem);
end
```

After the fix the ROM synthesizes to 128 LUT4s. The lesson: a design that passes simulation is not yet a design that works after synthesis.
