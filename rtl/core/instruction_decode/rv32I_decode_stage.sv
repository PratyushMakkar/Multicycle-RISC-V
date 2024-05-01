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
  output logic o_branch_adder_en,
  output logic o_branch_taken,
  output logic [WORD_SIZE-1:0] o_branch_pc_operand,
  output logic [WORD_SIZE-1:0] o_branch_immediate,
  output logic [WORD_SIZE-1:0] o_branch_register_data,
  
//---------  Execute Stage Pipeline Signals ----------- //
  input logic i_ex_stall_send, // When the skid buffer is full
  output logic o_ex_decode_ready,
  output logic [4:0] o_alu_instruction_type,
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

logic invalid_instruction;
logic i_type_instruction;
logic r_type_instruction;
logic b_type_instruction;
logic ld_type_instruction;
logic str_type_instruction;

logic pc_operand;
logic [3:0] alu_op;
logic [WORD_SIZE-1:0] alu_src_immediate;
logic [4:0] alu_src_a_reg;
logic [4:0] alu_src_b_reg;
logic [4:0] alu_dest_reg;
logic [2:0] branch_op;

logic memory_sign_extend;
logic [1:0] memory_op;
logic [1:0] memory_operand_size;

logic writeback_op;

rv32I_decode RV32_DECODE_INSTANCE (
  .i_fetch_instruction(i_fetch_instruction),
  .o_invalid_instruction(invalid_instruction),

  .o_i_type_opcode_instr(i_type_instruction),
  .o_r_type_opcode_instr(r_type_instruction),
  .o_b_type_opcode_instr(b_type_instruction),
  .o_ld_type_opcode_instr(ld_type_instruction),
  .o_str_type_opcode_instr(str_type_instruction),

  .o_pc_operand(pc_operand),
  .o_alu_op(alu_op),
  .o_alu_src_immediate(alu_src_immediate),
  .o_alu_src_a_reg(alu_src_a_reg),
  .o_alu_src_b_reg(alu_src_b_reg),
  .o_alu_dest_reg(alu_dest_reg),

  .o_branch_op(branch_op),
  
  .o_memory_sign_extend(memory_sign_extend),
  .o_memory_op(memory_op),
  .o_memory_operand_size(memory_operand_size),

  .o_writeback_op(writeback_op)
);

enum {DecodeRst, DecodeRegisterReadA, DecodeRegisterReadB, DecodeBranchResult} decode_state_e;

assign o_decode_ready_recv = (decode_state_e == DecodeRst && !i_fetch_valid_recv) ? 1'b1 : 1'b0;
assign o_branch_taken = i_branch_taken;
assign o_branch_pc_operand = i_fetch_instruction_pc;

always_ff @(posedge i_clk) begin 

  unique case (current_state)
    DecodeRst: begin
      o_register_read_en <= 1'b0;
      o_branch_adder_en <= 1'b0;

      if (i_fetch_valid_recv) begin
        o_register_read_en <= 1'b1;
        o_register_addr <= register_addr_a;
        decode_state_e <= DecodeRegisterReadA;
        
        o_alu_instruction_type <= {i_type_instruction, r_type_instruction, b_type_instruction, ld_type_instruction, str_type_instruction};
        o_alu_op <= alu_op;
        o_memory_op <= memory_op;
        o_memory_operand_size <= memory_operand_size;
        o_writeback_op <= writeback_op;
        o_register_writeback_addr <= alu_dest_reg;
        o_alu_src_two <= alu_src_immediate;
      end
    end

    DecodeRegisterReadA: begin 
      o_register_read_en <= 1'b1;

      if (i_register_read_valid) begin 
        o_alu_src_a_reg <= i_register_read_data;

        if (!r_type_instruction && !b_type_instruction && !i_ex_stall_send) begin
          decode_state_e <= DecodeRst;
          o_register_read_en <= 1'b0;
          o_ex_decode_ready <= 1'b1;
        end

        if (r_type_instruction) begin
          decode_state_e <= DecodeRegisterReadB;
          o_register_addr <= register_addr_b;
        end 
        
        if (b_type_instruction) begin
          decode_state_e <= DecodeBranchResult;
          o_register_read_en <= 1'b0;
          o_branch_adder_en <= 1'b1;
        end

      end 
    end 

    DecodeRegisterReadB: begin 
      o_register_read_en <= 1'b1;

      if (i_register_read_valid && !i_ex_stall_send) begin
        o_alu_src_b_reg <= i_register_read_data;
        decode_state_e <= DecodeRst;
        o_ex_decode_ready <= 1'b1;
      end
    end 

    DecodeBranchResult: begin 
      if (i_branch_result_valid && !i_ex_stall_send) begin
        o_ex_decode_ready <= 1'b1;
        o_branch_adder_en <= 1'b0;
        decode_state_e <= DecodeRst;
      end
    end 
  endcase

  if (i_rst) begin
    decode_state_e <= DecodeRst;
  end
end 

endmodule