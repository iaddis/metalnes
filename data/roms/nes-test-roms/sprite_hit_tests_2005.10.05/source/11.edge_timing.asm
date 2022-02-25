; Tests sprite 0 hit timing for which pixel it first reports hit on
; when some pixels are under clip, or at or beyond right edge.

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT EDGE TIMING",0
      .code

reset:
      jsr   begin_sprite_hit_tests
      
      lda   #solid_tile
      jsr   fill_nametable

      lda   #120
      sta   sprite_y
      lda   #two_corners_tile
      sta   sprite_tile
      lda   #0
      sta   sprite_attr
      
      lda   #7
      sta   sprite_x
      lda   #2;) Hit time shouldn't be based on pixels under left clip
      ldx   #$18
      jsr   begin_sprite_hit_timing
      ldy   #27         ; 16380 delay
      lda   #120        
      jsr   delay_ya1
      lda   $2002
      and   #$40
      jsr   error_if_ne
      
      lda   #$80
      sta   sprite_attr
      
      lda   #248
      sta   sprite_x
      lda   #3;) Hit time shouldn't be based on pixels at X=255
      ldx   #$18
      jsr   begin_sprite_hit_timing
      ldy   #41         ; 16458 delay
      lda   #79         
      jsr   delay_ya0
      lda   $2002
      and   #$40
      jsr   error_if_ne
      
      lda   #249
      sta   sprite_x
      lda   #4;) Hit time shouldn't be based on pixels off right edge
      ldx   #$18
      jsr   begin_sprite_hit_timing
      ldy   #41         ; 16458 delay
      lda   #79         
      jsr   delay_ya0
      lda   $2002
      and   #$40
      jsr   error_if_ne
      
      jmp   tests_passed
