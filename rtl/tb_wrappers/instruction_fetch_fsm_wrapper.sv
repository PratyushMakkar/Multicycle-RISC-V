module instruction_fetch_fsm_wrapper (
  input logic [2:0] i_operation_code,
  input logic [8:0] i_cycle_length,

  output logic o_debug_instruction_latch_en,
  output logic [31:0] o_debug_instruction_fetch,
  output logic [31:0] o_debug_instruction_fetch_pc,
  output logic o_debug_instruction_wr_valid,
  output logic o_debug_clk,

  input logic i_rx_continue,
  output logic o_tx_complete
);

localparam logic [2:0] OPERATION_CODE_LOAD_INSTRUCTION = 3'b000;
localparam logic [2:0] OPERATION_CODE_INSTRUCTION_FETCH = 3'b001;
localparam logic [2:0] OPERATION_CODE_END_SIM = 3'b10;
localparam logic [2:0] OPERATION_CODE_RESET_SIM = 3'b11;

logic debug_clk;
logic debug_rst;
logic [31:0] debug_branch_pc;
logic debug_branch_miss;
logic debug_decode_ready;
logic debug_instruction_wr_en;
logic [31:0] debug_instruction_wr_addr;
logic [31:0] debug_instruction_wr_data;
logic [31:0] debug_fetch_instruction;
logic [31:0] debug_fetch_instruction_pc;

always @(debug_clk) begin
  o_debug_clk <= debug_clk;
end

RV32I_instruction_fetch_stage RV32I_FETCH_STAGE (
  .i_clk(debug_clk),
  .i_rst(debug_rst),
  .i_branch_pc(debug_branch_pc),
  .i_branch_miss(debug_branch_miss),
  .i_decode_ready(debug_decode_ready),
  .o_instruction_latch_en(o_debug_instruction_latch_en),
  .o_fetch_instruction(o_debug_instruction_fetch),
  .o_fetch_instruction_pc(o_debug_instruction_fetch_pc),

  .i_instruction_wr_en(debug_instruction_wr_en),
  .i_instruction_wr_addr(debug_instruction_wr_addr),
  .i_instruction_wr_data(debug_instruction_wr_data),
  .o_instruction_wr_valid(o_debug_instruction_wr_valid)
);

task initializeClock();
  debug_clk = 1'b0;
  forever begin
    #5 debug_clk = ~debug_clk;
  end
endtask

task loadInstruction();
  bit [8:0] instruction_count;
  
  instruction_count = i_cycle_length;
  @(posedge debug_clk);
  debug_instruction_wr_en <= 1'b1;
  for (integer instruction_mem = 0; instruction_mem <= instruction_count; ++instruction_mem) begin
    debug_instruction_wr_data <= instruction_mem;
    debug_instruction_wr_addr <= instruction_mem;

    @(posedge o_debug_instruction_wr_valid);
    @(posedge debug_clk);
  end
  debug_instruction_wr_en <= 1'b0;
endtask

task resetDut;
  debug_rst <= 1'b1;
  o_tx_complete <= 1'b0;
  @(posedge debug_clk);
  debug_rst <= 1'b0;
endtask

task begin_test();
  bit[8:0] instruction_count;
  forever begin
    if (i_operation_code == OPERATION_CODE_LOAD_INSTRUCTION) loadInstruction();
    else if (i_operation_code == OPERATION_CODE_INSTRUCTION_FETCH) begin
      instruction_count = i_cycle_length;
      repeat (instruction_count) begin 
        @(posedge debug_clk);
      end
    end
    else if (i_operation_code == OPERATION_CODE_RESET_SIM) resetDut();
    else if (i_operation_code == OPERATION_CODE_END_SIM) disable fork;

    o_tx_complete = 1'b1;
    @(posedge i_rx_continue);
    o_tx_complete = 1'b0;
  end
endtask

initial begin
  debug_rst <= 1'b0;
  debug_branch_miss <= 1'b0;
  debug_branch_pc <= 'd0;
  debug_decode_ready <= 1'b0;
  debug_instruction_wr_en <= 1'b0;
  debug_instruction_wr_addr <= 'd0;
  debug_instruction_wr_data <= 'd0;

  fork
    initializeClock();
    resetDut();
  join_any
  fork
    begin_test();
  join_any
end

endmodule