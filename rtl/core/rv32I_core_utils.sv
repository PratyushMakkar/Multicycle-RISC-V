package RV32I_core_utils_package;

  localparam NOOP_INSTRUCTION = 32'h00000000 + I_TYPE_OPCODE;

  /////////// ---------------------------------- DECODE STAGE ----------------------------------- ///////
  typedef enum logic [3:0] {ALU_NOOP = 4'b000, ADD, OR, AND,  
                            XOR, LL_SHIFT, LR_SHIFT, AR_SHIFT, SUB, SLT, SLTU, EQ_ZERO} alu_op_t; // EQ_ZERO just tests if the value is equal to zero.
  typedef enum logic [1:0] {BYTE, HALF_WORD, WORD} memory_size_t;
  typedef enum logic [1:0] {MEM_NOOP = 0, LOAD, STORE} memory_op_t;
  typedef enum logic       {WB_NOOP = 1'b0, WB} writeback_op_t;

  ////// ------------ Instruction opcodes ---------- //////
  // Special instruction opcodes
  localparam LUI_OPCODE   = 7'b0110111;
  localparam AUIPC_OPCODE = 7'b0010111;
  localparam JAL_OPCODE   = 7'b1101111;
  localparam JALR_OPCODE  = 7'b1100111;

  localparam B_TYPE_OPCODE     = 7'b1100011;
  localparam I_TYPE_OPCODE     = 7'b0010011;
  localparam R_TYPE_OPCODE     = 7'b0110011;
  localparam LD_TYPE_OPCODE    = 7'b0000011;
  localparam STR_TYPE_OPCODE   = 7'b0100011;

  localparam USER_TYPE_INSTRUCTION  = 7'b0001111;
  localparam CSR_TYPE_INSTRUCTION   = 7'b1110011;

  ////// -------------- I-Type-Instruction-Functions ---------- //////
  localparam I_ADDI_FUNC  = 3'b000;
  localparam I_SLTI_FUNC  = 3'b010;
  localparam I_SLTIU_FUNC = 3'b011;
  localparam I_XORI_FUNC  = 3'b100;
  localparam I_ORI_FUNC   = 3'b110;
  localparam I_ANDI_FUNC  = 3'b111;

  localparam I_SLLI_FUNC  = 3'b001;
  localparam I_SRLI_FUNC  = 3'b101;
  localparam I_SRAI_FUNC  = 3'b101;

  ////// ------------ R-Type-Instruction-Functions ---------- //////
  localparam R_ADD_FUNC   = 3'b000;
  localparam R_SUB_FUNC   = 3'b000;
  localparam R_XOR_FUNC   = 3'b100;
  localparam R_OR_FUNC    = 3'b110;
  localparam R_AND_FUNC   = 3'b111; 
  localparam R_SRL_FUNC   = 3'b101;
  localparam R_SRA_FUNC   = 3'b101;
  localparam R_SLL_FUNC   = 3'b001;
  localparam R_SLT_FUNC   = 3'b010;
  localparam R_SLTU_FUNC  = 3'b011;

  //////---------- B-Type-Instruction-Functions ---------- //////
  localparam B_BEQ_FUNC = 3'b000;
  localparam B_BNE_FUNC = 3'b001;
  localparam B_BLT_FUNC = 3'b100;
  localparam B_BGE_FUNC = 3'b101;
  localparam B_BLTU_FUNC = 3'b110;
  localparam B_BGEU_FUNC = 3'b111;

  //////---------- Load/Store-Type-Instruction-Functions ---------- //////
  localparam LD_LB_FUNC  = 3'b000;
  localparam LD_LH_FUNC  = 3'b001;
  localparam LD_LW_FUNC  = 3'b010;
  localparam LD_LBU_FUNC = 3'b100;
  localparam LD_LHU_FUNC = 3'b101;

  localparam ST_SB_FUNC = 3'b000;
  localparam ST_SH_FUNC = 3'b001;
  localparam ST_SW_FUNC = 3'b010;
  
endpackage