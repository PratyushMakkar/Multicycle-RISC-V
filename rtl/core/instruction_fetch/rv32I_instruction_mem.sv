module RV32I_instruction_mem (
  input logic i_clk,
  input logic i_rst,

  input logic i_wr_en,
  input logic [31:0] i_wr_data,
  input logic [31:0] i_wr_addr,
  output logic o_wr_valid,
  input logic i_rd_en,
  input logic [31:0] i_rd_addr,
  output logic [31:0] o_rd_data,
  output logic o_rd_valid
);

logic [15:0] bram_rd_data;
logic [15:0] bram_wr_data;
logic [7:0] bram_rd_ptr, bram_wr_ptr;

logic [31:0] rd_data_reg;
logic write_upper_state, read_upper_state;

assign bram_wr_data = (write_upper_state) ? i_wr_data[31:16] : i_wr_data[15:0];
assign bram_rd_ptr = {i_rd_addr[8:2], read_upper_state};
assign bram_wr_ptr = {i_wr_addr[8:2], write_upper_state};

always_ff @(posedge i_clk) begin
  if (i_rst) begin
    write_state <= LOWER_WORD;
    read_state <= UPPER_WORD;
  end else begin
    write_state <= write_upper_state ^ i_wr_en;
    read_state <=  read_upper_state ^ i_rd_en;
    if (~read_upper_state) rd_data_reg <= {rd_data_reg[31:16], bram_rd_data};
  end
end

ICE40_BRAM INSTRUCTION_MEM (
  .wclk(i_clk),
  .wen(i_wr_en),
  .wdata(bram_wr_data),
  .waddr(bram_wr_ptr),
  .rclk(i_clk),
  .ren(i_rd_en),
  .raddr(bram_rd_ptr),
  .rdata(bram_rd_data)
);

assign o_wr_valid = write_upper_state;
assign o_rd_valid = read_upper_state;
assign o_rd_data = {bram_rd_data, rd_data_reg[15:0]};
endmodule