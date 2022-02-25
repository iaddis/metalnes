; Synchronizes APU divide-by-two so that an STA $4017
; immediately after the JSR (or some even number of
; clocks after) will start the frame counter without
; an extra clock delay.
; Preserved: A, X, Y
; Time: 16.7 msec
sync_apu:
	pha
	
	; Clear IRQ flag
	sei
	lda #$40
	sta SNDMODE
	
	; Mode 0, frame IRQ enabled
	lda #$00
	sta SNDMODE
	delay 29825
	
	; Delay extra clock if odd alignment
	lda #$40
	bit SNDCHN
	bne :+
:       
	; Clear IRQ flag
	sta SNDMODE
	pla
	rts
