; Verifies that $FFFF wraps around to 0 for
; STA abs,X and LDA abs,X

.include "shell.inc"

main:
	setb <0,0
	setb <1,0
	
	ldx #1
	lda #$12
	sta $FFFF,x
	
	ldx #2
	lda #$34
	sta $FFFF,x
	
	set_test 2,"Write wrap-around failed"
	
	lda <$00
	cmp #$12
	jne test_failed
	
	lda <$01
	cmp #$34
	jne test_failed
	
	set_test 3,"Read wrap-around failed"
	
	ldx #1
	lda $FFFF,x
	cmp #$12
	jne test_failed
	
	ldx #2
	lda $FFFF,x
	cmp #$34
	jne test_failed
	
	jmp tests_passed
