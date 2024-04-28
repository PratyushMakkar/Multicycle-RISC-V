
import cocotb
from cocotb.triggers import FallingEdge, RisingEdge
from sequences.rv32_instruction_fetch_sequences import instruction_fetch_sequence, load_instruction_sequence, fetch_reset_sequence
from sequences.sequences import sequencer_handle
from cocotb.queue import Queue
from cocotb.clock import Clock

from environment.rv32_instruction_fetch_env import rv32_instruction_fetch_driver

@cocotb.test()
async def rv32_instruction_repeated_test(dut):
  request_queue = Queue(5)
  response_queue = Queue(5)

  driver = rv32_instruction_fetch_driver(dut, request_queue, response_queue)
  handle = sequencer_handle(request_queue, response_queue)
  reset_seq = fetch_reset_sequence(handle)
  load_seq = load_instruction_sequence(handle)

  cocotb.start_soon(Clock(dut.i_clk, 1000).start())
  cocotb.start_soon(driver.driver_routine())
  
  await reset_seq.task_body()
  await load_seq.task_body()


 

