; Shell that calls begin, synchronizes with DMC, then
; calls test with DMC DMA occurring during its
; execution. Then stops DMC and calls end. Repeats
; above, each with the DMA one clock later than the
; previous.
;
; The following constants must be set before including
; this file:
;
;iter =  n  ; how many times the test is run
;time =  n  ; adjusts time of first DMA
;dma  =  1  ; set to 0 to disable DMA

CHR_RAM=1
.include "shell.inc"
.include "sync_dmc.s"

run_tests:
      for_loop dmc_test,iter,1,-1
      rts

dmc_test:
      pha
      
      jsr begin
      
      ; Synchronize with DMC
      jsr time_code_begin
      
      ; Start DMC
      lda #$10
      sta $4015
      lda #dma*$10
      sta $4015
      
      ; Delay
      pla
      jsr delay_a_25_clocks
      delay 3309+33+time-iter
      
      ; DMC DMA occurs during this code
      jsr test
      
      ; Stop DMC
      pha
      lda #0
      sta $4015
      pla
      
      jsr end
      
      rts

.align 256
