
import cocotb
from cocotb.triggers import FallingEdge, RisingEdge
from sequences.register_file_sequences import write_only_register_sequence
from sequences.sequences import sequencer_handle

@cocotb.test()
async def write_only_sanity_test(dut):
  handle = sequencer_handle(dut)
  write_only_seq = write_only_register_sequence(handle)
  await write_only_seq.task_body()