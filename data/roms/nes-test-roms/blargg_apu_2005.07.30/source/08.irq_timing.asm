; IRQ handler is invoked at minimum 29833 clocks after writing
; $00 to $4017.

      .include "prefix_apu.a"

phase = 1

reset:
      jsr   setup_apu
      
      ; Shortest instruction is 2 clocks, so two tests
      ; are needed with delays differing by 1 clock
      
      lda   #1
      sta   phase
loop: sei
      lda   #4;) Never occurred
      sta   result
      jsr   sync_apu
      lda   #$40        ; clear flag
      sta   $4017
      lda   #2;) Too soon
      cli
      ldx   #$00        ; begin mode 0
      stx   $4017       ; 1
      
      ldy   #255        ; 29823 delay
      ldx   #70
:     dex
      bne   -
      ldx   #22
      dey
      bne   -
      
      ldx   <phase      ; 3
      bne   +           ; 2/3
:     nop               ; 2
      lda   #0          ; 2
      ; IRQ occurs here
      lda   #3;) Too late
      
      ldy   #252        ; 29800 delay
      ldx   #135
:     dex
      bne   -
      ldx   #22
      dey
      bne   -
      
      sei
      lda   result
      bne   error
      
      dec   phase
      bpl   loop
      
      lda   #1;) Passed tests
      sta   result
error:
      jmp   report_final_result

irq:  sta   result
      bit   $4015
      rti
