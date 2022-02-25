; Tests basic length counter operation

      .include "prefix_apu.a"

; to do: test triangle channel's differing halt bit position

reset:
      jsr   setup_apu
      
      lda #2;) Problem with length counter load or $4015
      sta   result
      lda   #$18        ; length = 2
      sta   $4003
      jsr   should_be_playing
      
      lda #3;) Problem with length table, timing, or $4015
      sta   result
      lda   #250        ; delay 250 msec
      jsr   delay_msec
      jsr   should_be_silent
      
      lda #4;) Writing $80 to $4017 should clock length immediately
      sta   result
      lda   #$00        ; mode 0
      sta   $4017
      lda   #$18        ; length = 2
      sta   $4003
      lda   #$80        ; clock length twice
      sta   $4017
      sta   $4017
      jsr   should_be_silent
      
      lda #5;) Writing $00 to $4017 shouldn't clock length immediately
      sta   result
      lda   #$00        ; mode 0
      sta   $4017
      lda   #$18        ; length = 2
      sta   $4003
      lda   #$00        ; write mode twice
      sta   $4017
      sta   $4017
      jsr   should_be_playing
      
      lda #6;) Clearing enable bit in $4015 should clear length counter
      sta   result
      lda   #$18        ; length = 2
      sta   $4003
      lda   #$00
      sta   $4015
      lda   #$01
      sta   $4015
      jsr   should_be_silent
      
      lda #7;) When disabled via $4015, length shouldn't allow reloading
      sta   result
      lda   #$00
      sta   $4015
      lda   #$18        ; attempt to reload
      sta   $4003
      lda   #$01
      sta   $4015
      jsr   should_be_silent
      
      lda #8;) Halt bit should suspend length clocking
      sta   result
      lda   #$30        ; halt length
      sta   $4000
      lda   #$18        ; length = 2
      sta   $4003
      lda   #$80        ; attempt to clock length twice
      sta   $4017
      sta   $4017
      jsr   should_be_playing
      
      lda #1;) Passed tests
      sta   result
error:
      jmp   report_final_result

should_be_playing:
      lda   $4015
      and   #$01
      beq   error
      rts

should_be_silent:
      lda   $4015
      and   #$01
      bne   error
      rts
