# Makefile for the RV32I single-cycle processor
# Each target compiles the relevant RTL + testbench with Icarus Verilog,
# runs the simulation, and prints PASS / FAIL.

IV  = iverilog
VVP = vvp
RTL = rtl
TB  = tb

.PHONY: all clean fetch control_unit reg_file imm_gen alu top top2

all: fetch control_unit reg_file imm_gen

# ---------- Member 1: fetch stage ----------
fetch:
	$(IV) -o $(TB)/tb_fetch.vvp \
	    $(RTL)/pc.v $(RTL)/adder.v $(RTL)/instr_mem.v $(TB)/tb_fetch.v
	cd $(TB) && $(VVP) tb_fetch.vvp

# ---------- Member 2: register file ----------
reg_file:
	$(IV) -o $(TB)/tb_reg_file.vvp \
	    $(RTL)/reg_file.v $(TB)/tb_reg_file.v
	cd $(TB) && $(VVP) tb_reg_file.vvp

# ---------- Member 2: immediate generator ----------
imm_gen:
	$(IV) -o $(TB)/tb_imm_gen.vvp \
	    $(RTL)/imm_gen.v $(TB)/tb_imm_gen.v
	cd $(TB) && $(VVP) tb_imm_gen.vvp

# ---------- Member 4: control unit ----------
control_unit:
	$(IV) -o $(TB)/tb_control_unit.vvp \
	    $(RTL)/control_unit.v $(RTL)/mux2.v $(TB)/tb_control_unit.v
	cd $(TB) && $(VVP) tb_control_unit.vvp

# ---------- Member 3: ALU (placeholder, files not yet added) ----------
# alu:
#	$(IV) -o $(TB)/tb_alu.vvp \
#	    $(RTL)/alu.v $(RTL)/alu_control.v $(TB)/tb_alu.v
#	cd $(TB) && $(VVP) tb_alu.vvp

# ---------- Member 5: full processor (placeholder) ----------
# top:
#	$(IV) -o $(TB)/tb_rv32i_top.vvp \
#	    $(RTL)/pc.v $(RTL)/adder.v $(RTL)/instr_mem.v $(RTL)/reg_file.v \
#	    $(RTL)/imm_gen.v $(RTL)/alu.v $(RTL)/alu_control.v \
#	    $(RTL)/control_unit.v $(RTL)/mux2.v $(RTL)/data_mem.v \
#	    $(RTL)/rv32i_top.v $(TB)/tb_rv32i_top.v
#	cd $(TB) && $(VVP) tb_rv32i_top.vvp

clean:
	rm -f $(TB)/*.vvp $(TB)/*.vcd
