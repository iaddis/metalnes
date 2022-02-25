; Tests alignment of sprite hit with background.
; Places a solid background tile in the middle of the screen and
; places the sprite on all four edges both overlapping and
; non-overlapping.

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT ALIGNMENT",0
      .code

reset:
      jsr   begin_sprite_hit_tests
      
      ; Single solid tile in middle of screen
      lda   #$21
      ldx   #$f0
      jsr   set_vaddr
      lda   #solid_tile
      sta   $2007
      
      lda   #0
      sta   sprite_attr
      lda   #solid_tile
      sta   sprite_tile
      
      ldx   #128
      ldy   #119
      jsr   set_sprite_xy
      lda   #2;) Basic sprite-background alignment is way off
      ldx   #$18
      jsr   sprite_should_hit
      
      ; Left
      
      ldx   #120
      ldy   #119
      jsr   set_sprite_xy
      lda   #3;) Sprite should miss left side of bg tile
      ldx   #$18
      jsr   sprite_should_miss
      
      ldx   #121
      ldy   #119
      jsr   set_sprite_xy
      lda   #4;) Sprite should hit left side of bg tile
      ldx   #$18
      jsr   sprite_should_hit
      
      ; Right
      
      ldx   #136
      ldy   #119
      jsr   set_sprite_xy
      lda   #5;) Sprite should miss right side of bg tile
      ldx   #$18
      jsr   sprite_should_miss
      
      ldx   #135
      ldy   #119
      jsr   set_sprite_xy
      lda   #6;) Sprite should hit right side of bg tile
      ldx   #$18
      jsr   sprite_should_hit
      
      ; Above
      
      ldx   #128
      ldy   #111
      jsr   set_sprite_xy
      lda   #7;) Sprite should miss top of bg tile
      ldx   #$18
      jsr   sprite_should_miss
      
      ldx   #128
      ldy   #112
      jsr   set_sprite_xy
      lda   #8;) Sprite should hit top of bg tile
      ldx   #$18
      jsr   sprite_should_hit
      
      ; Below
      
      ldx   #128
      ldy   #127
      jsr   set_sprite_xy
      lda   #9;) Sprite should miss bottom of bg tile
      ldx   #$18
      jsr   sprite_should_miss
      
      ldx   #128
      ldy   #126
      jsr   set_sprite_xy
      lda   #10;) Sprite should hit bottom of bg tile
      ldx   #$18
      jsr   sprite_should_hit
      
      jmp   tests_passed
