import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly
from sequences.alu_execute_fsm_seq import add_sequence

#@cocotb.test()
async def rv32_alu_fsm_test(dut):
  await add_sequence(dut)