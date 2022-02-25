;
; File: joy.inc
; Namespace: joy_ / JOY_
; Code Segment: JOYLIB
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Joypad reading and handling library
;

.ifndef JOY_INC
JOY_INC = 1

; Joypad I/O locations

JOY1 = $4016
JOY2 = $4017

; Number of frames before the joypad button repeat starts

.globalzp JOY_REP_DELAY

; Interval of frames between joypad button repeats

.globalzp JOY_REP_SPEED



; State of the last joypad read

.global joy_state

; State of which buttons are being held down

.global joy_held

; State of which buttons where just pressed

.global joy_pressed

; State of which buttons where just released

.global joy_released

; State fed back into 'joy_pressed' on button repeats

.global joy_repeat

; Timer used for joypad button repeat

.global joy_timer



;
; Resets the held, pressed, and released states for JOY1.
;
; Out:
;	a = 0
;
; Preserved: x, y
; Destroyed: a
;
.macro joy_init1

	lda #$00
	sta joy_held
	sta joy_pressed
	sta joy_released

.endmacro

;
; Strobes and reads the state of JOY1. Note that the method used is unreliable
; if the DMC is playing.
;
; Out:
;	a, joy_state = The 8-bit state of the joypad read. The button state
;	from bit 7 to bit 0 is:
;
;		Right, Left, Down, Up, Start, Select, B, A
;
; Preserved: x, y
;
.global joy_read1

;
; Reads the state of JOY1 using 'joy_read1' and updates the states of the
; buttons held, pressed, and released.
;
; Out:
;	joy_held = The buttons currently being held down
;	joy_pressed = The buttons just pressed
;	joy_release = The buttons just released
;
;	The state of each button is stored in the same order as 'joy_state'.
;
; Preserved: x
; Destroyed: a, y
;
.global joy_update1

;
; Updates the button repeat timer and the state of the buttons just pressed for
; JOY1. This should be called once per frame after calling 'joy_update1'.
;
; Out:
;	joy_pressed = The buttons just pressed and repeated
;
; Preserved: x, y
; Destroyed: a
;
.global joy_repeat1

.endif

