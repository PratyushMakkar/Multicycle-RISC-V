
module RV32I_instruction_fetch_stage #(
  parameter REST_MEM_PTR = 'd0, 
  parameter MEM_SIZE = 1024) 
(
  input logic i_clk,
  input logic i_rst,
  input logic i_branch, i_stall,
  input logic [WORD_SIZE-1:0] i_addr,
  output logic o_next_addr,
  output logic [WORD_SIZE-1:0] o_fetch_decode_reg
);

  logic [WORD_SIZE-1:0] instruction_mem [$clog2(MEM_SIZE)-1:0];
  logic [WORD_SIZE-1:0] next_addr;

  always_ff @(posedge i_clk) begin
    if (i_rst == 1'b0) begin
      next_addr <= RESET_MEM_PTR;
    end else if (i_branch == 1'b1) begin
      next_addr <= i_addr;
    end else next_addr <= next_addr + 4;
  end

  always_ff @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
      for (integer i = 0; i < MEM_SIZE; ++i) begin
        instruction_mem[i] <= 'd0;
      end
    end
    if (i_stall == 1'b0 && i_rst == 1'b0) begin 
      o_fetch_decode_reg <= (i_branch == 1'b1) ? NOOP: instruction_mem[next_addr];
    end 
  end

  assign o_next_addr = next_addr;
endmodule