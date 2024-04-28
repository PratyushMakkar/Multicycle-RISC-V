import cocotb
from cocotb.triggers import RisingEdge, FallingEdge

from environment.environment import driver
from sequences.rv32_instruction_fetch_sequences import OPERATION_CODE

class rv32_instruction_fetch_driver(driver):
  def write_signals(self,item):
    self.dut.i_rst.value = item.i_rst
    self.dut.i_branch_miss.value = item.i_branch_miss
    self.dut.i_branch_pc.value = item.i_branch_pc
    self.dut.i_decode_ready.value = item.i_decode_ready
    self.dut.i_instruction_wr_en.value = item.i_instruction_wr_en
    self.dut.i_instruction_wr_addr.value = item.i_instruction_wr_addr
    self.dut.i_instruction_wr_data.value = item.i_instruction_wr_data

  async def write_instruction(self, item):
    await FallingEdge(self.dut.i_clk)
    self.write_signals(item)
    await RisingEdge(self.dut.o_instruction_wr_valid)
    await RisingEdge(self.dut.i_clk)
  
  async def branch_instruction(self, item):
    await FallingEdge(self.dut.i_clk)
    self.write_signals(item)
    await RisingEdge(self.dut.i_clk)

  async def reset_sequence(self, seq_item):
    await super().reset_sequence()
    while seq_item.i_rst == 1:
      await FallingEdge(self.dut.i_clk)
      self.write_signals(seq_item)
      await RisingEdge(self.dut.i_clk)
      
      await self.put_tx_resp(0)
      seq_item = await self.get_tx_req()
    self.dut.i_rst.value = 0
  
  async def driver_routine(self):
    while True:
      item = await self.get_tx_req()
      match item.i_operation_code:
        case OPERATION_CODE.RESET:
          await self.reset_sequence(item)
        case OPERATION_CODE.LOAD_INSTRUCTION:
          await self.write_instruction(item)
        case OPERATION_CODE.FETCH_INSTRUCTION:
          await RisingEdge(self.dut.i_clk)
        case OPERATION_CODE.BRANCH_INSTRUCTION:
          await self.branch_instruction(item)
      await self.put_tx_resp(0)