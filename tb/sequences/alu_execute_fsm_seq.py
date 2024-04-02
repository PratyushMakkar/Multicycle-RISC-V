import cocotb 
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly
import random

async def resetDut(dut):
  await FallingEdge(dut.o_clk)
  dut.tx_ack_data.value = 0

async def add_sequence(dut):
  stim_count = 5
  resetDut(dut)
  while (stim_count > 0):
    await FallingEdge(dut.o_clk)
    randValue1 = random.getrandbits(30)
    randValue2 =  random.getrandbits(30)
    dut.i_operand_one.value = randValue1
    dut.i_operand_two.value = randValue2
    dut.alu_op_sel.value = 00
    dut.carry_out_exp.value = 0
    dut.alu_result_exp.value = randValue1 + randValue2
    await RisingEdge(dut.tx_finished)
    assert dut.tb_error.value != 1
    dut.tx_ack_data.value = 1
    await resetDut(dut)
    stim_count -= 1
  await(FallingEdge(dut.o_clk))
