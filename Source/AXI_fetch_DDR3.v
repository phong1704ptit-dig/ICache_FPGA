module AXI_fetch_DDR3(
    input                clk,
    input                rst,         
    input        [31:0]  addr, 
    input                start_fetch, 
    output               m_axi_arready, 
    output reg   [255:0] Fetchdata,
    output reg           rvalid,
    
    // --- TÍN HI?U RESET ??NG B? T? PS ??A RA ---
    output wire          proc_sys_reset_n,

    // --- CHÂN V?T LÝ TRUY?N XU?NG T? CACHE CONTROLLER ---
    // Chuy?n sang inout ?? kh?p hoàn toàn v?i AXI4_DDR3_wrapper
    inout  wire [14:0]   DDR_addr,
    inout  wire [2:0]    DDR_ba,
    inout  wire          DDR_cas_n,
    inout  wire          DDR_ck_n,
    inout  wire          DDR_ck_p,
    inout  wire          DDR_cke,
    inout  wire          DDR_cs_n,
    inout  wire          DDR_odt,
    inout  wire          DDR_ras_n,
    inout  wire          DDR_reset_n,
    inout  wire          DDR_we_n,
    inout  wire [3:0]    DDR_dm,
    inout  wire [31:0]   DDR_dq,
    inout  wire [3:0]    DDR_dqs_n,
    inout  wire [3:0]    DDR_dqs_p,
    inout  wire          FIXED_IO_ddr_vrn,
    inout  wire          FIXED_IO_ddr_vrp,
    inout  wire [53:0]   FIXED_IO_mio,
    inout  wire          FIXED_IO_ps_clk,
    inout  wire          FIXED_IO_ps_porb,
    inout  wire          FIXED_IO_ps_srstb
);

    // --- Tín hi?u trung gian n?i gi?a logic và bus ---
    wire [31:0] m_axi_rdata;
    wire        m_axi_rvalid;
    wire        m_axi_rready;
    wire        m_axi_rlast;
    wire [ 1:0] m_axi_rresp;
    
    reg [255:0] data_buffer;
    assign m_axi_rready = 1'b1; 

    // --- Logic Fetch d? li?u (Gi? nguyên) ---
    always @(posedge clk) begin
        if (!proc_sys_reset_n) begin
            data_buffer <= 256'b0;
            Fetchdata   <= 256'b0;
            rvalid      <= 1'b0;
        end else begin
            if (m_axi_rvalid && m_axi_rready) begin
                data_buffer <= {m_axi_rdata, data_buffer[255:32]};
                
                if (m_axi_rlast) begin // nh?p cu?i
                    Fetchdata <= {m_axi_rdata, data_buffer[255:32]};
                    rvalid    <= 1'b1; 
                end else begin
                    rvalid    <= 1'b0;
                end
            end else begin
                rvalid <= 1'b0; 
            end
        end
    end
    
    // --- Logic ?i?u khi?n ARVALID (Gi? nguyên) ---
    reg               ar_valid_reg;
    wire              m_axi_arvalid_internal;
    assign            m_axi_arvalid_internal  =   ar_valid_reg;

    always @(posedge clk) begin
        if (!proc_sys_reset_n) begin
            ar_valid_reg <= 1'b0;
        end else begin
            if (start_fetch && !ar_valid_reg) begin
                ar_valid_reg <= 1'b1; 
            end else if (m_axi_arready && ar_valid_reg) begin
                ar_valid_reg <= 1'b0; 
            end
        end
    end

    // --- Kh?i t?o instance AXI4_bus (C?p nh?t chân Reset) ---
    AXI4_bus AXI4bus_inst (
        .clk             (clk),
        .reset_n         (rst),
        .proc_sys_reset_n(proc_sys_reset_n), // ??a tín hi?u reset t? PS lên
        
        .m_axi_araddr    (addr),
        .m_axi_arlen     (8'd7),     // Burst length = 8 beats
        .m_axi_arsize    (3'b010),   // 4 Bytes per beat
        .m_axi_arburst   (2'b01),    // INCR mode
        .m_axi_arvalid   (m_axi_arvalid_internal),
        .m_axi_arready   (m_axi_arready),
        
        .m_axi_rdata     (m_axi_rdata),
        .m_axi_rresp     (m_axi_rresp),
        .m_axi_rvalid    (m_axi_rvalid),
        .m_axi_rready    (m_axi_rready),
        .m_axi_rlast     (m_axi_rlast),
        
        // --- N?i chân v?t lý t? Port c?a AXI_fetch_DDR3 xu?ng ---
        .DDR_addr        (DDR_addr),
        .DDR_ba          (DDR_ba),
        .DDR_cas_n       (DDR_cas_n),
        .DDR_ck_n        (DDR_ck_n),
        .DDR_ck_p        (DDR_ck_p),
        .DDR_cke         (DDR_cke),
        .DDR_cs_n        (DDR_cs_n),
        .DDR_dm          (DDR_dm),
        .DDR_dq          (DDR_dq),
        .DDR_dqs_n       (DDR_dqs_n),
        .DDR_dqs_p       (DDR_dqs_p),
        .DDR_odt         (DDR_odt),
        .DDR_ras_n       (DDR_ras_n),
        .DDR_reset_n     (DDR_reset_n),
        .DDR_we_n        (DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio    (FIXED_IO_mio),
        .FIXED_IO_ps_clk (FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
    );

endmodule