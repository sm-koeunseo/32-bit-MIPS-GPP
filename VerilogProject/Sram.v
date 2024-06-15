`timescale 1ns/1ns

module Sram ( Data_In, Data_Out, Addr, RW, En, Clk, Rst );
    
    input [3:0] Addr;
    input RW;
    input En;
    input Clk;
    input Rst;
    input [31:0] Data_In;
    output reg [31:0] Data_Out;
    reg [31:0] Memory [0:15];
    integer Index;

    always @(posedge Clk) begin
        Data_Out <= 31'b0;
        if (Rst==1) begin
            for (Index=0; Index<(16); Index=Index+1)
                Memory[Index] <= 32'b0;
        end
        else if (En==1'b1 && RW==1'b1)  // write
            Memory[Addr] <= Data_In;
        else if (En==1'b1 && RW==1'b0)  // read
            Data_Out <= Memory[Addr];
    end

endmodule