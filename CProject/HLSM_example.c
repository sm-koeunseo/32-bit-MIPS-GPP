#include <stdio.h>
#include <stdint.h>

int main(void){

    // fetch
    uint32_t IC[] = {0x20080001, 0x20090003, 0x01098020, 0x20080002,
                        0x02088818, 0x0230881a, 0x02118022};
    int i, length=sizeof(IC)/sizeof(IC[0]);
    //char opcode[6], rs[5], rt[5], rd[5], shamt[5], funct[6];

    uint32_t regi[26];
    regi[0] = 0;

    uint32_t op, rs, rt, rd, sh, fn, im;


    for (i=0; i<length; i++){
        // opcode 추출, 1111 1100 0000 0000 0000 0000 0000 0000
        op = (IC[i] & 0xFC000000) >> 26;
        //printf("%06X, %d\n", opcode, opcode);

        // rs 추출, 0000 0011 1110 0000 0000 0000 0000 0000
        rs = (IC[i] & 0x3E00000) >> 21;

        // rt 추출, 0000 0000 0001 1111 0000 0000 0000 0000
        rt = (IC[i] & 0x1F0000) >> 16;

        //printf("%d, %d, %d\n", op, rs, rt);

        // immediate 추출, 0000 0000 0000 0000 1111 1111 1111 1111
        im = IC[i] & 0xFFFF;

       switch (op){
        case 0:
            // rd 추출, 0000 0000 0000 0000 1111 1000 0000 0000
            rd = (IC[i] & 0xF800) >> 11;
            
            // funct 추출, 0000 0000 0000 0000 0000 0000 0011 1111
            fn = IC[i] & 0x3F;

            switch (fn){

            case 24: //0x18
                regi[rd] = regi[rs] * regi[rt];
                printf("Multiply $(%d), $(%d), $(%d) : %d\n", rd, rs, rt, regi[rd]);
                break;

            case 26: //0x1a
                regi[rd] = regi[rs] / regi[rt];
                printf("Divide $(%d), $(%d), $(%d) : %d\n", rd, rs, rt, regi[rd]);
                break;

            case 32: // 0x20
                regi[rd] = regi[rs] + regi[rt];
                printf("Add $(%d), $(%d), $(%d) : %d\n", rd, rs, rt, regi[rd]);
                break;
            
            case 34: //0x22
                regi[rd] = regi[rs] - regi[rt];
                printf("Subract $(%d), $(%d), $(%d) : %d\n", rd, rs, rt, regi[rd]);
                break;

            }
            break;
        
        case 8:
            printf("addi $(%d), $(%d), %d\n", rt, rs, im);
            regi[rt] = regi[rs] + im;
            break;
        }
    }

    return 0;
}