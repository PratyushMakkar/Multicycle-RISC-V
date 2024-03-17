from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly
from lib.rv32VerifComponents import RV32Data, RV32IDriverModule, RV32IScoreboardModule, RV32IDut
from lib.rv32Utils import randomizeData

import random 

# This was a sample reference for the first dut. 
class RegisterFileDUT(RV32IDut):
  def __init__(self, dut):
    self.i_clk = dut.i_clk
    self.i_rst = dut.i_rst
    self.i_rd_en = dut.i_rd_en
    self.i_reg_one = dut.i_reg_one
    self.i_reg_two = dut.i_reg_two
    self.o_reg_one_data = dut.o_reg_one_data
    self.o_reg_two_data = dut.o_reg_two_data
    self.i_wr_en = dut.i_wr_en
    self.i_dest_reg = dut.i_dest_reg
    self.i_dest_reg_data = dut.i_dest_reg_data

class RegisterFileData(RV32Data):
  def contraintCallback(self) -> bool:
    return (self.i_reg_one != self.i_reg_two) and (self.i_dest_reg != 0)

  def randomize(self):
    super().randomize()
    self.i_rd_en = random.getrandbits(1)
    self.i_reg_one = random.getrandbits(5)
    self.i_reg_two = random.getrandbits(5)
    self.i_wr_en = random.getrandbits(1)
    self.i_dest_reg = random.getrandbits(5)
    self.i_dest_reg_data = random.getrandbits(31)

  def __init__(self):
    self.i_rd_en = 0
    self.i_reg_one = 0
    self.i_reg_two = 0
    self.i_wr_en = 0
    self.i_dest_reg = 0
    self.i_dest_reg_data = 0

class RegisterFileDriver(RV32IDriverModule):
  def __init__(self, dut : RegisterFileDUT):
    self.dut = dut
    self.memory : list = []

  async def resetDut(self):
    await super().resetDut()
    await FallingEdge(self.dut.i_clk)
    self.dut.i_rst.value = 1
    await RisingEdge(self.dut.i_clk)
    self.dut.i_rst.value = 0

  def buildPhase(self):
    super().buildPhase()
    for i in range (0, 32):
      self.memory.append(0)

  async def runPhase(self):
    await self.resetDut()
    
    rv32Data : RegisterFileData = RegisterFileData()
    for i in range(0, 400):
      randomizeData(rv32Data)
      
      await FallingEdge(self.dut.i_clk)
      self.dut.i_rd_en.value = rv32Data.i_rd_en
      self.dut.i_reg_one.value = rv32Data.i_reg_one
      self.dut.i_reg_two.value = rv32Data.i_reg_two
      self.dut.i_wr_en.value = rv32Data.i_wr_en
      self.dut.i_dest_reg.value  = rv32Data.i_dest_reg
      self.dut.i_dest_reg_data.value = rv32Data.i_dest_reg_data

      await ReadOnly()
      if ((rv32Data.i_wr_en == 1) and (self.dut.i_dest_reg.value != 0)):
        self.memory[self.dut.i_dest_reg.value] = self.dut.i_dest_reg_data.value

      if (rv32Data.i_rd_en == 1):
        try:
          assert(self.memory[rv32Data.i_reg_two] == self.dut.o_reg_two_data.value)
          assert(self.memory[self.dut.i_reg_one.value] == self.dut.o_reg_one_data.value)
        except AssertionError as err:
          print("ERROR")
          print(bin(self.memory[rv32Data.i_reg_one]))
          print(self.dut.o_reg_one_data.value)
          print(self.dut.i_reg_one.value)
          print(bin(rv32Data.i_reg_one))

  