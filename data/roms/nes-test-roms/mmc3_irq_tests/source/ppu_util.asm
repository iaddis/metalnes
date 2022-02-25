
; Clear VBL flag then wait for it to be set
; Preserved: A, X, Y
wait_vbl:
      bit   $2002
:     bit   $2002
      bpl   -
      rts
      .code
      
; Set VRAM address to A * $100
; Preserved: X, Y
set_vpage:
      bit   $2002
      sta   $2006
      lda   #0
      sta   $2006
      rts
      .code

; Set VRAM address to A * $100 + X
; Preserved: A, X, Y
set_vaddr:
      bit   $2002
      sta   $2006
      stx   $2006
      rts
      .code

; Set X and Y scroll
; Preserved: A, X, Y
set_vscroll:
      bit   $2002
      stx   $2005
      sty   $2005
      rts
      .code

; Turn off NMI and disable BG and sprites
; Preserved: A, X, Y
disable_ppu:
      pha
      lda   #0
      sta   $2000
      sta   $2001
      bit   $2002
      sta   $2006
      sta   $2006
      pla
      rts
      .code

; Set sprite memory to $ff
; Preserved: Y
clear_sprites:
      lda   #$ff
      ldx   #0
:     sta   $2004
      dex
      bne   -
      rts
      .code

; Clear/fill nametable with 0/A and clear attributes to 0
clear_nametable:
      lda   #0
fill_nametable:
      pha
      lda   #$20
      jsr   set_vpage
      pla
      ldx   #240
:     sta   $2007
      sta   $2007
      sta   $2007
      sta   $2007
      dex
      bne   -
      lda   #0
      ldx   #32
:     sta   $2007
      dex
      bne   -
      rts
      .code
      
; Clear/fill VRAM with 0/A
clear_vram:
      lda   #0
fill_vram:
      ldy   #$24
      jmp   fill_vram_
      .code
      
; Clear/fill CHR with 0/A
clear_chr:
      lda   #0
fill_chr:
      ldy   #$20
fill_vram_:
      tax
      lda   #0
      jsr   set_vpage
      txa
      ldx   #0
:     sta   $2007
      dex
      bne   -
      dey
      bne   -
      rts
      .code
