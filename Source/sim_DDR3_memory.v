module sim_ddr3_memory (
    input  wire        S_AXI_ACLK,
    input  wire        S_AXI_ARESETN,

    // Kênh ??a ch? ??c (Read Address Channel)
    input  wire [31:0] S_AXI_ARADDR,
    input  wire [7:0]  S_AXI_ARLEN,   // ?? dài burst (0 = 1 nh?p, 7 = 8 nh?p)
    input  wire [2:0]  S_AXI_ARSIZE,  // Kích th??c m?i nh?p (2 = 4 bytes/32-bit)
    input  wire [1:0]  S_AXI_ARBURST, // Lo?i burst (th??ng là 2'b01 - INCR)
    input  wire        S_AXI_ARVALID,
    output reg         S_AXI_ARREADY,

    // Kênh D? li?u ??c (Read Data Channel)
    output reg  [31:0] S_AXI_RDATA,
    output reg  [1:0]  S_AXI_RRESP,   // Ph?n h?i (2'b00 = OKAY)
    output reg         S_AXI_RVALID,
    input  wire        S_AXI_RREADY,
    output reg         S_AXI_RLAST    // Báo hi?u nh?p cu?i cùng
);

    // B? nh? n?i b? (1024 t? 32-bit)
    reg [31:0] memory [0:1023];
    
    // Bi?n ?i?u khi?n n?i b?
    reg [7:0]  burst_cnt;
    reg [31:0] current_addr;
    reg [7:0]  current_len;

    // --- KH?I T?O D? LI?U GI? L?P ---
    initial begin
        // D? li?u cho ??a ch? 0x0000_0000 (Index 0-7)
        memory[0] = 32'h87654321; 
        memory[1] = 32'h12345678;
        memory[2] = 32'hF0F0F0F0;
        memory[3] = 32'hE1E1E1E1;
        memory[4] = 32'hD2D2D2D2;
        memory[5] = 32'hC3C3C3C3;
        memory[6] = 32'hB4B4B4B4;
        memory[7] = 32'hA5A5A5A5;

        // --- N?P THÊM D? LI?U CHO ??A CH? 0x0000_0020 (Index 8-15) ---
        memory[8]  = 32'h11111111;
        memory[9]  = 32'h22222222;
        memory[10] = 32'h33333333;
        memory[11] = 32'h44444444;
        memory[12] = 32'h55555555;
        memory[13] = 32'h66666666;
        memory[14] = 32'h77777777;
        memory[15] = 32'h88888888;
    end

    // --- MÁY TR?NG THÁI ?I?U KHI?N ---
    localparam IDLE = 1'b0, DATA_TRANSFER = 1'b1;
    reg [2:0] state = IDLE;

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            state <= IDLE;
            S_AXI_ARREADY <= 0;
            S_AXI_RVALID  <= 0;
            S_AXI_RLAST   <= 0;
            burst_cnt     <= 0;
        end else begin
            case (state)
                IDLE: begin
                    S_AXI_ARREADY <= 1;
                    S_AXI_RLAST   <= 0;
                    if (S_AXI_ARVALID && S_AXI_ARREADY) begin
                        current_addr <= S_AXI_ARADDR;
                        current_len  <= S_AXI_ARLEN;
                        burst_cnt    <= 0;
                        S_AXI_ARREADY <= 0;
                        state        <= DATA_TRANSFER;
                    end
                end

                DATA_TRANSFER: begin
                    S_AXI_RVALID <= 1;
                    // L?y d? li?u d?a trên ??a ch? c? s? và nh?p burst
                    S_AXI_RDATA  <= memory[(current_addr >> 2) + burst_cnt];
                    S_AXI_RRESP  <= 2'b00;

                    if (burst_cnt == current_len) begin
                        S_AXI_RLAST <= 1;
                    end else begin
                        if (S_AXI_RREADY) begin
                            burst_cnt <= burst_cnt + 8'd1;
                        end
                    end
                    
                    if(S_AXI_RLAST) begin
                        if(S_AXI_RREADY) begin
                            S_AXI_RVALID <= 0;
                            S_AXI_RLAST  <= 0;
                            burst_cnt    <= 0;
                            S_AXI_RRESP  <= 0;
                            S_AXI_RDATA  <= 0;
                            state        <= IDLE;
                        end
                        else begin
                            // Gi? nguyên tr?ng thái n?u Master ch?a s?n sàng (Handshake)
                            S_AXI_RVALID <= S_AXI_RVALID;
                            S_AXI_RLAST  <= S_AXI_RLAST;
                            burst_cnt    <= burst_cnt;
                            S_AXI_RRESP  <= S_AXI_RRESP;
                            S_AXI_RDATA  <= S_AXI_RDATA;
                            state        <= state;
                        end
                    end
                end
            endcase
        end
    end
endmodule