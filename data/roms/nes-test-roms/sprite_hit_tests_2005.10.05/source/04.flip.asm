; Tests sprite 0 hit for single pixel sprite and background.

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT FLIPPING",0
      .code

test_flip:
      jsr   set_sprite_xy
      rts
      .code

reset:
      jsr   begin_sprite_hit_tests
      
      ; Single solid tile in middle of screen
      lda   #$21
      ldx   #$f0
      jsr   set_vaddr
      lda   #solid_tile
      sta   $2007
      
      ldx   #121
      ldy   #112
      jsr   set_sprite_xy
      
      lda   #$40
      sta   sprite_attr
      lda   #lower_left_tile
      sta   sprite_tile
      lda   #2;) Horizontal flipping doesn't work
      ldx   #$18
      jsr   sprite_should_hit
      
      lda   #$80
      sta   sprite_attr
      lda   #upper_right_tile
      sta   sprite_tile
      lda   #3;) Vertical flipping doesn't work
      ldx   #$18
      jsr   sprite_should_hit
      
      lda   #$c0
      sta   sprite_attr
      lda   #upper_left_tile
      sta   sprite_tile
      lda   #4;) Horizontal + Vertical flipping doesn't work
      ldx   #$18
      jsr   sprite_should_hit
      
      jmp   tests_passed
