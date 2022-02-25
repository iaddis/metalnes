      .include "prefix_swap.a"
      
r_set_reload      = $c000
r_clear_counter   = $c001
r_disable_irq     = $e000
r_enable_irq      = $e001

begin_mmc3_tests:
      lda   #200
      jsr   delay_msec
      lda   #$c0        ; disable frame irq
      sta   $4017
      lda   #0          ; disable PPU
      sta   $2001
      sta   $2000
      bit   $2002       ; vaddr = 0
      sta   $2006
      sta   $2006
      
      ; Setup RESET handler
      ldx   $fffc
      lda   #$4c
      sta   0,x
      lda   #$00
      sta   1,x
      lda   #$07
      sta   2,x
      
      ; Setup IRQ handler
      ldx   $fffe
      lda   #$4c
      sta   0,x
      lda   #irq.lsb
      sta   1,x
      lda   #irq.msb
      sta   2,x
      
      lda   #1
      jsr   set_reload
      jsr   clear_counter
      ldx   #0
      jsr   clock_counter_x
      jsr   clear_counter
      ldx   #0
      jsr   clock_counter_x
      jsr   clear_irq
      rts
      
      rts
      .code

; Decrement counter until IRQ occurs, then
; print how many decrements were required
print_count:
      jsr   get_count
      jsr   print_x
      jsr   clear_irq
      rts
      .code

; Print $01 if IRQ is pending, $00 if not
print_pending:
      jsr   get_pending
      lda   #'P'
      dex
      beq   +
      lda   #'-'
:     jsr   debug_char
      lda   #32
      jmp   debug_char
      .code

set_reload:
      sta   r_set_reload
      rts

clear_counter:
      lda   #123
      sta   r_clear_counter
      rts

disable_irq:
      lda   #123
      sta   r_disable_irq
      rts

; Disable then re-enable IRQ
clear_irq:
      lda   #123
      sta   r_disable_irq
enable_irq:
      lda   #123
      sta   r_enable_irq
      rts
      .code

; Clock counter X times
; Preserved: A, Y
clock_counter_x:
:     jsr   clock_counter
      dex
      bne   -
      rts
      .code

; Clock counter once
; Preserved: A, X, Y
clock_counter:
      pha
      lda   #0
      sta   $2006
      sta   $2006
      lda   #$10
      sta   $2006
      sta   $2006
      lda   #0
      sta   $2006
      sta   $2006
      pla
      rts
      .code

; Return X=1 if IRQ is pending, otherwise X=0
; Preserved: Y
get_pending:
      ldx   #1
      cli
      nop
      sei   ; IRQ causes return from this routine
      nop
      ldx   #0
      rts
      .code
      
; Decrement counter until IRQ occurs and return
; number of decrements required in A.
get_count:
      ldx   #0
      cli
      nop
      nop
:     lda   #0
      sta   $2006
      sta   $2006
      lda   #$10
      inx
      sta   $2006
      sta   $2006
      bne   -
      sei
      ldx   #$ff
      rts

; Return from get_count
irq:  pla
      pla
      pla
      lda   #0
      sta   $2006
      sta   $2006
      rts
      .code
