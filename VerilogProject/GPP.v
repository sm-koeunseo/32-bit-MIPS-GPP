`include "define.h"

module GPP (Addr, Data, RW, En, Done, Clk, Rst);

    output reg  [(`SA_WIDTH-1):0]   Addr;
    input       [(`D_WIDTH-1):0]    Data;
    output reg  RW, En, Done;

    input       Clk, Rst;
    reg [(`D_WIDTH-1):0]  regi [0:25];

    parameter   S_wait      = 0,
                S_initial   = 1,
                S_fetch     = 2,
                S_decode    = 3,
                S_execute   = 4,
                S_end       = 5;
                
    reg [2:0] State, StateNext;
    reg [(`D_WIDTH-1):0] IR;
    integer PC, J;
    reg Co;

    // im = rd+sh+fn
    wire [5:0] op;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] sh;
    wire [5:0] fn;

    Decoder decoder (IR, op, rs, rt, rd, sh, fn);

    // StateReg
    always @(posedge Clk) begin
        if (Rst == 1)
            State <= S_initial;
        else
            State <= StateNext;
    end

    // ComLogic
    always @(State) begin        
        Addr <= 4'b0000;
        RW <= 1'b0;
        En <= 1'b0;

        case(State)
            S_wait: begin
                StateNext <= S_wait;
            end
            S_initial: begin
                regi[0] <= 0;
                Done <= 1'b0;
                PC <= 0;
                StateNext <= S_fetch;
            end
            S_fetch: begin
                
                for (J=0; J<26; J=J+1) begin
                    $write("%d, ",regi[J]);
                end
                $display("");

                if (!(PC==9)) begin
                    Addr <= PC;
                    RW <= 1'b0;
                    En <= 1'b1;
                    PC <= PC+1;
                    StateNext <= S_decode;
                end else
                    StateNext <= S_end;
            end
            S_decode: begin // get value from regi
                $display("Data : %h", Data);
                IR <= Data;
                StateNext <= S_execute;
            end
            S_execute: begin
                case(op)
                    0: begin
                case(fn)
                    0: regi[rd] <= regi[rt] << sh;
                    2: regi[rd] <= regi[rt] >> sh;
                    24: regi[rd] <= regi[rs] * regi[rt];
                    26: regi[rd] <= regi[rs] / regi[rt];
                    32: {Co, regi[rd]} <= regi[rs] + regi[rt];
                    34: {Co, regi[rd]} <= regi[rs] - regi[rt];
                endcase
                    end
                    8: regi[rt] <= regi[rs] + {rd,sh,fn};
                endcase
                StateNext <= S_fetch;
            end
            S_end : begin
                Done <= 1;
                StateNext <= S_wait;
            end
        endcase
    end

endmodule