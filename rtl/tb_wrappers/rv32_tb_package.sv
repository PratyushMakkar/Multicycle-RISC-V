package rv32_tb_package;

task initializeClock(ref clk);
  forever begin
    #5 clk = ~clk;
  end
endtask

`define SYNCHRONIZE_DUT(TX_ACK); \
  task synchronizeDut(); \
    TX_ACK <= 1'b1; \
    @(posedge TX_ACK); \
    TX_ACK <= 1'b0; \
  endtask \

`define TOGGLE_CLOCK(CLK, O_CLK); \
  assign O_CLK = CLK; \
  task toggleClock; \
   forever begin  \
    #5 CLK = ~CLK; \
   end \
  endtask \

endpackage