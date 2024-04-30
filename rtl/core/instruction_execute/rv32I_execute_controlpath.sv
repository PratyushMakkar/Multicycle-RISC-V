module rv32I_execute_controlpath (
  input logic i_clk,
  input logic i_rst,

// ------------- ALU Input Interface ------------- //
  input logic i_alu_en,
  input logic [3:0] i_alu_sel,
  input logic [31:0] i_alu_operand_one,
  input logic [31:0] i_alu_operand_two,

// --------- ALU Datapath Interface --------//
  output logic [15:0] o_datapath_operand_one,
  output logic [15:0] o_datapath_operand_two,
  output logic o_datapath_carry_in,
  output logic [1:0] o_datapath_alu_op_sel,
  input logic i_datapath_carry_out,
  input logic [15:0] i_datapath_result,

// --------- Execute Stage Output Interface --------//
  output logic o_alu_carry_out,
  output logic o_alu_data_valid,
  output logic [31:0] o_alu_result
);

logic [2:0] alu_state_counter;
logic [15:0] datapath_result_register;
logic datapath_carry_out_register;

always_ff @(posedge i_clk) begin
  if (i_rst) begin
    alu_state_counter <= 0;
  end

  if (i_alu_en && !i_rst) begin
    alu_state_counter <= (o_alu_data_valid) ? '0: (alu_state_counter + 1'b1);
    datapath_result_register <= i_datapath_result;
    datapath_carry_out_register <= i_datapath_carry_out;
  end
end

always_comb begin
  o_alu_data_valid = 1'b0;
  o_datapath_carry_in = 1'b0;
  o_datapath_alu_op_sel = ADD;

  o_alu_result = {i_datapath_result, datapath_result_register};

  if (i_alu_sel == LUI) begin : alu_state_counter_lui
    o_alu_result = {i_operand_two[19:0], {12{1'b0}}}
    o_alu_data_valid = 1'b1;
  end : alu_state_counter_lui

  
  if (i_alu_sel == SUB) begin : alu_state_counter_sub
    o_datapath_alu_op_sel = ADD;

    if (alu_state_counter == '0) begin 
      o_datapath_carry_in = 1'b1;
      o_datapath_operand_one = i_alu_operand_one[15:0];
      o_datapath_operand_two = ~i_alu_operand_two[15:0];
    end else begin
      o_datapath_carry_in = datapath_carry_out_register;
      o_datapath_operand_one = i_alu_operand_one[31:16];
      o_datapath_operand_two = ~i_alu_operand_two[31:16];
      o_alu_data_valid = 1'b1;
    end 
  end : alu_state_counter_sub


  if (i_alu_sel == ADD) begin : alu_state_counter_add
    o_datapath_alu_op_sel = ADD;
  
    if (alu_state_counter == '0) begin 
      o_datapath_carry_in = 1'b0;
      o_datapath_operand_one = i_alu_operand_one[15:0];
      o_datapath_operand_two = i_alu_operand_two[15:0];
    end else begin
      o_datapath_carry_in = datapath_carry_out_register
      o_datapath_operand_one = i_alu_operand_one[31:16];
      o_datapath_operand_two = i_alu_operand_two[31:16];
      o_alu_data_valid = 1'b1;
    end 
  end : alu_state_counter_add


  if (i_alu_sel == AND) begin : alu_state_counter_and
    o_datapath_alu_op_sel = AND;

    if (alu_state_counter == '0) begin 
      o_datapath_operand_one = i_alu_operand_one[15:0];
      o_datapath_operand_two = i_alu_operand_two[15:0];
    end else begin
      o_datapath_operand_one = i_alu_operand_one[31:16];
      o_datapath_operand_two = i_alu_operand_two[31:16];
      o_alu_data_valid = 1'b1;
    end 
  end : alu_state_counter_and


  if (i_alu_sel == OR) begin : alu_state_counter_or
    o_datapath_alu_op_sel = OR;
    if (alu_state_counter == '0) begin 
      o_datapath_operand_one = i_alu_operand_one[15:0];
      o_datapath_operand_two = i_alu_operand_two[15:0];
    end else begin
      o_datapath_operand_one = i_alu_operand_one[31:16];
      o_datapath_operand_two = i_alu_operand_two[31:16];
      o_alu_data_valid = 1'b1;
    end 
  end : alu_state_counter_or


  if (i_alu_sel == XOR) begin : alu_state_counter_xor
    o_datapath_alu_op_sel = XOR;
    if (alu_state_counter == '0) begin 
      o_datapath_operand_one = i_alu_operand_one[15:0];
      o_datapath_operand_two = i_alu_operand_two[15:0];
    end else begin
      o_datapath_operand_one = i_alu_operand_one[31:16];
      o_datapath_operand_two = i_alu_operand_two[31:16];
      o_alu_data_valid = 1'b1;
    end 
  end : alu_state_counter_xor
end

assign o_alu_carry_out = i_datapath_carry_out;

endmodule

