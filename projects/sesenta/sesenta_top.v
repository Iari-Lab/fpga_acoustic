`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Camilo Soto
//
// Create Date: 08/12/2023 10:50:04 AM
// Design Name:
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module sesenta_top (
    inout [14:0] DDR_addr,
    inout [2:0] DDR_ba,
    inout DDR_cas_n,
    inout DDR_ck_n,
    inout DDR_ck_p,
    inout DDR_cke,
    inout DDR_cs_n,
    inout [3:0] DDR_dm,
    inout [31:0] DDR_dq,
    inout [3:0] DDR_dqs_n,
    inout [3:0] DDR_dqs_p,
    inout DDR_odt,
    inout DDR_ras_n,
    inout DDR_reset_n,
    inout DDR_we_n,
    inout FIXED_IO_ddr_vrn,
    inout FIXED_IO_ddr_vrp,
    inout [53:0] FIXED_IO_mio,
    inout FIXED_IO_ps_clk,
    inout FIXED_IO_ps_porb,
    inout FIXED_IO_ps_srstb,
    output M0_CLK,
    output M1_CLK,
    output M2_CLK,
    input M1_DATA,
    input M0_DATA,
    input M2_DATA,
    input M4_DATA,
    input M6_DATA,
    input M8_DATA,
    input M10_DATA,
    input M12_DATA
  );

  wire mc0;
  reg c0,c1,c2;
  wire clk;
  wire rst_addr,rst_mic;
  wire [31:0] trig1,trig0;
  wire [31 : 0] addr_w,addr_wo;
  wire [31 : 0] addr_dbg;
  wire [3 : 0] wen;
  wire [3 : 0] wen_dbg; 
  wire rst;
  wire       m_clk_rising;
  wire [31:0] m1_data,m2_data,m3_data,m4_data,m5_data,m6_data,m7_data,m8_data;
  wire mic_data_valid;
  reg m1_clk;
  wire m1_clk_buffer;
  reg [31:0] addr_reg;
  reg [31:0] m1_data_reg,m2_data_reg,m3_data_reg,m4_data_reg,m5_data_reg,m6_data_reg,m7_data_reg,m8_data_reg;
  wire [31:0] m1_data_buffer,m2_data_buffer,m3_data_buffer,m4_data_buffer,m5_data_buffer,m6_data_buffer,m7_data_buffer,m8_data_buffer;
  wire M_LRSEL;

  assign rst_addr = trig0[0:0];
  assign rst_mic = trig1[0:0];
  assign addr_wo = addr_reg;
  assign M0_CLK= c0;
  assign M2_CLK= c2;
  assign M1_CLK= c1;

  address_counter #(
    .COUNT_WIDTH(14)
  ) addr_gen (
    .rst(rst_addr),
    .clk(clk),
    .address(addr_w),
    .address_dbg(addr_dbg),
    .wen(wen),
    .wen_dbg(wen_dbg)
  );
  reg [7:0] mclks;
  wire [7:0] w_mclks;
  generate
      genvar i;
      for (i = 0; i < 8; i=i+1) begin : clks_gen
          always @(posedge clk) begin
              mclks[i] <= m_clk_rising;
          end
          assign w_mclks[i] = mclks[i];
      end
  endgenerate

    localparam integer INPUT_FREQ = 125000000;
    localparam integer PDM_FREQ = 2400000;
    // Clock generator instance
    pdm_clk_gen
      #(  
        .INPUT_FREQ(INPUT_FREQ),
        .OUTPUT_FREQ(PDM_FREQ)
      )
    pdm_clk_gen_i
    (
      .clk(clk),
      .rst(rst),
      .M_CLK(mc0),
      .m_clk_rising(m_clk_rising)
    );

   pdm_mic #(
   ) mic1 (
     .clk(clk),
     .rst(rst_mic),
     .mic_data(m1_data),
     .m_clk_rising(mclks[0]),  
     .mic_data_valid(mic_data_valid),
     .M_DATA(M0_DATA),
     .M_LRSEL(M_LRSEL)
   );

   pdm_mic #(
   ) mic2 (
     .clk(clk),
     .rst(rst_mic),
     .mic_data(m2_data),
     .m_clk_rising(mclks[1]),  
     .mic_data_valid(mic_data_valid),
     .M_DATA(M1_DATA),
     .M_LRSEL(M_LRSEL)
   );
  pdm_mic #(
    ) mic3 (
      .clk(clk),
      .rst(rst_mic),
      .mic_data(m3_data),
      .m_clk_rising(mclks[2]),  
      .mic_data_valid(mic_data_valid),
      .M_DATA(M2_DATA),
      .M_LRSEL(M_LRSEL)
    );
  pdm_mic #(
    ) mic4 (
      .clk(clk),
      .rst(rst_mic),
      .mic_data(m4_data),
      .m_clk_rising(mclks[3]),  
      .mic_data_valid(mic_data_valid),
      .M_DATA(M4_DATA),
      .M_LRSEL(M_LRSEL)
    );
  pdm_mic #(
    ) mic5 (
      .clk(clk),
      .rst(rst_mic),
      .mic_data(m5_data),
      .m_clk_rising(mclks[4]),  
      .mic_data_valid(mic_data_valid),
      .M_DATA(M6_DATA),
      .M_LRSEL(M_LRSEL)
    );
  pdm_mic #(
    ) mic6 (
      .clk(clk),
      .rst(rst_mic),
      .mic_data(m6_data),
      .m_clk_rising(mclks[5]),  
      .mic_data_valid(mic_data_valid),
      .M_DATA(M8_DATA),
      .M_LRSEL(M_LRSEL)
    );

  pdm_mic #(
    ) mic7 (
      .clk(clk),
      .rst(rst_mic),
      .mic_data(m7_data),
      .m_clk_rising(mclks[6]),  
      .mic_data_valid(mic_data_valid),
      .M_DATA(M10_DATA),
      .M_LRSEL(M_LRSEL)
    );

 pdm_mic #(
   ) mic8 (
     .clk(clk),
     .rst(rst_mic),
     .mic_data(m8_data),
     .m_clk_rising(mclks[7]),  
     .mic_data_valid(mic_data_valid),
     .M_DATA(M12_DATA),
     .M_LRSEL(M_LRSEL)
   );
  always @(posedge clk)
  begin
    addr_reg <= addr_w;
    c0 <= mc0;
    c1 <= mc0;
    c2 <= mc0;
    m1_data_reg <= m1_data;
    m2_data_reg <= m2_data;
    m3_data_reg <= m3_data;
    m4_data_reg <= m4_data;
    m5_data_reg <= m5_data;
    m6_data_reg <= m6_data;
    m7_data_reg <= m7_data;
    m8_data_reg <= m8_data;
  end
  assign m1_data_buffer = m1_data_reg;
  assign m2_data_buffer = m2_data_reg;
  assign m3_data_buffer = m3_data_reg;
  assign m4_data_buffer = m4_data_reg;
  assign m5_data_buffer = m5_data_reg;
  assign m6_data_buffer = m6_data_reg;
  assign m7_data_buffer = m7_data_reg;
  assign m8_data_buffer = m8_data_reg;
  assign m1_clk_buffer = c2;

  ila_0 ila_bram (
          .clk(clk), // input wire clk
          .probe0(m1_clk_buffer), 
          .probe1(m1_data_buffer),
          .probe2(m2_data_buffer),
          .probe3(m3_data_buffer),
          .probe4(m4_data_buffer),
          .probe5(m5_data_buffer),
          .probe6(m6_data_buffer),
          .probe7(m7_data_buffer),
          .probe8(m8_data_buffer) 
        );

  system system_i (
           .trig1(trig1),
           .trig0(trig0),
           .addrb(addr_wo),
           .dinb1(m1_data),
           .dinb2(m2_data),
           .dinb3(m3_data),
           .dinb4(m4_data),
           .dinb5(m5_data),
           .dinb6(m6_data),
           .dinb7(m7_data),
           .dinb8(m8_data),
           .web(wen),
           .DDR_addr(DDR_addr),
           .DDR_ba(DDR_ba),
           .DDR_cas_n(DDR_cas_n),
           .DDR_ck_n(DDR_ck_n),
           .DDR_ck_p(DDR_ck_p),
           .DDR_cke(DDR_cke),
           .DDR_cs_n(DDR_cs_n),
           .DDR_dm(DDR_dm),
           .DDR_dq(DDR_dq),
           .DDR_dqs_n(DDR_dqs_n),
           .DDR_dqs_p(DDR_dqs_p),
           .DDR_odt(DDR_odt),
           .DDR_ras_n(DDR_ras_n),
           .DDR_reset_n(DDR_reset_n),
           .DDR_we_n(DDR_we_n),
           .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
           .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
           .FIXED_IO_mio(FIXED_IO_mio),
           .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
           .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
           .peripheral_aresetn(rstn),
           .FCLK_CLK0(clk),
           .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
         );




endmodule
