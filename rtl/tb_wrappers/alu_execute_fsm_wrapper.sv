module alu_execute_fsm_wrapper (
  input logic [31:0] i_operand_one,
  input logic [31:0] i_operand_two,
  input logic [1:0] alu_op_sel,

  // Expected signals
  input logic [31:0] alu_result_exp,
  input logic carry_out_exp,
  output logic  [31:0] o_result, 

  // Sync signals
  input logic sim_finished_trigger,
  input logic tx_ack_data,
  output logic tx_finished,
  output logic tb_error,

  output logic o_clk
);

  logic clk;
  logic rst, en_alu;
  logic [31:0] operand_one, operand_two, alu_result;
  logic stall_reset;
  logic [1:0] alu_sel;
  logic carry_out, data_valid;

    // The synchronizing signal 
  task synchronizeDut();
    tx_finished <= 1'b1; 
    @(posedge tx_ack_data); 
    tx_finished <= 1'b0; 
  endtask 

  // Generate clock for the design 
  assign o_clk = clk; 
  task toggleClock; 
   forever begin  
    #5 clk = ~clk; 
   end 
  endtask 

  localparam MAX_ATTEMPS = 5;
  rv32_alu_fsm alu_fsm (
    .i_clk(clk),
    .i_rst(rst),
    .i_en_alu(en_alu),
    .i_operand_one(operand_one),
    .i_operand_two(operand_two),
    .i_alu_sel(alu_sel),
    .o_carry_out(carry_out),
    .o_data_valid(data_valid),
    .o_result(alu_result)
  );

  initial begin
    clk <= 1'b0;
    rst <= 1'b0;
    operand_one <= 'd0;
    operand_two <= 'd0;
    alu_sel <= 'd0;
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
      begin
        @(posedge sim_finished_trigger);
      end
    join_any
  end

  task resetDut();
    rst <= 1'b1;
    en_alu <= 1'b0;
    @(posedge clk);
    rst <= 1'b0;
  endtask
  logic debug_signal; 
  task driveStimulus();
    logic [31:0] alu_result_ff;
    logic carry_out_result_ff;

    resetDut();
    forever begin
      @(posedge clk);
      en_alu <= 1'b1;
      operand_one <= i_operand_one;
      operand_two <= i_operand_two;
      alu_sel <= alu_op_sel;
      fork 
        begin
          @(posedge data_valid);
          @(posedge clk);
          alu_result_ff = alu_result;
          carry_out_result_ff = carry_out_exp;
        end
        begin
          repeat (MAX_ATTEMPS) @(posedge clk);
        end
      join_any
      if (!data_valid) tb_error <= 1'b1;
      if (alu_result_exp != alu_result_ff) tb_error <= 1'b1;
      if (carry_out != carry_out_exp) tb_error <= 1'b1;
      o_result <= alu_result;
      synchronizeDut();
      resetDut();
    end
  endtask

endmodule