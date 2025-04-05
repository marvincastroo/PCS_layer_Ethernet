`include "PCS.v"
module TB_PCS;

//`include "PARAMETERS.v"

reg GTX_CLK, RESET, TX_EN, TX_ER;
reg [7:0] TXD;
wire [7:0] RXD;
wire RX_DV;

PCS uut(.RESET(RESET),
            .GTX_CLK(GTX_CLK),
            .TX_EN(TX_EN),
            .TX_ER(TX_ER),
            .TXD(TXD),
            .RXD(RXD),
            .RX_DV(RX_DV)
            );


initial begin
	$dumpfile("PCS.vcd");
	$dumpvars(-1, TB_PCS);

    
    RESET = 0; #5
    RESET = 1; #10
    RESET = 0;
    #20
    TX_EN = 1;
    TX_ER = 0;

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
    #40 TX_EN = 0;

    #200
    $finish;
    


end


always 
    begin
        GTX_CLK = 1; #5;
        GTX_CLK = 0; #5;
    end

endmodule
