module riscv_core #(parameter RESET_SP = 32'h0000)
(
  input logic i_clk,
  input logic i_reset,
  
  output logic [31:0] o_ins_addr,
  input logic [31:0] i_ins_data,

  output logic [31:0] o_data_addr,
  input logic [31:0] i_data
);

  localparam NOOP = 32'h0000;
  localparam WORD_SIZE = 32;

  logic [WORD_SIZE-1:0] fetch_decode_reg, decode_execute_reg, execute_memory_reg, memory_writeback_reg;
///////////////////// Fetch Instruction Stage ///////////////////////////


////////////// End of Fetch Instruction Stage /////////////////////
endmodule