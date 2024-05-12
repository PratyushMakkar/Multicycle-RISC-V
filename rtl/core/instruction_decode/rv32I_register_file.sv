module RV32I_register_file #(parameter WIDTH = 32) (
  input logic i_clk,
  input logic i_rst,

  input logic i_rd_en,
  input logic [4:0] i_reg_addr,
  output logic [31:0] o_reg_data,
  output logic o_rd_valid,

  input logic i_wr_en,
  input logic [4:0] i_dest_addr,
  input logic [WIDTH-1:0] i_dest_reg_data,
  output logic o_wr_valid
);

logic [7:0] write_address,read_address;
logic [31:0] read_data, write_data, read_lower_data;
logic read_en, write_en;

ICE40_BRAM BRAM_BLOCK (
  .wclk(i_clk),
  .wen(write_en),
  .wdata(write_data[31:16]),
  .waddr(write_address),
  .rclk(i_clk),
  .ren(read_en),
  .raddr(read_address),
  .rdata(read_data[31:16])
);

enum {RegisterFileReadLower, RegisterFileReadUpper} register_read_state_e;
enum {RegisterFileWriteIdle, RegisterFileWrite} register_write_state_e;

always_ff @(posedge i_clk) begin
  write_en <= 1'b0;
  o_wr_valid <= 1'b0;
  o_rd_valid <= 1'b0;

  if (i_wr_en) begin : register_file_write
    unique case (register_write_state_e) 
      RegisterFileWriteIdle: begin
        register_write_state_e <= RegisterFileWrite;
        write_en <= 1'b1;
        write_data <= i_dest_reg_data[15:0];
        write_address <= {3'b000, i_dest_addr};
      end

      RegisterFileWrite: begin
        o_wr_valid <= 1'b1;
        register_write_state_e <= RegisterFileWriteIdle;
        write_data <= i_dest_reg_data[31:16];
        write_address <= {3'b001, i_dest_addr};
      end
    endcase
  end : register_file_write

  if (i_rd_en) begin : register_file_read
    unique case (register_read_state_e) begin
      RegisterFileReadLower: begin
        register_read_state_e <= RegisterFileReadLower;
      end

      RegisterFileReadUpper: begin
        o_rd_valid <= 1'b1;
        read_lower_data <= read_data;
      end
    end
  end : register_file_read

end

always_comb begin
  read_en = i_rd_en;
  read_address = (register_read_state_e == RegisterFileReadUpper) ? {3'b001, i_reg_addr} : {3'b000, i_reg_addr};
end

assign o_reg_data = {read_data, read_lower_data};

endmodule