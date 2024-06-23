#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "tv.h"

int main(void){

    // 결과 레지스터 파일
    FILE *fp;
    int i, length=sizeof(IC)/sizeof(IC[0]);

    uint32_t regi[32] = {0,};
    uint32_t op, rs, rt, rd, sh, fn, im;

    fp = fopen("sw/sw_result.txt", "w");
	if(fp==NULL){
		printf("error occurs when opening sw_result.txt!\n", i);
		exit(1);
	}

    for (i=0; i<length; i++){
        // opcode 추출, 1111 1100 0000 0000 0000 0000 0000 0000
        op = (IC[i] & 0xFC000000) >> 26;

        // rs 추출, 0000 0011 1110 0000 0000 0000 0000 0000
        rs = (IC[i] & 0x3E00000) >> 21;

        // rt 추출, 0000 0000 0001 1111 0000 0000 0000 0000
        rt = (IC[i] & 0x1F0000) >> 16;

        // immediate 추출, 0000 0000 0000 0000 1111 1111 1111 1111
        im = IC[i] & 0xFFFF;

       switch (op){
        case 0:
            // rd 추출, 0000 0000 0000 0000 1111 1000 0000 0000
            rd = (IC[i] & 0xF800) >> 11;
            
            // funct 추출, 0000 0000 0000 0000 0000 0000 0011 1111
            fn = IC[i] & 0x3F;

            switch (fn){
            case 0: //0x00 shifh left
                // shamt 추출
                sh = (IC[i] & 0x7C0) >> 6; // 0000 0000 0000 0000 0000 0111 1100 0000
                regi[rd] = regi[rt] << sh;
                printf("Shift Left $(%d), $(%d), %d : %d\n", rd, rt, sh, regi[rd]);
                break;

            case 2: //0x02 shift right
                sh = (IC[i] & 0x7C0) >> 6; // 0000 0000 0000 0000 0000 0111 1100 0000
                regi[rd] = regi[rt] >> sh;
                printf("Shift Right $(%d), $(%d), %d : %d\n", rd, rt, sh, regi[rd]);
                break;

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

    for (i = 0; i < 32; i++)
        fprintf(fp, "%d: %x\n", i, regi[i]);
    
    return 0;
}