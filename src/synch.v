module synchronization(
                       input CLK,
                       input POWER,
                       input RESET,
                       input SIGNAL_CHANGE,
                       input SIGNAL_DETECT,
                       input [9:0] PUDI,
                       input MR_LOOPBACK,

                       output reg CODE_SYNC,
                       output reg RX_EVEN,
                       output reg [9:0] SUDI,
                       output reg GOOD_CGS,
                       output reg testing
);

`include "PARAMETERS.v"

localparam comma1 = 6'b110000;
localparam comma2 = 6'b001111;

/* -----------------------------------------------

   Como la elección de datos /D/ es arbitraria, se 
   van a utilizar únicamente los datos Dx.y, en 
   donde 0<x<2 y 0<y<2, es decir, solo son admiti-
   dos las combinaciones de estos datos:

   D0.0, D0.1, D0.2
   D1.0, D1.1, D1.2
   D2.0, D2.1, D2.2

   Para efectos del primer avance, se utilizarán 
   esos nueve datos /D/ únicamente y para poder 
   verificar que el dato es válido, se utilizara
   una función llamada Valid_PUDI que devolverá 
   TRUE si sí es válido y FALSE si no lo es

   ----------------------------------------------- */

function reg Valid_PUDI(input reg [9:0] PUDI);

    begin
      if (PUDI == set_Ip ||
          PUDI == set_In ||
          PUDI == set_Sp ||
          PUDI == set_Sn ||
          PUDI == set_Tp ||
          PUDI == set_Tn ||
          PUDI == set_Rp ||
          PUDI == set_Rn ||
          PUDI == set_D_0_0p ||
          PUDI == set_D_1_0p ||
          PUDI == set_D_2_1p ||

          PUDI == set_D_3_2p ||
          PUDI == set_D_4_3p ||
          PUDI == set_D_5_4p ||

          PUDI == set_D_6_5p ||
          PUDI == set_D_7_6p ||
          PUDI == set_D_7_6p ||
          
          PUDI == set_D_8_7p ||
          PUDI == set_D_9_7p || 
          PUDI == set_D_8_7p ||
          PUDI == set_D_0_0n ||
          PUDI == set_D_1_0n ||
          PUDI == set_D_2_1n ||

          PUDI == set_D_3_2n ||
          PUDI == set_D_4_3n ||
          PUDI == set_D_5_4n ||

          PUDI == set_D_6_5n ||
          PUDI == set_D_7_6n ||
          PUDI == set_D_7_6n ||
          
          PUDI == set_D_8_7n ||
          PUDI == set_D_9_7n || 
          PUDI == set_D_8_7n 
          ) begin
        
          Valid_PUDI = 1;

          end else Valid_PUDI = 0;
    end
    
endfunction

// -----------------------------------------------

/* 
   Según el diagrama del standard, 
   la sincronización cuenta con 13 estados 
   (Figura 36-9)
*/


parameter IDLE = 0;
parameter LOSS_OF_SYNC = 1;
parameter COMMA_DETECT_1 = 2;
parameter ACCQUIRE_SYNC_1 = 3;
parameter COMMA_DETECT_2 = 4;
parameter ACCQUIRE_SYNC_2 = 5;
parameter COMMA_DETECT_3 = 6;

parameter SYNC_ACQUIRED_1 = 7;
parameter SYNC_ACQUIRED_2 = 8;
parameter SYNC_ACQUIRED_3 = 9;
parameter SYNC_ACQUIRED_4 = 10;

parameter SYNC_ACQUIRED_2A = 11;
parameter SYNC_ACQUIRED_3A = 12;
parameter SYNC_ACQUIRED_4A = 13;

integer estado = IDLE; // Estado inicial

// -----------------------------------------------

always @ (*)  begin
    SUDI[9:0]  <= PUDI[9:0];
end

always @(negedge CLK) begin

    case (estado)
        IDLE: begin
            RX_EVEN = 1;
          if (POWER==1'b1 || RESET==1'b1 || (SIGNAL_CHANGE==1'b1 && MR_LOOPBACK==1'b0 && PUDI)) begin
            $display("Next State: LOSS_OF_SYNC");
            estado = estado + 1;
          end
        end

        LOSS_OF_SYNC: begin
            CODE_SYNC <= 0;
            RX_EVEN = !RX_EVEN;

            if ((PUDI && SIGNAL_DETECT==1'b0 && MR_LOOPBACK==1'b0) || PUDI[9:4]!=comma1) begin
                estado = LOSS_OF_SYNC;
            end

            if ((SIGNAL_DETECT==1 || MR_LOOPBACK==1) && PUDI[9:4]==comma1) begin
                estado = COMMA_DETECT_1;
            end
            $display("Current State: LOSS_OF_SYNC");
        end

        COMMA_DETECT_1: begin
          $display("Current State: COMMA_DETECT_1");
          RX_EVEN = 1;

          if (Valid_PUDI(PUDI) == 1) begin
            estado = ACCQUIRE_SYNC_1;
          end else if (Valid_PUDI(PUDI) == 0) begin
            estado = LOSS_OF_SYNC;
          end
        end

        ACCQUIRE_SYNC_1: begin
          $display("Current State: ACCQUIRE_SYNC_1");
          RX_EVEN = !RX_EVEN;
          testing = 1;

          if (RX_EVEN == 0 && PUDI[9:4] == comma1) begin
            estado = COMMA_DETECT_2;
          end else if((PUDI[9:4] == comma1 && RX_EVEN == 1) || Valid_PUDI(PUDI) == 0) begin
            estado = LOSS_OF_SYNC;
          end else if (PUDI[9:4] == comma1 && Valid_PUDI(PUDI) == 0) begin
            estado = ACCQUIRE_SYNC_1;
          end
        end

        COMMA_DETECT_2: begin
          $display("Current State: COMMA_DETECT_2");
          RX_EVEN = 1;

          if (Valid_PUDI(PUDI) == 1) begin
            estado = ACCQUIRE_SYNC_2;
          end else estado = LOSS_OF_SYNC;
        end

        ACCQUIRE_SYNC_2: begin
          $display("Current State: ACCQUIRE_SYNC_2");
          RX_EVEN = !RX_EVEN;

          if (RX_EVEN == 0 && PUDI[9:4] == comma1) begin
            estado = COMMA_DETECT_3;
          end else if((PUDI[9:4] == comma1 && RX_EVEN == 1) || Valid_PUDI(PUDI) == 0) begin
            estado = LOSS_OF_SYNC;
          end else if (PUDI[9:4] == comma1 && Valid_PUDI(PUDI) == 0) begin
            estado = ACCQUIRE_SYNC_2;
          end
        end

        COMMA_DETECT_3: begin
          $display("Current State: COMMA_DETECT_3");
          RX_EVEN = !RX_EVEN;
          CODE_SYNC = 1;

          if (Valid_PUDI(PUDI) == 1) begin
            estado = SYNC_ACQUIRED_1;
          end else estado = LOSS_OF_SYNC;
        end

        // SYNC_ACQUIRED_X

        SYNC_ACQUIRED_1: begin
          $display("Current State: SYNC_ACQUIRED_1");
          
          RX_EVEN = !RX_EVEN;
          if((PUDI[9:4] == comma1 && RX_EVEN == 1) || (Valid_PUDI(PUDI) == 1)) begin
            estado = SYNC_ACQUIRED_1;
          end
          else if ((Valid_PUDI(PUDI) == 0)) begin
            estado = SYNC_ACQUIRED_2;
          end 
        end

        SYNC_ACQUIRED_2: begin
          $display("Current State: SYNC_ACQUIRED_2");
          RX_EVEN = !RX_EVEN;
          GOOD_CGS = 0;

          if ((PUDI[9:4] == comma1 && RX_EVEN == 1) || !(Valid_PUDI(PUDI) == 0)) begin
            estado = SYNC_ACQUIRED_2A;
          end else if ((PUDI[9:4] == comma1 && RX_EVEN == 1) || Valid_PUDI(PUDI) == 0) begin
            estado = SYNC_ACQUIRED_3;
          end
        end

        SYNC_ACQUIRED_3: begin
          $display("Current State: SYNC_ACQUIRED_3");
          RX_EVEN = !RX_EVEN;
          GOOD_CGS = 0;

          if ((PUDI[9:4] == comma1 && RX_EVEN == 1) || !(Valid_PUDI(PUDI) == 0)) begin
            estado = SYNC_ACQUIRED_3A;
          end else if ((PUDI[9:4] == comma1 && RX_EVEN == 1) || Valid_PUDI(PUDI) == 0) begin
            estado = SYNC_ACQUIRED_4;
          end
        end

        SYNC_ACQUIRED_3: begin
          $display("Current State: SYNC_ACQUIRED_4");
          RX_EVEN = !RX_EVEN;
          GOOD_CGS = 0;

          if ((PUDI[9:4] == comma1 && RX_EVEN == 1) || !(Valid_PUDI(PUDI) == 0)) begin
            estado = SYNC_ACQUIRED_4A;
          end else if ((PUDI[9:4] == comma1 && RX_EVEN == 1) || Valid_PUDI(PUDI) == 0) begin
            estado = LOSS_OF_SYNC;
          end
        end

        // SYNC_ACQUIRED_XA

        SYNC_ACQUIRED_2A: begin
          $display("Current State: SYNC_ACQUIRED_2A");
          RX_EVEN = !RX_EVEN;
          GOOD_CGS = GOOD_CGS + 1;

          if (GOOD_CGS == 3 && ((PUDI[9:4] == comma1 && RX_EVEN == 1) || !(Valid_PUDI(PUDI) == 0))) begin
            estado = SYNC_ACQUIRED_1;
          end else if (GOOD_CGS != 3 && ((PUDI[9:4] == comma1 && RX_EVEN == 1) || !(Valid_PUDI(PUDI) == 0))) begin
            estado = SYNC_ACQUIRED_2A;
          end else if ((PUDI[9:4] == comma1 && RX_EVEN == 1) || Valid_PUDI(PUDI) == 0) begin
            estado = SYNC_ACQUIRED_3;
          end
        end

        SYNC_ACQUIRED_3A: begin
          $display("Current State: SYNC_ACQUIRED_2A");
          RX_EVEN = !RX_EVEN;
          GOOD_CGS = GOOD_CGS + 1;

          if (GOOD_CGS == 3 && ((PUDI[9:4] == comma1 && RX_EVEN == 1) || !(Valid_PUDI(PUDI) == 0))) begin
            estado = SYNC_ACQUIRED_2;
          end else if (GOOD_CGS != 3 && ((PUDI[9:4] == comma1 && RX_EVEN == 1) || !(Valid_PUDI(PUDI) == 0))) begin
            estado = SYNC_ACQUIRED_3A;
          end else if ((PUDI[9:4] == comma1 && RX_EVEN == 1) || Valid_PUDI(PUDI) == 0) begin
            estado = SYNC_ACQUIRED_4;
          end
        end

        SYNC_ACQUIRED_4A: begin
          $display("Current State: SYNC_ACQUIRED_2A");
          RX_EVEN = !RX_EVEN;
          GOOD_CGS = GOOD_CGS + 1;

          if (GOOD_CGS == 3 && ((PUDI[9:4] == comma1 && RX_EVEN == 1) || !(Valid_PUDI(PUDI) == 0))) begin
            estado = SYNC_ACQUIRED_3;
          end else if (GOOD_CGS != 3 && ((PUDI[9:4] == comma1 && RX_EVEN == 1) || !(Valid_PUDI(PUDI) == 0))) begin
            estado = SYNC_ACQUIRED_4A;
          end else if ((PUDI[9:4] == comma1 && RX_EVEN == 1) || Valid_PUDI(PUDI) == 0) begin
            estado = LOSS_OF_SYNC;
          end
        end

    endcase
end

endmodule