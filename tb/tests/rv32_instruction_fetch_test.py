import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly

@cocotb.test()
async def rv32_instruction_fetch_sanity_test(dut):
  dut.i_operation_code.value = 0
  dut.i_cycle_length.value = 20 
  await RisingEdge(dut.o_tx_complete)
  dut.i_rx_continue.value = 1
  await RisingEdge(dut.o_debug_clk)
  dut.i_rx_continue.value = 0
  dut.i_operation_code.value = 3
  dut.i_cycle_length.value = 20 
  dut.i_rx_continue.value = 1
  await RisingEdge(dut.o_debug_clk)
 

