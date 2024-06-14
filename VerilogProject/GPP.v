`timescale 1ns/1ns

module GPP (regi, Clk, Rst);

    input Clk, Rst;
    output [31:0] regi [0:25];

    parameter S_wait = 0, S_fetch = 1;
    parameter S_decode = 2, S_execute = 3;
    parameter S_store = 4;
    reg [1:0] State, StateNext;

    //tmp
    reg [31:0] IC;

    // im = rd+sh+fn
    reg [5:0] op;
    reg [4:0] rs;
    reg [4:0] rt;
    reg [4:0] rd;
    reg [4:0] sh;
    reg [5:0] fn;

    reg [4:0] rsv, rtv, rdv;
    reg Co;

    Decoder decoder (IC, op, rs, rt, rd, sh, fn);

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
                StateNext <= S_fetch;
            end
            S_fetch: begin
                IC = 32'h20080001;
                StateNext <= S_decode;
            end
            S_decode: begin // get value from regi
                case(op)
                    0: begin
                    end
                    8: begin
                        // get rtv, rsv
                    end
                endcase
            end
            S_execute: begin
                case(op)
                    0: begin
                    end
                    8: begin
                        {Co, rtv} = rsv + {rd,sh,fn};
                    end
                endcase
            end
            S_store: begin
            end
        endcase
        
    end

endmodule