; Reports whether initial values in palette at power-up match those
; that my NES has. These values are probably unique to my NES.

      .include "prefix_ppu.a"

reset:
      lda   #50
      jsr   delay_msec
      
      jsr   wait_vbl
      lda   #0
      sta   $2000
      sta   $2001
      
      lda   #2;) Palette differs from table
      sta   result
      lda   #$3f
      sta   $2006
      lda   #$00
      sta   $2006
      ldx   #0
:     lda   $2007
      cmp   table,x
      jsr   error_if_ne
      inx
      cpx   #$20
      bne   -
      
      lda   #1;) Palette matches
      sta   result
      jmp   report_final_result
      
table:
      .db   $09,$01,$00,$01,$00,$02,$02,$0D,$08,$10,$08,$24,$00,$00,$04,$2C
      .db   $09,$01,$34,$03,$00,$04,$00,$14,$08,$3A,$00,$02,$00,$20,$2C,$08
