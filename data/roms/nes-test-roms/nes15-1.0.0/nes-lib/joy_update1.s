;
; File: joy_update1.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; 'joy_update1' subroutine
;
; Adapted from the source code by 'blargg' posted in the thread 'Button
; Handling Headaches' at:
; http://nesdev.parodius.com/bbs/
;

.include "joy.inc"



.segment "BSS"

joy_held:			.res 1
joy_pressed:			.res 1
joy_released:			.res 1



.segment "JOYLIB"

.proc joy_update1

	jsr joy_read1
	tay
	ora joy_held
	eor joy_held
	sta joy_pressed
	tya
	eor joy_held
	and joy_held
	sta joy_released
	sty joy_held
	rts

.endproc

