; Write to length counter reload should be ignored when made during length
; counter clocking and the length counter is not zero.

      .include "prefix_apu.a"

; Length reload register and channel mask to allow testing each channel
reload = $4003
mask   = $01

reset:
      jsr   setup_apu
      
      lda   #2;) Reload just before length clock should work normally
      sta   result
      jsr   sync_apu
      lda   #$38        ; length = 6
      sta   reload
      lda   #$40        ; begin mode 0
      sta   $4017
      ldy   #244        ; 14908 delay
      lda   #11         
      jsr   delay_ya7
      lda   #$18        ; reload counter with 2
      sta   reload      ; write at 14915
      lda   #mask
      jsr   count_length
      cmp   #1          ; should have reloaded then decremented
      bne   error
      
      lda   #3;) Reload just after length clock should work normally
      sta   result
      jsr   sync_apu
      lda   #$38        ; length = 6
      sta   reload
      lda   #$40        ; begin mode 0
      sta   $4017
      ldy   #244        ; 14910 delay
      lda   #11         
      jsr   delay_ya9
      lda   #$18        ; reload counter with 2
      sta   reload      ; write at 14915
      lda   #mask
      jsr   count_length
      cmp   #2          ; should have reloaded
      bne   error
      
      lda   #4;) Reload during length clock when ctr = 0 should work normally
      sta   result
      jsr   sync_apu
      lda   #0          ; clear length
      sta   $4015
      lda   #mask       ; enable
      sta   $4015
      lda   #$40        ; begin mode 0
      sta   $4017
      ldy   #244        ; 14909 delay
      lda   #11         
      jsr   delay_ya8
      lda   #$18        ; reload counter with 2
      sta   reload      ; write at 14915
      lda   #mask
      jsr   count_length
      cmp   #2          ; should have reloaded (and not decremented)
      bne   error
      
      lda   #5;) Reload during length clock when ctr > 0 should be ignored
      sta   result
      jsr   sync_apu
      lda   #$38        ; length = 6
      sta   reload
      lda   #$40        ; begin mode 0
      sta   $4017
      ldy   #244        ; 14909 delay
      lda   #11         
      jsr   delay_ya8
      lda   #$18        ; try to reload counter with 2
      sta   reload      ; write at 14915
      lda   #mask
      jsr   count_length
      cmp   #5          ; should have ignored reload
      bne   error
      
      lda   #1;) Passed tests
      sta   result
error:
      jmp   report_final_result
