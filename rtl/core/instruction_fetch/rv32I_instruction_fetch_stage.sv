module RV32I_instruction_fetch_stage #(
  parameter REST_MEM_PTR = 32'd0) 
(
  input logic i_clk,
  input logic i_rst,

  input logic [31:0] i_branch_pc,
  input logic i_branch_miss,
  
  input logic i_decode_ready,
  output logic o_instruction_latch_en,
  output instruction_fetch_t o_instruction_fetch_result,

  // Outside of RISC-V Core signals
  input logic i_instruction_wr_en,
  input logic [31:0] i_instruction_wr_addr,
  input logic [31:0] i_instruction_wr_data,
  input logic o_instruction_wr_valid
);

// -------- Top level instruction fetch signals ------- //
logic instruction_latch_en;

// --------------------- Instrcuction memory interface ------- //
logic instruction_mem_rd_en, instruction_mem_rd_valid;
logic [31:0] instruction_mem_rd_addr, instruction_mem_rd_data;
logic instruction_mem_rst;

logic instruction_mem_wr_en, instruction_mem_wr_valid;
logic [31:0] instruction_mem_wr_addr, instruction_mem_wr_data;

RV32I_instruction_mem INSTRUCTION_CACHE (
  .i_clk(i_clk),
  .i_rst(instruction_mem_rst),
  .i_wr_en(instruction_mem_wr_en),
  .i_wr_data(instruction_mem_wr_data),
  .i_wr_addr(instruction_mem_wr_addr),
  .o_wr_valid(instruction_mem_wr_valid),
  .i_rd_en(instruction_mem_rd_en),
  .i_rd_addr(instruction_mem_rd_addr),
  .o_rd_data(instruction_mem_rd_data),
  .o_rd_valid(instruction_mem_rd_valid)
);

always_comb begin : INSTRUCTION_MEM_INTERFACE
  instruction_mem_wr_en = i_instruction_wr_en;
  instruction_mem_wr_addr = i_instruction_wr_addr;
  instruction_mem_wr_data = i_instruction_wr_data;
  o_instruction_wr_valid = instruction_mem_wr_valid;


  instruction_mem_rd_addr = pc_addr_reg;
  instruction_mem_rst = 1'b0;
  instruction_latch_en = 1'b0;
  instruction_mem_rd_en = 1'b1;
  if (i_branch_miss || i_rst) instruction_mem_rst = 1'b1;
  if ((instruction_mem_rd_valid && i_decode_ready) || i_branch_miss || i_rst) instruction_latch_en = 1'b1;
  if (instruction_mem_rd_valid && !i_decode_ready) instruction_mem_rd_en = 1'b0;
end

always_ff @(posedge i_clk) begin : INSTRUCTION_FETCH_FSM
  pc_addr_reg <= REST_MEM_PTR;

  if (instruction_latch_en) begin
    o_instruction_fetch_result.pc <= pc_addr_reg;
    if (i_rst || i_branch_miss) begin 
      if (branch_miss) pc_addr_reg <= i_branch_pc;
      o_instruction_fetch_result.instruction <= NOOP_INSTRUCTION;
    end else begin 
      o_instruction_fetch_result.instruction <= instruction_mem_rd_data;
      pc_addr_reg <= pc_addr_reg + 'd4;
    end
  end
end

assign o_instruction_latch_en = instruction_latch_en;
endmodule