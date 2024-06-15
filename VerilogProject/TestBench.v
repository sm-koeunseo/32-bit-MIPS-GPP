`timescale 1ns/1ns

module TestBench();

    reg Clk, Rst, Rst_m;
    wire [31:0] Di, Data;
    wire [3:0] Addr;
    wire RW, En, Done;

    parameter ClkPeriod = 20;

    GPP gpp(Addr, Data, RW, En, Done, Clk, Rst);
    Sram I_Cache(Di, Data, Addr, RW, En, Clk, Rst_m);

    // Clock Procedure
    always begin
        Clk <= 1'b0;    #(ClkPeriod/2);
        Clk <= 1'b1;    #(ClkPeriod/2);
    end

    initial $readmemh("I-Cache.txt", I_Cache.Memory);

    initial begin
        Rst_m <= 0; Rst <= 1;
        @(posedge Clk);

        // S_initail
        Rst <= 0;
        @(posedge Clk);

        while (Done != 1'b1)    // 종료 flag
            @(posedge Clk);

        // // S_fetch
        // @(posedge Clk);

        // // S_decode
        // @(posedge Clk);

        // // S_execute
        // @(posedge Clk);

        // // S_store
        // @(posedge Clk);

        $stop;
    end

endmodule