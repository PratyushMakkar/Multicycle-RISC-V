import cocotb
from cocotb.triggers import FallingEdge, RisingEdge

async def await_transaction(dut):
  await RisingEdge(dut.o_tx_complete)
  dut.i_rx_continue.value = 1
  await FallingEdge(dut.o_tx_complete)

def begin_next_transaction(dut):
  dut.i_rx_continue.value = 0

class sequence_item():
  def randomize(self):
    pass

  def drive_item(self, dut):
    pass

class sequencer_handle():
  def __init__(self, dut):
    self.sequence_items = []
    self.response_items = []
    self.dut = dut

  def insert_sequence_item(self, item):
    self.sequence_items.append(item)

  async def drive_sequence_item(self, item : sequence_item):
    begin_next_transaction(self.dut)
    item.drive_item(self.dut)
    await await_transaction(self.dut)

  async def drive_sequence(self):
    for item in self.sequence_items:
      await self.drive_sequence_item(item)

class sequence():
  def __init__(self, sequencer : sequencer_handle):
    self.sequencer = sequencer

  async def task_body(self):
    pass


