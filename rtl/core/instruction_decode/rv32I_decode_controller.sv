module rv32I_decode_controller #(parameter INSTRUCTION_WIDTH = 32, parameter WORD_SIZE = 32) (
  input logic i_clk,
  input logic i_rst,

  input logic i_pause,
  input logic [INSTRUCTION_WIDTH-1:0] i_fetch_instruction,
  output logic o_invalid_instruction,

  output logic o_opcode_latch_valid,
  output logic o_i_type_opcode_instr,
  output logic o_r_type_opcode_instr,
  output logic o_b_type_opcode_instr,
  output logic o_ld_type_opcode_instr,
  output logic o_str_type_opcode_instr,

  // ----------- EX Stage Operands -------------- //
  output logic o_carry_in,
  output logic o_signed_operand,
  output logic o_pc_operand, 
  output RV32I_core_utils_package::alu_op_t o_alu_op,
  output logic [WORD_SIZE-1:0] o_alu_src_immediate,
  output logic [4:0] o_alu_src_a_reg,
  output logic [4:0] o_alu_src_b_reg,
  output logic [4:0] o_alu_dest_reg,

  output logic o_branch_beq_test,  // If branch adder op is Add, then if its NE/EQ //
  
  // --------- Memory Stage Pipeline Signals ----------- //
  output RV32I_core_utils_package::memory_op_t o_memory_op,
  output RV32I_core_utils_package::memory_size_t o_memory_operand_size,

  // ----------- WB Stage Operands -------------- //
  output RV32I_core_utils_package::writeback_op_t o_writeback_op
);

// ------------- FSM Control Signals ----------------- //
localparam OPCODE_LATCH = 2'b01;
localparam OPERAND_LATCH = 2'b10; 

logic [1:0] decode_state;
logic instruction_opcode_latch_en, instruction_operand_latch_en;
assign {instruction_operand_latch_en, instruction_opcode_latch_en} = decode_state;

assign o_opcode_latch_valid = ~instruction_opcode_latch_en;
always_ff @(posedge i_clk) begin
  if (~i_pause) decode_state <= ~decode_state;
  if (i_rst) decode_state <= OPCODE_LATCH;
end

// ----------------------------- DECODER FIRST STAGE ----------------------------//
wire [3:0] instr_func   = i_fetch_instruction[14:12];
wire [6:0] instr_opcode = i_fetch_instruction[6:0];
wire [6:0] instr_suffix_func = i_fetch_instruction[31:25];

wire lui_opcode = (instr_opcode == LUI_OPCODE);
wire auipc_opcode = (instr_opcode == AUIPC_OPCODE);

assign o_i_type_opcode_instr = (instr_opcode == I_TYPE_OPCODE | lui_opcode | auipc_opcode);
assign o_r_type_opcode_instr = (instr_opcode == R_TYPE_OPCODE);
assign o_b_type_opcode_instr = (instr_opcode == B_TYPE_OPCODE);
assign o_ld_type_opcode_instr = (instr_opcode == LD_TYPE_OPCDOE);
assign o_str_type_opcode_instr = (instr_opcode == STR_TYPE_OPCODE);

// -------- I-Type-Decoding ------------ //
always_ff @(posedge i_clk) begin : LATCHING_INSTRUCTIONS_OPCODE_STAGE
  if (instruction_opcode_latch_en) begin

    o_i_addi_instr  <= (instr_func == I_ADDI_FUNC) & o_i_type_opcode_instr;
    o_i_sltiu_instr <= (instr_func == I_SLTIU_FUNC) & o_i_type_opcode_instr;
    o_i_slti_instr  <= (instr_func == I_SLTI_FUNC) & i_type_opcode_instr;
    o_i_ori_instr   <= (instr_func == I_ORI_FUNC) & o_i_type_opcode_instr;
    o_i_xori_instr  <= (instr_func == I_XORI_FUNC) & o_i_type_opcode_instr;
    o_i_andi_instr  <= (instr_func == I_ANDI_FUNC) & o_i_type_opcode_instr;

    o_i_slli_instr  <= (instr_func == I_SLLI_FUNC) & o_i_type_opcode_instr & (instr_suffix_func == 7'b0000000);
    o_i_srli_instr  <= (instr_func == I_SRLI_FUNC)  & o_i_type_opcode_instr & (instr_suffix_func == 7'b0000000);
    o_i_srai_instr  <= (instr_func == I_SRAI_FUNC)  & o_i_type_opcode_instr & (instr_suffix_func == 7'b0100000);

    o_auipc_instr <= auipc_opcode;
    o_lui_instr <= lui_opcode;

    // -------- R-Type-Decoding ------------ //
    o_r_add_instr <= (instr_func == R_ADD_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
    o_r_sub_instr <= (instr_func == R_SUB_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0100000);
    o_r_xor_instr <= (instr_func == R_XOR_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
    o_r_or_instr  <= (instr_func == R_OR_FUNC)  & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
    o_r_and_instr <= (instr_func == R_AND_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
    o_r_srl_instr <= (instr_func == R_SRL_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
    o_r_sra_instr <= (instr_func == R_SRA_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0100000);
    o_r_sll_instr <= (instr_func == R_SLL_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
    o_r_slt_instr <= (instr_func == R_SLT_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
    o_r_sltu_instr <= (instr_func == R_SLTU_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);

    // -------- B-Type-Decoding ------------ //
    o_b_beq_instr <= (instr_func == B_BEQ_FUNC) & o_b_type_opcode_instr;
    o_b_bne_instr <= (instr_func == B_BNE_FUNC) & o_b_type_opcode_instr;
    o_b_blt_instr <= (instr_func == B_BLT_FUNC) & o_b_type_opcode_instr;
    o_b_bge_instr <= (instr_func == B_BGE_FUNC) & o_b_type_opcode_instr;
    o_b_bltu_instr <= (instr_func == B_BLTU_FUNC) & o_b_type_opcode_instr;
    o_b_bgeu_instr <= (instr_func == B_BGEU_FUNC) & o_b_type_opcode_instr;

    // -------- LOAD/STORE-Type-Decoding ------------ //
    o_ld_lb_instr <= (instr_func == LD_LB_FUNC) & o_ld_type_opcode_instr;
    o_ld_lh_instr <= (instr_func == LD_LH_FUNC) & o_ld_type_opcode_instr;
    o_ld_lw_instr <= (instr_func == LD_LW_FUNC) & o_ld_type_opcode_instr;
    o_ld_lbu_instr <= (instr_func == LD_LBU_FUNC) & o_ld_type_opcode_instr;
    o_ld_lhu_instr <= (instr_func == LD_LHU_FUNC) & o_ld_type_opcode_instr;

    o_st_sb_instr <= (instr_func == ST_SB_FUNC) & o_str_type_opcode_instr;
    o_st_sh_instr <= (instr_func == ST_SH_FUNC) & o_str_type_opcode_instr;
    o_st_sw_instr <= (instr_func == ST_SW_FUNC) & o_str_type_opcode_instr;
  end
end

// ----------------------------- DECODER SECOND STAGE ----------------------------//
logic [11:0] lower_immediate = i_fetch_instruction[31:20];
logic [4:0] shamt            = i_fetch_instruction[24:20];
logic [19:0] upper_immediate = i_fetch_instruction[31:12];
logic [4:0] alu_src_a_reg    = i_fetch_instruction[19:15];
logic [4:0] alu_src_b_reg    = i_fetch_instruction[24:20];
logic [4:0] alu_dest_reg     = i_fetch_instruction[11:7];

wire sign_extend_lower_imm = (o_i_addi_instr | o_i_slti_instr | o_i_sltiu_instr | o_i_ori_instr | o_i_xori_instr | o_i_andi_instr);
always_ff @(posedge i_clk) begin : ALU_EXECUTE_STAGE_SIGNALS
  o_carry_in <= 1'b0;
  o_signed_operand <= 1'b0;
  o_alu_op <= ALU_NOOP;
  o_alu_src_immediate <= 32'd0
  o_alu_src_b_reg <= 5'd0;
  o_pc_operand <= 1'b0;

  o_alu_src_a_reg <= alu_src_a_reg;
  o_alu_src_b_reg <= alu_src_b_reg;
  o_alu_dest_reg <= alu_src_dest_reg;

  o_memory_op <= MEM_NOOP;
  o_memory_operand_size <= BYTE;

  o_writeback_op <= WB_EN;

  if (o_i_type_opcode_instr) begin
    if (sign_extend_lower_imm) o_alu_src_immediate <= {{20{lower_immediate[11]}}, lower_immediate};
    else if (o_i_slli_instr | o_i_srli_instr | o_i_srai_instr) o_alu_src_immediate <= {{27{1'b0}}, shamt};
    else if (o_auipc_instr | o_lui_instr) o_alu_src_immediate <= {upper_immediate, {12{1'b0}}};

    if (o_i_slti_instr | o_i_srai_instr) o_signed_operand <= 1'b1;
    if (o_auipc_instr) o_pc_operand <= 1'b1;

    if (o_lui_instr) o_alu_op <= ALU_NOOP;
    else o_alu_op <= {1'b0, instr_func};
  end

  if (o_r_type_opcode_instr) begin
    if (o_r_slt_instr | o_r_sra_instr) o_signed_operand <= 1'b1;
    if (o_r_sub_instr) o_carry_in <= 1'b1;

    o_alu_op <= {1'b0, instr_func};
  end

  if (o_b_type_opcode_instr) begin
    o_alu_src_immediate <= {{20{lower_immediate[11]}}, lower_immediate[10:5], alu_dest_reg[0], alu_dest_reg[4:1], 1'b0};
    if (o_b_bge_instr | o_b_bgeu_instr) begin
        o_alu_src_a_reg <= alu_src_b_reg;
        o_alu_src_b_reg <= alu_src_a_reg;
    end

    if (o_b_bge_instr | o_b_blt_instr) o_signed_operand <= 1'b1;
    if (o_b_bge_instr | o_b_blt_instr | o_b_bge_instr | o_b_bgeu_instr) o_alu_op <= SLT;
    else begin 
      o_alu_op <= ADD;
      o_branch_beq_test <= o_b_beq_instr; 
    end
  end

  if (o_ld_type_opcode_instr) begin
    o_alu_src_immediate <= {{20{lower_immediate[11]}}, lower_immediate};
    o_alu_op <= ADD:
  end

  if (o_str_type_opcode_instr) begin
    o_alu_src_immediate <= {{20{lower_immediate[11]}}, lower_immediate[11:5], alu_src_dest_reg};
    o_writeback_op <= WB_NOOP;
    o_alu_op <= ADD:
  end

  if (o_ld_type_opcode_instr | o_str_type_opcode_instr) begin : MEMORY_OPERAND_ENCODE
    {o_signed_operand, o_memory_operand_size} <= instr_func;
    o_memory_op <= {1'b0, instr_opcode[5]};
  end 
end

endmodule


