module rv32_skid_buffer #(parameter WIDTH = 32, parameter RST_DATA = 0) (
  input logic i_clk,
  input logic i_rst,

  input logic [WIDTH-1 :0] i_din_recv,
  input logic i_valid_recv,
  output logic o_ready_recv,

  output logic [WIDTH-1 :0] o_dout_send,
  input logic i_ready_send,
  output logic o_valid_send
);

  enum {RST, BUFFERED} buffer_state_e;
  logic [WIDTH-1:0] buffer;

  always_ff @(posedge i_clk) begin
    o_valid_send <= 1'b0;

    unique case (buffer_state_e) begin
      RST: begin
        if (i_valid_recv) begin
          buffer <= i_din_recv;
          buffer_state_e <= BUFFERED;
          
          if (i_ready_send) begin
            o_dout_send <= i_din_recv;
            buffer_state_e <= RST;
            o_valid_send <= 1'b1;
          end
        end
      end

      BUFFERED: begin
        if (i_ready_send) begin
          o_valid_send <= 1'b1;
          o_dout_send <= buffer;
          buffer_state_e <= RST;
        end
      end
    end

    if (i_rst) begin
      buffer_state_e <= RST;
      o_dout_send <= RST_DATA;
    end
  end

  assign o_ready_recv = (buffer_state_e == RST) ? 1'b1 : 1'b0;
endmodule