; Tests MMC3 IRQ counter operation. Requires support for clocking via
; manual toggling of VRAM address.

      .include "prefix_mmc3_validation.a"
      
test_name:
      .db   "MMC3 IRQ COUNTER",0

reset:
      jsr   begin_mmc3_tests
      
      lda   #2;) Counter/IRQ/A12 clocking isn't working at all
      ldx   #10
      jsr   begin_counter_test
      jsr   clock_counter
      jsr   clock_counter
      jsr   should_be_clear
      
      lda   #3;) Should decrement when A12 is toggled via $2006
      ldx   #2
      jsr   begin_counter_test
      ldx   #9
      jsr   clock_counter_x
      jsr   should_be_set
      
      lda   #4;) Writing to $C000 shouldn't cause reload
      ldx   #2
      jsr   begin_counter_test
      jsr   clock_counter     ; reloads with 2
      lda   #100
      jsr   set_reload
      ldx   #8
      jsr   clock_counter_x
      jsr   should_be_set
      
      lda   #5;) Writing to $C001 shouldn't cause immediate reload
      ldx   #1
      jsr   begin_counter_test
      lda   #1
      jsr   set_reload
      jsr   clear_counter
      lda   #4
      jsr   set_reload
      jsr   clock_counter     ; 4
      jsr   clock_counter     ; 3
      jsr   should_be_clear
      
      lda   #6;) Should reload (no decrement) on first clock after clear
      ldx   #2
      jsr   begin_counter_test
      jsr   clock_counter     ; 2
      jsr   clock_counter     ; 1
      jsr   should_be_clear
      
      lda   #7;) IRQ should be set when counter is decremented to 0
      ldx   #1
      jsr   begin_counter_test
      jsr   clock_counter     ; 1
      jsr   clock_counter     ; 0
      jsr   should_be_set
      
      lda   #8;) IRQ should never be set when disabled
      ldx   #1
      jsr   begin_counter_test
      jsr   disable_irq
      ldx   #10
      jsr   clock_counter_x
      jsr   should_be_clear
      
      lda   #9;) Should reload when clocked when counter is 0
      ldx   #1
      jsr   begin_counter_test
      jsr   clock_counter     ; 1
      lda   #10
      jsr   set_reload
      jsr   clock_counter     ; 0
      lda   #2
      jsr   set_reload
      jsr   clock_counter     ; 2
      jsr   clock_counter     ; 1
      jsr   clear_irq
      jsr   clock_counter     ; 0
      jsr   should_be_set
      
      jmp   tests_passed
