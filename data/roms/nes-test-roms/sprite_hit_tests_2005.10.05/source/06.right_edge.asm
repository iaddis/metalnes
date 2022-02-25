; Tests sprite 0 hit with regard to column 255 (ignored) and off
; right edge of screen.

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT RIGHT EDGE",0
      .code

reset:
      jsr   begin_sprite_hit_tests
      lda   #solid_tile
      jsr   fill_nametable
      lda   #0
      sta   sprite_attr
      lda   #120
      sta   sprite_y
      
      ; Basic
      
      lda   #solid_tile
      sta   sprite_tile
      lda   #255
      sta   sprite_x
      lda   #2;) Should always miss when X = 255
      ldx   #$1e
      jsr   sprite_should_miss
      
      lda   #254
      sta   sprite_x
      lda   #3;) Should hit; sprite has pixels < 255
      ldx   #$1e
      jsr   sprite_should_hit
      
      ; Detailed
      
      lda   #upper_right_tile
      sta   sprite_tile
      lda   #248
      sta   sprite_x
      lda   #4;) Should miss; sprite pixel is at 255
      ldx   #$1e
      jsr   sprite_should_miss
      
      lda   #247
      sta   sprite_x
      lda   #5;) Should hit; sprite pixel is at 254
      ldx   #$1e
      jsr   sprite_should_hit
      
      lda   #upper_left_tile
      sta   sprite_tile
      lda   #254
      sta   sprite_x
      lda   #6;) Should also hit; sprite pixel is at 254
      ldx   #$1e
      jsr   sprite_should_hit
      
      jmp   tests_passed

