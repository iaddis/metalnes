;
; File: lfsr32.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; 'lfsr32_next' subroutine
;

.include "lfsr32.inc"



.segment "ZEROPAGE"

lfsr32:				.res 4



.segment "LFSRLIB"

.proc lfsr32_next

	lsr lfsr32 + 3
	ror lfsr32 + 2
	ror lfsr32 + 1
	ror lfsr32
	bcc zero
	lda lfsr32 + 3		; Taps 32, 31, and 29
	eor #$D0
	sta lfsr32 + 3
	lda lfsr32
	eor #$01		; Tap 1
	sta lfsr32

zero:
	dey
	bne lfsr32_next
	rts

.endproc

