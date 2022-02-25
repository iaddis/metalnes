; Double read of $2007 sometimes ignores extra
; read, and puts odd things into buffer.
;
; Output (depends on CPU-PPU synchronization):
;22 33 44 55 66 
;22 44 55 66 77 or
;22 33 44 55 66 or
;02 44 55 66 77 or
;32 44 55 66 77 or
;85CFD627 or F018C287 or 440EF923 or E52F41A5

CHR_RAM=1
.include "shell.inc"

begin:      
      ; Disable PPU
      jsr wait_vbl
      lda #0
      sta PPUMASK
      
      ; Fill VRAM with $11 22 33 44 55 66 77
      lda #0
      sta PPUADDR
      sta PPUADDR
      ldx #7
      lda #$11
:     sta PPUDATA
      clc
      adc #$11
      dex
      bne :-
      
      ; PPUADDR=1, and fill buffer
      lda #$00
      sta PPUADDR
      lda #$01
      sta PPUADDR
      lda PPUDATA
      rts

end:
      jsr print_a
      
      ; Read several bytes
      ldx #4
:     lda PPUDATA
      jsr print_a
      dex
      bne :-
      jsr print_newline
      rts

main: jsr begin
      ldx #$00
      lda $20F7,x ; reads $2007 once
      jsr end
      
      jsr begin
      ldx #$10
      lda $20F7,x ; reads $2007 twice in succession
      jsr end
      
      jsr print_crc
      rts
