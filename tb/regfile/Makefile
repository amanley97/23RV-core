TOPLEVEL_LANG = verilog
TOPLEVEL = regfile_23rv
MODULE = 23rv_core_regfile_tb
SIM ?= icarus

RTL_DIR = $(PWD)/../../rtl
VERILOG_SOURCES = $(RTL_DIR)/23rv_core_regfile.sv

include $(shell cocotb-config --makefiles)/Makefile.sim
