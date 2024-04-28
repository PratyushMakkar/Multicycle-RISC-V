module RV32I_decode_stage #(parameter WORD_SIZE = 32, parameter INSTRUCTION_WIDTH = 32) 
(
  input logic i_clk,
  input logic i_rst,
  
  // --------- Register File Signals  ----------- //
  output logic o_register_rst,
  output logic o_register_read_en, o_register_write_en,
  output logic [4:0] o_register_addr,
  output logic [WORD_SIZE-1:0] o_register_write_data,
  input  logic [WORD_SIZE-1:0] i_register_read_data,
  input  logic i_register_read_valid, i_register_write_valid,

  // ------------- Branch result to fetch stage ----------------- //
  input logic i_flush,
  input logic i_fetch_valid_recv,  // When a new instruction comes
  input logic [INSTRUCTION_WIDTH-1:0] i_fetch_instruction,
  input logic [WORD_SIZE-1:0] i_fetch_instruction_pc,
  input logic i_branch_taken,

  output logic o_branch_mispredict, 
  output logic [WORD_SIZE-1:0] o_branch_adder_result,

  // --------- Execute Stage Pipeline Signals ----------- //
  output logic [3:0] o_alu_op,
  output logic [WORD_SIZE-1:0] o_alu_src_one,
  output logic [WORD_SIZE-1:0] o_alu_src_two,
  output logic o_ex_decode_ready,

  // --------- Memory Stage Pipeline Signals ----------- //
  output logic [1:0] o_memory_op,
  output logic [1:0] o_memory_operand_size,

  // --------- Writeback Stage Pipeline Signals ----------- //
  output logic o_writeback_op,
  output logic [4:0] o_register_writeback_addr
);



endmodule