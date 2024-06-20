`include "define.h"

module TestBench();

    wire [(`D_WIDTH-1):0] Di, Data;
    wire [(`SA_WIDTH-1):0] Addr;
    wire RW, En, Done;

    reg Clk, Rst, Rst_M;
    reg [(`D_WIDTH-1):0] M_di;
    reg [(`SA_WIDTH-1):0] MI_Addr;
    wire[(`D_WIDTH-1):0] MO_do;
    reg M_enb, M_web;

    reg [(`D_WIDTH-1):0] regi[(`SL_WIDTH-1):0];
    integer Index;
    parameter ClkPeriod = 20;

    //GPP gpp(Addr, Data, RW, En, Done, Clk, Rst);
    //Sram I_Cache(Di, Data, Addr, RW, En, Clk, Rst_m);

    GPP_TOP CompToTest(Clk, Done, Rst, M_di, MI_Addr, MO_do, M_enb, M_web, Rst_M);

    // Clock Procedure
    always begin
        Clk <= 1'b0;    #(ClkPeriod/2);
        Clk <= 1'b1;    #(ClkPeriod/2);
    end

    initial $readmemh("src/I-Cache.txt", regi);

    initial begin
        Rst_M <= 1'b1; Rst <= 1'b0;
        M_enb <= 1'b0; M_web <= 1'b0;
        @(posedge Clk);
     
        Rst_M <= 0;
        @(posedge Clk);

        for (Index=0; Index<`SL_WIDTH; Index=Index+1) begin
            M_enb <= 1'b1;
            M_web <= 1'b1;
            MI_Addr <= Index;
            M_di <= regi[Index];
            @(posedge Clk);
        end

        M_enb <= 1'b0; M_web <= 1'b0;
        @(posedge Clk);

        $stop;
    end

endmodule