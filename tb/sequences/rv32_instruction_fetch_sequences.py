
import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly
from sequences.sequences import sequencer_handle, sequence, sequence_item
import random

class instruction_fetch_stage_item(sequence_item):
  def __init__(self):
    self.i_operation_code = 0
    self.i_cycle_length = 0

  def drive_item(self, dut):
    super().drive_item(dut)
    dut.i_operation_code.value = self.i_operation_code
    dut.i_cycle_length.value = self.i_cycle_length
  
  def randomize(self):
    super().randomize()
    self.i_operation_code = random.getrandbits(1)
    self.i_cycle_length = random.getrandbits(4)

class instruction_fetch_item(instruction_fetch_stage_item):
  def randomize(self):
    super().randomize()
    self.i_operation_code = 1

class load_instruction_item(instruction_fetch_stage_item):
  def randomize(self):
    super().randomize()
    self.i_operation_code = 0
  
class instruction_fetch_sequence(sequence):
  async def task_body(self):
    await super().task_body()
    for i in range(0, 5):
      item : instruction_fetch_item = instruction_fetch_item()
      item.randomize()
      self.sequencer.insert_sequence_item(item)
    await self.sequencer.drive_sequence()

class load_instruction_sequence(sequence):
  async def task_body(self):
    load_item = load_instruction_item()
    load_item.randomize()
    self.sequencer.insert_sequence_item(load_item)
    await self.sequencer.drive_sequence()