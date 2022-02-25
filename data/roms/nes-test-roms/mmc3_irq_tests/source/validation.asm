
result = $f8

default_test_name:
      .db   0
      .default test_name = default_test_name
      
; Report error if branch with given condition would be taken
error_if_ne:
      bne   report_final_result_
      rts
error_if_eq:
      beq   report_final_result_
      rts
error_if_mi:
      bmi   report_final_result_
      rts
error_if_pl:
      bpl   report_final_result_
      rts
error_if_cc:
      bcc   report_final_result_
      rts
error_if_cs:
      bcs   report_final_result_
      rts
error_if_vc:
      bvc   report_final_result_
      rts
error_if_vs:
      bvs   report_final_result_
      rts

; Report passing result
tests_passed:
      lda   #1
      sta   result
; Report final result code and wait forever
report_final_result:
report_final_result_:
      sei               ; disable interrupts
      lda   #0
      sta   $2000
      jsr   init_runtime
      
      lda   test_name
      beq   no_name
      jsr   debug_char
      ldx   #1
:     lda   test_name,x
      beq   no_name
      jsr   debug_char_no_wait
      inx
      jmp   -
      
no_name:
      jsr   debug_newline
      
      lda   result
      cmp   #1
      beq   test_passed
      
      lda   #'F'
      jsr   debug_char
      lda   #'A'
      jsr   debug_char_no_wait
      lda   #'I'
      jsr   debug_char_no_wait
      lda   #'L'
      jsr   debug_char_no_wait
      lda   #'E'
      jsr   debug_char_no_wait
      lda   #'D'
      jsr   debug_char_no_wait
      lda   #32 ; ' '
      jsr   debug_char_no_wait
      lda   #'#'
      jsr   debug_char_no_wait
      
      lda   result
      cmp   #10
      bcc   +
      clc
      adc   #-10
      pha
      lda   #'1'
      jsr   debug_char_no_wait
      pla
:     clc
      adc   #'0'
      jsr   debug_char_no_wait
report_beeps:
      lda   result
      jsr   debug_beeps
      jmp   forever
      
test_passed:
      lda   #'P'
      jsr   debug_char
      lda   #'A'
      jsr   debug_char_no_wait
      lda   #'S'
      jsr   debug_char_no_wait
      lda   #'S'
      jsr   debug_char_no_wait
      lda   #'E'
      jsr   debug_char_no_wait
      lda   #'D'
      jsr   debug_char_no_wait
      jmp   report_beeps
      .code
      
      .default nmi = default_nmi
      .default irq = default_irq
      .code
default_irq:
      bit   $4015
default_nmi:
      rti
      
