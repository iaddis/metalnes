; Changes to length counter halt occur after clocking length, not before.

      .include "prefix_apu.a"

; Selection of which channel to use
chan = $4000
mask = $01
halt = $30
unhalt = $10

begin_test:
      sta   result
      jsr   sync_apu
      lda   #$18        ; length = 2
      sta   chan + 3
      lda   #unhalt
      sta   chan
      lda   #$c0        ; begin mode 1 and clock length
      sta   $4017
      rts

reset:
      jsr   setup_apu
      lda   #mask
      sta   $4015
      
      lda   #2;) Length shouldn't be clocked when halted at 14914
      jsr   begin_test
      lda   #unhalt
      sta   chan
      ldy   #43         ; 14896 delay
      lda   #68         
      jsr   delay_ya1
      lda   #halt
      sta   chan        ; at 14914
      jsr   should_be_playing
      
      lda   #3;) Length should be clocked when halted at 14915
      jsr   begin_test
      lda   #unhalt
      sta   chan
      ldy   #43         ; 14897 delay
      lda   #68         
      jsr   delay_ya2
      lda   #halt
      sta   chan        ; at 14915
      jsr   should_be_silent
      
      lda   #4;) Length should be clocked when unhalted at 14914
      jsr   begin_test
      lda   #halt
      sta   chan
      ldy   #43         ; 14896 delay
      lda   #68         
      jsr   delay_ya1
      lda   #unhalt
      sta   chan        ; at 14914
      jsr   should_be_silent
      
      lda   #5;) Length shouldn't be clocked when unhalted at 14915
      jsr   begin_test
      lda   #halt
      sta   chan
      ldy   #43         ; 14897 delay
      lda   #68         
      jsr   delay_ya2
      lda   #unhalt
      sta   chan        ; at 14915
      jsr   should_be_playing
      
      lda   #1;) Passed tests
      sta   result
error:
      jmp   report_final_result

should_be_playing:
      lda   $4015
      and   #mask
      beq   error
      rts

should_be_silent:
      lda   $4015
      and   #mask
      bne   error
      rts
