;
; File: vrub_from_mem.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; 'vrub_from_mem' subroutine
;

.include "vrub.inc"



.segment "ZEROPAGE"

vrub_src:			.res 2



.segment "VRUBLIB"

.proc vrub_from_mem

	sta vrub_src
	sty vrub_src + 1

update_loop:
	ldy #0
	lda (vrub_src), y
	bpl done
	lsr
	bcc get_length
	lda #VRUB_DATA + 1	; Read VRUB_DATA + 1 from 'vrub_src'
	bne copy

get_length:
	ldy #VRUB_LEN		; Read length + VRUB_DATA from 'vrub_src'
	lda (vrub_src), y
	adc #VRUB_DATA

copy:
	tay
	dey
	pha
	clc
	adc vrub_end
	sta vrub_end
	tax

	; Copy all bytes from last to first into 'vrub_buff'. Note that I
	; assume that no update is greater than 129 bytes.

copy_loop:
	lda (vrub_src), y
	sta vrub_buff - 1, x
	dex
	dey
	bpl copy_loop

	; Move the source address to the next update and continue.

	pla
	clc
	adc vrub_src
	sta vrub_src
	bcc update_loop
	inc vrub_src + 1
	bne update_loop

done:
	ldx vrub_end		; Add null terminator to 'vrub_buff'
	sta vrub_buff, x
	rts

.endproc

