module Lutram(
    input wire              clk,
    input wire      [ 7:0 ] addr,
    input wire              validw1,
    input wire              validw2,
    input wire              validw3,
    input wire              validw4,
    input wire      [ 3:0 ] Waymask,
    input wire              updatevalid,
    input wire              updateLRU,
    
    output          [ 6:0 ] control_data
);

    reg [6:0] MEM [0:255];
    
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            MEM[i] = 7'b0;
        end
    end
    
    
    always @(posedge clk) begin
        if(updatevalid) begin
            if(validw1) MEM[addr][0] <= 1'b1;
            if(validw2) MEM[addr][1] <= 1'b1;
            if(validw3) MEM[addr][2] <= 1'b1;
            if(validw4) MEM[addr][3] <= 1'b1;
        end
        if(updateLRU) begin
            case(1)
                Waymask[0]: begin
                    MEM[addr][4] <= 1'b1;
                    MEM[addr][5] <= 1'b1;
                end
                Waymask[1]: begin
                    MEM[addr][4] <= 1'b1;
                    MEM[addr][5] <= 1'b0;
                end
                Waymask[2]: begin
                    MEM[addr][4] <= 1'b0;
                    MEM[addr][6] <= 1'b1;
                end
                Waymask[3]: begin
                    MEM[addr][4] <= 1'b0;
                    MEM[addr][6] <= 1'b0;
                end
                default: MEM[addr][6:4] <= 3'b000;
            endcase
        end
    end
    
    assign control_data = MEM[addr];
endmodule
