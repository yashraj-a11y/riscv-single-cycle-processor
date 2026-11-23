# Run from the repository root.
#
# Simulation (needs Icarus Verilog: iverilog + vvp)
#   make            run every testbench
#   make top        full processor, program 1 (arithmetic, load, store)
#   make top2       full processor, program 2 (loop with branches)
#   make top3       full processor, program 3 (datapath corner cases)
#   make top4       full processor, program 4 (branch corner cases)
#   make alu        one unit testbench (same for the others)
#   make fpga       FPGA board wrapper testbench
#
# Synthesis and timing (needs Yosys and nextpnr-ecp5)
#   make synth      synthesize for a Lattice ECP5, write resource reports
#   make pnr        place and route, write the timing report
#
#   make clean      delete build output and waveforms

RTL := $(wildcard rtl/*.v)
IV  := iverilog -g2005 -Wall

.PHONY: all fetch reg_file imm_gen alu control_unit data_mem top top2 top3 top4 fpga synth pnr clean

all: fetch reg_file imm_gen alu control_unit data_mem top top2 top3 top4 fpga

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

top3:
	$(IV) -DPROG3 -DQUIET -o build_top3.out $(RTL) tb/tb_rv32i_top.v
	vvp build_top3.out

top4:
	$(IV) -DPROG4 -DQUIET -o build_top4.out $(RTL) tb/tb_rv32i_top.v
	vvp build_top4.out

fpga:
	$(IV) -o build_fpga.out $(RTL) fpga/fpga_top.v tb/tb_fpga_top.v
	vvp build_fpga.out

synth:
	yosys -q -l synth/reports/yosys_ecp5.log synth/synth_ecp5.ys

pnr: synth
	nextpnr-ecp5 --25k --package CABGA381 --speed 6 \
	    --json synth/reports/rv32i_top_ecp5.json \
	    --freq 25 --seed 1 --lpf-allow-unconstrained \
	    -q -l synth/reports/nextpnr_ecp5.log

clean:
	rm -f *.out *.vcd
