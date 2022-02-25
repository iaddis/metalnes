; Tests clock skipped on every other PPU frame when BG rendering
; is enabled.
;
; Tries pattern of BG enabled/disabled during a sequence of
; 5 frames, then finds how many clocks were skipped. Prints
; number skipped clocks to help find problems.
;
; Correct output: 00 01 01 02

.include "shell.inc"
.include "sync_vbl.s"

test:   pha
	lda #0
	sta $2001
	jsr sync_vbl
	delay 29755
	pla
	
	; Enable/disable rendering for each frame
	; based on corresponding bit in A.
	ldx #5
:       pha
	and #$08
	sta $2001
	delay 29781-3-2-4-4-2-2-3
	pla
	lsr a
	dex
	bne :-
	
	; Find number of PPU clocks skipped
	lda #0
	sta $2001
	ldx #6
:       delay 29781-2-4-3
	dex
	bit PPUSTATUS
	bpl :-
	
	jsr print_x
	rts

.macro test pattern,time,code,text
	set_test code,text
	lda #8*pattern
	jsr test
	cpx #time
	jne test_failed
.endmacro

main:   test %00000,0,2,"Pattern ----- should not skip any clocks"
	test %00011,1,3,"Pattern ---BB should skip 1 clock"
	test %01001,1,4,"Pattern -B--B (even, odd) should skip 1 clock"
	test %11011,2,5,"Pattern BB-BB (two pairs) should skip 2 clocks"
	jmp tests_passed
