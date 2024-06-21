`include "define.h"

module BSR(en, BS_AMT, D_IN, D_OUT);

input en;
input [2:0] BS_AMT;
input [`D_WIDTH-1:0] D_IN;
output reg [`D_WIDTH-1:0] D_OUT;
reg [`D_WIDTH-1:0] D_TMP;

// BSR2 bsr2 (BS_AMT[1], D_IN, D_TMP);
// BSR1 bsr1 (BS_AMT[0], D_TMP, D_OUT);

always @(en) begin
    if (en) begin
        D_TMP <= D_IN;

        if (BS_AMT[2])
            D_TMP <= {{2{D_TMP[`D_WIDTH-1]}}, D_TMP[`D_WIDTH-1:2]};

        if (BS_AMT[1])
            D_TMP <= {{D_TMP[`D_WIDTH-1]}, D_TMP[`D_WIDTH-1:1]};

        D_OUT <= D_TMP;
        $display("%b", D_TMP);
    end
end

endmodule