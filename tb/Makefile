
TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 1
RTL_DIR =  $(shell pwd)/../rtl
TB_DIR = $(shell pwd)/../tb
MODULE ?= main

DECODE_EXECUTE_RTL_SRCS := 
DECODE_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/decode_execute/rv32_adder_unit.sv
DECODE_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/decode_execute/rv32I_alu_execute_fsm.sv
DECODE_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/decode_execute/rv32I_register_file.sv
DECODE_EXECUTE_RTL_SRCS += $(RTL_DIR)/core/decode_execute/rv32I_decode_stage.sv

INSTRUCTION_FETCH_RTL_SRCS :=
INSTRUCTION_FETCH_RTL_SRCS +=  $(RTL_DIR)/core/instruction_fetch/rv32I_instruction_fetch_stage.sv
INSTRUCTION_FETCH_RTL_SRCS +=  $(RTL_DIR)/core/instruction_fetch/rv32I_instruction_mem.sv

SV_TB_DIR := $(RTL_DIR)/tb_wrappers/rv32_tb_package.sv

VERILOG_SOURCES :=
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_core_package.sv
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_core_utils.sv
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_sim_build_params.sv
VERILOG_SOURCES += $(RTL_DIR)/core/rv32I_writeback_stage.sv
VERILOG_SOURCES += $(RTL_DIR)/riscv_core.sv
VERILOG_SOURCES += $(RTL_DIR)/core/rv32_bram_wrapper.sv
VERILOG_SOURCES += $(DECODE_EXECUTE_RTL_SRCS)
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
	
