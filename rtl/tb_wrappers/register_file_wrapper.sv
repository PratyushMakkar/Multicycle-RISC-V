module register_file_wrapper (
  input logic i_rd_en,
  input logic [4:0] i_rd_reg_addr,
  output logic [31:0] o_debug_rd_reg_data,

  input logic i_wr_en,
  input logic [4:0] i_dest_addr,
  input logic [31:0] i_dest_reg_data,

  input logic [2:0] i_operation_code,
  input logic i_rx_continue,
  output logic o_tx_complete,
  output logic o_debug_clk
);

always @(debug_clk) begin
  o_debug_clk <= debug_clk;
end

localparam logic [2:0] OPERATION_CODE_READ_WRITE = 3'b000;
localparam logic [2:0] OPERATION_CODE_END_SIM = 3'b001;
localparam logic [2:0] OPERATION_CODE_RESET_DUT = 3'b010;

logic debug_clk;
logic debug_rst;
logic debug_rd_en;
logic [4:0] debug_rd_reg_addr;
logic [31:0] debug_rd_reg_data;
logic debug_wr_en;
logic [4:0] debug_wr_reg_addr;
logic [31:0] debug_wr_reg_data;
logic debug_rd_valid;
logic debug_wr_valid;

RV32I_register_file RV32I_REGISTER_FILE (
  .i_clk(debug_clk),
  .i_rst(debug_rst),

  .i_rd_en(debug_rd_en),
  .i_reg_addr(debug_rd_reg_addr),
  .o_reg_data(debug_rd_reg_data),
  .i_wr_en(debug_wr_en),
  .i_dest_addr(debug_wr_reg_addr),
  .i_dest_reg_data(debug_wr_reg_data),
  .o_rd_valid(debug_rd_valid),
  .o_wr_valid(debug_wr_valid)
);

task resetDut();
  debug_rst <= 1'b1;
  @(posedge debug_clk);
  debug_rst <= 1'b0;
endtask

task drive_item;
  fork 
    begin
      debug_rd_en <= i_rd_en;
      debug_rd_reg_addr <= i_rd_reg_addr;
      if (i_rd_en) begin
        @(posedge debug_rd_valid);
        @(negedge debug_clk);
      end
      o_debug_rd_reg_data <= debug_rd_reg_data;
    end  
    begin
      debug_wr_en <= i_wr_en;
      debug_wr_reg_addr <= i_dest_addr;
      debug_wr_reg_data <= i_dest_reg_data;
      if (i_wr_en) @(posedge debug_wr_valid);
    end
  join
  @(posedge debug_clk);
  {debug_rd_en, debug_wr_en} <= 2'b00;
endtask

task begin_test();
  forever begin
    if (i_operation_code == OPERATION_CODE_READ_WRITE) drive_item();
    else if (i_operation_code == OPERATION_CODE_RESET_DUT) resetDut();
    else if (i_operation_code == OPERATION_CODE_END_SIM) disable fork;
    
    o_tx_complete = 1'b1;
    @(posedge i_rx_continue);
    o_tx_complete = 1'b0;
    @(negedge i_rx_continue);
  end
endtask

task initializeClock();
  forever begin
    #5 debug_clk = ~debug_clk;
  end
endtask

initial begin
  debug_clk <= 0;
  debug_rst <= 0;
  debug_rd_en <= 0;
  debug_rd_reg_addr <= 0;
  debug_wr_en <= 0;
  debug_wr_reg_addr <= 0;
  debug_wr_reg_data <= 0;
  o_tx_complete <= 0;

  fork
    initializeClock();
    resetDut();
  join_any
  fork
    begin_test();
  join_any
end

endmodule