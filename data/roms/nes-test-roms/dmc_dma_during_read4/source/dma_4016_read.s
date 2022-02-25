; DMC DMA during $4016 read causes extra $4016
; read.
;
; Output:
;08 08 07 08 08

iter =  5  ; how many times the test is run
time = 14  ; adjusts time of first DMA
dma  =  1  ; set to 0 to disable DMA

.include "common.inc"

; Setup things before time-critical part of test
begin:
      ; Start controller read
      lda #1
      sta $4016
      lda #0
      sta $4016
      rts

; DMC DMA occurs during this code
test: nop
      nop
      lda $4016
      nop
      nop
      rts
      
; Dump results
end:  ; Count number of bits until controller
      ; returns 1
      ldx #0
:     inx
      lda $4016
      lsr a
      bcc :-
      
      jsr print_x
      rts

main: ; Run above routines with synchronized DMC DMA
      jsr run_tests
      check_crc $F0AB808C
      jmp tests_passed

