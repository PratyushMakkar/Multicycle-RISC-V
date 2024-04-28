module RV32I_decode_stage #(parameter WORD_SIZE = 32, parameter INSTRUCTION_WIDTH = 32) 
(
  input logic i_clk,
  input logic i_rst,
  
  // Signals for pipeline stalls/movement
  input logic i_flush,
  input logic i_new_instruction,  // When a new instruction comes in

  input logic [INSTRUCTION_WIDTH-1:0] i_fetch_instruction,
  input logic [WORD_SIZE-1:0] i_fetch_instruction_pc,
  
  // --------- Register File Signals From Writeback Stage ----------- //
  input logic i_rf_wb_en,
  input logic [4:0] i_rf_wb_addr,
  input logic [WORD_SIZE-1:0] i_rf_wb_data,
  output logic o_wb_valid,

  // ----------------- Register file signals --------------------//
  output logic o_reg_rst,
  input logic i_reg_rd_valid,
  input logic i_reg_wr_valid,

  output logic o_rd_en,
  output logic [4:0] o_rd_addr, 
  input logic [WORD_SIZE-1:0] i_rd_data,

  output logic o_wr_en,
  output logic [4:0] o_wr_addr,
  output logic [WORD_SIZE-1:0] o_wr_data,

  // ------------- Branch result to fetch stage ----------------- //
  input logic i_branch_taken,
  output logic o_branch_mispredict, 
  output logic [WORD_SIZE-1:0] o_branch_adder_result,

  // --------- Execute Stage Pipeline Signals ----------- //
  output RV32I_core_utils_package::alu_op_t o_alu_op,
  output logic [WORD_SIZE-1:0] o_alu_src_one,
  output logic [WORD_SIZE-1:0] o_alu_src_two,

  // --------- Memory Stage Pipeline Signals ----------- //
  output RV32I_core_utils_package::memory_op_t o_memory_op,
  output RV32I_core_utils_package::memory_size_t o_memory_operand_size,

  // --------- Writeback Stage Pipeline Signals ----------- //
  output RV32I_core_utils_package::writeback_op_t o_writeback_op,
  output logic [4:0] o_rf_wb_addr
);


endmodule