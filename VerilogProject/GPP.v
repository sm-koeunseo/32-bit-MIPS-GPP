`include "define.h"

module GPP (Addr, Data, RW, En, Done, Clk, Rst);

    output reg  [(`SA_WIDTH-1):0]   Addr;
    input       [(`D_WIDTH-1):0]    Data;
    output reg  RW, En, Done;

    input       Clk, Rst;
    
    reg [(`RA_WIDTH-1):0] R1_Addr, R2_Addr, W_Addr;
    wire [(`D_WIDTH-1):0] R1_Data, R2_Data;
    reg [(`D_WIDTH-1):0] W_Data;
    reg R1_en, R2_en, W_en, dis;
    
    RegFile regFile(R1_Addr, R2_Addr, W_Addr, R1_en, R2_en, W_en, R1_Data, R2_Data, W_Data, Clk, Rst, dis);

    parameter   S_wait      = 0,
                S_initial   = 1,
                S_fetch     = 2,
                S_decode    = 3,
                S_execute   = 4,
                S_end       = 5;
                
    reg [2:0] State, StateNext;
    reg [(`D_WIDTH-1):0] IR;
    integer PC;
    // reg Co;

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
        
        R1_Addr <= 5'b00000;
        R2_Addr <= 5'b00000;
        W_Addr <= 5'b00000;
        R1_en <= 1'b0;
        R2_en <= 1'b0;
        W_en <= 1'b0;

        case(State)
            S_wait: begin
                StateNext <= S_wait;
            end
            S_initial: begin
                Done <= 1'b0;
                PC <= 0;
                dis <= 0;
                StateNext <= S_fetch;
            end
            S_fetch: begin

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
                    0: begin  // regi[rd] <= regi[rt] << sh;
                        R1_Addr <= rt;
                        R1_en <= 1'b1;
                        #5;

                        W_Addr <= rd;
                        W_Data <= R1_Data << sh;
                        W_en <= 1'b1;
                    end
                    2: begin // regi[rd] <= regi[rt] >> sh;
                        R1_Addr <= rt;
                        R1_en <= 1'b1;
                        #5;

                        W_Addr <= rd;
                        W_Data <= R1_Data >> sh;
                        W_en <= 1'b1;
                    end
                    24: begin // regi[rd] <= regi[rs] * regi[rt];
                        R1_Addr <= rs;
                        R1_en <= 1'b1;
                        R2_Addr <= rt;
                        R2_en <= 1'b1;
                        #5;

                        W_Addr <= rd;
                        W_Data <= R1_Data * R2_Data;
                        W_en <= 1'b1;
                    end
                    26: begin // regi[rd] <= regi[rs] / regi[rt];
                        R1_Addr <= rs;
                        R1_en <= 1'b1;
                        R2_Addr <= rt;
                        R2_en <= 1'b1;
                        #5;

                        W_Addr <= rd;
                        W_Data <= R1_Data / R2_Data;
                        W_en <= 1'b1;
                    end
                    32: begin // {Co, regi[rd]} <= regi[rs] + regi[rt];
                        R1_Addr <= rs;
                        R1_en <= 1'b1;
                        R2_Addr <= rt;
                        R2_en <= 1'b1;
                        #5;

                        W_Addr <= rd;
                        W_Data <= R1_Data + R2_Data;
                        W_en <= 1'b1;
                    end
                    34: begin // {Co, regi[rd]} <= regi[rs] - regi[rt];
                        R1_Addr <= rs;
                        R1_en <= 1'b1;
                        R2_Addr <= rt;
                        R2_en <= 1'b1;
                        #5;

                        W_Addr <= rd;
                        W_Data <= R1_Data - R2_Data;
                        W_en <= 1'b1;
                    end
                endcase
                    end
                    8: begin
                        // regi[rt] <= regi[rs] + {rd,sh,fn};
                        R1_Addr <= rs;
                        R1_en <= 1'b1;
                        #5;

                        W_Addr <= rt;
                        W_Data <= R1_Data + {rd,sh,fn};
                        W_en <= 1'b1;
                    end
                endcase
                StateNext <= S_fetch;
            end
            S_end : begin
                Done <= 1;
                dis <= 1;
                StateNext <= S_wait;
            end
        endcase
    end

endmodule