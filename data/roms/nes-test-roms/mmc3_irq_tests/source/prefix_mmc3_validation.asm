      .include "prefix_mmc3.a"
      
begin_counter_test:
      sta   result
      jsr   clock_counter     ; avoid pathological reload behavior
      jsr   clock_counter
      txa
      jsr   set_reload
      jsr   clear_counter
      jsr   clear_irq
      rts
      .code
      
should_be_clear:
      jsr   get_pending
      cpx   #0
      jsr   error_if_ne
      jsr   clear_irq
      rts

should_be_set:
      jsr   get_pending
      cpx   #1
      jsr   error_if_ne
      jsr   clear_irq
      rts

