module rv32I_decode #(parameter INSTRUCTION_WIDTH = 32, parameter WORD_SIZE = 32) (

  input logic [INSTRUCTION_WIDTH-1:0] i_fetch_instruction,
  output logic o_invalid_instruction,

  output logic o_i_type_opcode_instr,
  output logic o_r_type_opcode_instr,
  output logic o_b_type_opcode_instr,
  output logic o_ld_type_opcode_instr,
  output logic o_str_type_opcode_instr,

  // ----------- EX / Branch Adder Stage Operands -------------- //
  output logic o_pc_operand,
  output logic [3:0] o_alu_op,
  output logic [WORD_SIZE-1:0] o_alu_src_immediate,
  output logic [4:0] o_alu_src_a_reg,
  output logic [4:0] o_alu_src_b_reg,
  output logic [4:0] o_alu_dest_reg,

  output logic [2:0] o_branch_op,
  
  // --------- Memory Stage Pipeline Signals ----------- //
  output logic o_memory_sign_extend,
  output logic [1:0] o_memory_op,
  output logic [1:0] o_memory_operand_size,

  // ----------- WB Stage Operands -------------- //
  output logic o_writeback_op
);

// ----------------------------- DECODER FIRST STAGE ----------------------------//
wire [3:0] instr_func   = i_fetch_instruction[14:12];
wire [6:0] instr_opcode = i_fetch_instruction[6:0];
wire [6:0] instr_suffix_func = i_fetch_instruction[31:25];

wire lui_opcode = (instr_opcode == LUI_OPCODE);
wire auipc_opcode = (instr_opcode == AUIPC_OPCODE);

assign o_i_type_opcode_instr = (instr_opcode == I_TYPE_OPCODE | lui_opcode | auipc_opcode);
assign o_r_type_opcode_instr = (instr_opcode == R_TYPE_OPCODE);
assign o_b_type_opcode_instr = (instr_opcode == B_TYPE_OPCODE);
assign o_ld_type_opcode_instr = (instr_opcode == LD_TYPE_OPCODE);
assign o_str_type_opcode_instr = (instr_opcode == STR_TYPE_OPCODE);

// -------- I-Type-Decoding ------------ //
wire o_i_addi_instr  = (instr_func == I_ADDI_FUNC) & o_i_type_opcode_instr;
wire o_i_sltiu_instr = (instr_func == I_SLTIU_FUNC) & o_i_type_opcode_instr;
wire o_i_slti_instr  = (instr_func == I_SLTI_FUNC) & i_type_opcode_instr;
wire o_i_ori_instr   = (instr_func == I_ORI_FUNC) & o_i_type_opcode_instr;
wire o_i_xori_instr  = (instr_func == I_XORI_FUNC) & o_i_type_opcode_instr;
wire o_i_andi_instr  = (instr_func == I_ANDI_FUNC) & o_i_type_opcode_instr;

wire o_i_slli_instr  = (instr_func == I_SLLI_FUNC) & o_i_type_opcode_instr & (instr_suffix_func == 7'b0000000);
wire o_i_srli_instr  = (instr_func == I_SRLI_FUNC)  & o_i_type_opcode_instr & (instr_suffix_func == 7'b0000000);
wire o_i_srai_instr  = (instr_func == I_SRAI_FUNC)  & o_i_type_opcode_instr & (instr_suffix_func == 7'b0100000);

wire o_auipc_instr = auipc_opcode;
wire o_lui_instr = lui_opcode;

// -------- R-Type-Decoding ------------ //
wire o_r_add_instr = (instr_func == R_ADD_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
wire o_r_sub_instr = (instr_func == R_SUB_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0100000);
wire o_r_xor_instr = (instr_func == R_XOR_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
wire o_r_or_instr  = (instr_func == R_OR_FUNC)  & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
wire o_r_and_instr = (instr_func == R_AND_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
wire o_r_srl_instr = (instr_func == R_SRL_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
wire o_r_sra_instr = (instr_func == R_SRA_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0100000);
wire o_r_sll_instr = (instr_func == R_SLL_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
wire o_r_slt_instr = (instr_func == R_SLT_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);
wire o_r_sltu_instr = (instr_func == R_SLTU_FUNC) & o_r_type_opcode_instr & (instr_suffix_func == 7'b0000000);

  // -------- B-Type-Decoding ------------ //
wire o_b_beq_instr = (instr_func == B_BEQ_FUNC) & o_b_type_opcode_instr;
wire o_b_bne_instr = (instr_func == B_BNE_FUNC) & o_b_type_opcode_instr;
wire o_b_blt_instr = (instr_func == B_BLT_FUNC) & o_b_type_opcode_instr;
wire o_b_bge_instr = (instr_func == B_BGE_FUNC) & o_b_type_opcode_instr;
wire o_b_bltu_instr = (instr_func == B_BLTU_FUNC) & o_b_type_opcode_instr;
wire o_b_bgeu_instr = (instr_func == B_BGEU_FUNC) & o_b_type_opcode_instr;

  // -------- LOAD/STORE-Type-Decoding ------------ //
wire o_ld_lb_instr = (instr_func == LD_LB_FUNC) & o_ld_type_opcode_instr;
wire o_ld_lh_instr = (instr_func == LD_LH_FUNC) & o_ld_type_opcode_instr;
wire o_ld_lw_instr = (instr_func == LD_LW_FUNC) & o_ld_type_opcode_instr;
wire o_ld_lbu_instr = (instr_func == LD_LBU_FUNC) & o_ld_type_opcode_instr;
wire o_ld_lhu_instr = (instr_func == LD_LHU_FUNC) & o_ld_type_opcode_instr;

wire o_st_sb_instr = (instr_func == ST_SB_FUNC) & o_str_type_opcode_instr;
wire o_st_sh_instr = (instr_func == ST_SH_FUNC) & o_str_type_opcode_instr;
wire o_st_sw_instr = (instr_func == ST_SW_FUNC) & o_str_type_opcode_instr;


// ----------------------------- DECODER SECOND STAGE ----------------------------//
wire [11:0] lower_immediate = i_fetch_instruction[31:20];
wire [4:0] shamt            = i_fetch_instruction[24:20];
wire [19:0] upper_immediate = i_fetch_instruction[31:12];
wire [4:0] alu_src_a_reg    = i_fetch_instruction[19:15];
wire [4:0] alu_src_b_reg    = i_fetch_instruction[24:20];
wire [4:0] alu_dest_reg     = i_fetch_instruction[11:7];

always_comb begin : ALU_EXECUTE_STAGE_SIGNALS
  o_alu_op = ALU_NOOP;
  o_alu_src_immediate = 32'd0;
  o_alu_src_a_reg = 0;
  o_alu_src_b_reg = 0;
  o_alu_dest_reg  = 0;

  o_branch_op = BRANCH_NOOP;
  o_pc_operand = 1'b0;

  o_memory_op = MEM_NOOP;
  o_memory_operand_size = BYTE;

  o_writeback_op = WB_NOOP;

  if (o_i_addi_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = {{20{lower_immediate[11]}}, lower_immediate};
    o_writeback_op = WB_EN;
    o_alu_op = ADD;
  end

  if (o_i_sltiu_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = lower_immediate;
    o_writeback_op = WB_EN;
    o_alu_op = SLTU;
  end

  if (o_i_slti_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = {{20{lower_immediate[11]}}, lower_immediate};;
    o_writeback_op = WB_EN;
    o_alu_op = SLT;
  end

  if (o_i_ori_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = {{20{lower_immediate[11]}}, lower_immediate};;
    o_writeback_op = WB_EN;
    o_alu_op = OR;
  end

  if (o_i_xori_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = {{20{lower_immediate[11]}}, lower_immediate};;
    o_writeback_op = WB_EN;
    o_alu_op = XOR;
  end

  if (o_i_andi_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = {{20{lower_immediate[11]}}, lower_immediate};;
    o_writeback_op = WB_EN;
    o_alu_op = AND;
  end

  if (o_i_slli_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = shamt;
    o_writeback_op = WB_EN;
    o_alu_op = SLL;
  end

  if (o_i_srli_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = shamt;
    o_writeback_op = WB_EN;
    o_alu_op = SRL;
  end

  if (o_i_srai_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = shamt;
    o_writeback_op = WB_EN;
    o_alu_op = SRA;
  end

  if (o_i_auipc_instr) begin
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = upper_immediate;
    o_writeback_op = WB_EN;
    o_alu_op = ADD;
    o_pc_operand = 1'b1;
  end

  if (o_i_lui_instr) begin
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_immediate = upper_immediate;
    o_writeback_op = WB_EN;
    o_alu_op = LUI;
  end

  if (o_r_add_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_writeback_op = WB_EN;
    o_alu_op = ADD;
  end

  if (o_r_sub_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_writeback_op = WB_EN;
    o_alu_op = SUB;
  end

  if (o_r_xor_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_writeback_op = WB_EN;
    o_alu_op = XOR;
  end

  if (o_r_or_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_writeback_op = WB_EN;
    o_alu_op = OR;
  end

  if (o_r_and_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_writeback_op = WB_EN;
    o_alu_op = AND:
  end

  if (o_r_srl_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_writeback_op = WB_EN;
    o_alu_op = SRL;
  end

  if (o_r_sra_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_writeback_op = WB_EN;
    o_alu_op = SRA;
  end

  if (o_r_sll_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_writeback_op = WB_EN;
    o_alu_op = SLL;
  end

  if (o_r_slt_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_writeback_op = WB_EN;
    o_alu_op = SLT:
  end

  if (o_r_sltu_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_dest_reg = alu_dest_reg;
    o_writeback_op = WB_EN;
    o_alu_op = SLTU;
  end

  if (o_b_beq_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_src_immediate = {i_fetch_instruction[31], i_fetch_instruction[7], i_fetch_instruction[30:25], i_fetch_instruction[11:8]};
    o_branch_op = BRANCH_BEQ;
  end

  if (o_b_bne_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_src_immediate = {i_fetch_instruction[31], i_fetch_instruction[7], i_fetch_instruction[30:25], i_fetch_instruction[11:8]};
    o_branch_op = BRANCH_BNE;
  end

  if (o_b_blt_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_src_immediate = {i_fetch_instruction[31], i_fetch_instruction[7], i_fetch_instruction[30:25], i_fetch_instruction[11:8]};
    o_branch_op = BRANCH_BLT;
  end

  if (o_b_bge_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_src_immediate = {i_fetch_instruction[31], i_fetch_instruction[7], i_fetch_instruction[30:25], i_fetch_instruction[11:8]};
    o_branch_op = BRANCH_BGE;
  end

  if (o_b_bltu_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_src_immediate = {i_fetch_instruction[31], i_fetch_instruction[7], i_fetch_instruction[30:25], i_fetch_instruction[11:8]};
    o_branch_op = BRANCH_BLTU;
  end

  if (o_b_bgeu_instr) begin
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_src_immediate = {i_fetch_instruction[31], i_fetch_instruction[7], i_fetch_instruction[30:25], i_fetch_instruction[11:8]};
    o_branch_op = BRANCH_BGEU;
  end

  if (o_ld_lb_instr) begin
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_immediate = {{20{i_fetch_instruction[31]}}, lower_immediate};
    o_alu_op = ADD_MEM;
    o_writeback_op = WB_EN;
    o_memory_op = LOAD:
    o_memory_sign_extend = 1'b1;
    o_memory_operand_size = BYTE;
  end

  if (o_ld_lh_instr) begin
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_immediate = {{20{i_fetch_instruction[31]}}, lower_immediate};
    o_alu_op = ADD_MEM;
    o_writeback_op = WB_EN;
    o_memory_op = LOAD:
    o_memory_sign_extend = 1'b1;
    o_memory_operand_size = HALF_WORD;
  end

  if (o_ld_lw_instr) begin
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_immediate = {{20{i_fetch_instruction[31]}}, lower_immediate};
    o_alu_op = ADD_MEM;
    o_writeback_op = WB_EN;
    o_memory_op = LOAD:
    o_memory_sign_extend = 1'b1;
    o_memory_operand_size = WORD;
  end

  if (o_ld_lbu_instr) begin
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_immediate = {{20{i_fetch_instruction[31]}}, lower_immediate};
    o_alu_op = ADD_MEM;
    o_writeback_op = WB_EN;
    o_memory_op = LOAD:
    o_memory_operand_size = BYTE;
  end

  if (o_ld_lhu_instr) begin
    o_alu_dest_reg = alu_dest_reg;
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_immediate = {{20{i_fetch_instruction[31]}}, lower_immediate};
    o_alu_op = ADD_MEM;
    o_writeback_op = WB_EN;
    o_memory_op = LOAD:
    o_memory_operand_size = HALF_WORD;
  end

  if (o_st_sb_instr) begin
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_immediate = {{20{i_fetch_instruction[31]}}, i_fetch_instruction[31:25], i_fetch_instruction[11:7]}};
    o_alu_op = ADD_MEM;
    o_memory_op = STORE;
  end

  if (o_st_sh_instr) begin
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_immediate = {{20{i_fetch_instruction[31]}}, i_fetch_instruction[31:25], i_fetch_instruction[11:7]}};
    o_alu_op = ADD_MEM;
    o_memory_op = STORE;
  end

  if (o_st_sw_instr) begin
    o_alu_src_b_reg = alu_src_b_reg;
    o_alu_src_a_reg = alu_src_a_reg;
    o_alu_src_immediate = {{20{i_fetch_instruction[31]}}, i_fetch_instruction[31:25], i_fetch_instruction[11:7]}};
    o_alu_op = ADD_MEM;
    o_memory_op = STORE;
  end

assign o_invalid_instruction = 1'b0;
endmodule

