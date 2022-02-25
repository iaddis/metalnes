      .include "validation.a"

; Arrange for IRQ to be pending on return.
; Preserved: A, X, Y
setup_pending_irq:
      sei
      pha
      lda   #$40        ; clear frame irq flag
      sta   $4017
      lda   #$00        ; begin mode 0
      sta   $4017
      
      lda   #40         ; wait for irq flag to be set
      jsr   delay_msec
      pla
      rts
      .code

