; Tests MMC3 revision B differences

      .include "prefix_mmc3_validation.a"
      
test_name:
      .db   "MMC3 IRQ COUNTER REVISION B",0

reset:
      jsr   begin_mmc3_tests
      
      lda   #2;) Should reload and set IRQ every clock when reload is 0
      ldx   #0
      jsr   begin_counter_test
      jsr   clock_counter     ; 0
      jsr   should_be_set
      jsr   clock_counter     ; 0
      jsr   should_be_set
      jsr   clock_counter     ; 0
      jsr   should_be_set
      
      lda   #3;) IRQ should be set when counter is 0 after reloading
      ldx   #1
      jsr   begin_counter_test
      jsr   clock_counter     ; 1
      jsr   clock_counter     ; 0
      jsr   clear_irq
      lda   #0
      jsr   set_reload
      jsr   clock_counter     ; 0
      jsr   should_be_set
      
            
      jmp   tests_passed

