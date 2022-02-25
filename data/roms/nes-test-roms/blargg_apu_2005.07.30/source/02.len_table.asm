; Tests all length table entries.
;
; 1) Passed
; 2) Failed. Prints four bytes $II $ee $cc $02 that indicate the length
; load value written (ll), the value that the emulator uses ($ee), and the
; correct value ($cc).

      .include "prefix_apu.a"

; Zero-page
entry = 10

reset:
      jsr   setup_apu
      
      lda   #31
      sta   entry
loop: lda   #$00        ; sync apu
      sta   $4017
      lda   entry
      asl   a
      asl   a
      asl   a
      sta   $4003       ; load length
      lda   #$01        ; check resulting length
      jsr   count_length
      ldx   entry
      cmp   table,x
      bne   error
      dec   entry
      bpl   loop
      
      lda   #1;) Passed
report:
      sta   result
      jmp   report_final_result

error:
      pha
      lda   entry
      asl   a
      asl   a
      asl   a
      jsr   debug_byte  ; entry
      pla
      jsr   debug_byte  ; value detected
      ldx   entry
      lda   table,x
      jsr   debug_byte  ; correct value
      lda   #2
      jmp   report

table:
      .byte 10, 254, 20,  2, 40,  4, 80,  6
      .byte 160,  8, 60, 10, 14, 12, 26, 14
      .byte 12,  16, 24, 18, 48, 20, 96, 22
      .byte 192, 24, 72, 26, 16, 28, 32, 30
