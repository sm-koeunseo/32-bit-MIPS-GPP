`timescale 1ns/1ns

module Decoder(IC, op, rs, rt, rd, sh, fn);

    input [31:0] IC;
    output reg [5:0] op;
    output reg [4:0] rs;
    output reg [4:0] rt;
    output reg [4:0] rd;
    output reg [4:0] sh;
    output reg [5:0] fn;

    always @(IC) begin
        op = IC[31:26];
        rs = IC[25:21];
        rt = IC[20:16];
        rd = IC[15:11];
        sh = IC[10:6];
        fn = IC[5:0];
    end

endmodule