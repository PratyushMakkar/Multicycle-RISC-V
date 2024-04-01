
import cocotb
from cocotb.triggers import FallingEdge, RisingEdge
from sequences.register_file_sequences import write_only_register_sequence
from sequences.sequences import sequencer_handle, begin_next_transaction, await_transaction

@cocotb.test()
async def directed_sanity_test(dut):
  dut.i_rd_en.value = 0;
  dut.i_rd_reg_addr.value = 0
  dut.i_wr_en.value = 1
  dut.i_dest_addr.value = 0
  dut.i_dest_reg_data.value = 0
  dut.i_operation_code.value = 0
  dut.i_dest_addr.value = 3
  dut.i_dest_reg_data.value = 10
  await await_transaction(dut)
  
@cocotb.test()
async def write_only_sanity_test(dut):
  handle = sequencer_handle(dut)
  write_only_seq = write_only_register_sequence(handle)
  await write_only_seq.task_body()