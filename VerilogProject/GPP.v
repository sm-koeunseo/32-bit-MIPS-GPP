`timescale 1ns/1ns

module GPP (Clk, Rst);

    input Clk, Rst;
    reg [31:0] regi [0:25];

    parameter S_wait = 0, S_fetch = 1;
    parameter S_decode = 2, S_execute = 3;
    parameter S_store = 4;
    reg [2:0] State, StateNext;

    //tmp
    reg [31:0] IC;

    // im = rd+sh+fn
    wire [5:0] op;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] sh;
    wire [5:0] fn;

    reg [31:0] rsv, rtv, rdv;
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
                regi[0] <= 0;
                StateNext <= S_fetch;
            end
            S_fetch: begin
                IC = 32'h20080001;
                StateNext <= S_decode;
            end
            S_decode: begin // get value from regi
                case(op)
                    0: begin
                        // rtv <= regi[rt];
                    end
                    8: begin
                        rsv <= regi[rs];
                        #5;
                        $display("S_decode  || rs : %d, rsv : %d", rs, regi[rs]);
                    end
                endcase
                StateNext <= S_execute;
            end
            S_execute: begin
                case(op)
                    0: begin
                    end
                    8: begin
                        {Co, rdv} <= rsv + {rd,sh,fn};
                        #5;
                        $display("S_execute || im : %d, Co : %d, rdv : %d", {rd,sh,fn}, Co, rdv);
                    end
                endcase
                StateNext <= S_store;
            end
            S_store: begin
                regi[rd] <= rdv;
                #5;
                $display("S_store   || rd : %d, regi[rd] : %d", rd, regi[rd]);
                StateNext <= S_wait;
            end
        endcase
    end

endmodule