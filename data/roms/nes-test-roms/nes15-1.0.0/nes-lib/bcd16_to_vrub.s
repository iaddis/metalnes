;
; File: bcd16_to_vrub.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; 'bcd16_to_vrub' subroutine
;

.include "bcd.inc"

.include "vrub.inc"



.segment "BCDLIB"

.proc bcd16_to_vrub

	; Setup the VRUB update to draw number.

	ldx vrub_end
	sta vrub_buff + VRUB_DSTLO, x
	tya
	sta vrub_buff + VRUB_DSTHI, x
	lda #$80
	sta vrub_buff + VRUB_CTRL, x
	lda #4
	sta vrub_buff + VRUB_LEN, x
	inx
	inx
	inx
	inx

	; Write the digits to be drawn.

	ldy #1

digit_loop:
	lda bcd_num, y
	and #$F0
	lsr
	lsr
	lsr
	lsr
	ora #'0'
	sta vrub_buff, x
	inx
	lda bcd_num, y
	and #$0F
	ora #'0'
	sta vrub_buff, x
	inx
	dey
	bpl digit_loop

	; Finish the VRUB update.

	lda #$00
	sta vrub_buff, x
	stx vrub_end

	; Remove any leading zeros from the number to be drawn.

	ldy #3

zero_loop:
	lda vrub_buff - 4, x
	cmp #'0'
	bne done
	lda #' '
	sta vrub_buff - 4, x
	inx
	dey
	bne zero_loop

done:
	rts

.endproc

