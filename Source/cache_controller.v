module cache_controller(
    input wire              clk,
    input wire              rst,
    input wire      [31:0 ] raddr,
    input wire              ren,
    output wire     [255:0] rdata,
    output wire             rvalid,
    
    // --- Tín hi?u reset ??ng b? t? PS ??a ra ---
    output wire             proc_sys_reset_n,

    // =========================================================
    // 2. CHÂN V?T LÝ DDR3
    // =========================================================
    output wire [14:0]      DDR_addr,
    output wire [2:0]       DDR_ba,
    output wire              DDR_cas_n,
    output wire              DDR_ck_n,
    output wire              DDR_ck_p,
    output wire              DDR_cke,
    output wire              DDR_cs_n,
    output wire              DDR_odt,
    output wire              DDR_ras_n,
    output wire              DDR_reset_n,
    output wire              DDR_we_n,
    inout  wire [3:0]       DDR_dm,
    inout  wire [31:0]      DDR_dq,
    inout  wire [3:0]       DDR_dqs_n,
    inout  wire [3:0]       DDR_dqs_p,

    // =========================================================
    // 3. CHÂN FIXED_IO
    // =========================================================
    inout  wire              FIXED_IO_ddr_vrn,
    inout  wire              FIXED_IO_ddr_vrp,
    inout  wire [53:0]       FIXED_IO_mio,
    inout  wire              FIXED_IO_ps_clk,
    inout  wire              FIXED_IO_ps_porb,
    inout  wire              FIXED_IO_ps_srstb 
);

// --- Gi? nguyên phong cách khai báo reg/wire c?a b?n ---
reg             start_fetch = 0;
wire    [255:0] DDR3data;
wire            DDR3rvalid;
wire            m_axi_arready;
    
wire    [ 4:0 ] word  =  raddr[ 4:0 ];
wire    [ 7:0 ] set   =  raddr[12:5 ];
wire    [15:0 ] tag   =  raddr[28:13];

wire            cacheHIT;
wire    [ 3:0 ] HITmask;

wire    [15:0 ] tagway1;
wire    [15:0 ] tagway2;
wire    [15:0 ] tagway3;
wire    [15:0 ] tagway4;
reg             updatevalid = 0;
reg             updatevalidff = 0;
wire            updateLRU = cacheHIT;
wire    [ 3:0 ] Waymask = HITmask;
wire    [ 6:0 ] control_data;

wire    [255:0] dataW1;
wire    [255:0] dataW2;
wire    [255:0] dataW3;
wire    [255:0] dataW4;

reg     [255:0] WdataW1  =   0;
reg     [255:0] WdataW2  =   0;
reg     [255:0] WdataW3  =   0;
reg     [255:0] WdataW4  =   0;
reg             SRAMWenW1 =   0;
reg             SRAMWenW2 =   0;
reg             SRAMWenW3 =   0;
reg             SRAMWenW4 =   0;
reg             TagWenW1  =   0;
reg             TagWenW2  =   0;
reg             TagWenW3  =   0;
reg             TagWenW4  =   0;

reg     [15:0 ] TagwdataW1  =   0;
reg     [15:0 ] TagwdataW2  =   0;
reg     [15:0 ] TagwdataW3  =   0;
reg     [15:0 ] TagwdataW4  =   0;

reg             validw1  =   0;
reg             validw2  =   0;
reg             validw3  =   0;
reg             validw4  =   0;
reg             validw1ff =   0;
reg             validw2ff =   0;
reg             validw3ff =   0;
reg             validw4ff =   0;

reg             rvalidout = 0;
wire            cacheMIS;

wire    [3:0]   hits;
assign          hits[0] = (tagway1 == tag) && control_data[0];
assign          hits[1] = (tagway2 == tag) && control_data[1];
assign          hits[2] = (tagway3 == tag) && control_data[2];
assign          hits[3] = (tagway4 == tag) && control_data[3];
assign          HITmask = hits;
assign          cacheHIT = |hits;
assign          cacheMIS = !cacheHIT;

assign          rvalid  =  cacheHIT;
assign          rdata   =  HITmask[0]?dataW1:
                           HITmask[1]?dataW2:
                           HITmask[2]?dataW3:
                           HITmask[3]?dataW4:
                           256'b0;

// --- Kh?i t?o module (D?ng d?c m?i chân m?t dòng) ---
    tagRAM tagram(
        .clk(clk),
        .Setin(set),
        .Tagway1(tagway1),
        .Tagway2(tagway2),
        .Tagway3(tagway3),
        .Tagway4(tagway4),
        .wenW1(TagWenW1),
        .wenW2(TagWenW2),
        .wenW3(TagWenW3),
        .wenW4(TagWenW4),
        .TagwdataW1(TagwdataW1),
        .TagwdataW2(TagwdataW2),
        .TagwdataW3(TagwdataW3),
        .TagwdataW4(TagwdataW4),
        .ren(ren),
        .validw1(validw1ff),
        .validw2(validw2ff),
        .validw3(validw3ff),
        .validw4(validw4ff),
        .Waymask(Waymask),
        .updatevalid(updatevalidff),
        .updateLRU(updateLRU),
        .control_data(control_data)
    );
    
    SRAMcache ramcache(
        .clk(clk),
        .Setin(set),
        .rdataW1(dataW1),
        .rdataW2(dataW2),
        .rdataW3(dataW3),
        .rdataW4(dataW4),
        .ren(ren),
        .wdataW1(WdataW1),
        .wdataW2(WdataW2),
        .wdataW3(WdataW3),
        .wdataW4(WdataW4),
        .wenW1(SRAMWenW1),
        .wenW2(SRAMWenW2),
        .wenW3(SRAMWenW3),
        .wenW4(SRAMWenW4)
    );

    AXI_fetch_DDR3 AXI_fetch_DDR3_istr(
        .clk(clk),
        .rst(rst),
        .addr(raddr),
        .start_fetch(start_fetch),
        .m_axi_arready(m_axi_arready),
        .Fetchdata(DDR3data),
        .rvalid(DDR3rvalid),
        .proc_sys_reset_n(proc_sys_reset_n),
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
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
    );
    
    reg flag = 0;
    
    // --- Logic ?i?u khi?n chính dùng reset ??ng b? ---
    always @(posedge clk) begin
        if(!proc_sys_reset_n) begin
            validw1   <= 1'b0;
            validw2   <= 1'b0;
            validw3   <= 1'b0;
            validw4   <= 1'b0;  
            updatevalid <= 1'b0;
            TagWenW1 <= 1'b0;
            TagWenW2 <= 1'b0;
            TagWenW3 <= 1'b0;
            TagWenW4 <= 1'b0;
            SRAMWenW1 <= 1'b0;
            SRAMWenW2 <= 1'b0;
            SRAMWenW3 <= 1'b0;
            SRAMWenW4 <= 1'b0;
            flag <= 1'b0;
            start_fetch <= 1'b0;
        end
        else begin
            validw1   <= 1'b0;
            validw2   <= 1'b0;
            validw3   <= 1'b0;
            validw4   <= 1'b0;  
            updatevalid <= 1'b0;
            TagWenW1 <= 1'b0;
            TagWenW2 <= 1'b0;
            TagWenW3 <= 1'b0;
            TagWenW4 <= 1'b0;
            SRAMWenW1 <= 1'b0;
            SRAMWenW2 <= 1'b0;
            SRAMWenW3 <= 1'b0;
            SRAMWenW4 <= 1'b0;

            if(cacheMIS && !flag && ren) begin
                start_fetch <= 1'b1;
                flag <= 1'b1;
            end
            
            if(m_axi_arready && flag) start_fetch <= 0;
            
            if(cacheHIT) flag <= 1'b0;
            
            if(flag && DDR3rvalid) begin
                case(control_data[6:4])
                    3'b000, 3'b001: begin
                        WdataW1 <= DDR3data;
                        SRAMWenW1 <= 1'b1;
                        validw1 <= 1'b1;
                        updatevalid <= 1'b1;
                        TagwdataW1 <= tag;
                        TagWenW1 <= 1'b1;
                    end
                    3'b010, 3'b011: begin
                        WdataW2 <= DDR3data;
                        SRAMWenW2 <= 1'b1;
                        validw2 <= 1'b1;
                        updatevalid <= 1'b1;
                        TagwdataW2 <= tag;
                        TagWenW2 <= 1'b1;
                    end
                    3'b100, 3'b110: begin
                        WdataW3 <= DDR3data;
                        SRAMWenW3 <= 1'b1;
                        validw3 <= 1'b1;
                        updatevalid <= 1'b1;
                        TagwdataW3 <= tag;
                        TagWenW3 <= 1'b1;
                    end
                    3'b101, 3'b111: begin
                        WdataW4 <= DDR3data;
                        SRAMWenW4 <= 1'b1;
                        validw4 <= 1'b1;
                        updatevalid <= 1'b1;
                        TagwdataW4 <= tag;
                        TagWenW4 <= 1'b1;
                    end
                endcase             
            end
            
            validw1ff   <= validw1;
            validw2ff   <= validw2;
            validw3ff   <= validw3;
            validw4ff   <= validw4;  
            updatevalidff <= updatevalid;
        end
    end

endmodule