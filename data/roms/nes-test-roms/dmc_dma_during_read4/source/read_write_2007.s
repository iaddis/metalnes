; Read of $2007 just before write behaves normally.
;
; Output:
;33 11 22 33 09 55 66 77 
;33 11 22 33 09 55 66 77 

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
      ; Dump VRAM
      lda #0
      sta PPUADDR
      sta PPUADDR
      ldx #8
:     lda PPUDATA
      jsr print_a
      dex
      bne :-
      jsr print_newline
      rts

main: ; Manually read before write
      jsr begin
      ldx #0
      lda #9
      ldx $2007
      sta $2007
      jsr end
      
      ; Read one clock before write
      jsr begin
      ldx #0
      lda #9
      sta $2007,x ; reads then writes $2007
      jsr end
      
      check_crc $0F877C4B
      jmp tests_passed
