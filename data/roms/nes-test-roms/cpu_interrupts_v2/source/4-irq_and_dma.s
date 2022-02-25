; Has IRQ occur at various times around sprite DMA.
; First column refers to what instruction IRQ occurred
; after. Second column is time of IRQ, in CPU clocks relative
; to some arbitrary starting point.
;
; 0 +0
; 1 +1
; 1 +2
; 2 +3
; 2 +4
; 4 +5
; 4 +6
; 7 +7
; 7 +8
; 7 +9
; 7 +10
; 8 +11
; 8 +12
; 8 +13
; ...
; 8 +524
; 8 +525
; 8 +526
; 9 +527

CUSTOM_IRQ=1
.include "shell.inc"
.include "sync_apu.s"

irq:  bit SNDCHN
      rti

begin:
      jsr sync_apu
      lda #0
      sta SNDMODE
      cli
      delay 29273
      lda #0
      rts

end:  tsx
      dex
      lda #$80
      sta $100,x
landing:
                  ; second column refers to these:
      nop         ; 0
      nop         ; 1
      lda #$07    ; 2
      sta SPRDMA  ; 4
      nop         ; 7
      nop         ; 8
      nop         ; 9
      sei
      lda $100,x
      sec
      sbc #<landing
      jsr print_dec
      rts

.macro test dly
      jsr begin
      delay 532-(dly)
      jsr end
      print_str {" +",.string(dly),newline}
.endmacro

main:
      test 0
      test 1
      test 2
      test 3
      test 4
      test 5
      test 6
      test 7
      test 8
      test 9
      test 10
      test 11
      test 12
      test 13
      print_str "...",newline
      test 512+12
      test 512+13
      test 512+14
      test 512+15
      
      check_crc $43571959
      jmp tests_passed
