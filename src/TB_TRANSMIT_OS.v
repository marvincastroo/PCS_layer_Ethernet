/*****  Archivo: "TB_TRANSMIT_OS.v"
******  Testbench de la primera máquina de estados para el TRANSMIT, 
******  TRANSMIT_ORDERED_SET
******              Grupo 3
****** IE0523 - Circuitos Digitales II                           */

`include "TRANSMIT_ORDERED_SET.v"

module TB_TRANSMIT_OS;

wire [7:0] TXD;
reg TX_EN, TX_OSET_indicate, TX_ER, CLK, RESET;
wire [7:0] tx_o_set;

wire transmitting, tx_even;

TRANSMIT_ORDERED_SET uut(.TXD(TXD), .TX_OSET_indicate(TX_OSET_indicate), .TX_EN(TX_EN), .TX_ER(TX_ER), .CLK(CLK), .RESET(RESET), .tx_o_set(tx_o_set));

initial begin
    $dumpfile("TRANSMIT_OS.vcd");
    $dumpvars(0, TB_TRANSMIT_OS);

    CLK = 0;
    TX_EN = 0;
    TX_ER = 0; 
    RESET = 0; #5
    RESET = 1;
    TX_EN = 1;
    TX_OSET_indicate = 1;
    TX_ER = 0;
    #50
    #50
    TX_EN = 0;
    #50
    $finish;
end

always
    begin
        CLK = 1; #5;
        CLK = 0; #5;
        
    end 

endmodule