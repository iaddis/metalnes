; The VBL flag ($2002.7) is cleared by the PPU around 2270 CPU clocks
; after NMI occurs.

      .include "prefix_ppu.a"

phase = 10

reset:
      lda   #100
      jsr   delay_msec
      
      lda   #1
      sta   phase
      
      jsr   wait_vbl
      lda   #$80
      sta   $2000
      lda   #$00
      sta   $2001
      
wait: jmp   wait

nmi:                    ; 7 clocks for NMI vectoring
      ldy   #203        ; 2251 delay
      lda   #1          
      jsr   delay_ya1
      
      dec   phase       ; 5
      bne   +           ; 3
                        ; -1
      
      lda   $2002       ; read at 2268
      ldx   #2;) VBL flag cleared too soon
      stx   result
      and   #$80
      jsr   error_if_eq
      jmp   wait
      
:     bit   <0
      lda   $2002       ; read at 2272
      ldx   #3;) VBL flag cleared too late
      stx   result
      and   #$80
      jsr   error_if_ne
      
      lda   #1;) Tests passed
      sta   result
      jmp   report_final_result
