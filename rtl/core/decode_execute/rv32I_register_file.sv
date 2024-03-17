module RV32I_register_file (
  input logic i_clk,
  input logic i_rst,
  input logic i_rd_en,
  input logic [4:0] i_reg_addr,
  output logic [31:0] o_reg_data,

  input logic i_wr_en,
  input logic [4:0] i_dest_addr,
  input logic [31:0] i_dest_reg_data,

  output logic o_rd_valid,
  output logic o_wr_valid
);

logic bram_state_rd_control;
logic bram_state_wr_control;

logic [7:0] bram_write_addr;
logic [15:0] bram_write_data;

logic file_reg_data;
wire [7:0] bram_read_addr = (!bram_state_rd_control) ? {3'b000, i_reg_addr} : {3'b001, i_reg_addr[4:0]};
wire [15:0] bram_read_data;

assign bram_write_addr = (!bram_state_wr_control) ? {3'b00, i_dest_addr[4:0]} : {3'b001, i_dest_addr[4:0]};
assign bram_write_data = (!bram_state_wr_control) ? i_dest_reg_data[15:0] : i_dest_reg_data[31:16];

ICE40_BRAM BRAM (
  .wclk(i_clk),
  .rclk(i_clk),
  .wen(i_wr_en),
  .ren(i_rd_en),
  .raddr(bram_read_addr),
  .waddr(bram_write_addr),
  .wdata(bram_write_data),
  .rdata(bram_read_data)
);

always_ff @(posedge i_clk) begin
  if (i_rst) begin
    bram_state_rd_control <= 1'b0;
    bram_state_wr_control <= 1'b0;
  end 

  if (i_wr_en & !i_rst) begin 
    bram_state_wr_control <= ~bram_state_wr_control;
  end 
  if (i_rd_en & !i_rst) begin
    bram_state_rd_control <= ~bram_state_rd_control;
    file_reg_data <= (!bram_state_control) ? {o_reg_data[31:16], bram_read_data} : {bram_read_data, o_reg_data[15:0]};
  end
end

assign o_reg_data = (i_wr_en & (i_dest_addr == i_reg_addr)) ? i_dest_reg_data : file_reg_data;
assign o_rd_valid = bram_state_rd_control;
assign o_wr_valid = bram_state_wr_control;
endmodule