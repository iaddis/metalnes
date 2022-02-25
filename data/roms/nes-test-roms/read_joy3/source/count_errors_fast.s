; Repeatedly calls read_joy_fast while DMC is
; playing and prints X when the DMC caused
; erroneous reading.

dmc_rate = 15 ; 0 to 15

.include "shell.inc"
.include "read_joy.inc"

iter = 1000
zp_byte errors

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
@loop:  jsr read_joy_fast

	; If error, won't have read zero
	cmp #0
	print_cc beq,'-','X'
	cmp #0
	beq :+
	inc errors
:
	dex
	bne @loop
	dey
	bne @loop
	
	; Print result
	print_str {newline,"Errors: "}
	lda errors
	jsr print_dec
	print_str "/1000"
	
	rts
