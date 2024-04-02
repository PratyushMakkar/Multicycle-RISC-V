module rv32_alu_fsm (
  input logic i_clk,
  input logic i_rst,
  input logic i_en_alu,
  input logic [1:0] i_alu_sel,
  input logic [31:0] i_operand_one,
  input logic [31:0] i_operand_two,
  output logic o_carry_out,
  output logic o_data_valid,
  output logic [31:0] o_result
);

wire add_op = (i_alu_sel == 2'b00) ? 1'b1 : 1'b0;
wire and_op = (i_alu_sel == 2'b01) ? 1'b1 : 1'b0;
wire or_op = (i_alu_sel == 2'b10) ? 1'b1 : 1'b0;
wire xor_op = (i_alu_sel == 2'b11) ? 1'b1 : 1'b0;

logic [15:0] alu_operand_one;
logic [15:0] alu_operand_two;
logic [15:0] alu_result;
logic [1:0] alu_op_sel;
logic alu_carry_in, alu_carry_out;

logic [2:0] alu_op_state;
logic alu_result_ready;

// Gate level implementation of Adders/AND/XOR/OR
rv32_adder_unit GL_ALU_INST (
  .i_operand_one(alu_operand_one),
  .i_operand_two(alu_operand_two),
  .i_c_in(alu_carry_in),
  .i_sel(alu_op_sel),
  .o_carry_out(alu_carry_out),
  .o_result(alu_result)
);


logic temp_en;
logic carry_out_q;
logic [15:0] temp_register_q;
logic [15:0] temp_register_d;

assign temp_register_d = alu_result;
/**
 Hold result logic.
 Freezes state machine until i_stall_result is held low again. 
**/
always_ff @(posedge i_clk) begin
  if (temp_en) temp_register_q <= temp_register_d;
  carry_out_q <= alu_carry_out;
end

always_comb begin
  alu_carry_in = 1'b0;
  alu_result_ready = 1'b0;
  temp_en = 1'b0;

  if (add_op) begin
    temp_en = 1'b1;
    alu_op_sel = 2'b00;
    if (!alu_op_state[0]) begin // 00001x
      alu_operand_one = i_operand_one[15:0];
      alu_operand_two = i_operand_two[15:0];
    end else begin
      alu_operand_one =  i_operand_one[31:16];
      alu_operand_two = i_operand_two[31:16];
      alu_carry_in = carry_out_q;
      alu_result_ready = 1'b1;
    end
  end

  if (and_op) begin
    temp_en = 1'b1;
    alu_op_sel = 2'b10;
    if (!alu_op_state[0]) begin
      alu_operand_one = i_operand_one[15:0];
      alu_operand_two = i_operand_two[15:0];
    end else begin
      alu_operand_one =  i_operand_one[31:16];
      alu_operand_two = i_operand_two[31:16];
      alu_result_ready = 1'b1;
    end
  end

  if (or_op) begin
    temp_en = 1'b1;
    alu_op_sel = 2'b01;
    if (!alu_op_state[0]) begin
      alu_operand_one = i_operand_one[15:0];
      alu_operand_two = i_operand_two[15:0];
    end else begin
      alu_operand_one =  i_operand_one[31:16];
      alu_operand_two = i_operand_two[31:16];
      alu_result_ready = 1'b1;
    end
  end

  if (xor_op) begin
    temp_en = 1'b1;
    alu_op_sel = 2'b11;
    if (!alu_op_state[0]) begin
      alu_operand_one = i_operand_one[15:0];
      alu_operand_two = i_operand_two[15:0];
    end else begin
      alu_operand_one =  i_operand_one[31:16];
      alu_operand_two = i_operand_two[31:16];
      alu_result_ready = 1'b1;
    end
  end
end

always_ff @(posedge i_clk) begin
  if (i_rst) begin 
    alu_op_state <= 3'b000;
  end else begin 
    if (i_en_alu) alu_op_state <= alu_op_state + 1'b1;
  end
end

assign o_result = {temp_register_d, temp_register_q};
assign o_carry_out = alu_carry_out;
assign o_data_valid = alu_result_ready;
endmodule