
import cocotb
from cocotb.triggers import FallingEdge, RisingEdge
from sequences.rv32_instruction_fetch_sequences import instruction_fetch_sequence, load_instruction_sequence
from sequences.sequences import sequencer_handle

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
  
@cocotb.test()
async def rv32_instruction_repeated_test(dut):
  handle = sequencer_handle(dut)
  load_seq = load_instruction_sequence(handle)
  fetch_seq = instruction_fetch_sequence(handle)
  await load_seq.task_body()
  await fetch_seq.task_body()



 

