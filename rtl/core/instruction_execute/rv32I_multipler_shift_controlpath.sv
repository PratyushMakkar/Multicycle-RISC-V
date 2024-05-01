module rv32I_multipler_shift_controlpath (
  input logic i_clk,
  input logic i_rst,

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
logic [4:0] multiplier_shift;
logic [63:0] multiplier_sign_extended;
logic [16:0] multiplier_shift_index;

assign multiplier_sign_extended = (i_execute_shifter_opcode == 4'b0001) ? {32'h0, i_execute_operand_one}
                                : (i_execute_shifter_opcode == 4'b0101) ? {32'h0, i_execute_operand_one}
                                : {{32{1'b1}}, i_execute_operand_one};

assign multiplier_shift_index = (multiplier_state_counter == 0) ? {multiplier_shift[0], ~multiplier_shift[0]}
                              : (multiplier_state_counter == 1) ? {multiplier_shift[1], 1'h0, ~multiplier_shift[1]}
                              : (multiplier_state_counter == 2) ? {multiplier_shift[2], 3'h0, ~multiplier_shift[2]}
                              : (multiplier_state_counter == 3) ? {multiplier_shift[3], 7'h0, ~multiplier_shift[3]}
                              : {multiplier_shift[4], 15'h0, ~multiplier_shift[4]};

                            
enum {ShifterRst, ShifterStage, ShifterValid} shifter_state_e;
logic [1:0] multiplier_phase_counter;
logic [63:0] multiplier_accumulator;
logic [63:0] multiplier_temp_register;

always_ff @(posedge i_clk) begin 
  o_execute_data_valid <= 1'b0;
  o_execute_data_result <= 0;

  if (i_execute_en) begin 

    unique case (shifter_state_e)
      ShifterRst: begin 
        multiplier_temp_register <= 0;
        multiplier_accumulator <= multiplier_sign_extended;

        multiplier_shift <= (i_execute_shifter_opcode == 4'b0001) ? i_execute_operand_two[4:0]
                          : (i_execute_shifter_opcode == 4'b0101) ? i_execute_operand_two[4:0]
                          : ~i_execute_operand_two[4:0] + 1;

        shifter_state_e <= ShifterStage;
        multiplier_state_counter <= 0;
        multiplier_phase_counter <= 0;
        o_multiplier_en <= 1'b0;
      end

      ShifterStage: begin 
        o_multiplier_en <= 1'b1;
        o_multiplier_operand_one <= (multiplier_phase_counter == 0) ? multiplier_accumulator[15:0]
                                    : (multiplier_phase_counter == 1) ? multiplier_accumulator[31:16]
                                    : (multiplier_phase_counter == 2) ? multiplier_accumulator[47:32]
                                    :  multiplier_accumulator[63:48];

        o_multiplier_operand_two <= multiplier_shift_index;

        if (i_multiplier_valid) begin
          multiplier_temp_register <= (multiplier_phase_counter == 0) ? {32'd0, i_multiplier_result}
                                    : (multiplier_phase_counter == 1) ? multiplier_temp_register | {16'd0, i_multiplier_result, 16'd0}
                                    : (multiplier_phase_counter == 2) ? multiplier_temp_register | {i_multiplier_result, 32'd0}
                                    :  multiplier_temp_register | {i_multiplier_result[15:0], 48'd0};

          shifter_state_e <= (multiplier_phase_counter == 3) ? ShifterValid : ShifterStage;
          o_multiplier_en <= 1'b0;
          multiplier_phase_counter <= multiplier_phase_counter + 1'b1;
        end
      end

      ShifterValid: begin 
        shifter_state_e <= ShifterStage;
        multiplier_phase_counter <= 0;
        multiplier_accumulator <= multiplier_temp_register;
        multiplier_state_counter <= multiplier_state_counter + 1;
        o_multiplier_en <= 1'b0;

        if (multiplier_state_counter == 4) begin 
          o_execute_data_valid <= 1'b1;
          o_execute_data_result <= (i_execute_shifter_opcode == 4'b0001) ? multiplier_temp_register[31:0]
                                  : multiplier_temp_register[63:32];

          shifter_state_e <= ShifterRst;
        end
      end 
    endcase

  end 

  if (i_rst) begin
    shifter_state_e <= ShifterRst;
  end
end

endmodule