# Phase II: who owns what

Phase II is graded on the final report, the repository history and an interview. Each person pushes their own files from their own account, in several commits over a few days, and should be able to explain every line of them.

| Member | Files to push | Report sections | Be ready to explain |
|---|---|---|---|
| Rishi Raj | `programs/prog3_corner.s` and `.hex`, `programs/prog4_branch.s` and `.hex`, `rtl/instr_mem.v` | Abstract, Introduction, test program results | How a branch is hand-assembled; why 0x80000000 is built with a loop; why the ROM came out empty in synthesis and how `ifndef SYNTHESIS` fixes it |
| Yash Yadav | `tb/tb_imm_gen.v`, `docs/waves/gtkwaverc`, `docs/waves/capture.tcl`, `docs/waves/*.png` | Literature Review, waveform evidence | Where the immediate bits sit for I, S and B types; why the branch offset range is -4096 to +4094; what each signal in the waveform shows |
| Aditya Samadhiya | `tb/tb_alu.v`, `synth/synth_ecp5.ys`, `synth/rom_random.hex`, `synth/reports/resources_total.txt`, `synth/reports/resources_per_module.txt`, `docs/synthesis_report.md` | Datapath, synthesis and resource usage | Signed overflow and wraparound; why the ROM is filled with random words for synthesis; why the register file is the biggest block |
| Kaustubh Ranjan Mishra | `synth/reports/nextpnr_ecp5.log`, `docs/timing_report.md` | Control, timing and performance | What a critical path is; the stages of the branch path; why the branch beats the load here; why single-cycle wastes time on simple instructions |
| Yash Raj | `tb/tb_rv32i_top.v`, `fpga/fpga_top.v`, `tb/tb_fpga_top.v`, `Makefile`, `.gitignore`, `README.md`, `docs/report_final.tex`, `docs/report_final.pdf`, `docs/team_plan_phase2.md` | Verification, limitations, Conclusion | How the testbench detects halt and counts cycles; what the board wrapper does; what was and was not tested |

## Push order

Some files depend on others, so push in this order:

1. **Rishi:** the `instr_mem.v` fix and the two new programs. Synthesis and the new top-level tests both need these.
2. **Yash Raj:** `tb_rv32i_top.v`, the FPGA wrapper and its testbench, the `Makefile` and `.gitignore`. After this `make` runs all eleven targets.
3. **Aditya:** ALU tests, then the synthesis script, random ROM file and resource reports.
4. **Kaustubh:** the place and route log and the timing report. Needs Aditya's synthesis files in place.
5. **Yash Yadav:** immediate tests and the waveform files. Independent of the others, can go at any time.
6. **Yash Raj:** `README.md`, then the final report last, after everyone has read their own sections.

Run `make` before every push and check that every testbench prints `ALL TESTS PASSED`.

## Before submitting

- Yash Yadav and Yash Raj have the same roll number (2401010514) in the report and README. One of them is a typo; fix it in `docs/report_final.tex` and `README.md`, then rebuild the PDF.
- Everyone reads the whole final report once. The interview can ask about any part of the project, not only your own.
- If the instructor has a board, `fpga/fpga_top.v` needs only a constraint file for that board. If you do run it, add a photo or short clip and update the "FPGA deployment" paragraph in the report, which currently says the design was not run on hardware.
