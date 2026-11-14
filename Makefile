# Run from the repository root.  Needs Icarus Verilog (iverilog + vvp).
#
#   make            run every testbench
#   make top        run the full processor on program 1
#   make top2       run the full processor on program 2
#   make alu        run a single unit testbench (same for the others)
#   make clean      delete build output and waveforms

RTL := $(wildcard rtl/*.v)
IV  := iverilog -g2005 -Wall

.PHONY: all fetch reg_file imm_gen alu control_unit data_mem top top2 clean

all: fetch reg_file imm_gen alu control_unit data_mem top top2

fetch:
	$(IV) -o build_fetch.out rtl/pc.v rtl/adder.v rtl/instr_mem.v tb/tb_fetch.v
	vvp build_fetch.out

reg_file:
	$(IV) -o build_reg_file.out rtl/reg_file.v tb/tb_reg_file.v
	vvp build_reg_file.out

imm_gen:
	$(IV) -o build_imm_gen.out rtl/imm_gen.v tb/tb_imm_gen.v
	vvp build_imm_gen.out

alu:
	$(IV) -o build_alu.out rtl/alu.v rtl/alu_control.v tb/tb_alu.v
	vvp build_alu.out

control_unit:
	$(IV) -o build_control_unit.out rtl/control_unit.v rtl/mux2.v tb/tb_control_unit.v
	vvp build_control_unit.out

data_mem:
	$(IV) -o build_data_mem.out rtl/data_mem.v tb/tb_data_mem.v
	vvp build_data_mem.out

top:
	$(IV) -o build_top.out $(RTL) tb/tb_rv32i_top.v
	vvp build_top.out

top2:
	$(IV) -DPROG2 -o build_top2.out $(RTL) tb/tb_rv32i_top.v
	vvp build_top2.out

clean:
	rm -f *.out *.vcd
