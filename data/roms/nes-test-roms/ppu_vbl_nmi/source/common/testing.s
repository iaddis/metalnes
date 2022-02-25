; Utilities for writing test ROMs

; In NVRAM so these can be used before initializing runtime,
; then runtime initialized without clearing them
nv_res test_code ; code of current test
nv_res test_name,2 ; address of name of current test, or 0 of none


; Sets current test code and optional name. Also resets
; checksum.
; Preserved: A, X, Y
.macro set_test code,name
	pha
	lda #code
	jsr set_test_
	.ifblank name
		setb test_name+1,0
	.else
		.local Addr
		setw test_name,Addr
		seg_data RODATA,{Addr: .byte name,0}
	.endif
	pla
.endmacro

set_test_:
	sta test_code
	jmp reset_crc


; Initializes testing module
init_testing = init_crc


; Reports that all tests passed
tests_passed:
	jsr print_filename
	print_str newline,"Passed"
	lda #0
	jmp exit


; Reports "Done" if set_test has never been used,
; "Passed" if set_test 0 was last used, or
; failure if set_test n was last used.
tests_done:
	ldx test_code
	jeq tests_passed
	inx
	bne test_failed
	jsr print_filename
	print_str newline,"Done"
	lda #0
	jmp exit


; Reports that the current test failed. Prints code and
; name last set with set_test, or just "Failed" if none
; have been set yet.
test_failed:
	ldx test_code
	
	; Treat $FF as 1, in case it wasn't ever set
	inx
	bne :+
	inx
	stx test_code
:       
	; If code >= 2, print name
	cpx #2-1        ; -1 due to inx above
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
	jsr print_filename

	; End program
	lda test_code
	jmp exit


; If checksum doesn't match expected, reports failed test.
; Clears checksum afterwards.
; Preserved: A, X, Y
.macro check_crc expected
	jsr_with_addr check_crc_,{.dword expected}
.endmacro

check_crc_:
	pha
	jsr is_crc_
	bne :+
	jsr reset_crc
	pla
	rts

:       jsr print_newline
	jsr print_crc
	jmp test_failed
