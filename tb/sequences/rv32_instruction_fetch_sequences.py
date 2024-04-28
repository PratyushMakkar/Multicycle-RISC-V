
import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly
from sequences.sequences import sequencer_handle, sequence, sequence_item
import random
from enum import Enum

class OPERATION_CODE(Enum):
  RESET = 0
  LOAD_INSTRUCTION = 1
  FETCH_INSTRUCTION = 2
  BRANCH_INSTRUCTION = 3

class instruction_fetch_stage_item(sequence_item):
  def __init__(self):
    self.i_operation_code = 0
    self.i_rst = 0
    self.i_branch_miss = 0
    self.i_branch_pc = 0
    self.i_decode_ready = 0
    self.i_instruction_wr_en = 0
    self.i_instruction_wr_addr = 0
    self.i_instruction_wr_data = 0

  def randomize(self):
    super().randomize()
    self.i_operation_code = random.getrandbits(1)
    self.i_branch_pc = random.getrandbits(32)
    self.i_instruction_wr_addr = random.getrandbits(32)
    self.i_instruction_wr_data = random.getrandbits(32)

class instruction_fetch_item(instruction_fetch_stage_item):
  def randomize(self):
    super().randomize()
    self.i_operation_code = OPERATION_CODE.FETCH_INSTRUCTION

class load_instruction_item(instruction_fetch_stage_item):
  def randomize(self):
    super().randomize()
    self.i_instruction_wr_en = 1
    self.i_operation_code = OPERATION_CODE.LOAD_INSTRUCTION
  
class reset_sequence_item(instruction_fetch_stage_item):
  def randomize(self):
    super().randomize()
    self.i_rst = 1
    self.i_operation_code = OPERATION_CODE.RESET
  
class branch_instruction_item(instruction_fetch_stage_item):
  def randomize(self):
    super().randomize()
    self.i_operation_code = OPERATION_CODE.BRANCH_INSTRUCTION
  
class branch_instruction_sequence(sequence):
  async def task_body(self):
    await super().task_body()
    item : branch_instruction_item = branch_instruction_item()
    self.sequencer.insert_sequence_item(item)
    await self.sequencer.drive_sequence()

class instruction_fetch_sequence(sequence):
  async def task_body(self):
    await super().task_body()
    for i in range(0, 5):
      item : instruction_fetch_item = instruction_fetch_item()
      item.randomize()
      self.sequencer.insert_sequence_item(item)
    await self.sequencer.drive_sequence()

class fetch_reset_sequence(sequence):
  async def task_body(self):
    await super().task_body()
    items : list = []
    for i in range(0, 2):
      items.append(reset_sequence_item())
      items[-1].randomize()

    items[-1].i_rst = 0
    for item in items:
      self.sequencer.insert_sequence_item(item)
    await self.sequencer.drive_sequence()

class load_instruction_sequence(sequence):
  async def task_body(self):
    load_item = load_instruction_item()
    load_item.randomize()
    self.sequencer.insert_sequence_item(load_item)
    await self.sequencer.drive_sequence()

class instruction_fetch_reset_sequence(sequence):
  async def task_body(self):
    super().task_body()
    load_item = reset_sequence_item()
    self.sequencer.insert_sequence_item(load_item)
    await self.sequencer.drive_sequence()