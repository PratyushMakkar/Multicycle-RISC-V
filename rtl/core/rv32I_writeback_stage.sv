import RV32I_core_utils_package::*;

module RVRV32I_writeback_stage #(
  parameter WORD_SIZE = 32, 
  parameter INSTRUCTION_WIDTH = 32)
( 
  input logic i_clk,
  input logic i_rst,

  output logic o_writeback_ready_recv,
  input logic i_writeback_valid_recv,
  input logic i_writeback_op,
  input logic [WORD_SIZE-1:0] i_writeback_register_data,
  input logic [4:0] i_writeback_register_addr,

// ----------- Register-File Interface ---------------//
  input logic i_register_write_valid,
  output logic [WORD_SIZE-1:0] o_register_write_data,
  output logic [4:0] o_register_write_addr,
  output logic o_register_write_en,
);

enum {WritebackRst, WritebackStage} writeback_state_e;

always_ff @(posedge i_clk) begin

  unique case (writeback_state_e) begin

    WritebackRst: begin
      o_writeback_ready_recv <= 1'b1;
      if (i_writeback_op && i_writeback_valid_recv) begin
        o_writeback_ready_recv <= 1'b0; 
        o_register_write_data <= i_writeback_register_data;
        o_register_write_addr <= i_writeback_register_addr;
        o_register_write_en <= 1'b1;
        writeback_state_e <= WritebackStage;
      end
    end

    WritebackStage: begin
      if (i_register_writeback_valid) begin
        o_register_write_en <= 1'b0;
        writeback_state_e <= WritebackRst;
      end
    end
  end

  if (i_rst) begin
    writeback_state_e <= WritebackRst;
    o_register_write_en <= 1'b0;
  end
end
endmodule