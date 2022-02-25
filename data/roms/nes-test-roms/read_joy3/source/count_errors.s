; Repeatedly calls read_joy while DMC is playing
; and prints X when the DMC conflicted with one
; of the internal reads. Note that a conflict
; doesn't affect the result of read_joy, since it
; compensates when this occurs.

dmc_rate = 15 ; 0 to 15

.include "shell.inc"
.include "read_joy.inc"

iter = 1000
zp_byte conflicts

main:
	; Start DMC
	lda #$40+dmc_rate
	sta $4010
	lda #$FF
	sta $4012
	sta $4013
	lda #0
	sta $4015
	lda #$10
	sta $4015
	
	; Repeatedly read controller
	ldy #>iter
	ldx #<iter
:       txa
	pha
	jsr test
	pla
	tax
	dex
	bne :-
	dey
	bne :-
	
	; Print result
	print_str {newline,"Conflicts: "}
	lda conflicts
	jsr print_dec
	print_str "/1000"
	
test:   jsr read_joy
	pha
	pha
	
	; Recover second controller read
	; from below stack pointer
	tsx
	dex
	txs
	pla
	
	; Compare all four reads
	cmp <temp3
	bne :+
	cmp <temp2
	bne :+
	cmp <temp
:       
	; Print and count whether they matched
	print_cc bne,'X','-'
	beq :+
	inc conflicts
:       
	; Be sure read worked correctly
	pla
	pla
	jne test_failed
	rts
