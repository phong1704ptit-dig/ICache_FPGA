module tagRAM(
    input wire              clk,
    input wire      [ 7:0 ] Setin,
    output          [15:0 ] Tagway1,
    output          [15:0 ] Tagway2,
    output          [15:0 ] Tagway3,
    output          [15:0 ] Tagway4,
    
    input                   wenW1,
    input                   wenW2,
    input                   wenW3,
    input                   wenW4,
    input           [15:0 ] TagwdataW1,
    input           [15:0 ] TagwdataW2,
    input           [15:0 ] TagwdataW3,
    input           [15:0 ] TagwdataW4,
    input                   ren,
    
    
    input                   updatevalid,
    input                   updateLRU,
    input           [ 3:0 ] Waymask,
    input                   validw1,
    input                   validw2,
    input                   validw3,
    input                   validw4,
    output          [ 6:0 ] control_data    
);

reg     [15:0 ] Tagwdata    = 0;
reg             Tagwen      = 0;
reg             Tagren      = 0;
    Blockram TagramW1(
        .clk            (clk),
        .addr           (Setin),
        .rdata          (Tagway1),
        .wdata          (TagwdataW1),
        .wen            (wenW1),
        .ren            (ren)
    );
    
    Blockram TagramW2(
        .clk            (clk),
        .addr           (Setin),
        .rdata          (Tagway2),
        .wdata          (TagwdataW2),
        .wen            (wenW2),
        .ren            (ren)
    );
  
    Blockram TagramW3(
        .clk            (clk),
        .addr           (Setin),
        .rdata          (Tagway3),
        .wdata          (TagwdataW3),
        .wen            (wenW3),
        .ren            (ren)
    );
    
    Blockram TagramW4(
        .clk            (clk),
        .addr           (Setin),
        .rdata          (Tagway4),
        .wdata          (TagwdataW4),
        .wen            (wenW4),
        .ren            (ren)
    );
  
    
    Lutram Lutram_istr(
        .clk            (clk),
        .addr           (Setin),
        .validw1        (validw1),
        .validw2        (validw2),
        .validw3        (validw3),
        .validw4        (validw4),
        .Waymask        (Waymask),
        .control_data   (control_data),
        .updatevalid    (updatevalid),
        .updateLRU      (updateLRU)
    );
    
endmodule
