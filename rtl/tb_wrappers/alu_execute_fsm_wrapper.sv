module alu_execute_fsm_wrapper();
  logic clk;
  logic rst;
  logic [31:0] operand_one, operand_two, alu_result;
  logic stall_reset;
  logic [1:0] alu_sel;
  logic carry_out, data_valid;

  rv32_alu_fsm alu_fsm (
    .i_clk(clk),
    .i_rst(rst),
    .i_operand_one(operand_one),
    .i_operand_two(operand_two),
    .i_stall_reset(stall_reset),
    .i_alu_sel(alu_sel),
    .o_carry_out(carry_out),
    .o_data_valid(data_valid),
    .o_result(alu_result)
  );

  initial begin
    rst <= 1'b0;
    operand_one <= 'd0;
    operand_two <= 'd0;
    stall_reset <= 'd0;
    alu_sel <= 'd0;
    carry_out <= 'd0;
    data_valid <= 'd0;
    alu_result <= 'd0;
    fork
      toggleClock();
      driveStimulus();
    join_any
  end

  task toggleClock;
   always #5 clk = ~clk;
  endtask

  task driveStimulus();

  endtask

endmodule