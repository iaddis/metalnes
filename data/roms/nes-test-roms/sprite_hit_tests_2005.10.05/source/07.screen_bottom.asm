; Tests sprite 0 hit with regard to bottom of screen.

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT SCREEN BOTTOM",0
      .code

reset:
      jsr   begin_sprite_hit_tests
      lda   #solid_tile
      jsr   fill_nametable
      lda   #0
      sta   sprite_attr
      lda   #128
      sta   sprite_x
      
      ; Basic
      
      lda   #solid_tile
      sta   sprite_tile
      lda   #239
      sta   sprite_y
      lda   #2;) Should always miss when Y >= 239
      ldx   #$1e
      jsr   sprite_should_miss
      
      lda   #238
      sta   sprite_y
      lda   #3;) Can hit when Y < 239
      ldx   #$1e
      jsr   sprite_should_hit
      
      lda   #255
      sta   sprite_y
      lda   #4;) Should always miss when Y = 255
      ldx   #$1e
      jsr   sprite_should_miss
      
      ; Detailed
      
      lda   #lower_right_tile
      sta   sprite_tile
      lda   #231
      sta   sprite_y
      lda   #5;) Should hit; sprite pixel is at 238
      ldx   #$1e
      jsr   sprite_should_hit
      
      lda   #232
      sta   sprite_y
      lda   #6;) Should miss; sprite pixel is at 239
      ldx   #$1e
      jsr   sprite_should_miss
      
      lda   #upper_left_tile
      sta   sprite_tile
      lda   #238
      sta   sprite_y
      lda   #7;) Should hit; sprite pixel is at 238
      ldx   #$1e
      jsr   sprite_should_hit
      
      jmp   tests_passed

