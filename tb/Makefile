
TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 1
RTL_DIR =  $(shell pwd)/../rtl
TB_DIR = $(shell pwd)/../tb
MODULE ?= main

INSTRUCTION_EXECUTE_RTL_SRCS := 
INSTRUCTION_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/instruction_execute/rv32_adder_unit.sv
INSTRUCTION_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/instruction_execute/rv32I_execute_controlpath.sv
INSTRUCTION_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/instruction_execute/rv32I_multipler_shift_controlpath.sv

INSTRUCTION_DECODE_RTL_SRCS :=
INSTRUCTION_DECODE_RTL_SRCS += $(RTL_DIR)/core/instruction_decode/rv32I_decode_stage.sv
INSTRUCTION_DECODE_RTL_SRCS += $(RTL_DIR)/core/instruction_decode/rv32I_decode.sv
INSTRUCTION_DECODE_RTL_SRCS += $(RTL_DIR)/core/instruction_decode/rv32I_register_file.sv

INSTRUCTION_FETCH_RTL_SRCS :=

SV_TB_DIR := $(RTL_DIR)/tb_wrappers/tb_multiplier_shift_controlpath.sv

VERILOG_SOURCES :=
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_core_package.sv
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_core_utils.sv
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_sim_build_params.sv
VERILOG_SOURCES += $(RTL_DIR)/riscv_core.sv
VERILOG_SOURCES += $(RTL_DIR)/core/rv32_bram_wrapper.sv
VERILOG_SOURCES += $(INSTRUCTION_DECODE_RTL_SRCS)
VERILOG_SOURCES += $(INSTRUCTION_EXECUTE_RTL_SRCS)
VERILOG_SOURCES += $(INSTRUCTION_FETCH_RTL_SRCS)
VERILOG_SOURCES += $(SV_TB_DIR)

PYTHON_DIR := $(TB_DIR)
PYTHON_DIR += $(TB_DIR)/lib
PYTHON_DIR += $(TB_DIR)/RV32Components
PYTHON_DIR += $(TB_DIR)/sequences
PYTHON_DIR += $(TB_DIR)/environment
PYTHON_DIR += $(TB_DIR)/tests

TOPLEVEL =  $(TOP) 

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: clean_build
clean_build:
	rm -rf $(patsubst %, %/__pycache__, $(PYTHON_DIR))
	rm -rf sim_build
	rm results.xml
	
