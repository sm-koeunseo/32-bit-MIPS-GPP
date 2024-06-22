`include "define.h"

module TestBench();

    reg Clk, Rst, Rst_M, Str;
    wire Done;
    
    reg [(`SA_WIDTH-1):0] Addr;
    reg [(`D_WIDTH-1):0] Data_I;
    wire[(`D_WIDTH-1):0] Data_O;
    reg En, RW;

    reg [(`D_WIDTH-1):0] regi[(`SL_WIDTH-1):0];
    integer Index;
    parameter ClkPeriod = 20;

    GPP_TOP CompToTest(Clk, Done, Rst, Str, Addr, Data_I, Data_O, En, RW, Rst_M);

    // Clock Procedure
    always begin
        Clk <= 1'b0;    #(ClkPeriod/2);
        Clk <= 1'b1;    #(ClkPeriod/2);
    end

    initial $readmemh("src/I-Cache.txt", regi);

    initial begin
        Rst_M <= 1'b1; Rst <= 1'b0; Str <= 1'b0;
        En <= 1'b0; RW <= 1'b0;
        @(posedge Clk);
     
        Rst_M <= 1'b0;
        @(posedge Clk);

        for (Index=0; Index<`SL_WIDTH; Index=Index+1) begin
            $display("Writing to SRAM: Addr=%2d, Data=%h", Index, regi[Index]);
            Addr <= Index;
            Data_I <= regi[Index];
            #5;
            RW <= 1'b1;
            En <= 1'b1;
            @(posedge Clk);
        end

        En <= 1'b0; RW <= 1'b0;
        @(posedge Clk);

        Rst <= 1'b1;
        @(posedge Clk);

        // S_wait
        Rst <= 1'b0; Str <= 1'b1;
        @(posedge Clk);

        // S_initial
        @(posedge Clk);

        // when GPP is done
        while (Done != 1'b1)
            @(posedge Clk);

        $stop;
    end

endmodule