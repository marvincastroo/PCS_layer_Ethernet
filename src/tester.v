
module probador(

  output reg POWER,
  output reg SIGNAL_CHANGE,
  output reg SIGNAL_DETECT,
  output reg MR_LOOPBACK,
  output reg xmit,
  output cg_timer_done,
  output GTX_CLK,
  output reset,
  output [7:0] TXD,
  output TX_EN,
  output TX_ER
);

    reg cg_timer_done, GTX_CLK,reset, TX_EN, TX_ER;
    reg [7:0] tx_o_set, TXD;

initial begin
  GTX_CLK = 0;
  reset = 0;
  TX_EN = 0;
  xmit = 0;
  TX_ER = 0; 
  cg_timer_done = 1;
  MR_LOOPBACK=1;
  TXD = 8'b00000000;
  // Prueba 1 y 2
  #20 reset = 1;
  POWER=1;
  SIGNAL_CHANGE = 1; 
  SIGNAL_DETECT = 1;
  #40 reset = 0;
  // Prueba 3
  #340 xmit = 1;
  // Prueba 4
  #40
  TX_EN = 1;
  xmit = 1;
  TX_ER = 0;
  // Prueba 5
  #60 TXD = 8'b00000000;
  #40 TXD = 8'b00000001;
  #40 TXD = 8'b00100010;
  #40 TXD = 8'b01000011;
  #40 TXD = 8'b01100100;

  #40 TXD = 8'b10000101;
  #40 TXD = 8'b10100110;
  #40 TXD = 8'b11000111;
  #40 TXD = 8'b11101000;
  #40 TXD = 8'b11101001;
  //Prueba 6
  #40 TX_EN = 0;
  xmit = 0;
  // Prueba 7
  #2000 $finish;
end


always begin
 #20 GTX_CLK = !GTX_CLK;
end
endmodule