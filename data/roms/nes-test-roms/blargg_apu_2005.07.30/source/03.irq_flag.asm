; Tests basic operation of frame irq flag.

      .include "prefix_apu.a"

reset:
      jsr   setup_apu
      
      lda   #2;) Flag shouldn't be set in $4017 mode $40
      sta   result
      lda   #$40
      sta   $4017
      lda   #20
      jsr   delay_msec
      jsr   should_be_clear
      
      lda   #3;) Flag shouldn't be set in $4017 mode $80
      sta   result
      lda   #$80
      sta   $4017
      lda   #20
      jsr   delay_msec
      jsr   should_be_clear
      
      lda   #4;) Flag should be set in $4017 mode $00
      sta   result
      lda   #$00
      sta   $4017
      lda   #20
      jsr   delay_msec
      jsr   should_be_set
      
      lda   #5;) Reading flag clears it
      sta   result
      lda   #$00
      sta   $4017
      lda   #20
      jsr   delay_msec
      lda   $4015
      jsr   should_be_clear
      
      lda   #6;) Writing $00 or $80 to $4017 doesn't affect flag
      sta   result
      lda   #$00
      sta   $4017
      lda   #20
      jsr   delay_msec
      lda   #$00
      sta   $4017
      lda   #$80
      sta   $4017
      jsr   should_be_set
      
      lda   #7;) Writing $40 or $c0 to $4017 clears flag
      sta   result
      lda   #$00
      sta   $4017
      lda   #20
      jsr   delay_msec
      lda   #$40
      sta   $4017
      lda   #$00
      sta   $4017
      jsr   should_be_clear
      
      lda   #1;) Tests passed
      sta   result
error:
      jmp   report_final_result

; Report error if flag isn't clear
should_be_clear:
      lda   $4015
      and   #$40
      bne   error
      rts

; Report error if flag isn't set
should_be_set:
      lda   $4015
      and   #$40
      beq   error
      rts
