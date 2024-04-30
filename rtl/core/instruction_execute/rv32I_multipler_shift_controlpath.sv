module rv32I_multipler_shift_controlpath (
  input logic i_execute_en,
  input logic [2:0] i_execute_shifter_opcode,
  input logic [31:0] i_execute_operand_one,
  input logic [31:0] i_execute_operand_two,
  output logic o_execute_data_valid,
  output logic [31:0] o_execute_data_result,

// -------- Multiplier IP Interface ------------ //
  output logic o_multiplier_en,
  output logic [15:0] o_multiplier_operand_one,
  output logic [15:0] o_multiplier_operand_two,
  input logic i_multiplier_valid,
  input logic [31:0] i_multiplier_result
);


logic [3:0] multiplier_state_counter;
logic [63:0] multiplier_accumulator;
logic [63:0] multiplier_temp_register;
logic [4:0] multiplier_shift;

logic [63:0] multiplier_sign_extended;
logic [16:0] multiplier_shift_index;

assign multiplier_sign_extended = (i_execute_shifter_opcode == SLL) ? {32'h0, i_operand_one}
                                : (i_execute_shifter_opcode == SRL) ? {32'h0, i_operand_one}
                                : {{32{1'b1}}, i_operand_one};

assign multiplier_shift_index = (multiplier_state_counter == 0) ? {{30{1'b0}}, i_operand_two[0]};
                              : (multiplier_state_counter == 1) ? {i_operand_two[1], 2'h0}
                              : (multiplier_state_counter == 2) ? {i_operand_two[2], 4'h0}
                              : (multiplier_state_counter == 3) ? {i_operand_two[3], 8'h0}
                              : {i_operand_two[4], 16'h0};

enum {ShifterRst, ShifterQuartOne, ShifterQuartTwo, ShifterQuartThree, ShifterQuartFour, ShifterValid} shifter_state_e;

always_ff @(posedge i_clk) begin : multipler_shifter_interface
  o_execute_data_valid <= 1'b0;

  if (i_execute_en) begin : shifter_circuit

    unique case (shifter_state_e) begin
      ShifterRst: begin : shifter_rst
        multiplier_temp_register <= 0;
        multiplier_accumulator <= multiplier_sign_extended;

        multiplier_shift <= (i_execute_shifter_opcode == SLL) ? i_operand_one[4:0];
                          : (i_execute_shifter_opcode == SRL) ? i_operand_one[4:0];
                          : ~i_operand_one[4:0] + 1;

        shifter_state_e <= ShifterQuartOne;
        multiplier_state_counter <= 0;
        o_multiplier_en <= 1'b0;
      end

      ShifterQuartOne: begin : shifter_quart_one
        o_multiplier_en <= 1'b1;
        o_multiplier_operand_one <= multiplier_accumulator[15:0]
        o_multiplier_operand_two <= multiplier_shift_index;

        if (i_multiplier_valid) begin
          multiplier_temp_register <= {32'd0, i_multiplier_result};
          shifter_state_e <= ShifterQuartTwo;
          o_multiplier_en <= 1'b0;
        end
      end

      ShifterQuartTwo: begin : shifter_quart_two
        o_multiplier_en <= 1'b1;
        o_multiplier_operand_one <= multiplier_accumulator[31:16]
        o_multiplier_operand_two <= multiplier_shift_index;

        if (i_multiplier_valid) begin
          multiplier_temp_register <= multiplier_temp_register | {16'd0, i_multiplier_result, 16'd0};
          shifter_state_e <= ShifterQuartThree;
          o_multiplier_en <= 1'b0;
        end
      end

      ShifterQuartThree: begin : shifter_quart_three
        o_multiplier_en <= 1'b1;
        o_multiplier_operand_one <= multiplier_accumulator[47:32]
        o_multiplier_operand_two <= multiplier_shift_index;

        if (i_multiplier_valid) begin
          multiplier_temp_register <= multiplier_temp_register | {i_multiplier_result, 32'd0};
          shifter_state_e <= ShifterQuartFour;
          o_multiplier_en <= 1'b0;
        end
      end

      ShifterQuartFour: begin : shifter_quart_four
        o_multiplier_en <= 1'b1;
        o_multiplier_operand_one <= multiplier_accumulator[47:32]
        o_multiplier_operand_two <= multiplier_shift_index;

        if (i_multiplier_valid) begin
          multiplier_temp_register <= multiplier_temp_register | {i_multiplier_result[15:0], 48'd0};
          shifter_state_e <= ShifterValid;
          o_multiplier_en <= 1'b0;
        end
      end : shifter_quart_four

      ShifterValid: begin : shifter_valid
        shifter_state_e <= ShifterQuartOne;
        multiplier_accumulator <= multiplier_temp_register;
        multiplier_state_counter <= multiplier_state_counter + 1;
        o_multiplier_en <= 1'b0;

        if (multiplier_state_counter == 4) begin 
          o_execute_data_valid <= 1'b1;
          o_execute_data_result <= (i_execute_shifter_opcode == SLL) ? multiplier_temp_register[31:0]
                                  : multiplier_accumulator[63:32];

          shifter_state_e <= ShifterRst;
        end
      end : shifter_valid

    end
  end : shifter_circuit

end

endmodule