/****   Archivo: "TRANSMIT_CODE_GROUP.v" 
***** De la máquina de estados de TRANSMIT relacionada a traducir los code-groups de 8 a 10 bits
***** de /I/ /S/ /D/... /D/ /T/ /R/
*****               Grupo 3
*****   IE0523 - Circuitos Digitales II
*/


// Declaración del módulo y parámetros
module TRANSMIT_CODE_GROUP (cg_timer_done, tx_o_set, TX_OSET_indicate, PUDR, tx_code_group, reset, GTX_CLK, TXD);

localparam GENERATECODEGROUPS    = 5'h01;
localparam SPECIAL_GO            = 5'h02;
localparam DATA_GO               = 5'h04;
localparam IDLE_DISPARITY_OK     = 5'h08;
localparam IDLE_I2B              = 5'h10;

parameter set_I = 4'b0001;
parameter set_S = 4'b0101;
parameter set_D = 4'b1101;
parameter set_T = 4'b0100;
parameter set_R = 4'b1000;

parameter set_Ip = 10'b1100000101; // K28.5 +
parameter set_Sp = 10'b0010010111; // K27.7 +
parameter set_Tp = 10'b0100010111; // K29.7 +
parameter set_Rp = 10'b0001010111; // K23.7 +

parameter set_In = 10'b0110110101; //D16.2 -
parameter set_Sn = 10'b1101101000; // K27.7 -
parameter set_Tn = 10'b1011101000; // K29.7 -
parameter set_Rn = 10'b1110101000; // K23.7 -

// Octetos de los diez datos elegidos
parameter set_D_0_0 = 8'b00000000;
parameter set_D_1_0 = 8'b00000001;
parameter set_D_2_1 = 8'b00100010;
parameter set_D_3_2 = 8'b01000011;
parameter set_D_4_3 = 8'b01100100;
parameter set_D_5_4 = 8'b10000101;
parameter set_D_6_5 = 8'b10100110;
parameter set_D_7_6 = 8'b11000111;
parameter set_D_8_7 = 8'b11101000;
parameter set_D_9_7 = 8'b11101001;

// Traducciones a diez bits en RD+ de los octetos
parameter set_D_0_0p = 10'b0110001011;
parameter set_D_1_0p = 10'b1000101011;
parameter set_D_2_1p = 10'b0100101001;
parameter set_D_3_2p = 10'b1100010101;
parameter set_D_4_3p = 10'b0010101100;
parameter set_D_5_4p = 10'b1010010010;
parameter set_D_6_5p = 10'b0110011010;
parameter set_D_7_6p = 10'b0001110110;
parameter set_D_8_7p = 10'b0001101110;
parameter set_D_9_7p = 10'b1001011110;

// Traducciones a diez bits en RD- de los octetos
parameter set_D_0_0n = 10'b1001110100;
parameter set_D_1_0n = 10'b0111010100;
parameter set_D_2_1n = 10'b1011011001;
parameter set_D_3_2n = 10'b1100010101;
parameter set_D_4_3n = 10'b1101010011;
parameter set_D_5_4n = 10'b1010011101;
parameter set_D_6_5n = 10'b0110011010;
parameter set_D_7_6n =  10'b1110000110;
parameter set_D_8_7n = 10'b1110010001;
parameter set_D_9_7n = 10'b1001010001;

// Declaración de entradas y salidas
input cg_timer_done, GTX_CLK,reset;
input [7:0]  tx_o_set, TXD;
output  TX_OSET_indicate, PUDR;
reg  TX_OSET_indicate, PUDR;
output reg [9:0] tx_code_group;

//Declaración de variables internas
reg tx_even, next_tx_even;

//Se usan 5 bits para que sea un flip flop por estado (one-hot encoding) que elimina las carreras
//de estado (race conditions)
reg [4:0] state, next_state;


//Definir todos los flip flops y el caso de reset
always @ (*)  begin
  if (state == GENERATECODEGROUPS) begin
    state        <= next_state;
  end
end

always @ (negedge GTX_CLK)  begin
  if (reset) begin
    state         <= GENERATECODEGROUPS;
    tx_code_group <= 0;
  end else begin
    state        <= next_state;
    tx_even <= next_tx_even;
  end
end

//Definir lógica combinacional
//Case de los estados
always @ (*)  begin
  //Case de estados para definir:
  //1. Lógica de próximo estado
  //2. Lógica de salida
  next_state     = state;
  TX_OSET_indicate    = 1'b0;
  PUDR                = 1'b0;
  next_tx_even = ~tx_even;

  case (state)
  //Estado de GENERATECODEGROUPS
    GENERATECODEGROUPS: begin
      if(tx_o_set == set_S || tx_o_set == set_T ||tx_o_set == set_R) begin 
        next_state     = SPECIAL_GO;
      end
      else if(tx_o_set == set_I) begin 
        next_state     = IDLE_DISPARITY_OK;
      end
      else if(tx_o_set == set_D)begin 
        next_state     = DATA_GO;
      end
    end
  //Estado de SPECIAL_GO
    SPECIAL_GO: begin 
        TX_OSET_indicate    = 1'b1;
        PUDR                = 1'b1;
        if(tx_o_set == set_T && tx_even) tx_code_group <= set_Tp;
        else if(tx_o_set == set_T && ~tx_even) tx_code_group <= set_Tn;
        else if(tx_o_set == set_S && tx_even) tx_code_group <= set_Sp;
        else if(tx_o_set == set_S && ~tx_even) tx_code_group <= set_Sn;
        else if(tx_o_set == set_R && tx_even) tx_code_group <= set_Rp;
        else if(tx_o_set == set_R && ~tx_even) tx_code_group <= set_Rn;
        if(cg_timer_done) begin 
            next_state     = GENERATECODEGROUPS;
        end
	end
  //Estado de DATA_GO
    DATA_GO: begin 
        TX_OSET_indicate    = 1'b1;
        PUDR                = 1'b1;
        if(TXD == set_D_1_0 && tx_even) tx_code_group <= set_D_1_0p;
        else if(TXD == set_D_1_0 && ~tx_even) tx_code_group <= set_D_1_0n;
        else if(TXD == set_D_2_1 && tx_even) tx_code_group <= set_D_2_1p;
        else if(TXD == set_D_2_1 && ~tx_even) tx_code_group <= set_D_2_1n;
        else if(TXD == set_D_3_2 && tx_even) tx_code_group <= set_D_3_2p;
        else if(TXD == set_D_3_2 && ~tx_even) tx_code_group <= set_D_3_2n;
        else if(TXD == set_D_4_3 && tx_even) tx_code_group <= set_D_4_3p;
        else if(TXD == set_D_4_3 && ~tx_even) tx_code_group <= set_D_4_3n;
        else if(TXD == set_D_0_0 && tx_even) tx_code_group <= set_D_0_0p;
        else if(TXD == set_D_0_0 && ~tx_even) tx_code_group <= set_D_0_0n;
        else if(TXD == set_D_5_4 && tx_even) tx_code_group <= set_D_5_4p;
        else if(TXD == set_D_5_4 && ~tx_even) tx_code_group <= set_D_5_4n;
        else if(TXD == set_D_6_5 && tx_even) tx_code_group <= set_D_6_5p;
        else if(TXD == set_D_6_5 && ~tx_even) tx_code_group <= set_D_6_5n;
        else if(TXD == set_D_7_6 && tx_even) tx_code_group <= set_D_7_6p;
        else if(TXD == set_D_7_6 && ~tx_even) tx_code_group <= set_D_7_6n;
        else if(TXD == set_D_8_7 && tx_even) tx_code_group <= set_D_8_7p;
        else if(TXD == set_D_8_7 && ~tx_even) tx_code_group <= set_D_8_7n;
        else if(TXD == set_D_9_7 && tx_even) tx_code_group <= set_D_9_7p;
        else if(TXD == set_D_9_7 && ~tx_even) tx_code_group <= set_D_9_7n;
        if(cg_timer_done) begin 
        next_state     = GENERATECODEGROUPS;
      end
	       end
  //Estado de IDLE_DISPARITY_OK
    IDLE_DISPARITY_OK: begin 
        PUDR                = 1'b1;
        tx_even <= 1;
	      tx_code_group <= set_Ip;
        if(cg_timer_done) begin 
        next_state     = IDLE_I2B;
        end
	       end
  //Estado de IDLE_I2B
    IDLE_I2B: begin 
        TX_OSET_indicate    = 1'b1;
        PUDR                = 1'b1;
        tx_even <= 0;
        tx_code_group <= set_In;
        if(cg_timer_done) begin 
        next_state     = GENERATECODEGROUPS;
      end
	       end
//Cualquier otro caso no se utilizo
    default: begin 
             end
  endcase

end

endmodule