`include "define.h"

module ALU(op_code, operand1, operand2, result, enable);

    input [2:0] op_code;
    input [(`D_WIDTH-1):0] operand1, operand2;
    output reg [(`D_WIDTH-1):0] result;
    input enable;

    reg en;
    reg [2:0] BS_AMT;
    wire [(`D_WIDTH-1):0] BS_RESULT;
    BSR bsr(en, BS_AMT, operand1, BS_RESULT);

    always @* begin
        if (enable) begin
            en <= 1'b0;
            case(op_code)
                0: result <= operand1 + operand2;        // add, addi
                1: result <= operand1 - operand2;        // sub
                2: result <= operand1 * operand2;        // mult
                3: begin                                // div
                    //result = operand1 / operand2;
                    //$display("%h, %b, %d", operand2, operand2, operand2[2:0]);
                    en <= 1'b1;
                    BS_AMT <= operand2[2:0];
                    result <= BS_RESULT;
                end
                4: result <= operand1 << operand2;       // shift left
                5: result <= operand1 >> operand2;       // shift right
            endcase
        end
    end

endmodule