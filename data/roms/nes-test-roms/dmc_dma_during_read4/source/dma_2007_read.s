; DMC DMA during $2007 read causes 2-3 extra $2007
; reads before real read.
;
; Number of extra reads depends in CPU-PPU
; synchronization at reset.
;
; Output:
;11 22 
;11 22 
;33 44 or 44 55
;11 22 
;11 22 
;159A7A8F or 5E3DF9C4

iter =  5  ; how many times the test is run
time = 14  ; adjusts time of first DMA
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
      ldx $2007
      nop
      nop
      rts
      
; Dump results
end:  lda $2007
      jsr print_x
      jsr print_a
      jsr print_newline
      rts

main: ; Run above routines with synchronized DMC DMA
      jsr run_tests
      
      jsr print_crc
      rts
