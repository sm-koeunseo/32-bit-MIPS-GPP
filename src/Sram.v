`include "define.h"

module Sram (Data_In, Data_Out, Addr, RW, En, Clk, Rst);
    
    input [(`SA_WIDTH-1):0] Addr;
    input RW;
    input En;
    input Clk;
    input Rst;
    input [(`D_WIDTH-1):0] Data_In;
    output reg [(`D_WIDTH-1):0] Data_Out;
    reg [(`D_WIDTH-1):0] Memory [0:(2**`SA_WIDTH-1)];
    integer Index;

    always @(posedge Clk) begin
        Data_Out <= `D_WIDTH'b0;
        if (Rst==1) begin
            for (Index=0; Index<(2**`SA_WIDTH); Index=Index+1)
                Memory[Index] <= `D_WIDTH'b0;
        end
        else if (En==1'b1 && RW==1'b1)  // write
            Memory[Addr] <= Data_In;
        else if (En==1'b1 && RW==1'b0)  // read
            Data_Out <= Memory[Addr];
    end

endmodule