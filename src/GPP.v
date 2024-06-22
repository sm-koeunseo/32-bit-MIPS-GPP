`include "define.h"

module GPP (Addr, Data, RW, En, Done, Clk, Rst, Str);

    input       Clk, Rst, Str;
    integer     I;

    // SRAM
    output reg  [(`SA_WIDTH-1):0]   Addr;
    input       [(`D_WIDTH-1):0]    Data;
    output reg  RW, En, Done;
    
    // register
    reg [(`D_WIDTH-1):0] regi [0:25];

    parameter   S_wait      = 0,
                S_initial   = 1,
                S_fetch1    = 2,
                S_fetch2    = 3,
                S_decode    = 4,
                S_execute1  = 5,
                S_execute2  = 6,
                S_end       = 7;
                
    reg         [3:0] State, StateNext;
    reg         [(`D_WIDTH-1):0] IR;
    integer     PC;

    // im = rd+sh+fn
    wire [5:0] op;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] sh;
    wire [5:0] fn;

    Decoder decoder (IR, op, rs, rt, rd, sh, fn);

    reg     [2:0] op_code;
    reg     [(`D_WIDTH-1):0] operand1, operand2;
    wire    [(`D_WIDTH-1):0] result;
    reg     enable;

    ALU alu (op_code, operand1, operand2, result, enable);

    // StateReg
    always @(posedge Clk) begin
        if (Rst == 1)
            State <= S_wait;
        else
            State <= StateNext;
    end

    // ComLogic
    always @(State) begin        
        case(State)
            S_wait: begin
                if (Str)
                    StateNext <= S_initial;
                else
                    StateNext <= S_wait;
            end
            S_initial: begin
                Done <= 1'b0;
                PC <= 0;
                regi[0] <= 0;
                StateNext <= S_fetch1;
            end
            S_fetch1: begin
                if (PC==`SL_WIDTH) 
                    StateNext <= S_end;
                else begin
                    Addr <= {`SA_WIDTH{1'b0}};
                    RW <= 1'b0;
                    En <= 1'b0;

                    op_code <= 3'b000;
                    operand1 <= {`D_WIDTH{1'b0}};
                    operand2 <= {`D_WIDTH{1'b0}};
                    enable <= 1'b0;

                    Addr <= PC;
                    RW <= 1'b0;
                    En <= 1'b1;
                    PC <= PC+1;

                    StateNext <= S_fetch2;
                end
            end
            S_fetch2: begin
                StateNext <= S_decode;
            end
            S_decode: begin
                IR <= Data;
                StateNext <= S_execute1;
            end
            S_execute1: begin
                case(op)
                    0: begin
                case(fn)
                    0: begin    // sll
                        op_code <= 3'b100;
                        operand1 <= regi[rt];
                        operand2 <= sh;
                    end
                    2: begin    // srl
                        op_code <= 3'b101;
                        operand1 <= regi[rt];
                        operand2 <= sh;
                    end
                    24: begin   // mult
                        op_code <= 3'b010;
                        operand1 <= regi[rs];
                        operand2 <= regi[rt];
                    end
                    26: begin   // div
                        op_code <= 3'b011;
                        operand1 <= regi[rs];
                        operand2 <= regi[rt];
                    end
                    32: begin   // add
                        op_code <= 3'b000;
                        operand1 <= regi[rs];
                        operand2 <= regi[rt];
                    end
                    34: begin   // sub
                        op_code <= 3'b001;
                        operand1 <= regi[rs];
                        operand2 <= regi[rt];
                    end
                endcase
                    end
                    8: begin    // addi
                        op_code <= 3'b000;
                        operand1 <= regi[rs];
                        operand2 <= {rd,sh,fn};
                    end
                endcase

                enable <= 1'b1;
                StateNext <= S_execute2;
            end
            S_execute2: begin
                case(op)
                    0: regi[rd] <= result;
                    8: regi[rt] <= result;
                endcase

                StateNext <= S_fetch1;
            end
            S_end : begin
                $write("regi : ");
                for (I=0; I<25; I=I+1) begin
                    $write("%2d, ", regi[I]);
                end
                $display("%2d", regi[25]);

                Done <= 1;
                StateNext <= S_wait;
            end
        endcase
    end

endmodule