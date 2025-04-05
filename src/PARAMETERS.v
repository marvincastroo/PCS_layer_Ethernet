

// Caráceteres especiales

    // COMMA
    parameter K_28_5_neg = 10'b00_1111_1010;
    parameter K_28_5_pos = 10'b11_0000_0101;


    // Ciclo par
    parameter set_Ip = 10'b11_0000_0101; // K28.5 +
    parameter set_Sp = 10'b00_1001_0111; // K27.7 +
    parameter set_Tp = 10'b01_0001_0111; // K29.7 +
    parameter set_Rp = 10'b00_0101_0111; // K23.7 +

    // Ciclo impar
    parameter set_In = 10'b01_1011_0101; //D16.2 -
    parameter set_Sn = 10'b11_0110_1000; // K27.7 -
    parameter set_Tn = 10'b10_1110_1000; // K29.7 -
    parameter set_Rn = 10'b11_1010_1000; // K23.7 -
// DATA
    // DATA: 8 bits
        parameter set_decod_D_0_0 = 8'b0000_0000;
        parameter set_decod_D_1_0 = 8'b0000_0001;
        parameter set_decod_D_2_1 = 8'b0010_0010;
        parameter set_decod_D_3_2 = 8'b0100_0011;
        parameter set_decod_D_4_3 = 8'b0110_0100;
        parameter set_decod_D_5_4 = 8'b1000_0101;
        parameter set_decod_D_6_5 = 8'b1010_0110;
        parameter set_decod_D_7_6 = 8'b1100_0111;
        parameter set_decod_D_8_7 = 8'b1110_1000;
        parameter set_decod_D_9_7 = 8'b1110_1001;

    // DATA: 10 bits (codificado)
        // Ciclo par
        parameter set_D_0_0p = 10'b01_1000_1011;
        parameter set_D_1_0p = 10'b10_0010_1011;
        parameter set_D_2_1p = 10'b01_0010_1001;
        parameter set_D_3_2p = 10'b11_0001_0101;
        parameter set_D_4_3p = 10'b00_1010_1100;
        parameter set_D_5_4p = 10'b10_1001_0010;
        parameter set_D_6_5p = 10'b01_1001_1010;
        parameter set_D_7_6p = 10'b00_0111_0110;
        parameter set_D_8_7p = 10'b00_0110_1110;
        parameter set_D_9_7p = 10'b10_0101_1110;

        // Ciclo impar
        parameter set_D_0_0n = 10'b10_0111_0100;
        parameter set_D_1_0n = 10'b01_1101_0100;
        parameter set_D_2_1n = 10'b10_1101_1001;
        parameter set_D_3_2n = 10'b11_0001_0101;
        parameter set_D_4_3n = 10'b11_0101_0011;
        parameter set_D_5_4n = 10'b10_1001_1101;
        parameter set_D_6_5n = 10'b01_1001_1010;
        parameter set_D_7_6n = 10'b11_1000_0110;
        parameter set_D_8_7n = 10'b11_1001_0001;
        parameter set_D_9_7n = 10'b10_0101_0001;



