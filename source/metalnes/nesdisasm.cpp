

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <stdint.h>
#include "nesdisasm.h"

namespace metalnes {

static const char *mn[]=
{
  "adc ","and ","asl ","bcc ","bcs ","beq ","bit ","bmi ",
  "bne ","bpl ","brk","bvc ","bvs ","clc","cld","cli",
  "clv","cmp ","cpx ","cpy ","dec ","dex","dey","inx",
  "iny","eor ","inc ","jmp ","jsr ","lda ","nop ","ldx ",
  "ldy ","lsr ","ora ","pha","php","pla","plp","rol ",
  "ror ","rti","rts","sbc ","sta ","stx ","sty ","sec ",
  "sed","sei","tax","tay","txa","tya","tsx","txs"
};

enum Addressing_Modes { Ac=0,Il,Im,Ab,Zp,Zx,Zy,Ax,Ay,Rl,Ix,Iy,In,No };

static uint8_t ad[512]=
{
  10,Il, 34,Ix, No,No, No,No, No,No, 34,Zp,  2,Zp, No,No,
  36,Il, 34,Im,  2,Ac, No,No, No,No, 34,Ab,  2,Ab, No,No,
   9,Rl, 34,Iy, No,No, No,No, No,No, 34,Zx,  2,Zx, No,No,
  13,Il, 34,Ay, No,No, No,No, No,No, 34,Ax,  2,Ax, No,No,
  28,Ab,  1,Ix, No,No, No,No,  6,Zp,  1,Zp, 39,Zp, No,No,
  38,Il,  1,Im, 39,Ac, No,No,  6,Ab,  1,Ab, 39,Ab, No,No,
   7,Rl,  1,Iy, No,No, No,No, No,No,  1,Zx, 39,Zx, No,No,
  47,Il,  1,Ay, No,No, No,No, No,No,  1,Ax, 39,Ax, No,No,
  41,Il, 25,Ix, No,No, No,No, No,No, 25,Zp, 33,Zp, No,No,
  35,Il, 25,Im, 33,Ac, No,No, 27,Ab, 25,Ab, 33,Ab, No,No,
  11,Rl, 25,Iy, No,No, No,No, No,No, 25,Zx, 33,Zx, No,No,
  15,Il, 25,Ay, No,No, No,No, No,No, 25,Ax, 33,Ax, No,No,
  42,Il,  0,Ix, No,No, No,No, No,No,  0,Zp, 40,Zp, No,No,
  37,Il,  0,Im, 40,Ac, No,No, 27,In,  0,Ab, 40,Ab, No,No,
  12,Rl,  0,Iy, No,No, No,No, No,No,  0,Zx, 40,Zx, No,No,
  49,Il,  0,Ay, No,No, No,No, No,No,  0,Ax, 40,Ax, No,No,
  No,No, 44,Ix, No,No, No,No, 46,Zp, 44,Zp, 45,Zp, No,No,
  22,Il, No,No, 52,Il, No,No, 46,Ab, 44,Ab, 45,Ab, No,No,
   3,Rl, 44,Iy, No,No, No,No, 46,Zx, 44,Zx, 45,Zy, No,No,
  53,Il, 44,Ay, 55,Il, No,No, No,No, 44,Ax, No,No, No,No,
  32,Im, 29,Ix, 31,Im, No,No, 32,Zp, 29,Zp, 31,Zp, No,No,
  51,Il, 29,Im, 50,Il, No,No, 32,Ab, 29,Ab, 31,Ab, No,No,
   4,Rl, 29,Iy, No,No, No,No, 32,Zx, 29,Zx, 31,Zy, No,No,
  16,Il, 29,Ay, 54,Il, No,No, 32,Ax, 29,Ax, 31,Ay, No,No,
  19,Im, 17,Ix, No,No, No,No, 19,Zp, 17,Zp, 20,Zp, No,No,
  24,Il, 17,Im, 21,Il, No,No, 19,Ab, 17,Ab, 20,Ab, No,No,
   8,Rl, 17,Iy, No,No, No,No, No,No, 17,Zx, 20,Zx, No,No,
  14,Il, 17,Ay, No,No, No,No, No,No, 17,Ax, 20,Ax, No,No,
  18,Im, 43,Ix, No,No, No,No, 18,Zp, 43,Zp, 26,Zp, No,No,
  23,Il, 43,Im, 30,Il, No,No, 18,Ab, 43,Ab, 26,Ab, No,No,
   5,Rl, 43,Iy, No,No, No,No, No,No, 43,Zx, 26,Zx, No,No,
  48,Il, 43,Ay, No,No, No,No, No,No, 43,Ax, 26,Ax, No,No
};

static int DAsm(char *S, const uint8_t *A, uint16_t PC)
{
  const uint8_t *B;
  uint8_t J;
  uint16_t OP,TO;

  B=A;OP=(*B++)*2;

  switch(ad[OP+1])
  {
    case Ac: sprintf(S,"%s a",mn[ad[OP]]);break;
    case Il: sprintf(S,"%s",mn[ad[OP]]);break;

    case Rl: J=*B++;TO=PC+2+((J<0x80)? J:(J-256));
             sprintf(S,"%s $%04X",mn[ad[OP]],TO);break;

    case Im: sprintf(S,"%s #$%02X",mn[ad[OP]],*B++);break;
    case Zp: sprintf(S,"%s $%02X",mn[ad[OP]],*B++);break;
    case Zx: sprintf(S,"%s $%02X,x",mn[ad[OP]],*B++);break;
    case Zy: sprintf(S,"%s $%02X,y",mn[ad[OP]],*B++);break;
    case Ix: sprintf(S,"%s ($%02X,x)",mn[ad[OP]],*B++);break;
    case Iy: sprintf(S,"%s ($%02X),y",mn[ad[OP]],*B++);break;

    case Ab: sprintf(S,"%s $%04X",mn[ad[OP]],B[1]*256+B[0]);B+=2;break;
    case Ax: sprintf(S,"%s $%04X,x",mn[ad[OP]],B[1]*256+B[0]);B+=2;break;
    case Ay: sprintf(S,"%s $%04X,y",mn[ad[OP]],B[1]*256+B[0]);B+=2;break;
    case In: sprintf(S,"%s ($%04X)",mn[ad[OP]],B[1]*256+B[0]);B+=2;break;

    default: sprintf(S,"db $%02X",OP/2);
  }
  return(int)(B-A);
}

//
//
//

int nes_disasm(std::string &str, const uint8_t *mem, uint16_t pc)
{
    char buffer[512];
    int size = DAsm(buffer, mem, pc);
    str = buffer;
    return size;
}

}





