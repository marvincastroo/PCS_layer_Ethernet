/*****  Archivo: "testbench.v"
******  Testbench de la segunda máquina de estados para el TRANSMIT, 
******  TRANSMIT_CODE_GROUP
******              Grupo 3
****** IE0523 - Circuitos Digitales II                           */
`include "PCS.v"
`include "tester.v"

module mdio_tb;

wire cg_timer_done, GTX_CLK,reset, POWER, SIGNAL_CHANGE, SIGNAL_DETECT, MR_LOOPBACK, CODE_SYNC, GOOD_CGS, testing;
wire [7:0] tx_o_set, TXD, RXD;
wire [9:0] tx_code_group;
wire [9:0] PUDI;
wire [9:0] SUDI;
wire TX_OSET_indicate, PUDR;


initial begin
	$dumpfile("pcs.vcd");
	$dumpvars(-1, U0);
end


PCS U0 (
  .GTX_CLK (GTX_CLK),
  .RESET(reset), 
  .TX_EN(TX_EN), 
  .TX_ER(TX_ER), 
  .cg_timer_done(cg_timer_done),
  .xmit(xmit),
  .MR_LOOPBACK(MR_LOOPBACK),
  .SIGNAL_CHANGE(SIGNAL_CHANGE),
  .SIGNAL_DETECT(SIGNAL_DETECT),
  .POWER(POWER),
  .TXD(TXD),
  .RXD(RXD),
  .RX_DV(RX_DV)
);


  probador P0 (
  .cg_timer_done(cg_timer_done),
  .reset (reset),
  .GTX_CLK (GTX_CLK),
  .TXD(TXD),
  .TX_EN(TX_EN), 
  .TX_ER(TX_ER),
  .SIGNAL_CHANGE(SIGNAL_CHANGE),
  .MR_LOOPBACK(MR_LOOPBACK),
  .POWER(POWER),
  .SIGNAL_DETECT(SIGNAL_DETECT),
  .xmit(xmit)
  );



endmodule