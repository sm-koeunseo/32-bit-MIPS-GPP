`include "define.h"

module GPP_TOP(Clk, Done, Rst, Str, Addr2, Data_I, Data2_O, en2, we2, Rst_M);

// Common Interface
    input   Clk;

    // GPP_Core Interface
    output  Done;
    input   Rst;
    input   Str;

    // Dual-port SRAM Interface
    input [(`SA_WIDTH-1):0] Addr2;
    input [(`D_WIDTH-1):0] Data_I;
    output [(`D_WIDTH-1):0] Data2_O;
    input en2, we2;
    input Rst_M;

    //Interface between GPP_Core and Dual_port SRAM
    wire [(`SA_WIDTH-1):0] Addr1;
    wire [(`D_WIDTH-1):0] Data1_O;
    wire en1, we1;

    GPP GPP_Core(Addr1, Data1_O, we1, en1, Done, Clk, Rst, Str);
    
    sram_coregen sram(
        Addr1,   //addra,
        Addr2,   //addrb,
        Clk,        //clka,
        Clk,        //clkb,
        Data_I,     //dina,
        Data_I,    //dinb,
        Data1_O,     //douta,
        Data2_O,    //doutb,
        en1,      //ena,
        en2,     //enb,
        Rst_M,      //sinita,
        Rst_M,      //sinitb,
        we1,      //wea,
        we2);    //web);

endmodule