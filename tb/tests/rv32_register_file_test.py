
import cocotb
from cocotb.triggers import FallingEdge, RisingEdge
from cocotb.queue import Queue
from cocotb.clock import Clock

from sequences.register_file_sequences import write_only_register_sequence
from sequences.sequences import sequencer_handle
from environment.register_file_env import register_file_driver

request_queue : Queue
response_queue : Queue

@cocotb.test()
async def write_only_sanity_test(dut):
  request_queue = Queue(5)
  response_queue = Queue(5)

  driver = register_file_driver(dut, request_queue, response_queue)
  handle = sequencer_handle(request_queue, response_queue)
  write_only_seq = write_only_register_sequence(handle)
  
  cocotb.start_soon(Clock(dut.i_clk, 1000).start())
  cocotb.start_soon(driver.driver_routine())

  dut.i_rst.value = 1
  await RisingEdge(dut.i_clk)
  dut.i_rst.value = 0

  await write_only_seq.task_body()