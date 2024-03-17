
import cocotb
from cocotb.triggers import RisingEdge, FallingEdge
from cocotb.types import LogicArray, Logic

from RV32Components.registerFileData import RegisterFileData
from RV32Components.registerFileData import RegisterFileDUT, RegisterFileDriver

async def clkSource(clk: Logic):
  while (True):
    await cocotb.triggers.Timer(10, 'ns')
    clk.value = 0
    await cocotb.triggers.Timer(10, 'ns')
    clk.value = 1

@cocotb.test()
async def RV32I_Test(dut):
  registerFileDUT : RegisterFileDUT = RegisterFileDUT(dut)
  registerFileDriver : RegisterFileDriver = RegisterFileDriver(registerFileDUT)
  clkThread = cocotb.start_soon(clkSource(dut.i_clk))
  registerFileDriver.buildPhase()
  await registerFileDriver.runPhase()



