module rv32_alu_fsm (
  input logic i_clk,
  input logic i_rst,
  input logic [31:0] i_operand_one,
  input logic [31:0] i_operand_two,
  input logic i_stall_reset,
  input logic [1:0] i_alu_sel,
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
RV32I_ALU GL_ALU_INST (
  .i_operand_one(alu_operand_one),
  .i_operand_two(alu_operand_two),
  .i_c_in(alu_carry_in),
  .i_sel(alu_op_sel),
  .o_carry_out(alu_carry_out),
  .o_result(alu_result)
);

logic temp_upper;
logic temp_en;
logic carry_out_q;
logic carry_out_en;
logic [31:0] temp_register_q;
logic [15:0] temp_register_d;

assign temp_register_d = alu_result;
always_ff @(posedge i_clk) begin
  else if (temp_upper & temp_en) temp_register_q[31:15] <= temp_register_d;
  else if (!temp_upper & temp_en) temp_register_q[15:0] <= temp_register_d;
  carry_out_q <= alu_carry_out;
end

/**
 Hold result logic.
 Freezes state machine until i_stall_result is held low again. 
**/
logic hold_q, logic hold_en;
always_ff @(posedge i_clk) begin
  if (i_stall_reset) hold_q <= 1'b0;
  if (hold_en) hold_q <= i_stall_reset;
end

always_comb begin
  alu_result_read = 1'b0;
  alu_carry_in = 1'b0;
  alu_result_ready = 1'b0;
  temp_en = 1'b0;
  temp_clear = 1'b0;
  temp_upper = 1'b0;

  carry_out_en = 1'b0;
  hold_en = 1'b0;

  if (add_op & !hold_q) begin
    carry_out_en = 1'b1;
    temp_en = 1'b1;
    alu_op_sel = 2'b00;
    if (!alu_op_state[0]) begin // 00001x
      alu_operand_one = i_operand_one[15:0];
      alu_operand_two = i_operand_two[15:0];
    end else begin
      alu_operand_one =  i_operand_one[31:16];
      alu_operand_two = i_operand_two[31:16];
      alu_carry_in = carry_out_q;
      temp_upper = 1'b1;
      alu_result_ready = 1'b1;
      hold_en = 1'b1;
    end
  end

  if (and_op & !hold_q) begin
    temp_en = 1'b1;
    alu_op_sel = 2'b10;
    if (!alu_op_state[0]) begin
      alu_operand_one = i_operand_one[15:0];
      alu_operand_two = i_operand_two[15:0];
    end else begin
      temp_upper = 1'b1;
      alu_operand_one =  i_operand_one[31:16];
      alu_operand_two = i_operand_two[31:16];
      alu_result_ready = 1'b1;
      hold_en = 1'b1;
    end
  end

  if (or_op & !hold_q) begin
    temp_en = 1'b1;
    alu_op_sel = 2'b01;
    if (!alu_op_state[0]) begin
      alu_operand_one = i_operand_one[15:0];
      alu_operand_two = i_operand_two[15:0];
    end else begin
      temp_upper = 1'b1;
      alu_operand_one =  i_operand_one[31:16];
      alu_operand_two = i_operand_two[31:16];
      alu_result_ready = 1'b1;
      hold_en = 1'b1;
    end
  end

  if (xor_op & !hold_q) begin
    temp_en = 1'b1;
    alu_op_sel = 2'b11;
    if (!alu_op_state[0]) begin
      alu_operand_one = i_operand_one[15:0];
      alu_operand_two = i_operand_two[15:0];
    end else begin
      temp_upper = 1'b1;
      alu_operand_one =  i_operand_one[31:16];
      alu_operand_two = i_operand_two[31:16];
      alu_result_ready = 1'b1;
      hold_en = 1'b1;
    end
  end
end

always_ff @(posedge i_clk) begin
  if (i_rst) alu_op_state <= 3'b000;
  else alu_op_state <= alu_op_state + 1'b1;
end

assign o_data_valid = alu_result_ready;
endmodule