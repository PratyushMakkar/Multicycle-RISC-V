module rv32_adder_unit (
  input logic[15:0] i_operand_one,
  input logic[15:0] i_operand_two,
  input logic i_c_in,
  input logic [1:0] i_sel,
  output logic o_carry_out, 
  output logic [15:0] o_result
);

wire  [15:0] x_i = i_operand_one;
wire  [15:0] y_i = i_operand_two;
wire  [1:0] sel = i_sel;
logic [15:0] l_o;
logic [15:0] c_in;
logic [15:0] c_out;

assign c_in[15:0] = {c_out[14:0], i_c_in};

`ifdef SIM 
always @(*) begin
  if (sel == 00) {c_out[15], l_o} = i_operand_one + i_operand_two + i_c_in;
  if (sel == 01) l_o = i_operand_one | i_operand_two;
  if (sel == 10) l_o = i_operand_one & i_operand_two;
  if (sel == 11) l_o = i_operand_one ^ i_operand_two;
end
`else
generate
  for (genvar k = 0; k < 16; k = k+1) begin
    TinyALU alu0 (
      .x_i(x_i[k]), 
      .y_i(y_i[k]),
      .c_in(c_in[k]),
      .sel(sel),
      .l_o(l_o[k]),
      .c_out(c_out[k])
    ); 
  end
endgenerate
`endif

assign o_result = l_o;
assign o_carry_out = c_out[15];
endmodule


// ---------------------------------------------------------------------------------------------------- //
// ------------------------------------- **************************** --------------------------------- //
// ------------------------------------- Beginning of Tiny ALU Module --------------------------------- //
// ------------------------------------- **************************** --------------------------------- //
// ---------------------------------------------------------------------------------------------------- //
module TinyALU (
  input logic x_i,
  input logic y_i,
  input logic c_in,
  input logic [1:0] sel,
  output logic l_o,
  output logic c_out
);

  wire p_i = x_i & y_i;
  wire g_i = ~x_i & ~y_i;
  wire _x_i = ~(p_i | g_i);
  
  wire s_i = (~c_in & _x_i) | (c_in & ~_x_i);
  wire o_i = ~g_i;
  wire a_i = p_i;
  wire x_i = _x_i;  // Only valid when y_i register is cleared. 

  assign c_out = (c_in & ~g_i) + (~c_in & p_i);
  assign l_o = (sel == 2'b00) ? s_i :  // Add  00
               (sel == 2'b01) ? o_i :  // Or   01
               (sel == 2'b10) ? a_i :  // And  10
               x_i;                    // Xor  11
endmodule

