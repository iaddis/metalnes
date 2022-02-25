;
; File: joy_read1.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; 'joy_read1' subroutine
;

.include "joy.inc"



.segment "BSS"

joy_state:			.res 1



.segment "JOYLIB"

.proc joy_read1

	lda #$01
	sta JOY1
	lsr
	sta JOY1
	ror
	sta joy_state

loop:
	lda JOY1
	and #$03
	cmp #$01
	ror joy_state
	bcc loop
	lda joy_state
	rts

.endproc

