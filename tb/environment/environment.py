from asyncio.queues import Queue

class driver():
  def __init__(self, dut, req_queue : Queue, resp_queue : Queue):
    self.dut = dut
    self.sequencer_req_q = req_queue
    self.sequencer_resp_q = resp_queue
  
  async def get_tx_req(self):
    return await self.sequencer_req_q.get()
  
  async def put_tx_resp(self, item):
    await self.sequencer_resp_q.put(item)
  
  async def reset_sequence(self):
    pass

  async def driver_routine(self):
    pass