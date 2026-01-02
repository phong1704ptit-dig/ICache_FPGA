module Blockram32(
    input wire              clk,
    input wire      [ 7:0 ] raddr,
    output          [31:0 ] rdata,
    input wire              ren,
    
    input wire      [ 7:0 ] waddr,
    input wire      [31:0 ] wdata,
    input wire              wen

);
    (* ram_style = "block" *) reg [31:0] MEM [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            MEM[i] = 32'b0;
        end
    end
   
    wire [31:0] raddrr = raddr;
    wire [31:0] waddrr = waddr;
    reg [31:0] rdatar = 0; assign rdata = rdatar;
    always @(posedge clk) begin
        if(ren) rdatar <= MEM[raddr];
    end
    always @(posedge clk) begin
        if(wen) MEM[waddr] <= wdata;
    end
endmodule
