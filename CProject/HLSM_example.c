#include <stdio.h>
#include <stdint.h>

int main(void){

    // fetch
    uint32_t array[] = {0x20080001, 0x20090003, 0x01098020, 0x20080002,
                        0x02088818, 0x0230881a, 0x02118022};
    int i, length=sizeof(array)/sizeof(array[0]);
    //char opcode[6], rs[5], rt[5], rd[5], shamt[5], funct[6];

    uint32_t op, rs, rt, rd, sh, fn, im;


    for (i=0; i<length; i++){
        // opcode 추출, 1111 1100 0000 0000 0000 0000 0000 0000
        op = (array[i] & 0xFC000000) >> 26;
        //printf("%06X, %d\n", opcode, opcode);

        // rs 추출, 0000 0011 1110 0000 0000 0000 0000 0000
        rs = (array[i] & 0x3E00000) >> 21;

        // rt 추출, 0000 0000 0001 1111 0000 0000 0000 0000
        rt = (array[i] & 0x1F0000) >> 16;

        //printf("%d, %d, %d\n", op, rs, rt);

        // immediate 추출, 0000 0000 0000 0000 1111 1111 1111 1111
        im = array[i] & 0xFFFF;

       switch (op){
        case 0:
            // rd 추출, 0000 0000 0000 0000 1111 1000 0000 0000
            rd = (array[i] & 0xF800) >> 11;
            
            // funct 추출, 0000 0000 0000 0000 0000 0000 0011 1111
            fn = array[i] & 0x3F;

            switch (fn){

            case 24: //0x18
                printf("Multiply $(%d), $(%d), $(%d)\n", rd, rs, rt);
                break;

            case 26: //0x1a
                printf("Divide $(%d), $(%d), $(%d)\n", rd, rs, rt);
                break;

            case 32: // 0x20
                printf("Add $(%d), $(%d), $(%d)\n", rd, rs, rt);
                break;
            
            case 34: //0x22
                printf("Subract $(%d), $(%d), $(%d)\n", rd, rs, rt);
                break;

            }
            break;
        
        case 8:
            printf("addi $(%d), $(%d), %d\n", rt, rs, im);
            break;
        
        // case 35:
        //     printf("It is Load Word\n");
        //     break;
        }

        /*

        // shamt 추출
        uint32_t masked_shamt = array[i] & 0x7C0; // 0000 0000 0000 0000 0000 0111 1100 0000
        uint32_t shamt_shifted = masked_shamt >> 6;*/
    }

    return 0;
}