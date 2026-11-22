# capture.tcl - adds the signals used in the report and saves a screenshot.
# Run from the repository root after a simulation has written tb_rv32i_top.vcd:
#
#   gtkwave -r docs/waves/gtkwaverc -S docs/waves/capture.tcl tb_rv32i_top.vcd
#
# The picture is written to wave.png in the current folder. Set the
# environment variables WAVE_END (in ps) and WAVE_OUT to change the time range
# and the file name.

set sigs [list \
    tb_rv32i_top.clk \
    tb_rv32i_top.reset \
    tb_rv32i_top.pc \
    tb_rv32i_top.instr \
    tb_rv32i_top.alu_result \
    tb_rv32i_top.write_data \
    tb_rv32i_top.dut.reg_write \
    tb_rv32i_top.dut.mem_write \
    tb_rv32i_top.dut.mem_to_reg \
    tb_rv32i_top.dut.branch \
    tb_rv32i_top.dut.zero \
    tb_rv32i_top.dut.pc_src ]
gtkwave::addSignalsFromList $sigs
gtkwave::/Edit/Highlight_All
gtkwave::/Edit/Data_Format/Hex
gtkwave::/Edit/UnHighlight_All

set t_end 170000
if {[info exists ::env(WAVE_END)]} { set t_end $::env(WAVE_END) }
set out wave.png
if {[info exists ::env(WAVE_OUT)]} { set out $::env(WAVE_OUT) }

gtkwave::setZoomRangeTimes 0 $t_end
gtkwave::/File/Grab_To_File $out
gtkwave::/File/Quit
