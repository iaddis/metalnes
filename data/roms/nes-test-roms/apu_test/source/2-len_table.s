; Verifies all length table entries

.include "apu_shell.inc"

main:   test_main_chans test
	jmp tests_passed

test:   loop_n_times test_entry,32
	rts

test_entry:
	tay
	setb SNDMODE,0
	
	; Load
	tya
	asl a
	asl a
	asl a
	ldx chan_off
	sta $4003,x
	
	; Verify
	lda table,y
	tax
	dex
:       setb SNDMODE,$C0        ; clock length counter
	dex
	bne :-
	jsr len_should_be_1
	rts

table:  .byte 10, 254, 20,  2, 40,  4, 80,  6
	.byte 160,  8, 60, 10, 14, 12, 26, 14
	.byte 12,  16, 24, 18, 48, 20, 96, 22
	.byte 192, 24, 72, 26, 16, 28, 32, 30
