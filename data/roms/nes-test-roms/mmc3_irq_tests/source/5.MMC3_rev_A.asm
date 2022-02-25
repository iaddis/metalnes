; Tests MMC3 revision A differences

      .include "prefix_mmc3_validation.a"
      
test_name:
      .db   "MMC3 IRQ COUNTER REVISION A",0

reset:
      jsr   begin_mmc3_tests
      
      lda   #2;) IRQ should be set when reloading to 0 after clear
      ldx   #0
      jsr   begin_counter_test
      jsr   clock_counter     ; 0
      jsr   should_be_set
      
      lda   #3;) IRQ shouldn't occur when reloading after counter normally reaches 0
      ldx   #1
      jsr   begin_counter_test
      jsr   clock_counter     ; 1
      lda   #0
      jsr   set_reload
      jsr   clock_counter     ; 0
      jsr   clear_irq
      jsr   clock_counter     ; 0
      jsr   should_be_clear
      ldx   #255
            
      jmp   tests_passed

