; Tests basic sprite 0 hit behavior (nothing timing related).

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT BASICS",0
      .code

reset:
      jsr   begin_sprite_hit_tests
      
      lda   #solid_tile
      jsr   fill_nametable
      
      ; Put sprite in middle of screen
      lda   #0
      sta   sprite_attr
      ldx   #128
      ldy   #120
      jsr   set_sprite_xy
      
      lda   #solid_tile
      sta   sprite_tile
      lda   #2;) Sprite hit isn't working at all
      ldx   #$18
      jsr   sprite_should_hit
      
      lda   #$20
      sta   sprite_attr
      lda   #3;) Should hit even when completely behind background
      ldx   #$18
      jsr   sprite_should_hit
      
      lda   #4;) Should miss when background rendering is off
      ldx   #$10
      jsr   sprite_should_miss
      
      lda   #5;) Should miss when sprite rendering is off
      ldx   #$08
      jsr   sprite_should_miss
      
      lda   #6;) Should miss when all rendering is off
      ldx   #$00
      jsr   sprite_should_miss
      
      lda   #blank_tile
      sta   sprite_tile
      
      lda   #7;) All-transparent sprite should miss
      ldx   #$18
      jsr   sprite_should_miss
      
      lda   #$ff
      sta   sprite_attr
      lda   #8;) Only low two palette index bits are relevant
      ldx   #$18
      jsr   sprite_should_miss
      
      lda   #1
      jsr   fill_nametable
      lda   #2
      sta   sprite_tile
      lda   #0
      sta   sprite_attr
      
      lda   #9;) Any non-zero palette index should hit with any other
      ldx   #$18
      jsr   sprite_should_hit
      
      lda   #0
      jsr   fill_nametable
      
      lda   #10;) Should miss when background is all transparent
      ldx   #$18
      jsr   sprite_should_miss
      
      lda   #120
      sta   sprites + 4
      lda   #3
      sta   sprites + 5
      lda   #0
      sta   sprites + 6
      lda   #128
      sta   sprites + 7
      lda   #11;) Should always miss other sprites
      ldx   #$18
      jsr   sprite_should_miss
      
      jmp   tests_passed

