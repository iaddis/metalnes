; Tests basic sprite 0 hit double-height operation.

      .include "prefix_sprite_hit.a"

test_name:
      .db   "SPRITE HIT DOUBLE HEIGHT",0
      .code

reset:
      jsr   begin_sprite_hit_tests
      
      lda   #$20        ; double-height sprites
      sta   $2000
      
      ; Single solid tile in middle of screen
      lda   #$21
      ldx   #$f0
      jsr   set_vaddr
      lda   #solid_tile
      sta   $2007
      
      lda   #0
      sta   sprite_attr
      lda   #0          ; tiles 0 and 1
      sta   sprite_tile
      
      ldx   #128
      ldy   #119
      jsr   set_sprite_xy
      lda   #2;) Lower sprite tile should miss bottom of bg tile
      ldx   #$18
      jsr   sprite_should_miss
      
      ldx   #128
      ldy   #118
      jsr   set_sprite_xy
      lda   #3;) Lower sprite tile should hit bottom of bg tile
      ldx   #$18
      jsr   sprite_should_hit
      
      ldx   #128
      ldy   #103
      jsr   set_sprite_xy
      lda   #3;) Lower sprite tile should miss top of bg tile
      ldx   #$18
      jsr   sprite_should_miss
      
      ldx   #128
      ldy   #104
      jsr   set_sprite_xy
      lda   #4;) Lower sprite tile should hit top of bg tile
      ldx   #$18
      jsr   sprite_should_hit
      
      jmp   tests_passed
