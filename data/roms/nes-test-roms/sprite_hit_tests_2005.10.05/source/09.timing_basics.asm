; Tests sprite 0 hit timing to within 12 or so PPU clocks.
; Tests flag timing for upper-left corner, upper-right corner,
; lower-right corner, and time flag is cleared (at end of VBL).
; Depends on proper PPU frame length (less than 29781 CPU clocks).

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT TIMING",0
      .code

reset:
      jsr   begin_sprite_hit_tests
      
      lda   #solid_tile
      jsr   fill_nametable
      
      lda   #0
      sta   sprite_attr
      lda   #solid_tile
      sta   sprite_tile
      
      ldx   #0
      ldy   #0
      jsr   set_sprite_xy
      lda   #2;) Upper-left corner
      ldx   #$1e
      jsr   begin_sprite_hit_timing
      ldy   #3          ; 1943 delay
      lda   #127        
      jsr   delay_ya3
      ldx   $2002
      ldy   $2002
      jsr   check_sprite_hit_timing
      
      ldx   #254
      ldy   #0
      jsr   set_sprite_xy
      lda   #4;) Upper-right corner
      ldx   #$1e
      jsr   begin_sprite_hit_timing
      ldy   #5          ; 2027 delay
      lda   #79         
      jsr   delay_ya5
      ldx   $2002
      ldy   $2002
      jsr   check_sprite_hit_timing
      
      ldx   #0
      ldy   #238
      jsr   set_sprite_xy
      lda   #6;) Lower-left corner
      ldx   #$1e
      jsr   begin_sprite_hit_timing
      ldy   #111        ; 28995 delay
      lda   #51         
      jsr   delay_ya7
      ldx   $2002
      ldy   $2002
      jsr   check_sprite_hit_timing
      
      ldx   #0
      ldy   #0
      jsr   set_sprite_xy
      lda   #8;) Cleared at end of VBL
      ldx   #$1e
      jsr   begin_sprite_hit_timing
      ldy   #60         ; 29780 delay
      lda   #98         
      jsr   delay_ya3
      ldy   #3          ; 1715 delay
      lda   #112        
      jsr   delay_ya0
      lda   $2002
      ldy   $2002
      eor   #$40        ; invert readings
      tax
      tya
      eor   #$40
      tay
      jsr   check_sprite_hit_timing
      
      jmp   tests_passed
