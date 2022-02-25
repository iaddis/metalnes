;
; File: joy_update1.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; 'joy_repeat1' subroutine
;
; Adapted from the source code to 'Concentration Room' by 'Damian Yerrick'
; found at:
; http://www.pineight.com/croom/
;

.include "joy.inc"



.segment "BSS"

joy_repeat:			.res 1
joy_timer:			.res 1



.segment "JOYLIB"

.proc joy_repeat1

	lda joy_held
	beq done
	lda joy_pressed
	beq cont
	sta joy_repeat
	lda #JOY_REP_DELAY
	sta joy_timer
	bne done

cont:
	dec joy_timer
	bne done
	lda #JOY_REP_SPEED
	sta joy_timer
	lda joy_repeat
	and joy_held
	ora joy_pressed
	sta joy_pressed

done:
	rts

.endproc

