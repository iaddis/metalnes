;
; File: oam_clear.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; 'oam_clear' subroutine
;

.include "oam.inc"



.segment "OAMLIB"

.proc oam_clear

	ldx #0
	lda #248

loop:
	sta oam_buff + OAM_Y, x
	inx
	inx
	inx
	inx
	bne loop
	rts

.endproc

