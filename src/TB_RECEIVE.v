`include "RECEIVE.v"


module TB_RECEIVE;

`include "PARAMETERS.v"

wire [7:0] RXD;
wire RX_DV;
reg RESET, CLK, sync_status, xmit;
reg [9:0] SUDI;

RECEIVE uut(.RESET(RESET),
            .CLK(CLK),
            .sync_status(sync_status),
            .xmit(xmit),
            .SUDI(SUDI),
            .RXD(RXD),
            .RX_DV(RX_DV)
            );

initial begin
    $dumpfile("RECEIVE.vcd");
    $dumpvars(0, TB_RECEIVE);

    sync_status = 1;
    xmit = 0;
    CLK = 0;
    SUDI = 10'h000;
    RESET = 0; #5
    RESET = 1; #10
    RESET = 0;
    #20
    sync_status = 1;
    xmit = 1;
    #20
    SUDI = K_28_5_neg;
    #20
    SUDI = 10'h010;
    #20
    SUDI = set_D_1_0p;
    #20
    SUDI = set_D_0_0p;
    #20
    SUDI = set_D_0_0n;
    #20
    SUDI = set_D_1_0n;
    #20
    SUDI = set_D_1_0p;
    #20
    SUDI = set_D_5_4n;
    #20
    SUDI = set_D_5_4p;
    #20
    SUDI = set_D_9_7n;
    #20
    SUDI = set_Tp; ////// hex =117
    #20
    SUDI = set_Rn; ///// hex = 3A8
    #20
    SUDI = K_28_5_pos; ///// hex = 305




    #200
    $finish;

end 

always 
    begin
        CLK = 1; #5;
        CLK = 0; #5;
    end

endmodule