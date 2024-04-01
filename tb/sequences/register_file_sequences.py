import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly
from sequences.sequences import sequencer_handle, sequence, sequence_item
import random

class register_file_item(sequence_item):
  def __init__(self):
    self.i_rd_en = 0
    self.i_wr_en = 0
    self.i_rd_reg_addr = 0
    self.i_dest_addr = 0
    self.i_dest_reg_data = 0
    self.o_debug_rd_reg_data = 0
    self.i_operation_code = 0

  def drive_item(self, dut):
    super().drive_item(dut)
    dut.i_rd_en.value = self.i_rd_en
    dut.i_wr_en.value = self.i_wr_en
    dut.i_rd_reg_addr.value = self.i_rd_reg_addr
    dut.i_dest_addr.value = self.i_dest_addr
    dut.i_dest_reg_data.value = self.i_dest_reg_data
    dut.i_operation_code.value = self.i_operation_code
  
  def randomize(self):
    super().randomize()
    self.i_rd_en = random.getrandbits(1)
    self.i_wr_en = random.getrandbits(1)
    self.i_rd_reg_addr = random.getrandbits(5)
    self.i_dest_addr = random.getrandbits(5)
    self.i_dest_reg_data = random.getrandbits(32)

class read_only_register_tx(register_file_item):
  def randomize(self):
    super().randomize()
    self.i_rd_en = 1
    self.i_wr_en = 0

class write_only_register_tx(register_file_item):
  def randomize(self):
    super().randomize()
    self.i_wr_en = 1
    self.i_rd_en = 0

class read_write_register_tx(register_file_item):
  def randomize(self):
    super().randomize()
    self.i_rd_en = 1
    self.i_wr_en = 1

class same_port_register_tx(read_write_register_tx):
  def randomize(self):
    super().randomize()
    self.i_dest_addr = self.i_rd_reg_addr

class write_only_register_sequence(sequence):
  async def task_body(self):
    await super().task_body()
    for i in range(0, 5):
      item : register_file_item = write_only_register_tx()
      item.randomize()
      self.sequencer.insert_sequence_item(item)
    await self.sequencer.drive_sequence()
