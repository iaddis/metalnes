CUSTOM_IRQ=1
.include "shell.inc"

irq:    pla
	pha
	rti

jmp_6ff:
	.byte $6C ; JMP ($6FF) (to avoid warning)
	.word $6FF

main:
	setb SNDMODE,$40 ; disable frame IRQ
	
	set_test 3,"JMP ($6FF) should get high byte from $600"
	setb $6FF,$F0
	setb $600,$07
	setb $700,$06
	setb $7F0,$E8 ; INX
	setb $7F1,$60 ; RTS
	setb $6F0,$60 ; RTS
	ldx #0
	jsr jmp_6ff
	cpx #1
	jne test_failed
	
	set_test 4,"RTS should return to addr+1"
	lda #>:+
	pha
	lda #<:+
	pha
	ldx #0
	rts
	inx
:       inx
	inx
	cpx #1
	jne test_failed
	
	set_test 5,"RTI should return to addr"
	lda #>:+
	pha
	lda #<:+
	pha
	ldx #0
	php
	rti
	inx
:       inx
	inx
	cpx #2
	jne test_failed
	
	set_test 6,"JSR should push addr of next instr - 1"
	setb $6FE,$20 ; JSR
	setb $6FF,<:+
	setb $700,>:+
	jmp $6FE
:       pla
	cmp #$00
	jne test_failed
	pla
	cmp #$07
	jne test_failed
	
	set_test 7,"BRK should push status with bits 4 and 5 set"
	lda #$00
	pha
	plp
	brk
	nop
	cmp #$30
	jne test_failed
	lda #$FF
	pha
	plp
	brk
	nop
	cmp #$FF
	jne test_failed
	
	set_test 8,"BRK should push address BRK + 2"
	ldx #1
	brk
	inx
	inx
	cpx #2
	jne test_failed
	
	jmp tests_passed
