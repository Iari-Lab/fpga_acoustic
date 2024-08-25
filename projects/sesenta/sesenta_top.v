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
    input [7:0] M_DATA
);

    wire mc0;
    reg c0,c1,c2;
    wire clk;
    wire rst_addr;
    wire [31:0] trig1,trig0;
    wire [31 : 0] addr_w,addr_wo;
    wire [31 : 0] addr_dbg;
    wire [3 : 0] wen;
    wire [3 : 0] wen_dbg;
    wire rst;
    wire       m_clk_rising;
    wire mic_data_valid;
    reg m1_clk;
    wire m1_clk_buffer;
    reg [31:0] addr_reg;
    wire M_LRSEL;

    assign rst_addr = r_addr;
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
    reg r_addr;
    reg [7:0] mclks,addrs,wens,mdatas,mdatas_dbg,r_mics;
    wire [7:0] w_mclks,w_addrs,w_wens,w_mdatas2,w_mdatas,w_mdatas_dbg, w_rst_mics;

    genvar i;
    generate
        for (i = 0; i < 8; i=i+1) begin : clks_gen
            always @(posedge clk) begin
                r_addr <= trig0[0:0];
                r_mics[i] <= trig1[0:0];
                mclks[i] <= m_clk_rising;
                addrs[i] <= addr_w;
                wens[i] <= wen;
                mdatas_dbg[i] <= w_mdatas[i];
                mdatas[i] <= w_mdatas[i];
            end
            assign w_rst_mics[i] = r_mics[i];
            assign w_mclks[i] = mclks[i];
            assign w_addrs[i] = addrs[i];
            assign w_wens[i] = wens[i];
            assign w_mdatas_dbg[i] = mdatas_dbg[i];
            assign w_mdatas2[i] = mdatas[i];
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

    generate
        for (i = 0; i < 8; i=i+1) begin : pdms_gen
            pdm_mic #(
            ) mic (
                .clk(clk),
                .rst(w_rst_mics[i]),
                .mic_data(w_mdatas[i]),
                .m_clk_rising(w_mclks[i]),
                .mic_data_valid(mic_data_valid),
                .M_DATA(M_DATA[i]),
                .M_LRSEL(M_LRSEL)
            );
        end
    endgenerate

    always @(posedge clk)
    begin
        c0 <= mc0;
        c1 <= mc0;
        c2 <= mc0;
    end
    assign m1_clk_buffer = c2;

    ila_0 ila_bram (
        .clk(clk), // input wire clk
        .probe0(m1_clk_buffer),
        .probe1(w_mdatas_dbg[0]),
        .probe2(w_mdatas_dbg[1]),
        .probe3(w_mdatas_dbg[2]),
        .probe4(w_mdatas_dbg[3]),
        .probe5(w_mdatas_dbg[4]),
        .probe6(w_mdatas_dbg[5]),
        .probe7(w_mdatas_dbg[6]),
        .probe8(w_mdatas_dbg[7])
    );

    system system_i (
        .trig1(trig1),
        .trig0(trig0),
        .addrb1(w_addrs[0]),
        .addrb2(w_addrs[1]),
        .addrb3(w_addrs[2]),
        .addrb4(w_addrs[3]),
        .addrb5(w_addrs[4]),
        .addrb6(w_addrs[5]),
        .addrb7(w_addrs[6]),
        .addrb8(w_addrs[7]),
        .web1(w_wens[0]),
        .web2(w_wens[1]),
        .web3(w_wens[2]),
        .web4(w_wens[3]),
        .web5(w_wens[4]),
        .web6(w_wens[5]),
        .web7(w_wens[6]),
        .web8(w_wens[7]),
        .dinb1(w_mdatas2[0]),
        .dinb2(w_mdatas2[1]),
        .dinb3(w_mdatas2[2]),
        .dinb4(w_mdatas2[3]),
        .dinb5(w_mdatas2[4]),
        .dinb6(w_mdatas2[5]),
        .dinb7(w_mdatas2[6]),
        .dinb8(w_mdatas2[7]),
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
