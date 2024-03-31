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
logic [7:0] bram_rd_ptr;
logic [7:0] bram_wr_ptr;

enum logic [1:0] {S0, S1, S2} read_upper_state, next_upper_state;

logic [31:0] rd_data_reg;
logic write_upper_state;

assign bram_wr_data = (write_upper_state) ? i_wr_data[31:16] : i_wr_data[15:0];
assign bram_wr_ptr = {i_wr_addr[8:2], write_upper_state};

always_comb begin
  bram_rd_ptr = {i_rd_addr[8:2], 1'b0};
  if (read_upper_state == S1) bram_rd_ptr = {i_rd_addr[8:2], 1'b1};

  case (read_upper_state)
    S0: next_upper_state = S1;
    S1: next_upper_state = S2;
    S2: next_upper_state = S0;
  endcase
end

always_ff @(posedge i_clk) begin
  if (i_rst) begin
    write_upper_state <= 1'b0;
    read_upper_state <= 'd0;
  end else begin
    write_upper_state <= write_upper_state ^ i_wr_en;

    read_upper_state <=  next_upper_state;
    if (read_upper_state == S1) rd_data_reg <= {rd_data_reg[31:15], bram_rd_data};
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
assign o_rd_valid = (read_upper_state == S2) ? 1'b1 : 1'b0;
assign o_rd_data = {bram_rd_data, rd_data_reg[15:0]};
endmodule