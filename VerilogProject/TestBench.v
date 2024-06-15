`timescale 1ns/1ns

module TestBench();

    reg Clk, Rst;

    GPP gpp(Clk, Rst);

    // clock 생성
    always begin
        Clk <= 0;
        #10;
        Clk <= 1;
        #10;
    end

    initial begin
        Rst <= 1;
        @(posedge Clk);

        // S_wait
        Rst <= 0;
        @(posedge Clk);

        // S_fetch
        @(posedge Clk);

        // S_decode
        @(posedge Clk);

        // S_execute
        @(posedge Clk);

        // S_store
        @(posedge Clk);

        $stop;
    end


endmodule