module ICE40_BRAM #(parameter WORD_SIZE=16, parameter DEPTH=1024) 
(
  input logic wclk,
  input logic wen,
  input logic [WORD_SIZE-1 :0] wdata,
  input logic [DEPTH-1 :0] waddr,
  input logic rclk,
  input logic ren,
  input logic [DEPTH-1 :0] raddr,
  output logic [WORD_SIZE-1 :0] rdata
);
  
  reg [WORD_SIZE-1 :0] memory [DEPTH-1 :0];
  always_ff @(posedge wclk) begin
    if (wen) memory[waddr] <= wdata;
  end

  always_ff @(posedge rclk) begin
    if (ren) rdata <= memory[raddr];
  end
endmodule