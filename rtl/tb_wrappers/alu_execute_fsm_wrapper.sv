module alu_execute_fsm_wrapper (
  input logic [31:0] i_operand_one,
  input logic [31:0] i_operand_two,
  input logic [31:0] alu_result_exp,
  input logic carry_out_exp,
  input logic [1:0] alu_op_sel,
  input logic tx_ack_data,
  output logic tx_finished,
  output logic tb_error,
  output logic clk,
);

  logic clk;
  logic rst;
  logic [31:0] operand_one, operand_two, alu_result;
  logic stall_reset;
  logic [1:0] alu_sel;
  logic carry_out, data_valid;

  localparam MAX_ATTEMPS = 8;
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
    tb_error <= 1'b0;
    tx_finished <= 1'b0;
    fork
      begin : toggle_clk_thread
        toggleClock();
      end
      begin : drive_stim_thread
        driveStimulus();
      end
      begin : tb_error_thread
        @(posedge tb_error);
      end
    join_any
    disable fork;
  end

  task toggleClock;
   always #5 clk = ~clk;
  endtask

  task driveStimulus();
    forever begin
      @(posedge clk);
      operand_one <= i_operand_one;
      operand_two <= i_operand_two;
      alu_sel <= alu_op_sel;
      stall_reset <= 1'b1;
      fork 
        @(posedge o_data_valid);
        repeat (MAX_ATTEMPS) @(posedge clk);
      join_any
      if (!o_data_valid) tb_error <= 1'b1;
      if (alu_result_exp != alu_result) tb_error <= 1'b1;
      if (carry_out != carry_out_exp) tb_error <= 1'b1;
      tx_finished <= 1'b1;
      @(posedge tx_ack_data);
    end
  endtask
endmodule