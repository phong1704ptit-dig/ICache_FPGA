module CacheWay(
    input wire          clk,
    input wire  [ 7:0 ] addr,
    output      [255:0] rdata,
    input wire          ren,
    
    input wire  [255:0] wdata,
    input wire          wen
);
    
wire    [31:0]  rdata1;
wire    [31:0]  rdata2;
wire    [31:0]  rdata3;
wire    [31:0]  rdata4;
wire    [31:0]  rdata5;
wire    [31:0]  rdata6;
wire    [31:0]  rdata7;
wire    [31:0]  rdata8;
assign          rdata = {rdata8, rdata7, rdata6, rdata5, rdata4, rdata3, rdata2, rdata1};

    Blockram32 SRAMcache1(
        .clk        (clk),
        .raddr      (addr),
        .rdata      (rdata1),
        .ren        (ren),
        .waddr      (addr),
        .wdata      (wdata[31:0]),
        .wen        (wen)
    );
    
    Blockram32 SRAMcache2(
        .clk        (clk),
        .raddr      (addr),
        .rdata      (rdata2),
        .ren        (ren),
        .waddr      (addr),
        .wdata      (wdata[63:32]),
        .wen        (wen)
    );
    
    Blockram32 SRAMcache3(
        .clk        (clk),
        .raddr      (addr),
        .rdata      (rdata3),
        .ren        (ren),
        .waddr      (addr),
        .wdata      (wdata[95:64]),
        .wen        (wen)
    );
    
    Blockram32 SRAMcache4(
        .clk        (clk),
        .raddr      (addr),
        .rdata      (rdata4),
        .ren        (ren),
        .waddr      (addr),
        .wdata      (wdata[127:96]),
        .wen        (wen)
    );
    
    Blockram32 SRAMcache5(
        .clk        (clk),
        .raddr      (addr),
        .rdata      (rdata5),
        .ren        (ren),
        .waddr      (addr),
        .wdata      (wdata[159:128]),
        .wen        (wen)
    );
    
    Blockram32 SRAMcache6(
        .clk        (clk),
        .raddr      (addr),
        .rdata      (rdata6),
        .ren        (ren),
        .waddr      (addr),
        .wdata      (wdata[191:160]),
        .wen        (wen)
    );
    
    Blockram32 SRAMcache7(
        .clk        (clk),
        .raddr      (addr),
        .rdata      (rdata7),
        .ren        (ren),
        .waddr      (addr),
        .wdata      (wdata[223:192]),
        .wen        (wen)
    );
    
    Blockram32 SRAMcache8(
        .clk        (clk),
        .raddr      (addr),
        .rdata      (rdata8),
        .ren        (ren),
        .waddr      (addr),
        .wdata      (wdata[255:224]),
        .wen        (wen)
    );
endmodule
