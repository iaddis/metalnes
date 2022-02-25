; DMC DMA during $2007 write has no effect.
;
; Output:
;22 11 22 AA 44 55 66 77 
;22 11 22 AA 44 55 66 77 
;22 11 22 AA 44 55 66 77 
;22 11 22 AA 44 55 66 77 
;22 11 22 AA 44 55 66 77 

iter =  5  ; how many times the test is run
time = 11  ; adjusts time of first DMA
dma  =  1  ; set to 0 to disable DMA

.include "common.inc"

; Setup things before time-critical part of test
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
      
      ; PPUADDR=0, and read once to fill buffer
      lda #0
      sta PPUADDR
      sta PPUADDR
      lda PPUDATA
      
      rts

; DMC DMA occurs during this code
test: nop
      nop
      lda #$AA
      sta $2007
      nop
      nop
      rts
      
; Dump results
end:  lda #0
      sta PPUADDR
      sta PPUADDR
      ldx #8
:     lda PPUDATA
      jsr print_a
      dex
      bne :-
      jsr print_newline
      
      rts

main: ; Run above routines with synchronized DMC DMA
      jsr run_tests
      
      check_crc $28F53CA4
      jmp tests_passed
