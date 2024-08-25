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
    input [7:0] M_DATA,
    output WS_LED

);

    localparam integer INPUT_FREQ = 125000000;
    localparam integer PDM_FREQ = 2400000;
    localparam integer LED_FREQ = 12000000;
    wire mc0,mc1;
    reg c0,c1,c2, r_ws_led,r_ws_led_dbg;
    wire clk, clk_led,w_ws_led,w_ws_led_dbg;
    wire rst_addr;
    wire [31:0] trig1,trig0,trig2;
    wire [31 : 0] addr_w,w_addr_w;
    wire [31 : 0] addr_dbg;
    wire [3 : 0] wen;
    wire [3 : 0] wen_dbg;
    wire       m_clk_rising;
    wire mic_data_valid,w_rst_clk_mic;
    reg r_rst_clk_mic;
    wire m1_clk_buffer,w_reset_led;
    wire M_LRSEL;



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
    reg r_addr;

    reg [7:0] mclks, r_mics,r_trig1,r_trig0,r_trig2;
    reg [255:0] addrs, mdatas, mdatas_dbg; // Flattened 32x8 to 256 bits
    reg [31:0] wens,r_addr_w; // Flattened 4x8 to 32 bits
    wire [7:0] w_mclks, w_rst_mics;
    wire [255:0] w_addrs, w_mdatas,w_mdatas2, w_mdatas_dbg; // Flattened 32x8 to 256 bits
    wire [31:0] w_wens; // Flattened 4x8 to 32 bits

    genvar i;
    generate
        for (i = 0; i < 8; i=i+1) begin : safe_gen
            always @(posedge clk) begin
                r_mics[i] <= w_rst_clk_mic;
                mclks[i] <= m_clk_rising;
                addrs[i*32 +: 32] <= w_addr_w; // Slice 32 bits
                wens[i*4 +: 4] <= wen; // Slice 4 bits
                mdatas_dbg[i*32 +: 32] <= w_mdatas[i*32 +: 32];
                mdatas[i*32 +: 32] <= w_mdatas[i*32 +: 32];
            end
            assign w_rst_mics[i] = r_mics[i];
            assign w_mclks[i] = mclks[i];
            assign w_addrs[i*32 +: 32] = addrs[i*32 +: 32];
            assign w_wens[i*4 +: 4] = wens[i*4 +: 4];
            assign w_mdatas_dbg[i*32 +: 32] = mdatas_dbg[i*32 +: 32];
            assign w_mdatas2[i*32 +: 32] = mdatas[i*32 +: 32];
        end
    endgenerate

    assign rst_addr = r_trig0;
    assign w_reset_led = r_trig2;
    assign w_rst_clk_mic = r_trig1;
    assign w_addr_w = r_addr_w;
    assign M0_CLK= c0;
    assign M2_CLK= c2;
    assign M1_CLK= c1;
    assign WS_LED= r_ws_led;
    assign w_ws_led_dbg = r_ws_led_dbg;
    assign m1_clk_buffer = c2;
    // clk all the inputs
    always @(posedge clk)
    begin
        r_trig0 <= trig0[0:0];
        r_trig1 <= trig1[0:0];
        r_trig2 <= trig2[0:0];
        r_ws_led <= w_ws_led;
        r_ws_led_dbg <= w_ws_led;
        r_addr_w <= addr_w;
        c0 <= mc0;
        c1 <= mc0;
        c2 <= mc0;
    end

    // Clock generator instance
    clk_gen #(
    .INPUT_FREQ(INPUT_FREQ),
    .OUTPUT_FREQ(PDM_FREQ)
    ) pdm_clk_gen_i
    (
        .clk(clk),
        .rst(w_rst_clk_mic),
        .M_CLK(mc0),
        .m_clk_rising(m_clk_rising)
    );

    clk_gen #(
    .INPUT_FREQ(INPUT_FREQ),
    .OUTPUT_FREQ(LED_FREQ)
    ) led_clk_gen_i
    (
        .clk(clk_led),
        .rst(w_rst_clk_mic),
        .M_CLK(mc1)
    );

    leds #(
    ) led_i
    (
        .clk(clk_led),
        .ws_data(w_ws_led),
        .reset(w_reset_led)
    );

    generate
        for (i = 0; i < 8; i=i+1) begin : pdms_gen
            pdm_mic #(
            ) mic (
                .clk(clk),
                .rst(w_rst_mics[i]),
                .mic_data(w_mdatas[i*32 +: 32]),
                .m_clk_rising(w_mclks[i]),
                .mic_data_valid(mic_data_valid),
                .M_DATA(M_DATA[i]),
                .M_LRSEL(M_LRSEL)
            );
        end
    endgenerate



    ila_0 ila_bram (
        .clk(clk), // input wire clk
        .probe0(m1_clk_buffer),
        .probe1(w_mdatas_dbg[32*0 +: 32]),
        .probe2(w_mdatas_dbg[32*1 +: 32]),
        .probe3(w_mdatas_dbg[32*2 +: 32]),
        .probe4(w_mdatas_dbg[32*3 +: 32]),
        .probe5(w_mdatas_dbg[32*4 +: 32]),
        .probe6(w_mdatas_dbg[32*5 +: 32]),
        .probe7(w_mdatas_dbg[32*6 +: 32]),
        .probe8(w_mdatas_dbg[32*7 +: 32]),
        .probe9(w_ws_led_dbg)
    );
    system system_i (
        .trig1(trig1),
        .trig0(trig0),
        .trig2(trig2),
        .addrb1(w_addrs[32*0 +: 32]),
        .addrb2(w_addrs[32*1 +: 32]),
        .addrb3(w_addrs[32*2 +: 32]),
        .addrb4(w_addrs[32*3 +: 32]),
        .addrb5(w_addrs[32*4 +: 32]),
        .addrb6(w_addrs[32*5 +: 32]),
        .addrb7(w_addrs[32*6 +: 32]),
        .addrb8(w_addrs[32*7 +: 32]),
        .web1(w_wens[4*0 +: 4]),
        .web2(w_wens[4*1 +: 4]),
        .web3(w_wens[4*2 +: 4]),
        .web4(w_wens[4*3 +: 4]),
        .web5(w_wens[4*4 +: 4]),
        .web6(w_wens[4*5 +: 4]),
        .web7(w_wens[4*6 +: 4]),
        .web8(w_wens[4*7 +: 4]),
        .dinb1(w_mdatas2[32*0 +: 32]),
        .dinb2(w_mdatas2[32*1 +: 32]),
        .dinb3(w_mdatas2[32*2 +: 32]),
        .dinb4(w_mdatas2[32*3 +: 32]),
        .dinb5(w_mdatas2[32*4 +: 32]),
        .dinb6(w_mdatas2[32*5 +: 32]),
        .dinb7(w_mdatas2[32*6 +: 32]),
        .dinb8(w_mdatas2[32*7 +: 32]),
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
        .FCLK_CLK1(clk_led),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
    );




endmodule
