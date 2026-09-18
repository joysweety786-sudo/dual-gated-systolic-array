# Simulator and language setup
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Direct relative paths to synthesizable RTL sources
VERILOG_SOURCES += $(PWD)/../phase2_rtl/sky130_icg.v
VERILOG_SOURCES += $(PWD)/../phase2_rtl/operand_analyzer.v
VERILOG_SOURCES += $(PWD)/../phase2_rtl/pe.v

# Top-level DUT module name and cocotb test Python file
TOPLEVEL = pe
MODULE = test_pe

# Cocotb simulation makefile inclusion
include $(shell cocotb-config --makefiles)/Makefile.sim