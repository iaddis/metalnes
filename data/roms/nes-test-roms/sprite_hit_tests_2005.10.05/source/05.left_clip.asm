; Tests sprite 0 hit with regard to clipping of left 8 pixels of screen.

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT LEFT CLIPPING",0
      .code

reset:
      jsr   begin_sprite_hit_tests
      
      lda   #solid_tile
      jsr   fill_nametable
      lda   #0
      sta   sprite_attr
      ldy   #120
      sta   sprite_y
      
      ; Basic
      
      lda   #solid_tile
      sta   sprite_tile
      
      lda   #0
      sta   sprite_x
      lda   #2;) Should miss when entirely in left-edge clipping
      ldx   #$18
      jsr   sprite_should_miss
      
      lda   #3;) Left-edge clipping occurs when $2001 is not $1e
      ldx   #$1a
      jsr   sprite_should_miss
      lda   #3
      ldx   #$1c
      jsr   sprite_should_miss
      
      lda   #4;) Left-edge clipping is off when $2001 = $1e
      ldx   #$1e
      jsr   sprite_should_hit
      
      lda   #1
      sta   sprite_x
      lda   #5;) Left-edge clipping blocks all hits only when X = 0
      ldx   #$18
      jsr   sprite_should_hit
      
      ; Detailed
      
      lda   #upper_left_tile
      sta   sprite_tile
      lda   #7
      sta   sprite_x
      lda   #6;) Should miss; sprite pixel covered by left-edge clip
      ldx   #$18
      jsr   sprite_should_miss
      
      lda   #8
      sta   sprite_x
      lda   #7;) Should hit; sprite pixel outside left-edge clip
      ldx   #$18
      jsr   sprite_should_hit
      
      lda   #upper_right_tile
      sta   sprite_tile
      lda   #1
      sta   sprite_x
      lda   #8;) Should hit; sprite pixel outside left-edge clip
      ldx   #$18
      jsr   sprite_should_hit

      jmp   tests_passed

