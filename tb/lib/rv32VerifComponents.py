import cocotb
from cocotb.types import Logic

# Purely used a reference object to make typing hinting easier
class RV32IDut:
  def __init__(self, dut):
    self.dut = dut

class RV32Data:
  def contraintCallback(self) -> bool:
    return True
  def preRandomize(self):
    pass
  def postRandomize(self):
    pass
  def randomize(self):
    pass

class RV32IDriverModule():
  def __init__(self, dut: RV32IDut):
    self.dut = dut
    self.queueList = []

  def buildPhase(self):
    pass

  async def resetDut(self):
    pass

  async def runPhase(self):
    pass

class RV32IScoreboardModule():
  def __init__(self):
    self.queueList = []
    pass
  async def runPhase(self):
    pass
  
  

