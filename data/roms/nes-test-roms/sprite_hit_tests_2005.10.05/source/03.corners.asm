; Tests sprite 0 hit using a sprite with a single pixel set,
; for each of the four corners.

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT CORNERS",0
      .code

set_params:
      sta   sprite_tile
      eor   #$03
      pha
      jsr   set_sprite_xy
      lda   #$21
      ldx   #$f0
      jsr   set_vaddr
      pla
      sta   $2007
      rts
      .code

reset:
      jsr   begin_sprite_hit_tests
      
      lda   #0
      sta   sprite_attr
      
      lda   #lower_right_tile
      ldx   #121
      ldy   #112
      jsr   set_params
      lda   #2;) Lower-right pixel should hit
      ldx   #$18
      jsr   sprite_should_hit
      
      lda   #lower_left_tile
      ldx   #135
      ldy   #112
      jsr   set_params
      lda   #3;) Lower-left pixel should hit
      ldx   #$18
      jsr   sprite_should_hit
      
      lda   #upper_right_tile
      ldx   #121
      ldy   #126
      jsr   set_params
      lda   #4;) Upper-right pixel should hit
      ldx   #$18
      jsr   sprite_should_hit
      
      lda   #upper_left_tile
      ldx   #135
      ldy   #126
      jsr   set_params
      lda   #5;) Upper-left pixel should hit
      ldx   #$18
      jsr   sprite_should_hit
      
      jmp   tests_passed
