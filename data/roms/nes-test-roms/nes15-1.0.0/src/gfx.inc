;
; File: gfx.inc
; Namespace: gfx_ / GFX_
; Code Segment: CODE
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Graphics module
;

.ifndef GFX_INC
GFX_INC = 1

; Game display message indexes

.enum

	GFX_MSG_CLEAR
	GFX_MSG_SOLVED
	GFX_MSG_SOLVING

.endenum



; High byte of the name table to draw to

.globalzp gfx_nt

; Tile sprite's horizontal position on the puzzle board

.globalzp gfx_tile_x

; Cursor's horizontal position on the puzzle board

.globalzp gfx_cursor_x

; Tile sprite's vertical position on the puzzle board

.globalzp gfx_tile_y

; Cursor's vertical position on the puzzle board

.globalzp gfx_cursor_y

; Tile sprite's on-screen horizontal position

.globalzp gfx_tile_sx

; Cursor's on-screen horizontal position

.globalzp gfx_cursor_sx

; Tile sprite's on-screen vertical position

.globalzp gfx_tile_sy

; Cursor's on-screen vertical position

.globalzp gfx_cursor_sy

.endif



;
; Sets up the VRUB update to write the background and sprite palettes used by
; the game.
;
; Destroyed: a, x, y
;
.global gfx_write_pals

;
; Sets up the VRUB updates to draw a puzzle tile to the background. Note that
; this should not be used to draw the puzzle's gap.
;
; In:
;	a = The horizontal position of the tile to draw
;	y = The vertical position of the tile to draw
;
; Destroyed: a, x, y, game_temp/+1/+2
;
.global gfx_draw_tile_bgd

;
; Sets up the VRUB updates to erase a puzzle tile from the background.
;
; In:
;	a = The horizontal position of the tile to erase
;	y = The vertical position of the tile to erase
;
; Destroyed: a, x, y, game_temp/+1
;
.global gfx_erase_tile_bgd

;
; Initializes the tile sprite and draws it to the OAM buffer. Note that this
; should not be used to draw the puzzle's gap.
;
; In:
;	gfx_tile_x = The tile sprite's starting horizontal position
;	gfx_tile_y = The tile sprite's starting vertical position
;	gfx_tile_sx = The horizontal position of the tile sprite's destination
;	on the puzzle board
;	gfx_tile_sy = The vertical position of the tile sprite's destination on
;	the puzzle board
;
; Destroyed: a, x, y
;
.global gfx_init_tile_spr

;
; Positions the OAM sprites used by the tile sprite.
;
; Destroyed: a, x, y
;
.global gfx_pos_tile_spr

;
; Moves the tile sprite's on-screen position to match its position on the
; puzzle board.
;
; Out:
;	Z = Reset if the tile sprite's on-screen position matches its puzzle
;	board position, else set
;
; Destroyed: a, x, y
;
.global gfx_update_tile_spr

;
; Sets the OAM sprites used by the tile sprite to a non-visible state.
;
; Destroyed: a, x, y
;
.global gfx_erase_tile_spr

;
; Initializes the cursor and draws it to the OAM buffer.
;
; In:
;	gfx_cursor_x = The cursor's horizontal position on the puzzle board
;	gfx_cursor_y = The cursor's vertical position on the puzzle board
;
; Preserved: x, y
; Destroyed: a
;
.global gfx_init_cursor

;
; Positions the OAM sprites used by the cursor.
;
; Preserved: x, y
; Destroyed: a
;
.global gfx_pos_cursor

;
; Moves the cursor's on-screen position to match its position on the puzzle
; board.
;
; Out:
;	Z = Reset if the cursor's on-screen position matches its puzzle board
;	position, else set
;
; Destroyed: a, x, y
;
.global gfx_update_cursor

;
; Draws the number of moves used by the player to the screen.
;
; In:
;	a = The low byte of the number of moves to draw
;	y = The high byte of the number of moves to draw
;
; Destroyed: a, x, y
;
.global gfx_draw_moves

;
; Draws a message to the message display area of the game screen.
;
; In:
;	a = The index of the message to draw
;
; Destroyed: a, x, y
;
.global gfx_draw_msg

