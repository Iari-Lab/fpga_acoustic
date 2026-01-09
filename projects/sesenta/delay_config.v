module delay_config #(
    parameter DELAY_SELECT = 0
)(
    output wire [119:0] delays  // 30 x 4-bit delays packed
);

  // Function to pack 30 4-bit delays into 120 bits
  function [119:0] pack_delays;
    input [3:0] d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14;
    input [3:0] d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29;
    begin
      pack_delays = {d29, d28, d27, d26, d25, d24, d23, d22, d21, d20, d19, d18, d17, d16, d15, d14, d13, d12, d11, d10, d9, d8, d7, d6, d5, d4, d3, d2, d1, d0};
    end
  endfunction

  // Delay configurations for all 30 source directions
  // Mics: M1  M3  M5  M7  M9  M11  M13  M15  M17  M19  M21  M23  M25  M27  M29  M31  M33  M35  M37  M39  M41  M43  M45  M47  M49  M51  M53  M55  M57  M59
  localparam [119:0] DELAY_CONFIG_0  = pack_delays(4,4,4,4,4,4,3,3,3,3,4,4,4,3,2,2,2,2,2,2,3,3,3,2,2,1,1,0,1,1);  // Source M1
  localparam [119:0] DELAY_CONFIG_1  = pack_delays(4,4,4,3,3,4,4,4,3,2,2,2,3,4,4,4,3,2,1,0,1,1,2,2,3,3,3,2,2,1);  // Source M3
  localparam [119:0] DELAY_CONFIG_2  = pack_delays(4,4,4,4,3,3,3,4,4,4,3,2,2,2,2,3,4,4,3,2,2,1,1,0,1,1,2,2,3,3);  // Source M5
  localparam [119:0] DELAY_CONFIG_3  = pack_delays(5,4,5,6,5,4,3,4,5,6,6,5,4,3,2,3,4,5,5,5,5,4,3,1,1,0,1,1,3,4);  // Source M7
  localparam [119:0] DELAY_CONFIG_4  = pack_delays(6,5,5,5,6,5,4,3,4,4,5,6,5,4,3,2,2,3,3,4,5,5,5,4,3,1,1,0,1,1);  // Source M9
  localparam [119:0] DELAY_CONFIG_5  = pack_delays(5,5,4,4,5,6,5,4,3,3,4,5,6,6,5,4,3,2,1,1,3,4,5,5,5,4,3,1,1,0);  // Source M11
  localparam [119:0] DELAY_CONFIG_6  = pack_delays(5,6,5,3,4,5,6,5,4,2,2,3,4,5,6,5,4,3,1,0,1,1,3,4,5,5,5,4,3,1);  // Source M13
  localparam [119:0] DELAY_CONFIG_7  = pack_delays(4,5,5,4,3,4,5,6,5,4,3,2,3,4,5,6,6,5,3,1,1,0,1,1,3,4,5,5,5,4);  // Source M15
  localparam [119:0] DELAY_CONFIG_8  = pack_delays(5,5,6,5,4,3,4,5,6,5,4,3,2,2,3,4,5,6,5,4,3,1,1,0,1,1,3,4,5,5);  // Source M17
  localparam [119:0] DELAY_CONFIG_9  = pack_delays(6,5,6,7,5,4,3,5,6,7,6,5,3,2,2,3,5,6,7,6,6,4,3,1,1,0,2,2,5,6);  // Source M19
  localparam [119:0] DELAY_CONFIG_10 = pack_delays(6,5,6,7,6,5,3,4,5,6,7,6,5,3,2,2,3,5,6,6,7,6,5,2,2,0,1,1,3,4);  // Source M21
  localparam [119:0] DELAY_CONFIG_11 = pack_delays(7,5,5,6,8,6,4,3,4,5,7,8,7,5,3,3,3,3,4,5,7,8,7,5,4,2,1,0,1,2);  // Source M23
  localparam [119:0] DELAY_CONFIG_12 = pack_delays(6,6,5,5,6,7,5,4,3,3,5,6,7,6,5,3,2,2,2,2,5,6,7,6,6,4,3,1,1,0);  // Source M25
  localparam [119:0] DELAY_CONFIG_13 = pack_delays(6,6,5,4,5,7,6,5,3,2,3,5,6,7,6,5,3,2,1,1,3,4,6,6,7,6,5,2,2,0);  // Source M27
  localparam [119:0] DELAY_CONFIG_14 = pack_delays(5,7,5,3,4,6,8,6,4,3,3,3,5,7,8,7,5,3,1,0,1,2,4,5,7,8,7,5,4,2);  // Source M29
  localparam [119:0] DELAY_CONFIG_15 = pack_delays(5,6,6,4,3,5,6,7,5,3,2,2,3,5,6,7,6,5,3,1,1,0,2,2,5,6,7,6,6,4);  // Source M31
  localparam [119:0] DELAY_CONFIG_16 = pack_delays(5,6,6,5,3,4,5,7,6,5,3,2,2,3,5,6,7,6,5,2,2,0,1,1,3,4,6,6,7,6);  // Source M33
  localparam [119:0] DELAY_CONFIG_17 = pack_delays(5,5,7,6,4,3,4,6,8,7,5,3,3,3,3,5,7,8,7,5,4,2,1,0,1,2,4,5,7,8);  // Source M35
  localparam [119:0] DELAY_CONFIG_18 = pack_delays(6,5,7,7,5,3,3,5,7,8,7,5,3,2,2,4,6,8,8,7,6,3,2,0,1,0,2,3,6,7);  // Source M37
  localparam [119:0] DELAY_CONFIG_19 = pack_delays(7,5,7,9,8,5,4,5,8,9,9,7,5,3,2,3,5,7,9,10,9,7,5,2,2,0,2,2,5,7);  // Source M39
  localparam [119:0] DELAY_CONFIG_20 = pack_delays(7,5,6,7,7,5,3,3,5,7,8,8,6,4,2,2,3,5,6,7,8,7,6,3,2,0,1,0,2,3);  // Source M41
  localparam [119:0] DELAY_CONFIG_21 = pack_delays(8,6,6,8,9,8,5,4,5,6,8,10,8,6,4,3,3,4,5,7,9,10,9,7,5,2,2,0,2,2);  // Source M43
  localparam [119:0] DELAY_CONFIG_22 = pack_delays(7,6,5,5,7,7,5,3,3,4,6,8,8,7,5,3,2,2,2,3,6,7,8,7,6,3,2,0,1,0);  // Source M45
  localparam [119:0] DELAY_CONFIG_23 = pack_delays(7,7,5,5,8,9,8,5,4,3,5,7,9,9,7,5,3,2,2,2,5,7,9,10,9,7,5,2,2,0);  // Source M47
  localparam [119:0] DELAY_CONFIG_24 = pack_delays(6,7,5,3,5,7,7,5,3,2,3,5,7,8,8,6,4,2,1,0,2,3,6,7,8,7,6,3,2,0);  // Source M49
  localparam [119:0] DELAY_CONFIG_25 = pack_delays(6,8,6,4,5,8,9,8,5,3,3,4,6,8,10,8,6,4,2,0,2,2,5,7,9,10,9,7,5,2);  // Source M51
  localparam [119:0] DELAY_CONFIG_26 = pack_delays(5,7,6,3,3,5,7,7,5,3,2,2,4,6,8,8,7,5,2,0,1,0,2,3,6,7,8,7,6,3);  // Source M53
  localparam [119:0] DELAY_CONFIG_27 = pack_delays(5,7,7,5,4,5,8,9,8,5,3,2,3,5,7,9,9,7,5,2,2,0,2,2,5,7,9,10,9,7);  // Source M55
  localparam [119:0] DELAY_CONFIG_28 = pack_delays(5,6,7,5,3,3,5,7,7,6,4,2,2,3,5,7,8,8,6,3,2,0,1,0,2,3,6,7,8,7);  // Source M57
  localparam [119:0] DELAY_CONFIG_29 = pack_delays(6,6,8,8,5,4,5,8,9,8,6,4,3,3,4,6,8,10,9,7,5,2,2,0,2,2,5,7,9,10);  // Source M59

  // Select the appropriate delay configuration
  assign delays = 
    (DELAY_SELECT == 0 ) ? DELAY_CONFIG_0  :
    (DELAY_SELECT == 1 ) ? DELAY_CONFIG_1  :
    (DELAY_SELECT == 2 ) ? DELAY_CONFIG_2  :
    (DELAY_SELECT == 3 ) ? DELAY_CONFIG_3  :
    (DELAY_SELECT == 4 ) ? DELAY_CONFIG_4  :
    (DELAY_SELECT == 5 ) ? DELAY_CONFIG_5  :
    (DELAY_SELECT == 6 ) ? DELAY_CONFIG_6  :
    (DELAY_SELECT == 7 ) ? DELAY_CONFIG_7  :
    (DELAY_SELECT == 8 ) ? DELAY_CONFIG_8  :
    (DELAY_SELECT == 9 ) ? DELAY_CONFIG_9  :
    (DELAY_SELECT == 10) ? DELAY_CONFIG_10 :
    (DELAY_SELECT == 11) ? DELAY_CONFIG_11 :
    (DELAY_SELECT == 12) ? DELAY_CONFIG_12 :
    (DELAY_SELECT == 13) ? DELAY_CONFIG_13 :
    (DELAY_SELECT == 14) ? DELAY_CONFIG_14 :
    (DELAY_SELECT == 15) ? DELAY_CONFIG_15 :
    (DELAY_SELECT == 16) ? DELAY_CONFIG_16 :
    (DELAY_SELECT == 17) ? DELAY_CONFIG_17 :
    (DELAY_SELECT == 18) ? DELAY_CONFIG_18 :
    (DELAY_SELECT == 19) ? DELAY_CONFIG_19 :
    (DELAY_SELECT == 20) ? DELAY_CONFIG_20 :
    (DELAY_SELECT == 21) ? DELAY_CONFIG_21 :
    (DELAY_SELECT == 22) ? DELAY_CONFIG_22 :
    (DELAY_SELECT == 23) ? DELAY_CONFIG_23 :
    (DELAY_SELECT == 24) ? DELAY_CONFIG_24 :
    (DELAY_SELECT == 25) ? DELAY_CONFIG_25 :
    (DELAY_SELECT == 26) ? DELAY_CONFIG_26 :
    (DELAY_SELECT == 27) ? DELAY_CONFIG_27 :
    (DELAY_SELECT == 28) ? DELAY_CONFIG_28 :
    (DELAY_SELECT == 29) ? DELAY_CONFIG_29 :
    120'h0;

endmodule