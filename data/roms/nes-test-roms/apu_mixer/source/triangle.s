; Verifies triangle DAC and non-linear mixing
;
; Plays triangle wave. Cancels this to silence with inverse
; wave generated using DMC DAC. Scans over range of DMC DAC
; to test non-linearity.

.include "vol_shell.inc"
	
test_main:
	setb $4008,$FF
	setb $400A,0
	setb $400B,0
	delay_msec 20
	setb $4015,$04
	setb $4009,0
	
	wait = 8
	
	lda #wait
	sta temp
	sta temp+1
	ldy #127-41
	
	extra = 13-1
	
	setb $400A,$37
	setb $400B,0
	delay 28-extra
	
	ldx #16
@1:     delay extra
@2:     inx
	txa
	and #$1F
	tax
	tya
	clc
	adc table,x
	sta $4011
	delay 3
	dec_tempw
	bne @1
	lda #wait
	sta temp
	sta temp+1
	dey
	bne @2
	
	rts

.align 32
table:
	.byte 0,3,6,8,11,14,17,19,22,25,28,30,33,35,38,41
	.byte 41,38,35,33,30,28,25,22,19,17,14,11,8,6,3,0
