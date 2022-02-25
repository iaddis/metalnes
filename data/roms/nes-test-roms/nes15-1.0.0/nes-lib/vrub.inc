;
; File: vrub.inc
; Namespace: vrub_ / VRUB_
; Code Segment: VRUBLIB
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; The VRAM update buffer
;

.ifndef VRUB_INC
VRUB_INC = 1

.enum

	; Control byte: t---i--r
	;
	; t = Terminate
	;	0: No transfers left
	;	1: Continue transferring
	;
	; i = VRAM increment
	; 	0: Increment by 1
	;	1: Increment by 32
	;
	; r = Repeat byte
	;	0: No repeating
	;	1: Repeat first byte read from source

	VRUB_CTRL

	; VRAM destination address

	VRUB_DSTHI
	VRUB_DSTLO

	; Length of the transfer

	VRUB_LEN

	; Begining of the data to transfer

	VRUB_DATA

.endenum



; ROM/RAM to VRAM updates storage. Note that the first byte must be set to zero
; before NMIs are enabled.
;
; Bytes: May be as little as 'VRUB_DATA + 1' to a full page if needed

.global vrub_buff

; Current position of the next entry to write to. If set to zero, 'vrub_update'
; does nothing. This should initially be set to zero before NMIs are enabled.
; After an update is added to the 'vrub_buff', 'vrub_end' should be set to the
; first byte of the next update and a null terminator (zero) should written.

.globalzp vrub_end



;
; VRUB NMI macro. Note that afterwards PPUCTRL and PPUSCROLL should be updated
; to reset the PPU's internal address.
;
; In:
;	ppuctrl = The bits to write to PPUCTRL when setting the VRAM increment
;
; Preserved: vrub_buff
; Destroyed: a, x, y, vrub_end
;
.macro vrub_update ppuctrl

	ldy #0
	sty vrub_end

.local buff_loop
buff_loop:
	lda vrub_buff + VRUB_CTRL, y
	bpl done
	lsr
	ora ppuctrl
	sta PPUCTRL
	lda vrub_buff + VRUB_DSTHI, y
	sta PPUADDR
	lda vrub_buff + VRUB_DSTLO, y
	sta PPUADDR
	ldx vrub_buff + VRUB_LEN, y
	iny
	iny
	iny
	iny
	bcs repeat

.local literal_loop
literal_loop:
	lda vrub_buff, y
	sta PPUDATA
	iny
	dex
	bne literal_loop
	beq buff_loop

.local repeat
repeat:
	lda vrub_buff, y
	iny

.local repeat_loop
repeat_loop:
	sta PPUDATA
	dex
	bne repeat_loop
	beq buff_loop

.local done
done:

.endmacro

;
; Creates a VRUB update to draw a string to VRAM.
;
; In:
;	addr = The address to draw the string to
;	string = The string to be drawn
;
.macro vrub_str addr, string

	.byte $80, >addr, <addr, .strlen(string), string

.endmacro

;
; Copies one or more VRUB updates from memory into 'vrub_buff'. The update(s)
; should be followed by a value less than $80.
;
; In:
;	a = The low byte of the address of the update to copy
;	y = The high byte of the address of the update to copy
; Out:
;	x = The new value of 'vrub_end'
;
; Destroyed: a, y
;
.global vrub_from_mem

.endif

