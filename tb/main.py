
import cocotb
from cocotb.triggers import RisingEdge, FallingEdge
from cocotb.types import LogicArray, Logic

from RV32Components.registerFileData import RegisterFileData
from RV32Components.registerFileData import RegisterFileDUT, RegisterFileDriver

from tests.rv32_alu_fsm_test import rv32_alu_fsm_test

