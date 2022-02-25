; Frame interrupt flag is set three times in a row 29831 clocks after
; writing $4017 with $00.

      .include "prefix_apu.a"

reset:
      jsr   setup_apu
      
      lda   #2;) Flag first set too soon
      jsr   begin_test
      lda   #$00        ; begin mode 0
      sta   $4017
      ldy   #48         ; 29826 delay
      lda   #123        
      jsr   delay_ya1
      lda   $4015       ; at 29830 flag should be clear
      and   #$40
      bne   error
      
      lda   #3;) Flag first set too late
      jsr   begin_test
      lda   #$00        ; begin mode 0
      sta   $4017
      ldy   #48         ; 29827 delay
      lda   #123        
      jsr   delay_ya2
      lda   $4015       ; at 29831 flag should be set
      and   #$40
      beq   error
      
      lda   #4;) Flag last set too soon 
      jsr   begin_test
      lda   #$00        ; begin mode 0
      sta   $4017
      ldy   #48         ; 29828 delay
      lda   #123        
      jsr   delay_ya3
      lda   $4015       ; at 29832 read and clear flag
      lda   $4015       ; flag should be set again
      and   #$40
      beq   error
      
      lda   #5;) Flag last set too late 
      jsr   begin_test
      lda   #$00        ; begin mode 0
      sta   $4017
      ldy   #48         ; 29829 delay
      lda   #123        
      jsr   delay_ya4
      lda   $4015       ; at 29833 read and clear flag
      lda   $4015       ; flag should't be set again
      and   #$40
      bne   error
      
      lda   #1;) Success
      sta   result
error:
      jmp   report_final_result
      
begin_test:
      sta   result
      jsr   sync_apu
      lda   #$40        ; clear flag
      sta   $4017
      rts
