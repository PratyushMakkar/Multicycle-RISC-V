package RV32I_core_utils_package;

  localparam NOOP_INSTRUCTION = 32'h00000000 + I_TYPE_OPCODE;

  /////////// ---------------------------------- DECODE STAGE ----------------------------------- ///////
  localparam logic [3:0] ADD = 4'b0000;
  localparam logic [3:0] SLL = 4'b0001;
  localparam logic [3:0] SLT = 4'b0010;
  localparam logic [3:0] SLTU = 4'b0011;
  localparam logic [3:0] XOR = 4'b0100;
  localparam logic [3:0] SRL = 4'b0101;
  localparam logic [3:0] OR = 4'b0110;
  localparam logic [3:0] AND = 4'b0111;
  localparam logic [3:0] ALU_NOOP  = 4'b1000;

  localparam logic [1:0] BYTE = 2'b00;
  localparam logic [1:0] HALF_WORD = 2'b01;
  localparam logic [1:0] WORD = 2'b10;

  localparam logic [1:0] LOAD = 2'b00;
  localparam logic [1:0] STORE = 2'b01;
  localparam logic [1:0] MEM_NOOP = 2'b11; 

  localparam logic WB_NOOP = 1'b0;
  localparam logic WB_EN   = 1'b1;

  ////// ------------ Instruction opcodes ---------- //////
  // Other Instruction Opcodes
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