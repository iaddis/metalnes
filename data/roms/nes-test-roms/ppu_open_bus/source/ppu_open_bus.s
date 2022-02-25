; Tests PPU "decay value", the open-bus value read back from
; write-only registers and unimplemented bits of $2002.
; Takes about five seconds.

.include "shell.inc"

main:
      set_test 2,"Write to any PPU register should set decay value"
      lda #$55
      sta PPUSTATUS
      cmp PPUCTRL
      jne test_failed
      lda #$AA
      sta PPUSTATUS
      cmp PPUCTRL
      jne test_failed
      lda #$12
      sta SPRDATA
      cmp PPUCTRL
      jne test_failed
      lda #$34
      sta PPUADDR
      cmp PPUCTRL
      jne test_failed
      
      set_test 3,"Decay value should become zero by one second"
      setb $2002,$FF
      delay_msec 1000
      lda PPUCTRL
      jne test_failed
      
      set_test 4,"Read from $2007 from VRAM should set decay value to what's read"
      set_ppuaddr $2000
      setb PPUDATA,$55
      setb PPUDATA,$AA
      set_ppuaddr $2000
      bit PPUDATA
      lda PPUDATA
      cmp PPUCTRL
      jne test_failed

      set_test 5,"Reading write-only register should not refresh decay value"
      setb $2002,$FF
      ldx #100
:     delay_msec 10
      lda PPUCTRL
      dex
      bne :-
      cmp #0
      jne test_failed
      
      set_test 6,"Low 5 bits of $2002 should be from decay value"
      setb PPUSTATUS,$FF
      lda PPUSTATUS
      and #$1F
      cmp #$1F
      jne test_failed
      setb PPUSTATUS,$00
      lda PPUSTATUS
      and #$1F
      jne test_failed
      
      set_test 7,"Reading $2002 shouldn't refresh low 5 bits of decay value"
      setb PPUSTATUS,$FF
      ldx #100
:     delay_msec 10
      lda PPUSTATUS
      dex
      bne :-
      and #$1F
      jne test_failed

      set_test 8,"High 2 bits from $2007 from palette should be from decay value"
      set_ppuaddr $3F00
      setb PPUSTATUS,$00
      lda PPUDATA
      and #$C0
      jne test_failed
      set_ppuaddr $3F00
      setb PPUSTATUS,$FF
      lda PPUDATA
      and #$C0
      cmp #$C0
      jne test_failed
      
      set_test 9,"Reading palette from $2007 shouldn't refresh high 2 bits of decay value"
      setb PPUSTATUS,$FF
      ldx #100
:     delay_msec 10
      set_ppuaddr $3F00
      lda PPUDATA
      dex
      bne :-
      and #$C0
      jne test_failed
      
      set_test 10,"Bits 2-4 of sprite attributes should always be clear when read"
      setb SPRADDR,2
      setb PPUSTATUS,$FF
      lda SPRDATA
      and #$1C
      jne test_failed
      
      set_test 11,"Reading third byte of a sprite from $2004 should refresh all bits of decay value"
      setb SPRADDR,2
      setb PPUSTATUS,$FF
      lda SPRDATA
      lda PPUCTRL
      and #$1C
      jne test_failed
      
      jmp tests_passed
