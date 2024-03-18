module RV32I_decode_stage #(
  parameter WORD_SIZE = 32, 
  parameter INSTRUCTION_WIDTH = 32) 
(
  input logic i_clk,
  input logic i_rst,
  input logic i_stall,
  input logic [INSTRUCTION_WIDTH-1:0] instr_register,
  
  // --------- Register File Signals From Writeback Stage ----------- //
  input logic i_rf_wr_en,
  input logic [4:0] i_rf_wr_addr,
  input logic [WORD_SIZE-1:0] i_rf_wr_data,
  output logic o_wr_valid,

  // --------- Execute Stage Pipeline Signals ----------- //
  output RV32I_core_utils_package::alu_op_t o_alu_op,
  output logic [WORD_SIZE-1:0] o_alu_src_one,
  output logic [WORD_SIZE-1:0] o_alu_src_two,

  // --------- Memory Stage Pipeline Signals ----------- //
  output RV32I_core_utils_package::memory_op_t o_memory_op,
  output RV32I_core_utils_package::memory_size_t o_memory_operand_size,

  // --------- Writeback Stage Pipeline Signals ----------- //
  output RV32I_core_utils_package::writeback_op_t o_writeback_op,
  output logic [4:0] o_rf_wr_addr
);

// ----------------------------- DECODER----------------------------//
wire [3:0] instr_func   = instr_register[14:12];
wire [6:0] instr_opcode = instr_register[6:0];
wire [6:0] instr_suffix_func = instr_register[31:25];

wire i_type_opcode_instr = (instr_opcode == I_TYPE_OPCODE);
wire r_type_opcode_instr = (instr_opcode == R_TYPE_OPCODE);
wire b_type_opcode_instr = (instr_opcode == B_TYPE_OPCODE);
wire ld_type_opcode_instr = (instr_opcode == LD_TYPE_OPCDOE);
wire str_type_opcode_instr = (instr_opcode == STR_TYPE_OPCODE);

// -------- I-Type-Decoding ------------ //
wire i_addi_instr  = (instr_func == I_ADDI_FUNC) && i_type_opcode_instr;
wire i_slti_instr  = (instr_func == I_SLTI_FUNC) && i_type_opcode_instr;
wire i_sltiu_instr = (instr_func == I_SLTIU_FUNC) && i_type_opcode_instr;
wire i_ori_instr   = (instr_func == I_ORI_FUNC) && i_type_opcode_instr;
wire i_xori_instr  = (instr_func == I_XORI_FUNC) && i_type_opcode_instr;
wire i_andi_instr  = (instr_func == I_ANDI_FUNC) && i_type_opcode_instr;

wire i_slli_instr  = (instr_func == I_SLLI_FUNC) && i_type_opcode_instr && (instr_suffix_func == 7'b0000000);
wire i_srli_instr  = (instr_func == I_SRLI_FUNC)  && i_type_opcode_instr && (instr_suffix_func == 7'b0000000);
wire i_srai_instr  = (instr_func == I_SRAI_FUNC)  && i_type_opcode_instr && (instr_suffix_func == 7'b0100000);

// -------- R-Type-Decoding ------------ //
wire r_add_instr = (instr_func == R_ADD_FUNC) && r_type_opcode_instr && (instr_suffix_func == 7'b0000000);
wire r_sub_instr = (instr_func == R_SUB_FUNC) && r_type_opcode_instr && (instr_suffix_func == 7'b0100000);
wire r_xor_instr = (instr_func == R_XOR_FUNC) && r_type_opcode_instr && (instr_suffix_func == 7'b0000000);
wire r_or_instr  = (instr_func == R_OR_FUNC)  && r_type_opcode_instr && (instr_suffix_func == 7'b0000000);
wire r_and_instr = (instr_func == R_AND_FUNC) && r_type_opcode_instr && (instr_suffix_func == 7'b0000000);
wire r_srl_instr = (instr_func == R_SRL_FUNC) && r_type_opcode_instr && (instr_suffix_func == 7'b0000000);
wire r_sra_instr = (instr_func == R_SRA_FUNC) && r_type_opcode_instr && (instr_suffix_func == 7'b0100000);
wire r_sll_instr = (instr_func == R_SLL_FUNC) && r_type_opcode_instr && (instr_suffix_func == 7'b0000000);
wire r_slt_instr = (instr_func == R_SLT_FUNC) && r_type_opcode_instr && (instr_suffix_func == 7'b0000000);
wire r_sltu_instr = (instr_func == R_SLTU_FUNC) && r_type_opcode_instr && (instr_suffix_func == 7'b0000000);

// -------- B-Type-Decoding ------------ //
wire b_beq_instr = (instr_func == B_BEQ_FUNC) && b_type_opcode_instr;
wire b_bne_instr = (instr_func == B_BNE_FUNC) && b_type_opcode_instr;
wire b_blt_instr = (instr_func == B_BLT_FUNC) && b_type_opcode_instr;
wire b_bge_instr = (instr_func == B_BGE_FUNC) && b_type_opcode_instr;
wire b_bltu_instr = (instr_func == B_BLTU_FUNC) && b_type_opcode_instr;
wire b_bgeu_instr = (instr_func == B_BGEU_FUNC) && b_type_opcode_instr;

// -------- LOAD/STORE-Type-Decoding ------------ //
wire ld_lb_instr = (instr_func == LD_LB_FUNC) && ld_type_opcode_instr;
wire ld_lh_instr = (instr_func == LD_LH_FUNC) && ld_type_opcode_instr;
wire ld_lw_instr = (instr_func == LD_LW_FUNC) && ld_type_opcode_instr;
wire ld_lbu_instr = (instr_func == LD_LBU_FUNC) && ld_type_opcode_instr;
wire ld_lhu_instr = (instr_func == LD_LHU_FUNC) && ld_type_opcode_instr;

wire st_sb_instr = (instr_func == ST_SB_FUNC) && str_type_opcode_instr;
wire st_sh_instr = (instr_func == ST_SH_FUNC) && str_type_opcode_instr;
wire st_sw_instr = (instr_func == ST_SW_FUNC) && str_type_opcode_instr;

// -------------------------------------- Pipeline Signals --------------------------------//
// -------- Execute Register Signals ------------ //
RV32I_core_utils_package::alu_op_t alu_op; 
wire [WORD_SIZE-1:0] alu_op_src_one;
wire [WORD_SIZE-1:0] alu_op_src_two;

// -------- Memory Register Signals ------------ //
RV32I_core_utils_package::memory_op_t memory_op;
RV32I_core_utils_package::memory_size_t memory_operand_size;

// -------- Writeback Register Signals ------------ //
RV32I_core_utils_package::writeback_op_t writeback_op;

// ---------------------------------- ALU OP Decoding ------------------------------//
always_comb begin
  case (1) 
    (r_add_instr || i_addi_instr) : alu_op = RV32I_core_utils_package::ADD;
    (r_sub_instr || b_beq_instr || b_bne_instr) : alu_op = RV32I_core_utils_package::SUB;
    (r_slt_instr  || i_slti_instr || b_blt_instr || b_bge_instr) : alu_op = RV32I_core_utils_package::SLT;
    (r_sltu_instr || i_sltiu_instr || b_bltu_instr || b_bgeu_instr) : alu_op = RV32I_core_utils_package::SLTU;
    (r_xor_instr || i_xori_instr) : alu_op = RV32I_core_utils_package::XOR;
    (r_or_instr  || i_ori_instr)  : alu_op = RV32I_core_utils_package::OR;
    (r_and_instr || i_andi_instr) : alu_op = RV32I_core_utils_package::AND;
    (r_sra_instr || i_srai_instr) : alu_op = RV32I_core_utils_package::AR_SHIFT;
    (r_sll_instr || i_slli_instr) : alu_op = RV32I_core_utils_package::LL_SHIFT;
    (r_srtl_instr || i_srli_instr) : alu_op = RV32I_core_utils_package::LR_SHIFT;
    default: alu_op = RV32I_core_utils_package::ALU_NOOP;
  endcase
end


// ----------------------------- REGFILE DECODING ----------------------------//
wire i_file_wr_en = i_rf_wr_en;

logic i_file_rd_en;
logic [4:0] i_file_rd_addr;
logic [31:0] i_file_rd_data;
logic rd_ready, wr_ready;

/**
  Reads/Writes are 2 cycle operations.
**/
RV32I_register_file REGFILE_INST (     // Instantiated register file
  .i_clk(i_clk),
  .i_rst(i_rst),
  .i_rd_en(i_file_rd_en),
  .i_reg_addr(i_file_rd_addr), 
  .o_reg_data(i_file_rd_data),

  .i_wr_en(i_file_wr_en),
  .i_dest_addr(i_rf_wr_data),
  .i_dest_reg_data(i_rf_wr_data),

  .o_rd_valid(rd_ready),
  .o_wr_valid(wr_ready)
); 

assign o_wr_valid = wr_ready;
endmodule