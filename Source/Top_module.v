module Top_module (
    inout  wire [14:0] DDR_addr,
    inout  wire [2:0]  DDR_ba,
    inout  wire        DDR_cas_n,
    inout  wire        DDR_ck_n,
    inout  wire        DDR_ck_p,
    inout  wire        DDR_cke,
    inout  wire        DDR_cs_n,
    inout  wire        DDR_odt,
    inout  wire        DDR_ras_n,
    inout  wire        DDR_reset_n,
    inout  wire        DDR_we_n,
    inout  wire [3:0]  DDR_dm,
    inout  wire [31:0] DDR_dq,
    inout  wire [3:0]  DDR_dqs_n,
    inout  wire [3:0]  DDR_dqs_p,

    inout  wire        FIXED_IO_ddr_vrn,
    inout  wire        FIXED_IO_ddr_vrp,
    inout  wire [53:0] FIXED_IO_mio,
    inout  wire        FIXED_IO_ps_clk,
    inout  wire        FIXED_IO_ps_porb,
    inout  wire        FIXED_IO_ps_srstb,

    input  wire        sys_clk,
    input  wire        sys_rst_n,
    output reg         GPIO = 1'b0
);

localparam [255:0] EXPECTED_DATA = 256'hA5A5A5A5_B4B4B4B4_C3C3C3C3_D2D2D2D2_E1E1E1E1_F0F0F0F0_12345678_87654321;
    
// --- Tín hi?u ?i?u khi?n Cache n?i b? ---
    wire        proc_sys_reset_n;
    reg [31:0]  test_raddr;
    reg         test_ren;
    wire [255:0] test_rdata;
    wire        test_rvalid;

    // --- Khai báo các tr?ng thái FSM ---
    localparam IDLE         = 3'd0;
    localparam READ_0_A     = 3'd1; // ??c ??a ch? 0 l?n 1 (Miss)
    localparam READ_NEXT    = 3'd2; // ??c ??a ch? ti?p theo (Miss)
    localparam READ_0_B     = 3'd3; // ??c l?i ??a ch? 0 (Hit)
    localparam DONE         = 3'd4;

    reg [2:0] state = IDLE;

    // =========================================================
    // MÁY TR?NG THÁI KI?M TRA (TEST FSM)
    // =========================================================
    always @(posedge sys_clk) begin
        if (!proc_sys_reset_n) begin
            state       <= IDLE;
            test_raddr  <= 32'h0;
            test_ren    <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    state <= READ_0_A;
                end

                READ_0_A: begin
                    test_raddr <= 32'h0;
                    test_ren   <= 1'b1;
                    if (test_rvalid) begin
                        test_ren <= 1'b0;
                        state    <= READ_NEXT;
                        
                        test_raddr <= 32'h0000_0020; 
                        test_ren   <= 1'b1;
                        
                        // --- KI?M TRA D? LI?U T?I ??A CH? 0 ---
                        if (test_rdata == EXPECTED_DATA) begin
                            GPIO <= ~GPIO; // ??o tr?ng thái n?u kh?p
                        end
                    end
                end

                READ_NEXT: begin
                    // 0x20 = 32 bytes (Kích th??c 1 line cache 256-bit)
                    test_raddr <= 32'h0000_0020; 
                    test_ren   <= 1'b1;
                    if (test_rvalid) begin
                        test_ren <= 1'b0;
                        state    <= READ_0_B;
                        
                        test_raddr <= 32'h0; // ??c l?i ??a ch? 0
                        test_ren   <= 1'b1;
                    end
                end

                READ_0_B: begin
                    test_raddr <= 32'h0; // ??c l?i ??a ch? 0
                    test_ren   <= 1'b1;
                    if (test_rvalid) begin
                        test_ren <= 1'b0;
                        state    <= DONE;
                        
                    end
                end

                DONE: begin
                    test_ren <= 1'b0;
                    state    <= IDLE; // D?ng l?i sau khi hoàn thành
                end
                
                default: state <= IDLE;
            endcase
        end
    end

    // --- Kh?i t?o Cache Controller (D?ng d?c) ---
    cache_controller Icache (
        .clk(sys_clk),
        .rst(sys_rst_n),
        .raddr(test_raddr),            // ??a ch? c?n ??c (Ví d? n?i CPU t?i ?ây)
        .ren(test_ren),               // L?nh cho phép ??c
        .rdata(test_rdata),                 // D? li?u 256-bit tr? v?
        .rvalid(test_rvalid),                // Tín hi?u d? li?u s?n sàng
        .proc_sys_reset_n(proc_sys_reset_n), // Reset ??ng b? l?y t? h? th?ng ra

        // K?t n?i chân v?t lý DDR3
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),

        // K?t n?i chân FIXED_IO
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
    );

endmodule