`include "define.h"

module TestBench();

    reg Clk, Rst, Rst_M;
    wire Done;
    
    reg [(`SA_WIDTH-1):0] Addr;
    reg [(`D_WIDTH-1):0] Data_I;
    wire[(`D_WIDTH-1):0] Data_O;
    reg En, RW;

    reg [(`D_WIDTH-1):0] regi[(`SL_WIDTH-1):0];
    integer Index;
    parameter ClkPeriod = 20;

    //GPP gpp(Addr, Data, RW, En, Done, Clk, Rst);
    //Sram I_Cache(Di, Data, Addr, RW, En, Clk, Rst_m);

    //                (Clk, Done, Rst, Addr2, Data_I, Data2_O, en2, we2, Rst_M);
    GPP_TOP CompToTest(Clk, Done, Rst, Addr, Data_I, Data_O, En, RW, Rst_M);

    // Clock Procedure
    always begin
        Clk <= 1'b0;    #(ClkPeriod/2);
        Clk <= 1'b1;    #(ClkPeriod/2);
    end

    initial $readmemh("src/I-Cache.txt", regi);

    initial begin

        Rst_M <= 1'b1; Rst <= 1'b0;
        En <= 1'b0; RW <= 1'b0;
        @(posedge Clk);
     
        Rst_M <= 0;
        @(posedge Clk);

        for (Index=0; Index<`SL_WIDTH; Index=Index+1) begin
            $display("%h", regi[Index]);
            Addr <= Index;
            Data_I <= regi[Index];
            RW <= 1'b1;
            En <= 1'b1;
            @(posedge Clk);
        end

        En <= 1'b0; RW <= 1'b0;
        @(posedge Clk);

        Rst <= 1'b1;
        @(posedge Clk);

        // S_initail
        Rst <= 1'b0;
        @(posedge Clk);

        while (Done != 1'b1)    // 종료 flag
            @(posedge Clk);

        $stop;
    end

endmodule