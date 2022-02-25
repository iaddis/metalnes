; Tests basic MMC3 IRQ timing for scanlines 0, 1, and 240

      .include "prefix_mmc3_validation.a"
      
test_name:
      .db   "MMC3 IRQ TIMING",0

reset:
      jsr   begin_mmc3_tests
      
      lda   #0
      jsr   clear_vram
      jsr   clear_sprites
      
      lda   #0
      jsr   begin_test
      ldy   #5          ; 2327 delay
      lda   #91         
      jsr   delay_ya5
      lda   #2;) Scanline 0 time is too soon/late
      jsr   check_irq_time
      
      lda   #1
      jsr   begin_test
      ldy   #20         ; 2440 delay
      lda   #23         
      jsr   delay_ya3
      lda   #4;) Scanline 1 time is too soon/late
      jsr   check_irq_time
      
      lda   #240
      jsr   begin_test
      ldy   #173        ; 29606 delay
      lda   #33         
      jsr   delay_ya6
      lda   #6;) Scanline 239 time is too soon/late
      jsr   check_irq_time
      
      jmp   tests_passed
      .code

begin_test:
      pha
      jsr   sync_ppu_align2_30
      lda   #$08        ; 12
      sta   $2000
      lda   #$18
      sta   $2001
      pla               ; 20
      sta   r_set_reload
      sta   r_clear_counter
      sta   r_disable_irq
      sta   r_enable_irq
      rts               ; 6
      .code

get_irq_time:
      ldx   #0
      cli
      nop
      ldx   #1
      nop
      sei   ; IRQ causes return from this routine
      ldx   #2
      rts
      .code

check_irq_time:
      sta   result
      jsr   get_irq_time
      dex
      bne   +
      rts
:     bmi   +
      inc   result
:     jmp   report_final_result
      .code
