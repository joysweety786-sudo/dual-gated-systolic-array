SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/phase2_rtl/sky130_icg.v
VERILOG_SOURCES += $(PWD)/phase2_rtl/operand_analyzer.v
VERILOG_SOURCES += $(PWD)/phase2_rtl/pe.v

TOPLEVEL = pe
MODULE = test_pe

include $(shell cocotb-config --makefiles)/Makefile.sim