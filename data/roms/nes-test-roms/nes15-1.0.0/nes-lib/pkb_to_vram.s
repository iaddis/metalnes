;
; File: pkb_to_vram.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; 'pkb_to_vram' subroutine
;

.include "ppu.inc"

.include "pkb.inc"



.segment "PKBLIB"

.proc pkb_to_vram

	ldy #0
	lda (pkb_src), y
	bpl literal
	cmp #-128
	beq done

	; Write out repeated data

	eor #$FF
	clc
	adc #2
	tax
	iny
	lda (pkb_src), y
	iny

run_loop:
	sta PPUDATA
	dex
	bne run_loop
	beq cont

	; Write out literal data

literal:
	clc
	adc #1
	tax
	iny

literal_loop:
	lda (pkb_src), y
	sta PPUDATA
	iny
	dex
	bne literal_loop

	; Advance the source address to the next header byte

cont:
	tya
	clc
	adc pkb_src
	sta pkb_src
	lda #0
	adc pkb_src + 1
	sta pkb_src + 1
	bne pkb_to_vram

done:
	rts

.endproc

