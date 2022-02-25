; Tests sprite 0 hit timing for which pixel it first reports hit on.
; Each test hits at the same location on screen, though different
; relative to the position of the sprite.

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT ORDER",0
      .code

test_hit_time:
      jsr   set_sprite_xy
      ldx   #$18
      jsr   begin_sprite_hit_timing
      ldy   #88         ; 15511 delay
      lda   #34         
      jsr   delay_ya6
      ldx   $2002       ; timing really tight here
      ldy   $2002
      jsr   check_sprite_hit_timing
      rts
      .code

reset:
      jsr   begin_sprite_hit_tests
      
      ; Solid tile in middle of screen
      lda   #blank_tile
      jsr   fill_nametable
      lda   #$21
      ldx   #$f0
      jsr   set_vaddr
      lda   #solid_tile
      sta   $2007

      lda   #0
      sta   sprite_attr
      lda   #solid_tile
      sta   sprite_tile
      
      lda   #2;) Upper-left corner
      ldx   #128
      ldy   #119
      jsr   test_hit_time
      
      lda   #4;) Upper-right corner
      ldx   #123
      ldy   #119
      jsr   test_hit_time
      
      lda   #6;) Lower-left corner
      ldx   #128
      ldy   #114
      jsr   test_hit_time
      
      lda   #8;) Lower-right corner
      ldx   #123
      ldy   #114
      jsr   test_hit_time
      
      jmp   tests_passed
