module AXI4_bus (
    // --- H? th?ng ---
    input  wire        clk,
    input  wire        reset_n,
    // Tín hi?u reset ?ã qua x? lý t? Block Design ??a ra ngoài
    output wire        proc_sys_reset_n, 

    // --- Giao di?n AXI4 (N?i t? logic Fetch) ---
    input  wire [31:0] m_axi_araddr,
    input  wire [7:0]  m_axi_arlen,
    input  wire [2:0]  m_axi_arsize,
    input  wire [1:0]  m_axi_arburst,
    input  wire        m_axi_arvalid,
    output wire        m_axi_arready,
    output wire [31:0] m_axi_rdata,
    output wire [1:0]  m_axi_rresp,
    output wire        m_axi_rvalid,
    input  wire        m_axi_rready,
    output wire        m_axi_rlast,

    // --- CHÂN V?T LÝ DDR3 (Toàn b? là inout theo wrapper) ---
    inout  wire [14:0] DDR_addr,
    inout  wire [2:0]  DDR_ba,
    inout  wire        DDR_cas_n,
    inout  wire        DDR_ck_n,
    inout  wire        DDR_ck_p,
    inout  wire        DDR_cke,
    inout  wire        DDR_cs_n,
    inout  wire [3:0]  DDR_dm,
    inout  wire [31:0] DDR_dq,
    inout  wire [3:0]  DDR_dqs_n,
    inout  wire [3:0]  DDR_dqs_p,
    inout  wire        DDR_odt,
    inout  wire        DDR_ras_n,
    inout  wire        DDR_reset_n,
    inout  wire        DDR_we_n,

    // --- CHÂN FIXED_IO ---
    inout  wire        FIXED_IO_ddr_vrn,
    inout  wire        FIXED_IO_ddr_vrp,
    inout  wire [53:0] FIXED_IO_mio,
    inout  wire        FIXED_IO_ps_clk,
    inout  wire        FIXED_IO_ps_porb,
    inout  wire        FIXED_IO_ps_srstb
);

    // =========================================================
    // G?I KH?I BLOCK DESIGN WRAPPER (AXI4_DDR3_wrapper)
    // =========================================================
    AXI4_DDR3_wrapper bd_wrapper_inst (
        // --- K?t n?i chân v?t lý DDR3 ---
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

        // --- K?t n?i chân FIXED_IO ---
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),

        // --- H? th?ng ---
        .clk(clk),
        .reset_n(reset_n),
        .proc_sys_reset_n(proc_sys_reset_n), // ??a Reset ?ã ??ng b? ra ngoài

        // --- Kênh ??c ??a ch? (Read Address) ---
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),
        
        // Các chân c?u hình t?nh (Kh?p v?i ?? r?ng bit c?a wrapper)
        .m_axi_arcache(4'b0011),
        .m_axi_arprot(3'b000),
        .m_axi_arlock(1'b0),
        .m_axi_arqos(4'b0000),
        .m_axi_arregion(4'b0000), // B? sung arregion

        // --- Kênh ??c D? li?u (Read Data) ---
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
        .m_axi_rlast(m_axi_rlast),

        // --- Các chân Ghi (T?nh) ---
        .m_axi_awaddr(32'h0),
        .m_axi_awlen(8'h0),
        .m_axi_awsize(3'b010),
        .m_axi_awburst(2'b01),
        .m_axi_awlock(1'b0),
        .m_axi_awcache(4'b0011),
        .m_axi_awprot(3'b000),
        .m_axi_awqos(4'b0000),
        .m_axi_awregion(4'b0000), // B? sung awregion
        .m_axi_awvalid(1'b0),
        .m_axi_awready(),
        
        .m_axi_wdata(32'h0),
        .m_axi_wstrb(4'hF),
        .m_axi_wlast(1'b0),
        .m_axi_wvalid(1'b0),
        .m_axi_wready(),
        
        .m_axi_bready(1'b1),
        .m_axi_bresp(), // Output m_axi_bresp [1:0]
        .m_axi_bvalid()
    );







//assign proc_sys_reset_n = reset_n; // Gi? l?p Reset h? th?ng luôn OK

//    sim_ddr3_memory ddr3_sim_inst (
//        .S_AXI_ACLK(clk),
//        .S_AXI_ARESETN(reset_n),

//        // Kênh ??a ch? ??c
//        .S_AXI_ARADDR(m_axi_araddr),
//        .S_AXI_ARLEN(m_axi_arlen),
//        .S_AXI_ARSIZE(m_axi_arsize),
//        .S_AXI_ARBURST(m_axi_arburst),
//        .S_AXI_ARVALID(m_axi_arvalid),
//        .S_AXI_ARREADY(m_axi_arready),

//        // Kênh D? li?u ??c
//        .S_AXI_RDATA(m_axi_rdata),
//        .S_AXI_RRESP(m_axi_rresp),
//        .S_AXI_RVALID(m_axi_rvalid),
//        .S_AXI_RREADY(m_axi_rready),
//        .S_AXI_RLAST(m_axi_rlast)
//    );

endmodule