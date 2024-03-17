from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly
from lib.rv32VerifComponents import RV32Data, RV32IDut, RV32IScoreboardModule

from enum import Enum
import random

class WritebackOP(Enum):
  WB_NOOP = 0
  WB = 1

class RV32WritebackStageDUT(RV32IDut):
  def __init__(self, dut):
    self.i_clk = dut.i_clk
    self.i_rst = dut.i_rst
    self.i_writeback_op = dut.i_writeback_op
    self.i_rf_wr_data = dut.i_rf_wr_data
    self.i_rf_wr_addr = dut.i_rf_wr_addr
    self.o_rf_wr_addr = dut.o_rf_wr_addr
    self.o_rf_wr_data = dut.o_rf_wr_data
    self.o_rf_wr_en = dut.o_rf_wr_en

class RV32WritebackData(RV32Data):
  def __init__(self):
    self.i_rst = 0
    self.i_writeback_op : WritebackOP = 0
    self.i_rf_wr_data = 0
    self.i_rf_wr_addr = 0
  
  def randomize(self):
    super().randomize()
    self.i_rst = random.getrandbits(1)
    self.i_writeback_op = random.getrandbits(1)
    self.i_rf_wr_data = random.getrandbits(32)
    self.i_rf_wr_addr = random.getrandbits(5)

class RV32WritebackStageInterface(RV32IScoreboardModule):
  def __init__(self, dut : RV32WritebackStageDUT):
    self.dut : RV32WritebackStageDUT = dut

  async def runPhase(self):
    super().runPhase()
    for i in range(0, 50):
      writebackData : RV32WritebackData = RV32WritebackData()
      await FallingEdge(self.dut.i_clk)
      self.dut.i_rst.value = writebackData.i_rst
      self.dut.i_writeback_op.value = writebackData.i_writeback_op
      self.dut.i_rf_wr_data.value = writebackData.i_rf_wr_data
      self.dut.i_rf_wr_addr.value = writebackData.i_rf_wr_addr
      await ReadOnly()
      assert self.dut.o_rf_wr_data.value == (writebackData.i_writeback_op == WritebackOP.WB)
      if (writebackData.i_writeback_op == WritebackOP.WB):
        assert (writebackData.i_rf_wr_data == self.dut.o_rf_wr_data.value)
        assert (writebackData.i_rf_wr_addr == self.dut.o_rf_wr_addr.value)
      else:
        assert (self.dut.o_rf_wr_data.value == 0)
        assert (self.dut.o_rf_wr_addr.value == 0)
        

