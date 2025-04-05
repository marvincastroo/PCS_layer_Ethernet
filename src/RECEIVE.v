/****   Archivo: "RECEIVE.v" 
***** Implementación de la máquina de estados RECEIVE, encargada de recibir
***** los code groups de 10 bits, enviar el preámbulo y decodificar los 
***** codegroups /D/ de 10 a 8 bits. El resultado se observa en la salida RXD
*****               Grupo 3
*****   IE0523 - Circuitos Digitales II               *****/


module RECEIVE(RESET, CLK, EVEN, xmit, sync_status, SUDI, RXD, RX_DV);

    `include "PARAMETERS.v"
    // sync_status: Señal de SYNCHRONIZE que indica sincronización exitosa
    // xmit: señal de AUTO_NEGOTIATION. Se asume un valor de 1


    input RESET, CLK, sync_status, xmit;
    input [9:0] SUDI;                        // 10 bits codificados, ciclo par o impar
    input EVEN;                              // señal que indica ciclo par o impar
    output reg [7:0] RXD;                    // salida 8 bits decodificados
    output reg RX_DV;                        // dato valido. 1 = valido, 0 = no valido
    
    reg receiving;                          // indica si se están recibiendo codegroups
    reg [5:0] EstPres, ProxEst;             
    reg [29:0] check_end;                   // Registro desplazante para verificar 
                                            // un tramo de /T/R/K28.5/
                    
    parameter LINK_FAILED       = 6'b00_0001;   
    parameter WAIT_FOR_K        = 6'b00_0010;   
    parameter RX_K              = 6'b00_0100;   
    parameter IDLE_D            = 6'b00_1000;   
    parameter START_OF_PACKET   = 6'b01_0000;
    parameter RECEIVE           = 6'b00_0000;      
    parameter TRI_RRI           = 6'b10_0000;

    always @ (*)  begin
        if (EstPres == WAIT_FOR_K | RX_K) begin
            EstPres <= ProxEst;
        end
    end

    always @ (negedge CLK) begin
        if (RESET) begin
            EstPres <= LINK_FAILED;
            receiving <= 0;
            RX_DV <= 0;
            end
        else begin
            EstPres <= ProxEst;
        end
        if (EstPres == RECEIVE) begin
            check_end <= {SUDI, check_end[29 :10] };
        end
        
    end

    always @(*) begin
        case (EstPres)
            // Estado 01: Inicial
            // Se sale de este estado solo si sync_status es 1
            LINK_FAILED: begin
                if (sync_status) begin ProxEst = WAIT_FOR_K; end
                else begin ProxEst = LINK_FAILED;
                    end 
                end
            
            // Estado 02: Se esperan valores de comma 
            // una vez recibidos, se pasa a RX_K
            WAIT_FOR_K: begin
                if (SUDI == K_28_5_neg || SUDI == K_28_5_pos && EVEN) begin
                        ProxEst = RX_K;   
                    end
                receiving <= 0;
                RX_DV <= 0;  
            end
            // Estado 04: Se esperan valores /D/
            // una vez recibidos, se pasa a IDLE_D
            RX_K: begin
                if (SUDI == set_In || 
                    SUDI == set_D_0_0p || SUDI == set_D_0_0n ||
                    SUDI == set_D_1_0p || SUDI == set_D_1_0n ||
                    SUDI == set_D_2_1p || SUDI == set_D_2_1n ||
                    SUDI == set_D_3_2p || SUDI == set_D_3_2n ||
                    SUDI == set_D_4_3p || SUDI == set_D_4_3n ||
                    SUDI == set_D_5_4p || SUDI == set_D_5_4n ||
                    SUDI == set_D_6_5p || SUDI == set_D_6_5n ||
                    SUDI == set_D_7_6p || SUDI == set_D_7_6n ||
                    SUDI == set_D_8_7p || SUDI == set_D_8_7n ||
                    SUDI == set_D_9_7p || SUDI == set_D_9_7n ) begin
                    ProxEst = IDLE_D;
                    end
                    check_end = 0;
                    RX_DV = 0;    
            end
            // Estado 08: Se espera nuevamente una comma
            // una vez recibido, se pasa a START_OF_PACKET
            IDLE_D: begin
                if (SUDI == K_28_5_neg || SUDI == K_28_5_pos) ProxEst = RX_K;
                else if (xmit) ProxEst = START_OF_PACKET;
            end
            // Estado 10: Marca el inicio del tramo de datos. Se envía el preámbulo en RXD
            // Se pasa a RECEIVE
            START_OF_PACKET: begin 
                receiving = 1;
                ProxEst =   RECEIVE;
                RX_DV = 1;
                RXD = 8'b0101_0101;
            end

            // Estado 00: Se hace la traducción de cada codegroup de /D/
            // Se verifica por medio de un registro desplazante de 30 bits, si entran
            // los codegroups /T/R/K28.5/ consecutivamente. 
            // Si es así, se pasa al estado TRI_RRI
            RECEIVE: begin
                case (SUDI)
                    set_D_0_0p: RXD = set_decod_D_0_0;
                    set_D_0_0n: RXD = set_decod_D_0_0;
                    set_D_1_0p: RXD = set_decod_D_1_0;
                    set_D_1_0n: RXD = set_decod_D_1_0;
                    set_D_2_1p: RXD = set_decod_D_2_1;
                    set_D_2_1n: RXD = set_decod_D_2_1;
                    set_D_3_2p: RXD = set_decod_D_3_2;
                    set_D_3_2n: RXD = set_decod_D_3_2;
                    set_D_4_3p: RXD = set_decod_D_4_3;
                    set_D_4_3n: RXD = set_decod_D_4_3;
                    set_D_5_4p: RXD = set_decod_D_5_4;
                    set_D_5_4n: RXD = set_decod_D_5_4;
                    set_D_6_5p: RXD = set_decod_D_6_5;
                    set_D_6_5n: RXD = set_decod_D_6_5;
                    set_D_7_6p: RXD = set_decod_D_7_6;
                    set_D_7_6n: RXD = set_decod_D_7_6;
                    set_D_8_7p: RXD = set_decod_D_8_7;
                    set_D_8_7n: RXD = set_decod_D_8_7;
                    set_D_9_7p: RXD = set_decod_D_9_7;
                    set_D_9_7n: RXD = set_decod_D_9_7;
                endcase 

                
                if (check_end == {set_Rp, set_Rn, set_Tp} ||
                    check_end == {set_Rn, set_Rp, set_Tn}) begin 
                        ProxEst = TRI_RRI;
                        RX_DV = 0;
                    end
                else begin ProxEst = RECEIVE; end
            end
            // Estado 20: Final de la trama. Se hace RX_DV = 0
            // Si se recibe una comma, se regresa al estado RX_K
            TRI_RRI:
                begin
                    receiving = 0;
                    RX_DV = 0;
                    if (SUDI == K_28_5_neg || SUDI == K_28_5_pos) ProxEst = RX_K;
                end
        endcase
    end


endmodule

