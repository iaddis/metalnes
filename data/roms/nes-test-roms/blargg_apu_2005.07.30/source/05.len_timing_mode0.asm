; Tests length counter timing in mode 0.

      .include "prefix_apu.a"

reset:
      jsr   setup_apu
      
      lda   #2;) First length is clocked too soon
      sta   result
      jsr   sync_apu
      lda   #$18        ; load length with 2
      sta   $4003
      lda   #$c0        ; clock length
      sta   $4017
      lda   #$00        ; begin mode 0
      sta   $4017
      ldy   #53         ; 14911 delay
      lda   #55         
      jsr   delay_ya1
      lda   $4015       ; read at 14915
      jsr   should_be_playing
      
      lda   #3;) First length is clocked too late
      sta   result
      jsr   sync_apu
      lda   #$18        ; load length with 2
      sta   $4003
      lda   #$c0        ; clock length
      sta   $4017
      lda   #$00        ; begin mode 0
      sta   $4017
      ldy   #53         ; 14912 delay
      lda   #55         
      jsr   delay_ya2
      lda   $4015       ; read at 14916
      jsr   should_be_silent
      
      lda   #4;) Second length is clocked too soon
      sta   result
      jsr   sync_apu
      lda   #$18        ; load length with 2
      sta   $4003
      lda   #$00        ; begin mode 0
      sta   $4017
      ldy   #110        ; 29827 delay
      lda   #53         
      jsr   delay_ya0
      lda   $4015       ; read at 29831
      jsr   should_be_playing
      
      lda   #5;) Second length is clocked too late
      sta   result
      jsr   sync_apu
      lda   #$18        ; load length with 2
      sta   $4003
      lda   #$00        ; begin mode 0
      sta   $4017
      ldy   #110        ; 29828 delay
      lda   #53         
      jsr   delay_ya1
      lda   $4015       ; read at 29832
      jsr   should_be_silent
      
      lda   #6;) Third length is clocked too soon
      sta   result
      jsr   sync_apu
      lda   #$28        ; load length with 4
      sta   $4003
      lda   #$c0        ; clock length
      sta   $4017
      lda   #$00        ; begin mode 0
      sta   $4017
      ldy   #58         ; 44741 delay
      lda   #153        
      jsr   delay_ya6
      lda   $4015       ; read at 44745
      jsr   should_be_playing
      
      lda   #7;) Third length is clocked too late
      sta   result
      jsr   sync_apu
      lda   #$28        ; load length with 4
      sta   $4003
      lda   #$c0        ; clock length
      sta   $4017
      lda   #$00        ; begin mode 0
      sta   $4017
      ldy   #58         ; 44741 delay
      lda   #153        
      jsr   delay_ya7
      lda   $4015       ; read at 44746
      jsr   should_be_silent
      
      lda #1;) Passed tests
      sta   result
error:
      jmp   report_final_result

should_be_playing:
      and   #$01
      beq   error
      rts

should_be_silent:
      and   #$01
      bne   error
      rts
