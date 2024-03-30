package rv32I_core_package;

typedef struct {
  logic [31:0] instruction;
  logic [31:0] pc;
} instruction_fetch_t;


endpackage