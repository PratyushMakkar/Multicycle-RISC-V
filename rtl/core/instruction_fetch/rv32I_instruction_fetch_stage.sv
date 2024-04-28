module RV32I_instruction_fetch_stage #(parameter REST_MEM_PTR = 32'd0) 
(
  input logic i_clk,
  input logic i_rst,

  input logic [31:0] i_branch_pc,
  input logic i_branch_miss,
  
  input logic i_decode_ready,
  output logic o_instruction_ready,
  output logic [31:0] o_fetch_instruction,
  output logic [31:0] o_fetch_instruction_pc,

  // Outside of RISC-V Core signals
  input logic i_instruction_wr_en,
  input logic [31:0] i_instruction_wr_addr,
  input logic [31:0] i_instruction_wr_data,
  output logic o_instruction_wr_valid
);

// -------- Top level instruction fetch signals ------- //
typedef enum {FETCH, FETCH_LATCH_AWAIT, LOAD} instruction_state_t;
instruction_state_t current_state, next_state;

// --------------------- Instruction memory interface ------- //
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

// ---------------- Three always block style FSM ------------- //
logic [31:0] pc_addr_reg, pc_addr;
logic pc_addr_latch_en;

logic [31:0] instruction_reg, next_instruction;
logic instruction_latch_en;

always_comb begin : NEXT_STATE_LOGIC_BLOCK
  next_instruction = NOOP_INSTRUCTION;
  pc_addr = REST_MEM_PTR;
  instruction_latch_en = 1'b0;
  pc_addr_latch_en = 1'b0;

  if (i_rst) begin
    pc_addr_latch_en = 1'b1;
    instruction_latch_en = 1'b1;
    next_state = FETCH;
  end

  else if (i_branch_miss) begin
    pc_addr = i_branch_pc;
    pc_addr_latch_en = 1'b1;
    instruction_latch_en = 1'b1;
    next_state = FETCH;
  end

  else begin : NORMAL_FSM_SEQUENCE
    case (current_state)
      FETCH: begin
        if (i_instruction_wr_en) next_state = LOAD;
        if (i_decode_ready)      next_state = FETCH;
        if (instruction_mem_rd_valid) begin
          {instruction_latch_en, pc_addr_latch_en} = 2'b11;
          next_instruction = instruction_mem_rd_data;
          pc_addr = pc_addr_reg + 32'd4;
          if (!i_decode_ready)    next_state = FETCH_LATCH_AWAIT;
          else                    next_state = FETCH;
        end
      end
      
      FETCH_LATCH_AWAIT: begin
        if (i_instruction_wr_en)  next_state = LOAD;
        else if (i_decode_ready)  next_state = FETCH;
        else                      next_state = FETCH_LATCH_AWAIT;
      end

      LOAD: begin
        if (!i_instruction_wr_en) next_state = FETCH;
        else                      next_state = LOAD;
      end
    endcase
  end
end

always_ff @(posedge i_clk) begin : SEQUENTIAL_LOGIC_BLOCK
  if (i_rst) next_state <= FETCH;
  else current_state <= next_state;

  if (pc_addr_latch_en) pc_addr_reg <= pc_addr;
  if (instruction_latch_en) instruction_reg <= next_instruction;
end

always_comb begin : COMBO_OUTPUT_BLOCK
  instruction_mem_wr_en = 1'b0;
  instruction_mem_rd_en = 1'b0;
  o_instruction_ready = 1'b0;
  o_fetch_instruction = instruction_reg;

  case (current_state)
    FETCH: begin 
      instruction_mem_rd_en = 1'b1;
      if (instruction_mem_rd_valid) begin : SKID_BUFFER
        o_instruction_ready = instruction_mem_rd_valid;
        o_fetch_instruction = next_instruction;
        o_fetch_instruction_pc = pc_addr;
      end
    end
    FETCH_LATCH_AWAIT: begin 
      instruction_mem_rd_en = 1'b0;
      o_instruction_ready = 1'b1;
    end
    LOAD: instruction_mem_wr_en = 1'b1;
  endcase
end

assign instruction_mem_rst = i_rst;
assign instruction_mem_rd_addr = pc_addr_reg;
assign instruction_mem_wr_addr = i_instruction_wr_addr;
assign instruction_mem_wr_data = i_instruction_wr_data;
assign o_instruction_wr_valid = instruction_mem_wr_valid;
assign o_fetch_instruction_pc = pc_addr_reg;
endmodule