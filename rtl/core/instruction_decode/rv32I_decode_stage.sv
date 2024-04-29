module RV32I_decode_stage #(parameter WORD_SIZE = 32, parameter INSTRUCTION_WIDTH = 32) 
(
  input logic i_clk,
  input logic i_rst,
  
// --------------- Register File Interface  ----------- //
  input  logic i_register_read_valid,
  input  logic [WORD_SIZE-1:0] i_register_read_data,
  output logic o_register_rst,
  output logic o_register_read_en,
  output logic [4:0] o_register_addr,
  
// ---------------- Fetch Interface ----------------- //
  input logic i_fetch_valid_recv,  // When a new instruction comes
  output logic o_decode_ready_recv,
  input logic i_branch_taken,
  input logic [INSTRUCTION_WIDTH-1:0] i_fetch_instruction,
  input logic [WORD_SIZE-1:0] i_fetch_instruction_pc,

// ------------- Branch-Adder Interface ----------------- //
  input logic i_branch_result_valid,
  output logic o_branch_taken,
  output logic [WORD_SIZE-1:0] o_branch_pc_operand,
  output logic [WORD_SIZE-1:0] o_branch_immediate,
  output logic [WORD_SIZE-1:0] o_branch_register_data,
  

//---------  Execute Stage Pipeline Signals ----------- //
  input logic i_ex_stall_send, // When the skid buffer is full
  output logic o_ex_decode_ready,
  output logic [3:0] o_alu_op,
  output logic [WORD_SIZE-1:0] o_alu_src_one,
  output logic [WORD_SIZE-1:0] o_alu_src_two,

//--------- Memory Stage Pipeline Signals ----------- //
  output logic [1:0] o_memory_op,
  output logic [1:0] o_memory_operand_size,

//--------- Writeback Stage Pipeline Signals ----------- //
  output logic o_writeback_op,
  output logic [4:0] o_register_writeback_addr
);

typedef enum {DecodeRst, DecodeRegisterReadA, DecodeRegisterReadB} decode_state_t;
decode_state_t current_state, next_state;

always_ff @(posedge i_clk) begin
  current_state <= next_state;

  if (i_rst) begin
    current_state <= DecodeRst;
  end
end


logic [4:0] register_addr_a, register_addr_b;
logic r_type_instruction;


logic alu_src_latch_en_a, alu_src_latch_en_b;
logic alu_src_b_value;

always_comb begin
o_register_rst = 1'b0;
o_register_read_en = 1'b0;
o_register_addr = 'd0;

alu_src_b_value = i_register_read_data;
next_state = current_state;

unique case (current_state) begin
  DecodeRst: begin
    o_register_read_en = 1'b1;
    o_ex_decode_ready = 1'b1;
    o_fetch_ready_recv = ~i_fetch_valid_recv;

    if (i_fetch_valid_recv) begin
      o_register_addr = register_addr_a;
      next_state = DecodeRegisterReadA;
    end
  end

  DecodeRegisterReadA: begin
    o_register_read_en = 1'b1;
    if (i_register_read_valid) begin
      o_register_addr = register_addr_a;

      if (r_type_instruction) begin
        alu_src_latch_en_a = 1'b1;
        next_state = DecodeRegisterReadB;
      end else begin
        alu_src_latch_en_a = 1'b1;
        next_state = DecodeRst;
        o_ex_decode_ready = 1'b1;
      end
    end
  end

  DecodeRegisterReadB: begin
    o_register_read_en = 1'b1;
    if (i_register_read_valid && !i_ex_stall_send) begin
      alu_src_latch_en_b = 1'b1;
      o_register_addr = register_addr_b;
      next_state = DecodeRst;
      o_ex_decode_ready = 1'b1;
    end
  end
end

end

always_ff @(posedge i_clk) begin : LatchingOutputs
  if (alu_src_latch_en_a) begin 
    o_alu_src_one <= i_register_read_data;
  end

  if (alu_src_latch_en_b) begin 
    o_alu_src_two <= alu_src_b_value;
  end
end

endmodule