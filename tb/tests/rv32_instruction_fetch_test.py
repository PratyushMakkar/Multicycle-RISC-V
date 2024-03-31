import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly

@cocotb.test()
async def rv32_instruction_fetch_sanity_test(dut):
  dut.i_operation_code.value = 0
  dut.i_cycle_length.value = 20 
  await RisingEdge(dut.o_tx_complete)

  dut.i_rx_continue.value = 1
  await FallingEdge(dut.o_tx_complete)
  dut.i_operation_code.value = 3
  dut.i_rx_continue.value = 0

  await RisingEdge(dut.o_tx_complete)

  dut.i_rx_continue.value = 1
  await FallingEdge(dut.o_tx_complete)
  dut.i_operation_code.value = 1
  dut.i_cycle_length.value = 15
  dut.i_rx_continue.value = 0

  await RisingEdge(dut.o_tx_complete)


 

