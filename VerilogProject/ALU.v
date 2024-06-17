`include "define.h"

module ALU(op_code, operand1, operand2, result, enable);

    input [2:0] op_code;
    input [(`D_WIDTH-1):0] operand1, operand2;
    output reg [(`D_WIDTH-1):0] result;
    input enable;

    always @* begin
        if (enable) begin
            case(op_code)
                0: result = operand1 + operand2;        // add, addi
                1: result = operand1 - operand2;        // sub
                2: result = operand1 * operand2;        // mult
                3: result = operand1 / operand2;        // div
                4: result = operand1 << operand2;       // shift left
                5: result = operand1 >> operand2;       // shift right
            endcase
        end
    end


endmodule