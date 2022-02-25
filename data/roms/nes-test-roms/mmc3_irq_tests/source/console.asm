
console_pos = $7f0

; Print char A to console
; Preserved: A, X, Y
print_char:
      jsr   wait_vbl    ; wait for safe access
print_char_no_wait:
      pha
      lda   #$20
      sta   $2006
      inc   console_pos
      lda   console_pos
      sta   $2006
      lda   #0          ; restore scroll
      sta   $2005
      sta   $2005
      pla
      sta   $2007
      rts
      .code

; Go to next line
; Preserved: A, X, Y
console_newline:
      pha
      lda   console_pos
      and   #$e0
      clc
      adc   #$21
      sta   console_pos
      pla
      rts
      .code
      
; Initialize console
init_console:
      lda   #$81
      sta   console_pos
      
      jsr   wait_vbl    ; init ppu
      lda   #0
      sta   $2000
      sta   $2001
      
      lda   #$3f        ; load palette
      jsr   set_vpage
      lda   #15         ; bg
      ldx   #48         ; fg
      ldy   #8
pal:  sta   $2007
      stx   $2007
      stx   $2007
      stx   $2007
      dey
      bne   pal
      
      lda   #$02        ; load tiles
      jsr   set_vpage
      lda   #chr_data.lsb
      sta   <$f0
      lda   #chr_data.msb
      sta   <$f1
      ldy   #0
      lda   #59         ; 59 chars in data
      sta   <$f2
chr_loop:
      ldx   #8
      lda   #0
:     sta   $2007
      dex
      bne   -
      
      ldx   #8
:     lda   ($f0),y
      iny
      sta   $2007
      dex
      bne   -
      
      tya
      bne   +
      inc   <$f1
:     dec   <$f2
      bne   chr_loop
      
      lda   #32
      jsr   fill_nametable
      
      jsr   wait_vbl    ; enable ppu
      lda   #0
      sta   $2005
      sta   $2005
      lda   #$08
      sta   $2001
      rts
      .code
      
chr_data:
      .incbin "chr.bin"

