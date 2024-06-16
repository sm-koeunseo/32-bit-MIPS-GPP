`include "define.h"

module RegFile(R1_Addr, R2_Addr, W_Addr, R1_en, R2_en, W_en, R1_Data, R2_Data, W_Data, Clk, Rst, dis);

    input [(`RA_WIDTH-1):0] R1_Addr, R2_Addr, W_Addr;
    input R1_en, R2_en, W_en;
    output reg [(`D_WIDTH-1):0] R1_Data, R2_Data;
    input [(`D_WIDTH-1):0] W_Data;
    input Clk, Rst;

    input dis;
    integer I;

    // 앞 : 크기 설정 [n:0] -> n+1 bit 변수 선언
    // 뒤 : 개수 설정 [0:m] -> m+1 개의 배열 선언
    reg [(`D_WIDTH-1):0] RegFile [0:(2**`RA_WIDTH-1)],
                        RegFile_Next [0:(2**`RA_WIDTH-1)];

    integer Index;

    // Reg
    always @(posedge Clk) begin
        if (Rst == 1'b1)
            for(Index=0; Index<(2**`RA_WIDTH);Index=Index+1)
                RegFile[Index] <= {`D_WIDTH{1'b0}};
        else
            for(Index=0; Index<(2**`RA_WIDTH);Index=Index+1)
                RegFile[Index] <= RegFile_Next[Index];
    end

    // CombLogic - Write Operation
    always @* begin
        for(Index=0; Index<(2**`RA_WIDTH);Index=Index+1)
                RegFile_Next[Index] <= RegFile[Index];
        
        if(W_en == 1'b1)
            RegFile_Next[W_Addr] <= W_Data;
    end

    // CombLogic - Read1 Operation
    always @* begin
        if (R1_en == 1'b1)
            R1_Data <= RegFile[R1_Addr];
        else
            R1_Data <= {`D_WIDTH{1'bZ}};
    end

    // CombLogic - Read2 Operation
    always @* begin
        if (R2_en == 1'b1)
            R2_Data <= RegFile[R2_Addr];
        else
            R2_Data <= {`D_WIDTH{1'bZ}};
    end

    always @(dis) begin
        if(dis) begin    
            for (I=0; I<26; I=I+1) begin
                $write("%d, ",RegFile[I]);
            end
            $display("");
        end
    end

endmodule