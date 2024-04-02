import cocotb
from cocotb.triggers import RisingEdge, FallingEdge

from environment.environment import driver

class register_file_driver(driver):
  async def read_register(self, seq_item):
    self.dut.i_rd_en.value = seq_item.i_rd_en
    self.dut.i_reg_addr.value = seq_item.i_rd_reg_addr

    if (seq_item.i_rd_en):
      await RisingEdge(self.dut.o_rd_valid)
      await FallingEdge(self.dut.i_clk)
    seq_item.o_reg_data = self.dut.o_reg_data

  async def write_register(self, seq_item):
    self.dut.i_wr_en.value = seq_item.i_wr_en
    self.dut.i_dest_addr.value = seq_item.i_dest_addr
    self.dut.i_dest_reg_data.value = seq_item.i_dest_reg_data
    if (seq_item.i_wr_en):
      await RisingEdge(self.dut.o_wr_valid)
      await RisingEdge(self.dut.i_clk)

  async def driver_routine(self):
    while True:
      seq_item = await self.get_tx_req()
      cocotb.start_soon(self.read_register(seq_item))
      await self.write_register(seq_item)
      await self.put_tx_resp(seq_item)