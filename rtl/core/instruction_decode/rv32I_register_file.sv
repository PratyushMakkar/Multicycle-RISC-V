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

enum logic [1:0] {S0, S1, S2} bram_read_state, bram_next_state;
logic bram_write_state;

always_comb begin
  case (bram_read_state)
    S0: bram_next_state = S1;
    S1: bram_read_state = S2;
    S2: bram_next_state = S0;
  endcase
end


logic [31:0] latched_read_data;
logic [7:0] bram_write_addr;
logic [7:0] bram_read_addr;
logic [15:0] bram_write_data;
logic [15:0] bram_read_data;

assign bram_read_addr = (bram_read_state == S0) ? {3'b000, i_reg_addr} : {3'b001, i_reg_addr};
assign bram_write_addr = (bram_write_state) ? {3'b00, i_dest_addr[4:0]} : {3'b001, i_dest_addr[4:0]};
assign bram_write_data = (bram_write_state) ? i_dest_reg_data[31:16] : i_dest_reg_data[15:0];

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
    bram_write_state <= 1'b0;
    bram_read_state <= S0;
  end 
  
  else if (i_wr_en) begin 
    bram_write_state <= ~bram_write_state;
  end 
  
  else if (i_rd_en) begin
    bram_read_state <= bram_next_state;
    latched_read_data <= (bram_read_state == S0) ? {latched_read_data[31:16], bram_read_data} : {bram_read_data, latched_read_data[15:0]};
  end
end

assign o_reg_data = (i_wr_en & (i_dest_addr == i_reg_addr))
                  ? i_dest_reg_data : latched_read_data;

assign o_rd_valid = (bram_read_state == S2) ? 1'b1 : 1'b0;
assign o_wr_valid = bram_write_state;
endmodule