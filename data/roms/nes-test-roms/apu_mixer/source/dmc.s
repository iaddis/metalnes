; Verifies DMC DAC and non-linear mixing
;
; Plays square channel at maximum volume. Cancels this
; to silence with inverse wave generated using DMC DAC.
; Scans over range of DMC DAC to test non-linearity.

.include "vol_shell.inc"

test_main:
	setb $4000,$BF  ; max volume
	setb $4001,$7F  ; disable sweep
	setb $4002,0    ; period = 0
	setb $4003,0
	delay 5000      ; allow period to settle in
	setb $4015,$01
	
	ldx #82
	ldy #0
	
	setb $4002,$6F  ; period = 896*2
	setb $4003,0
	delay 216-6
@1:     delay 6
@2:     stx $4011
	delay 896-4-4
	lda vols,x
	sta $4011
	delay 896-4-5-6
	dey
	bne @1
	ldy #80
	dex
	bne @2
	
	rts

.align 128
vols:   .byte 23,25,26,27,28,29,31,32,33,34,36,37,38,39,40,42
	.byte 43,44,45,47,48,49,50,52,53,54,55,57,58,59,60,62
	.byte 63,64,65,67,68,69,70,72,73,74,75,77,78,79,81,82
	.byte 83,84,86,87,88,89,91,92,93,95,96,97,98,100,101
	.byte 102,104,105,106,107,109,110,111,113,114,115,117
	.byte 118,119,120,122,123,124,126,127
