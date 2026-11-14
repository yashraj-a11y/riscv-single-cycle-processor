# Team plan: who owns what

Five roughly equal slices. Each person owns some RTL, the testbench for it, a part of the report and about a minute of the video. Everyone should be able to explain their own modules in the Phase II interview, so read your files line by line before you commit them.

| | Rishi Raj: Fetch | Yash Yadav: Decode data | Aditya Samadhiya: Execute | Kaustubh Mishra: Control | Yash Raj: Memory + integration |
|---|---|---|---|---|---|
| RTL | `pc.v`, `adder.v`, `instr_mem.v` | `reg_file.v`, `imm_gen.v` | `alu.v`, `alu_control.v` | `control_unit.v`, `mux2.v` | `data_mem.v`, `rv32i_top.v` |
| Testbench | `tb_fetch.v` | `tb_reg_file.v`, `tb_imm_gen.v` | `tb_alu.v` | `tb_control_unit.v` | `tb_data_mem.v`, `tb_rv32i_top.v` |
| Other files | `programs/*` (assembly and hand-assembled hex) | | `docs/datapath.tex` (block diagram) | | `Makefile`, `README.md`, `.gitignore` |
| Report | Abstract, Introduction | Literature Review, References | Instruction subset, Datapath | Control, truth table | Verification and status, Phase II plan |
| Video | Intro + fetch | Register file + immediates | ALU | Control signals | Full run + wrap-up |

## Committing (this affects Phase II marks)

Phase II looks at version history and individual contributions, so each person should push their own files from their own GitHub account. Don't upload everything in one commit from one account.

A sensible order, since later pieces depend on earlier ones:

1. Member 5 creates the repo with `README.md`, `.gitignore`, `Makefile` and the empty folder layout, and adds everyone as collaborators.
2. Members 1 to 4 each push their RTL and testbench (one commit per module is fine). Run your own testbench first and check it prints `ALL TESTS PASSED`.
3. Member 1 pushes the test programs.
4. Member 5 pushes `data_mem.v`, then `rv32i_top.v` and `tb_rv32i_top.v` once the other modules are in.
5. Member 3 pushes the block diagram; everyone pushes their section of the report source; Member 5 adds the built PDF and the video link.

Use clear commit messages, for example `Add ALU with zero flag` or `Add register file testbench`.

## Things to fill in before submitting

- Names and roll numbers in `docs/report_phase1.tex` (author block and contributions table), then rebuild the PDF: `pdflatex report_phase1.tex` twice, inside `docs/`. Overleaf also works: upload `report_phase1.tex` and `datapath.pdf`.
- Names in `README.md`.
- Video link in `README.md`.
- One or two GTKWave screenshots for the video (and optionally the report).
