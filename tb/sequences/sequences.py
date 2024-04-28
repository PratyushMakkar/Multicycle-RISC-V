import cocotb
from cocotb.triggers import FallingEdge, RisingEdge
from cocotb.queue import Queue

class sequence_item():
  def randomize(self):
    pass

class sequencer_handle():
  def __init__(self, req_q, resp_q):
    self.sequence_items = []
    self.response_items = []
    self.request_q = req_q
    self.response_q = resp_q

  def insert_sequence_item(self, item):
    self.sequence_items.append(item)

  async def drive_sequence_item(self, item : sequence_item):
    await self.request_q.put(item)
    item_resp = await self.response_q.get()
    self.response_items.append(item_resp)

  async def drive_sequence(self):
    for item in self.sequence_items:
      await self.drive_sequence_item(item)
    self.sequence_items = []

class sequence():
  def __init__(self, sequencer : sequencer_handle):
    self.sequencer = sequencer

  async def task_body(self):
    pass


