module tb_multiplier_shift_controlpath (
  output logic o_complete,
  output logic o_clk
);

logic execute_en, multiplier_en;
logic clk, rst;
logic [2:0] execute_shifter_opcode;
logic [31:0] execute_operand_one;
logic [31:0] execute_operand_two;
logic execute_data_valid;
logic [31:0] execute_data_result;

logic [15:0] multiplier_operand_one;
logic [15:0] multiplier_operand_two;
logic multiplier_valid;
logic [31:0] multiplier_result;

always @(*) begin 
  if (multiplier_en) begin
    repeat (2) @(posedge clk);
    multiplier_result <= multiplier_operand_one * multiplier_operand_two;
    multiplier_valid <= 1'b1;
    @(posedge clk);
    multiplier_valid <= 1'b0;
  end
end

rv32I_multipler_shift_controlpath CONTROLPATH_INST (
  .i_clk(clk),
  .i_rst(rst),

  .i_execute_en(execute_en),
  .i_execute_shifter_opcode(execute_shifter_opcode),
  .i_execute_operand_one(execute_operand_one),
  .i_execute_operand_two(execute_operand_two),
  .o_execute_data_valid(execute_data_valid),
  .o_execute_data_result(execute_data_result),

  .o_multiplier_en(multiplier_en),
  .o_multiplier_operand_one(multiplier_operand_one),
  .o_multiplier_operand_two(multiplier_operand_two),
  .i_multiplier_valid(multiplier_valid),
  .i_multiplier_result(multiplier_result)
);

task toggle_clock();
  clk <= 0;
 forever # 5 clk <= ~clk;
endtask

initial begin
  fork
    toggle_clock;
    begin
      o_complete <= 1'b0;
      rst <= 1'b1;
      @(posedge clk);

      rst <= 1'b0;
      execute_shifter_opcode <= 4'b0001;
      execute_en <= 1'b1;
      execute_operand_one <= 32'h0104F82;
      execute_operand_two <= 12;
      @(posedge execute_data_valid);
      @(posedge clk);

      rst <= 1'b1;
      @(posedge clk);

      rst <= 1'b0;
      execute_shifter_opcode <= 4'b0110;
      execute_en <= 1'b1;
      execute_operand_one <= 32'hF1040F82;
      execute_operand_two <= 12;
      @(posedge execute_data_valid);
      @(posedge clk);

      o_complete <= 1'b1;
    end
  join_none
end

assign o_clk = clk;
endmodule