import RV32I_core_utils_package::*;

module RVRV32I_writeback_stage #(
  parameter WORD_SIZE = 32, 
  parameter INSTRUCTION_WIDTH = 32)
( 
  input logic i_clk,
  input logic i_rst,
  input RV32I_core_utils_package::writeback_op_t i_writeback_op,
  input logic [WORD_SIZE-1:0] i_rf_wr_data,
  input logic [4:0] i_rf_wr_addr,

  output logic [WORD_SIZE-1:0] o_rf_wr_data,
  output logic [4:0] o_rf_wr_addr,
  output logic o_rf_wr_en
);

assign o_rf_wr_en = (o_writeback_op == WB);
assign o_rf_wr_data = (o_rf_wr_en) ? i_rf_wr_data : 'd0;
assign o_rf_wr_addr = (o_rf_wr_addr) ? i_rf_wr_addr : 'd0;
endmodule