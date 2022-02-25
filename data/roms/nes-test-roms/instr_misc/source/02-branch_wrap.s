; Verifies that branching past end or before beginning
; of RAM wraps around

.include "shell.inc"

main:
	set_test 2,"Branch from $FF8x to $000x"
	setb <0,$E8 ; INX
	setb <1,$E8 ; INX
	setb <2,$60 ; RTS
	ldx #0
	clc
	jsr forward
	cpx #1
	jne test_failed
	
	set_test 3,"Branch from $000x to $FFFx"
	setb <0,$90 ; BCC
	setb <1,-$3F
	ldx #0
	clc
	jsr <0
	cpx #1
	jne test_failed
	
	jmp tests_passed


.segment "FF80"
	.res $40
; $FFC0
forward:
	.byte $90,$3F ; BCC $3F
	inx
return:
	inx
	rts
