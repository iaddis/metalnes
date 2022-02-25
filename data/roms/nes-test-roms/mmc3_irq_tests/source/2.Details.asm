; Tests MMC3 IRQ counter details

      .include "prefix_mmc3_validation.a"
      
test_name:
      .db   "MMC3 IRQ COUNTER DETAILS",0

reset:
      jsr   begin_mmc3_tests
      
      lda   #2;) Counter isn't working when reloaded with 255
      ldx   #255
      jsr   begin_counter_test
      ldx   #255
      jsr   clock_counter_x
      jsr   should_be_clear
      jsr   clock_counter
      jsr   should_be_set
      
      lda   #3;) Counter should run even when IRQ is disabled
      ldx   #2
      jsr   begin_counter_test
      jsr   disable_irq
      jsr   clock_counter     ; 2
      jsr   clock_counter     ; 1
      jsr   clock_counter     ; 0
      jsr   clock_counter     ; 2
      jsr   clock_counter     ; 1
      jsr   enable_irq
      jsr   should_be_clear
      jsr   clock_counter     ; 0
      jsr   should_be_set
      
      lda   #4;) Counter should run even after IRQ flag has been set
      ldx   #2
      jsr   begin_counter_test
      jsr   clock_counter     ; 2
      jsr   clock_counter     ; 1
      jsr   clock_counter     ; 0
      jsr   clock_counter     ; 2
      jsr   clear_irq
      jsr   clock_counter     ; 1
      jsr   should_be_clear
      jsr   clock_counter     ; 0
      jsr   should_be_set
      
      lda   #5;) IRQ should not be set when counter reloads with non-zero
      ldx   #1
      jsr   begin_counter_test
      jsr   clock_counter     ; 1
      jsr   clock_counter     ; 0
      jsr   clear_irq
      jsr   clock_counter     ; 1
      jsr   should_be_clear
      
      lda   #6;) IRQ should not be set when counter is cleared via $C001
      ldx   #2
      jsr   begin_counter_test
      jsr   clock_counter     ; 2
      jsr   clock_counter     ; 1
      jsr   clear_counter
      jsr   should_be_clear
      
      lda   #0
      jsr   clear_vram
      jsr   clear_sprites
      lda   #7;) Counter should be clocked 241 times in PPU frame
      ldx   #241
      jsr   begin_counter_test
      jsr   wait_vbl
      lda   #0
      sta   $2005
      sta   $2005
      lda   #$08              ; sprites use tiles at $1xxx
      sta   $2000
      lda   #$18              ; enable bg and sprites
      sta   $2001
      ldy   #25               ; 29800 delay
      lda   #237        
      jsr   delay_ya8
      lda   #$00              ; disable rendering
      sta   $2001
      jsr   should_be_clear
      jsr   clock_counter
      jsr   should_be_set
            
      jmp   tests_passed

