;Joypad handling

.section "ReadnLockPads" FREE
ReadLockJoypad
	jsr ReadJoypad
	ldx #$01
-	lda Pad1,X
	tay
	eor Pad1Locked,X	;This detects the key who had a '0' to '1' transition
	and Pad1,X
	sta Pad1,X
	sty Pad1Locked,X
	dex
	bpl -
	rts
.ends

.section "ReadLockPadsDPCM" FREE	;To be used when the DPCM may occasionally glitch the reads
ReadLockJoypadDPCM
	jsr ReadJoypad
-	ldx Pad1
	ldy Pad2		;Read until 2 consecutive reads returns the same data
	jsr ReadJoypad
	cpx Pad1
	bne -
	cpy Pad2
	bne -

	ldx #$01
-	lda Pad1,X
	tay
	eor Pad1Locked,X	;This detects the key who had a '0' to '1' transition
	and Pad1,X
	sta Pad1,X
	sty Pad1Locked,X
	dex
	bpl -
	rts
.ends

.section "ReadPad" FREE
;Do read the hardware joypads ports
;Exit with JoyData=Joypad value
;X and Y unchanged

ReadJoypad
	lda #$01
	sta $4016			;Be sure to reset the shift counters
	sta Pad1
	sta Pad2
	lsr A				;Simple trick to get a 0, heh
	sta $4016

-	lda $4016			;Read the value of JoyPad 1
	lsr A
	bcs +
	lsr A
+	rol Pad1
	bcc -				;Carry will be set when all 8 keys are read

-	lda $4017			;Read the value of JoyPad 1
	lsr A
	bcs +
	lsr A
+	rol Pad2
	bcc -				;Carry will be set when all 8 keys are read
	rts
.ends