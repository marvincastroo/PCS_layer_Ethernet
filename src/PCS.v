`include "TRANSMIT_CODE_GROUP.v"
`include "TRANSMIT_ORDERED_SET.v"
`include "synch.v"
`include "RECEIVE.v"

module PCS (GTX_CLK, RESET, TXD, cg_timer_done, xmit, MR_LOOPBACK, SIGNAL_DETECT, SIGNAL_CHANGE, POWER, TX_EN, TX_ER, RXD, RX_DV);


input GTX_CLK, RESET, TX_EN, TX_ER, cg_timer_done, xmit, MR_LOOPBACK, SIGNAL_DETECT, SIGNAL_CHANGE, POWER;
input [7:0] TXD;
output [7:0] RXD;
output RX_DV;

wire CODE_SYNC, GOOD_CGS, testing;
wire EVEN;
wire [7:0] tx_o_set;
wire [9:0] tx_code_group;
wire [9:0] PUDI;
wire [9:0] SUDI;
wire TX_OSET_indicate, PUDR;
wire RXD, RX_DV;

TRANSMIT_CODE_GROUP U0 (
  .cg_timer_done(cg_timer_done),
  .reset (RESET),
  .GTX_CLK (GTX_CLK),
  .tx_o_set (tx_o_set),
  .TX_OSET_indicate (TX_OSET_indicate),
  .PUDR(PUDR),
  .tx_code_group(tx_code_group),
  .TXD(TXD)
);

TRANSMIT_ORDERED_SET U1(
  .TXD(TXD), 
  .TX_OSET_indicate(TX_OSET_indicate), 
  .TX_EN(TX_EN), 
  .TX_ER(TX_ER), 
  .CLK(GTX_CLK), 
  .RESET(RESET), 
  .tx_o_set(tx_o_set)
  );

synchronization U2(
  .CLK(GTX_CLK), 
  .POWER(POWER),
  .RESET(RESET), 
  .SIGNAL_CHANGE(SIGNAL_CHANGE),
  .SIGNAL_DETECT(SIGNAL_DETECT),
  .PUDI(tx_code_group),
  .MR_LOOPBACK(MR_LOOPBACK),
  .CODE_SYNC(CODE_SYNC),
  .SUDI(SUDI),
  .RX_EVEN(RX_EVEN),
  .GOOD_CGS(GOOD_CGS),
  .testing(testing)
);

RECEIVE U3(
  .CLK(GTX_CLK), 
  .RESET(RESET), 
  .sync_status(CODE_SYNC),
  .xmit(xmit),
  .EVEN(RX_EVEN),
  .SUDI(SUDI),
  .RXD(RXD),
  .RX_DV(RX_DV)
);

endmodule