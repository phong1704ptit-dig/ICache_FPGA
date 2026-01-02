module SRAMcache(
    input wire              clk,
    input wire      [ 7:0 ] Setin,
    output          [255:0] rdataW1,
    output          [255:0] rdataW2,
    output          [255:0] rdataW3,
    output          [255:0] rdataW4,
    input                   ren,
    
    input wire      [255:0] wdataW1,
    input wire      [255:0] wdataW2,
    input wire      [255:0] wdataW3,
    input wire      [255:0] wdataW4,
    
    input wire              wenW1,
    input wire              wenW2,
    input wire              wenW3,
    input wire              wenW4    
);

    CacheWay Way1(
        .clk        (clk),
        .addr       (Setin),
        .rdata      (rdataW1),
        .ren        (ren),
        .wdata      (wdataW1),
        .wen        (wenW1)
    );
    
    CacheWay Way2(
        .clk        (clk),
        .addr       (Setin),
        .rdata      (rdataW2),
        .ren        (ren),
        .wdata      (wdataW2),
        .wen        (wenW2)
    );
    
    CacheWay Way3(
        .clk        (clk),
        .addr       (Setin),
        .rdata      (rdataW3),
        .ren        (ren),
        .wdata      (wdataW3),
        .wen        (wenW3)
    );
    
    CacheWay Way4(
        .clk        (clk),
        .addr       (Setin),
        .rdata      (rdataW4),
        .ren        (ren),
        .wdata      (wdataW4),
        .wen        (wenW4)
    );
    
endmodule
