module Blockram(
    input wire              clk,
    input wire      [ 7:0 ] addr,
    output          [15:0 ] rdata,
    input wire      [15:0 ] wdata,
    input wire              ren,
    input wire              wen
);

    (* ram_style = "block" *) reg [15:0] MEM [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            MEM[i] = 16'b0;
        end
    end
    
    reg     [15:0 ] rdatar = 0; assign rdata = rdatar;
    
    always @(posedge clk) begin
        if(ren) rdatar <= MEM[addr];
        if(wen) MEM[addr] <= wdata;
    end
endmodule
