`timescale 1ns/1ns

module GPP (Addr, Data, RW, En, Done, Clk, Rst);

    output reg  [3:0] Addr;
    input       [31:0] Data;
    output reg  RW, En, Done;

    input       Clk, Rst;
    reg [31:0]  regi [0:25];

    parameter   S_wait      = 0,
                S_initial   = 1,
                S_fetch     = 2,
                S_decode    = 3,
                S_execute1  = 4,    // load data
                S_execute2  = 5,    // execute data
                S_store     = 6,
                S_end       = 7;
                
    reg [2:0] State, StateNext;
    reg [31:0] IC;
    integer I;

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
                I <= 0;
                StateNext <= S_fetch;
            end
            S_fetch: begin
                if (!(I==1)) begin
                    Addr <= I;
                    RW <= 1'b0;
                    En <= 1'b1;
                    StateNext <= S_decode;
                end else
                    StateNext <= S_end;
            end
            S_decode: begin // get value from regi
                $display("Data : %h", Data);
                IC <= Data;
                StateNext <= S_execute1;
            end
            S_execute1: begin
                case(op)
                    0: begin
                        // rtv <= regi[rt];
                    end
                    8: begin
                        rsv <= regi[rs];
                        #5;
                        $display("S_execute1  || rs : %d, rsv : %d", rs, regi[rs]);
                    end
                endcase
                StateNext <= S_execute2;
            end
            S_execute2: begin
                case(op)
                    0: begin
                    end
                    8: begin
                        {Co, rdv} <= rsv + {rd,sh,fn};
                        #5;
                        $display("S_execute2 || im : %d, Co : %d, rdv : %d", {rd,sh,fn}, Co, rdv);
                    end
                endcase
                StateNext <= S_store;
            end
            S_store: begin
                regi[rd] <= rdv;
                #5;
                $display("S_store   || rd : %d, regi[rd] : %d", rd, regi[rd]);
                I <= I + 1;
                StateNext <= S_fetch;
            end
            S_end : begin
                Done <= 1;
                StateNext <= S_wait;
            end
        endcase
    end

endmodule