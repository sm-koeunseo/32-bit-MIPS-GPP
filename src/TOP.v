`include "define.h"

module GPP_TOP(Clk, Done, Rst,
            M_di, MI_Addr, MO_do, M_enb, M_web, Rst_M);

    // Common Interface
    input   Clk;

    // GPP_Core Interface
    output  Done;
    input   Rst;

    // Dual-port SRAM Interface
    input    [(`D_WIDTH-1):0] M_di;
    input    [(`SA_WIDTH-1):0] MI_Addr;
    output  [(`D_WIDTH-1):0] MO_do;
    input    M_enb, M_web;
    input    Rst_M;
   
    //Interface between GPP_Core and Dual_port SRAM
    wire [(`D_WIDTH-1):0] MW_do;
    wire [(`SA_WIDTH-1):0] MW_Addr;
    wire M_ena, M_wea;

    GPP GPP_Core(MW_Addr, MO_do, M_wea, M_ena, Done, Clk, Rst);
    
    sram_coregen sram(
        MW_Addr,   //addra,
        MI_Addr,   //addrb,
        Clk,        //clka,
        Clk,        //clkb,
        M_di,     //dina,
        M_di,    //dinb,
        MW_do,     //douta,
        MO_do,    //doutb,
        M_ena,      //ena,
        M_enb,     //enb,
        Rst_M,      //sinita,
        Rst_M,      //sinitb,
        M_wea,      //wea,
        M_web);    //web);

endmodule