; Utilities for writing test ROMs

zp_res  test_code,1 ; code of current test
zp_res  test_name,2 ; address of name of current test, or 0 of none


; Reports that all tests passed
tests_passed:
.if !BUILD_MULTI
	jsr print_filename
	print_str "Passed"
.endif
	lda #0
	jmp exit


; Reports that the current test failed. Prints code and
; name last set with set_test, or just "Failed" if none
; have been set yet.
test_failed:
	lda test_code
	
	; Treat 0 as 1, in case it wasn't ever set
	bne :+
	lda #1
	sta test_code
:       
	; If code >= 2, print name
	cmp #2
	blt :+
	lda test_name+1
	beq :+
	jsr print_newline
	sta addr+1
	lda test_name
	sta addr
	jsr print_str_addr
	jsr print_newline
:       
.if !BUILD_MULTI
	jsr print_filename
.endif
	; End program
	lda test_code
	jmp exit


; Sets current test code and optional name. Also resets
; checksum.
.macro set_test code,name
	pha
	lda #code
	jsr set_test_
	.local Addr
	lda #<Addr
	sta <test_name
	lda #>Addr
	sta <test_name+1
	seg_data "STRINGS",{Addr: .byte name,0}
	pla
.endmacro

set_test_:
	sta test_code
	jmp reset_crc


; If checksum doesn't match expected, reports failed test.
; Passing 0 just prints checksum.
; Preserved: A, X, Y
.macro check_crc expected
	.if expected
		jsr_with_addr check_crc_,{.dword expected}
	.else
		; print checksum if 0 is passed
		jsr print_newline
		jsr print_crc
		jsr print_newline
	.endif
.endmacro

check_crc_:
	pha
	tya
	pha
	
	; Compare with complemented checksum
	ldy #3
:       lda (addr),y
	sec
	adc checksum,y
	bne @wrong
	dey
	bpl :-
	
	pla
	tay
	pla
	rts
	
@wrong: jsr print_newline
	jsr print_crc
	jsr print_newline
	jmp test_failed

; Reports value of A via low/high beeps.
; Preserved: A, X, Y
beep_bits:
	pha
	
	; Make reference low beep
	clc
	jsr @beep
	
	; End marker
	sec
	
	; Remove high zero bits
:       rol a
	beq @zero
	bcc :-
	
	; Play remaining bits
:       php
	jsr @beep
	plp
	asl a
	bne :-
	
@zero:  pla
	rts

@beep:  pha
	
	; Set LSB of pitch based on carry
	lda #0
	adc #$FF
	sta $4002
	
	; Set up square
	lda #1
	sta SNDCHN
	sta $4003
	sta $4001
	
	; Fade volume
	lda #15
:       pha
	eor #$30
	sta $4000
	delay_msec 8
	pla
	clc
	adc #-1
	bne :-
	
	; Silence
	sta SNDCHN
	delay_msec 120
	
	pla
	rts
