module delay_config #(
    parameter DELAY_SELECT = 0
)(
    output wire [47:0] delays  // 12 x 4-bit delays packed
);

  // Function to pack 12 4-bit delays into 48 bits
  function [47:0] pack_delays;
    input [3:0] d0, d1, d2, d3, d4, d5;
    input [3:0] d6, d7, d8, d9, d10, d11;
    begin
      pack_delays = {d11, d10, d9, d8, d7, d6, d5, d4, d3, d2, d1, d0};
    end
  endfunction

  // Delay configurations for all 12 source directions
  // Mics: M37  M39  M41  M43  M45  M47  M49  M51  M53  M55  M57  M59
  localparam [47:0] DELAY_CONFIG_0  = pack_delays(8,7,6,3,2,0,1,0,2,3,6,7);  // Source M37
  localparam [47:0] DELAY_CONFIG_1  = pack_delays(9,10,9,7,5,2,2,0,2,2,5,7);  // Source M39
  localparam [47:0] DELAY_CONFIG_2  = pack_delays(6,7,8,7,6,3,2,0,1,0,2,3);  // Source M41
  localparam [47:0] DELAY_CONFIG_3  = pack_delays(5,7,9,10,9,7,5,2,2,0,2,2);  // Source M43
  localparam [47:0] DELAY_CONFIG_4  = pack_delays(2,3,6,7,8,7,6,3,2,0,1,0);  // Source M45
  localparam [47:0] DELAY_CONFIG_5  = pack_delays(2,2,5,7,9,10,9,7,5,2,2,0);  // Source M47
  localparam [47:0] DELAY_CONFIG_6  = pack_delays(1,0,2,3,6,7,8,7,6,3,2,0);  // Source M49
  localparam [47:0] DELAY_CONFIG_7  = pack_delays(2,0,2,2,5,7,9,10,9,7,5,2);  // Source M51
  localparam [47:0] DELAY_CONFIG_8  = pack_delays(2,0,1,0,2,3,6,7,8,7,6,3);  // Source M53
  localparam [47:0] DELAY_CONFIG_9  = pack_delays(5,2,2,0,2,2,5,7,9,10,9,7);  // Source M55
  localparam [47:0] DELAY_CONFIG_10 = pack_delays(6,3,2,0,1,0,2,3,6,7,8,7);  // Source M57
  localparam [47:0] DELAY_CONFIG_11 = pack_delays(9,7,5,2,2,0,2,2,5,7,9,10);  // Source M59

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
    48'h0;

endmodule