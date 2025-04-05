/****   Archivo: "TRANSMIT_ORDERED_SET.v" 
***** De la máquina de estados de TRANSMIT relacionada a enviar un ext_code-group
***** de /I/ /S/ /D/... /D/ /T/ /R/
*****               Grupo 3
*****   IE0523 - Circuitos Digitales II
*/




module TRANSMIT_ORDERED_SET(TXD, TX_OSET_indicate, TX_EN, TX_ER, CLK, RESET, tx_o_set);

    input [7:0] TXD;
    input TX_OSET_indicate, TX_EN, TX_ER, CLK, RESET;
    output reg [7:0] tx_o_set;

    reg transmitting, tx_even;

    reg [5:0] EstPres, ProxEstado;  // Estados presente, proximoo estado

    parameter XMIT_DATA             = 6'b00_0001;   // "Idle"   /I/
    parameter START_OF_PACKET       = 6'b00_0010;   // tx_o_set <= /S/
    parameter TX_PACKET             = 6'b00_0100;   // transicionar a /D/
    parameter TX_DATA               = 6'b00_1000;   // tx_o_set <= /D/
    parameter END_OF_PACKET_NOEXT   = 6'b01_0000;   // tx_o_set <= /T/
    parameter EPD2_NOEXT            = 6'b10_0000;   // tx_o_set <= /R/

    parameter set_I = 4'b0001;
    parameter set_S = 4'b0101;
    parameter set_D = 4'b1101;
    parameter set_T = 4'b0100;
    parameter set_R = 4'b1000;


    // Memoria de estados, FFs
    always @ (posedge CLK)  begin
        if (EstPres == TX_PACKET) begin
            EstPres <= ProxEstado;
        end
    end

    always @(negedge CLK) begin

        if (RESET) begin
            EstPres <= XMIT_DATA;
            ProxEstado <= XMIT_DATA;
            transmitting <= 0;
            tx_even <= 1;
        end
        else begin
            EstPres <= ProxEstado;
            tx_even <= ~tx_even;
            
        end
    end

    always @(*)
        case (EstPres)
            XMIT_DATA:  begin 
                if (!TX_EN & !TX_ER & TX_OSET_indicate) ProxEstado = XMIT_DATA;
                if (TX_EN  & !TX_ER & TX_OSET_indicate) ProxEstado = START_OF_PACKET;
                tx_o_set = set_I;
            end  
            START_OF_PACKET: begin
                tx_o_set = set_S;
                transmitting = 1;
                if (TX_OSET_indicate) ProxEstado = TX_PACKET;
                
            end

            TX_PACKET: begin
                if (TX_EN)              ProxEstado = TX_DATA;
                if (!TX_EN & !TX_ER)    ProxEstado = END_OF_PACKET_NOEXT;
                tx_o_set = 0;
            end

            TX_DATA: begin
                if (TX_OSET_indicate) ProxEstado = TX_PACKET;
                tx_o_set = set_D;
            end

            END_OF_PACKET_NOEXT: begin
                if (!tx_even) transmitting = 0;
                tx_o_set = set_T;
                if (TX_OSET_indicate) ProxEstado = EPD2_NOEXT;
            end

            EPD2_NOEXT: begin
                transmitting = 0;
                tx_o_set = set_R;
                if (!tx_even & TX_OSET_indicate) ProxEstado = XMIT_DATA;
            end
        endcase


endmodule