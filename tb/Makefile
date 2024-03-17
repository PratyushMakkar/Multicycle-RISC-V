
TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 0
RTL_DIR =  $(shell pwd)/../rtl
TB_DIR = $(shell pwd)/../tb

DECODE_EXECUTE_RTL_SRCS := 
DECODE_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/decode_execute/rv32_adder_unit.sv
DECODE_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/decode_execute/rv32I_alu_execute_fsm.sv
DECODE_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/decode_execute/rv32I_register_file.sv
DECODE_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/decode_execute/rv32I_decode_stage.sv

VERILOG_SOURCES :=
VERILOG_SOURCES += $(DECODE_EXECUTE_RTL_SRCS)
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_sim_build_params.sv
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_core_utils.sv
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_instruction_fetch_stage.sv
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_writeback_stage.sv
VERILOG_SOURCES += $(RTL_DIR)/riscv_core.sv

SV_TB_DIR :=

PYTHON_DIR := $(TB_DIR)
PYTHON_DIR += $(TB_DIR)/lib
PYTHON_DIR += $(TB_DIR)/RV32Components

MODULE = main
TOPLEVEL =  $(TOP) 

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: clean_build
clean_build:
	rm -rf $(patsubst %, %/__pycache__, $(PYTHON_DIR))
	rm -rf sim_build
	rm results.xml
	
