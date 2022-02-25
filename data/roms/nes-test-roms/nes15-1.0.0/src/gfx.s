;
; File: gfx.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Graphics subroutines and data
;

.include "bcd.inc"
.include "oam.inc"
.include "ppu.inc"
.include "vrub.inc"

.include "fifteen.inc"
.include "game.inc"

.include "gfx.inc"



; Puzzle tile's dimensions in pattern table tiles

TILE_WIDTH = 4
TILE_HEIGHT = 4
TILE_SIZE = TILE_WIDTH * TILE_HEIGHT

; Pattern table indexes used to draw the puzzle's tiles

TILE_TLCORNER = $00
TILE_TRCORNER = $01
TILE_BLCORNER = $02
TILE_BRCORNER = $03
TILE_TEDGE = $04
TILE_BEDGE = $05
TILE_LEDGE = $06
TILE_REDGE = $07
TILE_NUM_BASE = $60

; Name table position of the top left corner of the tile area

TILE_NT_X = 8
TILE_NT_Y = 6

; Name table address of the top left corner of the tile area

TILE_NT_ADDR = TILE_NT_X + TILE_NT_Y * 32

; First and last OAM sprites used by the tile sprite

TILE_OAM_FIRST = CURSOR_OAM_LAST + OAM_SIZE
TILE_OAM_LAST = TILE_OAM_FIRST + (TILE_SIZE - 1) * OAM_SIZE

; Pattern table indexes used to draw the cursor

CURSOR_TLCORNER = $08
CURSOR_TRCORNER = $09
CURSOR_BLCORNER = $0A
CURSOR_BRCORNER = $0B

; First and last OAM sprites used by the cursor

CURSOR_OAM_FIRST = 0
CURSOR_OAM_LAST = 3 * OAM_SIZE

; Name table address of the moves display area

MOVES_NT_ADDR = 22 + 27 * 32

; Name table address of the message display area

MSG_NT_ADDR = 6 + 26 * 32



.segment "ZEROPAGE"

gfx_nt:			.res 1

gfx_tile_x:		.res 1
gfx_cursor_x:		.res 1

gfx_tile_y:		.res 1
gfx_cursor_y:		.res 1

gfx_tile_sx:		.res 1
gfx_cursor_sx:		.res 1

gfx_tile_sy:		.res 1
gfx_cursor_sy:		.res 1



.segment "CODE"

.proc gfx_write_pals

	lda #<pal_update
	ldy #>pal_update
	jmp vrub_from_mem

pal_update:
	.byte $80, $3F, $00, 32
	.incbin "bgd.pal"
	.incbin "spr.pal"

.endproc



.proc gfx_draw_tile_bgd

nt_addr = game_temp
tile_offset = game_temp + 2

	; Store the offset to add to the tile's center indexes.

	sta nt_addr
	tya
	asl
	asl
	adc nt_addr		; Carry is already cleared
	tax
	lda fifteen_board, x
	asl
	asl
	sta tile_offset

	; Store the name table address to write to.

	jsr calc_nt_addr

	; Setup the VRUB updates for each column of the tile.

	ldx vrub_end
	ldy #TILE_WIDTH - 1

loop:

	; Store the pattern table indexes for this column.

	lda pt_indexes, y
	sta vrub_buff + VRUB_DATA, x
	lda pt_indexes + TILE_WIDTH, y
	sta vrub_buff + VRUB_DATA + 1, x
	lda pt_indexes + TILE_WIDTH * 2, y
	sta vrub_buff + VRUB_DATA + 2, x
	lda pt_indexes + TILE_WIDTH * 3, y
	sta vrub_buff + VRUB_DATA + 3, x

	; If drawing the inner columns, add the offset already stored.

	tya
	beq cont
	cpy #TILE_WIDTH - 1
	bcs cont
	lda vrub_buff + VRUB_DATA + 1, x
	adc tile_offset
	sta vrub_buff + VRUB_DATA + 1, x
	lda vrub_buff + VRUB_DATA + 2, x
	adc tile_offset
	sta vrub_buff + VRUB_DATA + 2, x

cont:
	; Set the control byte for the update.

	lda #$88
	sta vrub_buff + VRUB_CTRL, x

	; Finish writing the update and move to the next column.

	jsr finish_update
	txa
	adc #VRUB_DATA + TILE_HEIGHT
	tax
	dey
	bpl loop
	lda #$00
	sta vrub_buff + VRUB_CTRL, x
	stx vrub_end
	rts

;
; Calculates the name table address for the top left-hand corner of a puzzle
; tile (nt_addr * 4 + y * 128 + TILE_NT_ADDR). Note that this is reused by
; 'gfx_erase_tile_bgd'.
;
; In:
;	nt_addr = The horizontal position of the tile to draw
;	y = The vertical position of the tile to draw
;
; Out:
;	nt_addr/+1 = The name table address for the puzzle tile
;
; Preserved: x
; Destroyed: a, y
;
.proc calc_nt_addr

	tya
	ldy nt_addr
	lsr
	sta nt_addr + 1
	ror
	sta nt_addr
	tya
	asl
	asl
	adc nt_addr		; Carry is already cleared
	adc #<TILE_NT_ADDR
	sta nt_addr
	lda nt_addr + 1
	adc #>TILE_NT_ADDR
	ora gfx_nt
	sta nt_addr + 1
	rts

.endproc

;
; Sets the destination and length bytes for current column's VRUB update. Note
; that this is reused by 'gfx_erase_tile_bgd'.
;
; In:
;	x = The index in 'vrub_buff' to write to
;	y = The column of the tile being written
;
; Preserved: y
; Destroyed: a
;
.proc finish_update

	tya
	clc
	adc nt_addr
	sta vrub_buff + VRUB_DSTLO, X
	lda #0
	adc nt_addr + 1
	sta vrub_buff + VRUB_DSTHI, X
	lda #TILE_HEIGHT
	sta vrub_buff + VRUB_LEN, x
	rts

.endproc

pt_indexes:
	.byte TILE_TLCORNER, TILE_TEDGE, TILE_TEDGE, TILE_TRCORNER
	.byte TILE_LEDGE, TILE_NUM_BASE - 4, TILE_NUM_BASE - 2, TILE_REDGE
	.byte TILE_LEDGE, TILE_NUM_BASE - 3, TILE_NUM_BASE - 1, TILE_REDGE
	.byte TILE_BLCORNER, TILE_BEDGE, TILE_BEDGE, TILE_BRCORNER

.endproc



.proc gfx_erase_tile_bgd

nt_addr = game_temp

	; Store the name table address to write to.

	sta nt_addr
	jsr gfx_draw_tile_bgd::calc_nt_addr

	; Setup the VRUB updates for each column of the tile to erase.

	ldx vrub_end
	ldy #TILE_WIDTH - 1

loop:

	; Set the control byte for the update.

	lda #$89
	sta vrub_buff + VRUB_CTRL, x

	; Store the blank pattern table index, which will be repeated for the
	; entire column.

	lda #' '
	sta vrub_buff + VRUB_DATA, x

	; Finish writing the update and move to the next column.

	jsr gfx_draw_tile_bgd::finish_update
	txa
	adc #VRUB_DATA + 1
	tax
	dey
	bpl loop
	lda #$00
	sta vrub_buff + VRUB_CTRL, x
	stx vrub_end
	rts

.endproc



.proc gfx_init_tile_spr

; Center OAM sprites that contain the tile's number

oam0 = oam_buff + TILE_OAM_FIRST + 5 * OAM_SIZE
oam1 = oam_buff + TILE_OAM_FIRST + 6 * OAM_SIZE
oam2 = oam_buff + TILE_OAM_FIRST + 9 * OAM_SIZE
oam3 = oam_buff + TILE_OAM_FIRST + 10 * OAM_SIZE

	; Set the sprite's pattern table indexes and color.

	ldx #TILE_OAM_LAST
	ldy #TILE_SIZE - 1

loop:
	lda gfx_draw_tile_bgd::pt_indexes, y
	sta oam_buff + OAM_TILE, x
	lda #1
	sta oam_buff + OAM_ATT, x
	dex
	dex
	dex
	dex
	dey
	bpl loop

	lda gfx_tile_y
	asl
	asl
	adc gfx_tile_x		; Carry is already cleared
	tay
	lda fifteen_board, y
	asl
	asl
	adc #TILE_NUM_BASE - 4	; Carry is already cleared
	tay
	sty oam0 + OAM_TILE
	iny
	sty oam2 + OAM_TILE
	iny
	sty oam1 + OAM_TILE
	iny
	sty oam3 + OAM_TILE

	; Initialize the tile sprite's on-screen position from the puzzle board
	; position already stored in 'gfx_tile_sx' and 'gfx_tile_sy'.

	lda gfx_tile_sx
	lsr
	ror
	ror
	ror
	adc #TILE_NT_X * 8	; Carry is already cleared
	sta gfx_tile_sx
	lda gfx_tile_sy
	lsr
	ror
	ror
	ror
	adc #TILE_NT_Y * 8	; Carry is already cleared
	sta gfx_tile_sy
	rts

.endproc



.proc gfx_pos_tile_spr

	ldx #TILE_OAM_LAST
	ldy #TILE_SIZE - 1

loop:
	tya
	and #$0C
	asl
	adc gfx_tile_sy		; Carry is already cleared
	adc #$FF
	sta oam_buff + OAM_Y, x
	tya
	and #$03
	asl
	asl
	asl
	adc gfx_tile_sx		; Carrys is already cleared
	sta oam_buff + OAM_X, x
	dex
	dex
	dex
	dex
	dey
	bpl loop
	rts

.endproc



.proc gfx_update_tile_spr

	ldx #0

;
; Update either the tile sprite or the cursor. Note that this is reused by
; 'gfx_update_cursor'.
;
; In:
;	x = Which sprite to update (0 = tile, 1 = cursor)
;
; Out:
;	Z = Reset if the sprite's on-screen position matches its puzzle board
;	position, else set
;
; Preserved: x
; Destroyed: a, y
;
.proc update

	; Keep count of the number of coordinates updated.

	ldy #0

	; Update the sprite's horizontal position.

	lda gfx_tile_x, x
	lsr
	ror
	ror
	ror
	adc #TILE_NT_X * 8	; Carry is already cleared
	sec
	sbc gfx_tile_sx, x
	beq move_ver
	bcs move_right

	lsr
	lsr
	ora #$C0
	bne hor_done

move_right:
	adc #2			; Carry is already set
	lsr
	lsr

hor_done:
	clc
	adc gfx_tile_sx, x
	sta gfx_tile_sx, x
	iny

	; Update the sprite's vertical position.

move_ver:
	lda gfx_tile_y, x
	lsr
	ror
	ror
	ror
	adc #TILE_NT_Y * 8	; Carry is already cleared
	sec
	sbc gfx_tile_sy, x
	beq done
	bcs move_down

	lsr
	lsr
	ora #$C0
	bne ver_done

move_down:
	adc #2			; Carry is already set
	lsr
	lsr

ver_done:
	clc
	adc gfx_tile_sy, x
	sta gfx_tile_sy, x
	iny

done:
	tya			; Set Z based on the number coordinates updated
	rts

.endproc

.endproc



.proc gfx_erase_tile_spr

	ldx #TILE_OAM_LAST
	ldy #TILE_SIZE - 1
	lda #248

loop:
	sta oam_buff + OAM_Y, x
	dex
	dex
	dex
	dex
	dey
	bpl loop
	rts

.endproc



.proc gfx_init_cursor

oam0 = oam_buff + CURSOR_OAM_FIRST
oam1 = oam_buff + CURSOR_OAM_FIRST + OAM_SIZE
oam2 = oam_buff + CURSOR_OAM_FIRST + OAM_SIZE * 2
oam3 = oam_buff + CURSOR_OAM_FIRST + OAM_SIZE * 3

	; Set the sprite's pattern table indexes and color.

	lda #CURSOR_TLCORNER
	sta oam0 + OAM_TILE
	lda #CURSOR_BLCORNER
	sta oam1 + OAM_TILE
	lda #CURSOR_TRCORNER
	sta oam2 + OAM_TILE
	lda #CURSOR_BRCORNER
	sta oam3 + OAM_TILE

	lda #0
	sta oam0 + OAM_ATT
	sta oam1 + OAM_ATT
	sta oam2 + OAM_ATT
	sta oam3 + OAM_ATT

	; Initialize the cursor's on-screen position.

	lda gfx_cursor_x
	lsr
	ror
	ror
	ror
	adc #TILE_NT_X * 8	; Carry is already cleared
	sta gfx_cursor_sx
	lda gfx_cursor_y
	lsr
	ror
	ror
	ror
	adc #TILE_NT_Y * 8	; Carry is already cleared
	sta gfx_cursor_sy
	rts

.endproc



.proc gfx_pos_cursor

oam0 = oam_buff + CURSOR_OAM_FIRST
oam1 = oam_buff + CURSOR_OAM_FIRST + OAM_SIZE
oam2 = oam_buff + CURSOR_OAM_FIRST + OAM_SIZE * 2
oam3 = oam_buff + CURSOR_OAM_FIRST + OAM_SIZE * 3

	lda gfx_cursor_sx
	sta oam0 + OAM_X
	sta oam1 + OAM_X
	clc
	adc #(TILE_WIDTH - 1) * 8
	sta oam2 + OAM_X
	sta oam3 + OAM_X

	lda gfx_cursor_sy
	adc #$FF		; Carry is already cleared
	sta oam0 + OAM_Y
	sta oam2 + OAM_Y
	clc
	adc #(TILE_HEIGHT - 1) * 8
	sta oam1 + OAM_Y
	sta oam3 + OAM_Y
	rts

.endproc



.proc gfx_update_cursor

	ldx #1
	jmp gfx_update_tile_spr::update

.endproc



.proc gfx_draw_moves

	; Convert the number of moves to BCD format.

	jsr bcd16_from_bin

	; Setup the VRUB update to draw the number of moves.

	lda #>MOVES_NT_ADDR
	ora gfx_nt
	tay
	lda #<MOVES_NT_ADDR
	jmp bcd16_to_vrub

.endproc



.proc gfx_draw_msg

; Length of the longest message. Remember to update this when adding and
; removing messages.

MSG_LEN = 10

; Offset to the high byte of last VRUB update's destination.

LAST_DSTHI = VRUB_DSTHI - (VRUB_DATA + MSG_LEN)

	tax
	lda msg_table_lo, x
	ldy msg_table_hi, x
	jsr vrub_from_mem
	lda vrub_buff + LAST_DSTHI, x
	ora gfx_nt
	sta vrub_buff + LAST_DSTHI, x
	rts

; Message address lookup table

msg_table_lo:
	.byte <msg0, <msg1, <msg2

msg_table_hi:
	.byte >msg0, >msg1, >msg2

; Game screen messages

msg0:
	vrub_str MSG_NT_ADDR, "          "
	.byte $00

msg1:
	vrub_str MSG_NT_ADDR, "SOLVED!   "
	.byte $00

msg2:
	vrub_str MSG_NT_ADDR, "SOLVING..."
	.byte $00

.endproc



.segment "CHR1"

	.incbin "edges.chr"	; $00
	.incbin "cursor.chr"	; $08
	.incbin "tile.chr"	; $0C
	.res $130
	.incbin "font.chr"	; $20
	.incbin "nums.chr"	; $60

