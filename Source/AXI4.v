module axi_fetch_logic (
    input  wire        clk,
    input  wire        reset_n,    // Reset m?c th?p
    
    // --- AXI READ ADDRESS CHANNEL ---
    output reg  [31:0] m_axi_araddr,
    output wire [7:0]  m_axi_arlen,   // S? l?n transfer (0 có ngh?a là 1 l?n)
    output wire [2:0]  m_axi_arsize,  // 3'b010 = 4 bytes
    output wire [1:0]  m_axi_arburst, // 2'b01 = Incremental
    output reg         m_axi_arvalid,
    input  wire        m_axi_arready,

    // --- AXI READ DATA CHANNEL ---
    input  wire [31:0] m_axi_rdata,
    input  wire [1:0]  m_axi_rresp,
    input  wire        m_axi_rvalid,
    output reg         m_axi_rready,
    input  wire        m_axi_rlast,

    // Giao ti?p v?i logic bên ngoài
    output reg [31:0]  data_out,
    output reg         done
);

    // C?u hình Burst m?c ??nh cho 1 l?n ??c 32-bit
    assign m_axi_arlen   = 8'h00; 
    assign m_axi_arsize  = 3'b010; 
    assign m_axi_arburst = 2'b01;

    // Các tr?ng thái c?a FSM
    localparam IDLE  = 2'b00;
    localparam READ_ADDR = 2'b01;
    localparam READ_DATA = 2'b10;
    localparam FINISH    = 2'b11;

    reg [1:0] state;

    always @(posedge clk) begin
        if (!reset_n) begin
            state <= IDLE;
            m_axi_arvalid <= 0;
            m_axi_rready <= 0;
            m_axi_araddr <= 32'h0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    m_axi_araddr <= 32'h0000_0000; // ??a ch? mu?n ??c
                    state <= READ_ADDR;
                    done <= 0;
                end

                READ_ADDR: begin
                    m_axi_arvalid <= 1'b1;
                    if (m_axi_arready) begin     // Khi PS s?n sàng nh?n ??a ch?
                        m_axi_arvalid <= 1'b0;
                        m_axi_rready <= 1'b1;    // B?t s?n sàng nh?n d? li?u
                        state <= READ_DATA;
                    end
                end

                READ_DATA: begin
                    if (m_axi_rvalid) begin      // Khi PS ??y d? li?u ra bus
                        data_out <= m_axi_rdata; // L?y d? li?u v?
                        m_axi_rready <= 1'b0;    // K?t thúc b?t tay
                        done <= 1'b1;
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    state <= FINISH; // D?ng l?i ?? quan sát k?t qu?
                end
            endcase
        end
    end
endmodule