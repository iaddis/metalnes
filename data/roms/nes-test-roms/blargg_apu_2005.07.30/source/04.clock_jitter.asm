; Tests for APU clock jitter. Also tests basic timing of frame irq flag
; since it's needed to determine jitter.

      .include "prefix_apu.a"

jitter = 1

reset:
      jsr   setup_apu
      
      lda   #2;) Frame irq is set too soon
      sta   result
      lda   #$40        ; clear frame irq flag
      sta   $4017
      lda   #$00        ; begin mode 0, frame irq enabled
      sta   $4017
      ldy   #48         ; 29826 delay
      lda   #123        
      jsr   delay_ya1
      lda   $4015       ; read at 29830
      and   #$40
      bne   error
      
      lda   #3;) Frame irq is set too late
      sta   result
      lda   #$40        ; clear frame irq flag
      sta   $4017
      lda   #$00        ; begin mode 0, frame irq enabled
      sta   $4017
      ldy   #48         ; 29828 delay
      lda   #123        
      jsr   delay_ya3
      lda   $4015       ; read at 29832
      and   #$40
      beq   error
      
      lda   #4;) Even jitter not handled properly
      sta   result
      jsr   get_jitter
      sta   <jitter
      sta   <jitter     ; keep on even clocks
      jsr   get_jitter
      cmp   <jitter
      bne   error
      
      lda   #5;) Odd jitter not handled properly
      sta   result
      jsr   get_jitter
      sta   <jitter
      jsr   get_jitter  ; occurs on odd clock
      cmp   <jitter
      beq   error
      
      lda   #1;) Passed tests
      sta   result
error:
      jmp   report_final_result

; Return current jitter in A. Takes an even number of clocks.
get_jitter:
      lda   <0          ; make routine total an even number of clocks
      lda   #$40        ; clear frame irq flag
      sta   $4017
      lda   #$00        ; begin mode 0, frame irq enabled
      sta   $4017
      ldy   #48         ; 29827 delay
      lda   #123        
      jsr   delay_ya2
      lda   $4015       ; read at 29831
      and   #$40
      rts
