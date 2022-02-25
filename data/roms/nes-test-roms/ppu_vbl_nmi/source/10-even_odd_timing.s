; Tests timing of skipped clock every other frame
; when BG is enabled.
;
; Output: 08 08 09 07 

.include "shell.inc"
.include "sync_vbl.s"

adjust = 2359

.align 256
test:   jsr disable_rendering
	jsr sync_vbl_delay
	delay 13

	; $2001=X for most of VBL, Y for part of frame, then 0
	stx $2001
	delay adjust-4-4
	sty $2001
	delay 20000
	lda #0
	sta $2001
	delay 29781-adjust-4-20000-6
	
	; Two frames with BG off
	delay 29781
	delay 29781-1
	
	; Third frame same as first. Since clock is skipped every
	; other frame, only one of these two will have the skipped
	; clock, so its effect on later frame timing won't be a
	; problem.
	stx $2001
	delay adjust-4
	sty $2001
	delay 20000
	lda #0
	sta $2001
	delay 29781-adjust-4-20000-6

	; Find number of PPU clocks until VBL
	delay 29781-3-22
	ldx #0
:       delay 29781-2-4-3
	inx
	bit PPUSTATUS
	bpl :-
	
	jsr print_x
	rts

main:   jsr console_hide
	
	set_test 2,"Clock is skipped too soon, relative to enabling BG"
	lda #4
	ldx #0
	ldy #8
	jsr test
	cpx #8
	jne test_failed
	
	set_test 3,"Clock is skipped too late, relative to enabling BG"
	lda #5
	ldx #0
	ldy #8
	jsr test
	cpx #8
	jne test_failed
	
	set_test 4,"Clock is skipped too soon, relative to disabling BG"
	lda #4
	ldx #8
	ldy #0
	jsr test
	cpx #9
	jne test_failed
	
	set_test 5,"Clock is skipped too late, relative to disabling BG"
	lda #5
	ldx #8
	ldy #0
	jsr test
	cpx #7
	jne test_failed
	
	jmp tests_passed
