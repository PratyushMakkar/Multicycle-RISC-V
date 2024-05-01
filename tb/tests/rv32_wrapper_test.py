import cocotb
from cocotb.triggers import FallingEdge, RisingEdge

@cocotb.test()
async def wrapper_test(dut):
  print("Got here")
  for i in range(0, 250):
    await RisingEdge(dut.o_clk)