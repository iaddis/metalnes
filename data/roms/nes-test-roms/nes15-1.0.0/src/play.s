;
; File: play.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Playing game state subroutines and data
;

.include "joy.inc"
.include "muse.inc"
.include "pkb.inc"
.include "ppu.inc"

.include "fifteen.inc"
.include "game.inc"
.include "gfx.inc"
.include "nmi.inc"
.include "snd.inc"

.include "play.inc"



; Playing game states

.enum

	; Generates and draws a new puzzle and prepares the game for play.
	;
	; Preconditions:
	;
	; 'gfx_nt' must be initialized.
	; The background must be drawn to both name tables.

	PLAY_NEW_PUZZLE

	; Waits for player input and performs any valid actions.
	;
	; Preconditions:
	;
	; The puzzle board must be drawn.
	; The message area must be cleared.

	PLAY_WAIT_ACTION

	; Displays tile movement.
	;
	; Preconditions:
	;
	; A valid move must have occurred.
	; 'tile_x' and 'tile_x' must be set to the tile's new position.
	; The cursor's position must be set to the tile's old position.

	PLAY_MOVE_TILE

	; Displays the solved message and waits for input.
	;
	; Preconditions:
	;
	; The puzzle must be solved.

	PLAY_PUZZLE_SOLVED

.endenum

; Maximum number of that can be counted

MAX_MOVES = 9999



.segment "ZEROPAGE"

; Current playing game state

play_state:		.res 1

; Play state flags: ps------
;
; p = Paused
;	0: Play is active
;	1: Play is paused
;
; s = Auto-solving
;	0: Auto-solver is inactive
;	1: Auto-solver is active

play_flags:		.res 1

; Position of the current tile being processed

tile_x:			.res 1
tile_y:			.res 1

; Number of moves used by the player

moves:			.res 2



.segment "CODE"

;
; 'PLAY_NEW_PUZZLE' state
;
.proc new_puzzle

.proc init

	jsr fifteen_gen		; Generate a new puzzle state
	lda gfx_nt		; Prepare to draw to the off-screen name table
	eor #$04
	sta gfx_nt
	lda #0			; Initialize the current position to draw
	sta tile_x
	sta tile_y
	tay			; Reset and the number of moves used
	sta moves
	sty moves + 1
	jsr gfx_draw_moves	; Draw the number of moves to the screen
	lda #GFX_MSG_CLEAR	; Clear the message display area
	jsr gfx_draw_msg
	lda #SND_MUS0		; Start the background music
	jmp muse_play

.endproc

.proc update

	; If the current position is the gap, erase any tile that might be
	; there, else draw the tile at the current position.

	lda tile_x
	ldy tile_y
	cmp fifteen_gap_x
	bne draw_tile
	cpy fifteen_gap_y
	bne draw_tile
	jsr gfx_erase_tile_bgd
	jmp next

draw_tile:
	jsr gfx_draw_tile_bgd

next:

	; Advance to the next tile.

	inc tile_x
	lda tile_x
	sec
	sbc #FIFTEEN_WIDTH
	bne update
	sta tile_x
	inc tile_y
	lda tile_y
	cmp #FIFTEEN_HEIGHT
	bne done

	; Begin play if the puzzle board is fully draw.

	lda nmi_ppuctrl		; Switch the visible name table to one drawn to
	eor #$01
	sta nmi_ppuctrl
	lda #$1E		; Enable rendering if not already enabled
	sta nmi_ppumask
	lda #PLAY_WAIT_ACTION	; Change the state to 'wait_action'
	jmp change_state

done:
	rts

.endproc

.endproc



;
; 'PLAY_WAIT_ACTION' state
;
.proc wait_action

.proc init

	rts

.endproc

.proc update

	; If auto-solving is enabled, perform the next move provided by the
	; auto-solver.

	bit play_flags
	bvc test_move
	lda fifteen_gap_x
	sta tile_x
	lda fifteen_gap_y
	sta tile_y
	jsr fifteen_solve
	jsr fifteen_move
	lda fifteen_gap_x
	sta gfx_cursor_x
	lda fifteen_gap_y
	sta gfx_cursor_y
	lda #PLAY_MOVE_TILE
	jmp change_state

	; Else, attempt to move the tile under the cursor if 'A' is pressed.

test_move:
	lda joy_pressed
	lsr
	bcc done
	lda fifteen_gap_x
	sta tile_x
	lda fifteen_gap_y
	sta tile_y
	lda gfx_cursor_x
	ldy gfx_cursor_y
	jsr fifteen_move
	bne done
	lda #PLAY_MOVE_TILE
	jmp change_state

done:
	rts

.endproc

.endproc



;
; 'PLAY_MOVE_TILE' state
;
.proc move_tile

.proc init

	; Play the tile movement SFX.

	lda #SND_SFX0
	jsr muse_play

	; Initialize the tile sprite. Note that the tile sprite starts under
	; the cursor and must move to the new position of the tile that was
	; moved.

	lda gfx_cursor_x
	sta gfx_tile_sx
	lda gfx_cursor_y
	sta gfx_tile_sy
	lda tile_x
	sta gfx_tile_x
	lda tile_y
	sta gfx_tile_y
	jsr gfx_init_tile_spr
	jsr gfx_pos_tile_spr

	; Erase the moved tile from the background.

	lda gfx_cursor_x
	ldy gfx_cursor_y
	jsr gfx_erase_tile_bgd

	; Update and draw the number of moves used by the player.

	lda moves
	cmp #<MAX_MOVES
	bne update_moves
	lda moves + 1
	cmp #>MAX_MOVES
	beq done

update_moves:
	inc moves
	bne draw_moves
	inc moves + 1

draw_moves:
	lda moves
	ldy moves + 1
	jmp gfx_draw_moves

done:
	rts

.endproc

.proc update

	; Update the tile sprite.

	jsr gfx_update_tile_spr
	beq done
	jmp gfx_pos_tile_spr

	; Continue play if the tile sprite has reached its destination.

done:
	lda gfx_tile_x
	ldy gfx_tile_y
	jsr gfx_draw_tile_bgd	; Draw the moved tile to the background
	jsr gfx_erase_tile_spr	; Erase the tile sprite

	; If the puzzle is solved, switch to 'solved' state.

	jsr fifteen_solved
	bne unsolved
	lda #PLAY_PUZZLE_SOLVED
	jmp change_state

	; Else, go back to 'wait_action' state.

unsolved:
	lda #PLAY_WAIT_ACTION
	jmp change_state

.endproc

.endproc



;
; 'PLAY_PUZZLE_SOLVED' state
;
.proc puzzle_solved

.proc init

	lda #0			; Disable the auto-solver and pausing
	sta play_flags
	lda #SND_MUS1		; Play the puzzle solved music
	jsr muse_play
	lda #GFX_MSG_SOLVED	; Draw the solved message to the screen
	jmp gfx_draw_msg

.endproc

.proc update

	; If the solved music is still playing, then continue waiting.

	muse_music_playing
	bne done

	; Else, continue waiting until the player presses either 'A' or 'B'.

	lda joy_pressed
	and #$03
	beq done

	; Else, generate a new puzzle and begin playing.

	lda #PLAY_NEW_PUZZLE
	jmp change_state

done:
	rts

.endproc

.endproc



.proc play_init

	; Draw the playing state's PackBits encoded name table to both name
	; tables.

	lda #$20
	sta PPUADDR
	sta gfx_nt
	lda #$00
	sta PPUADDR
	sta play_flags		; Initialize the play state flags
	sta gfx_cursor_x	; Initialize the cursor to top left-hand corner
	sta gfx_cursor_y	; of the puzzle board
	lda #<play_pkb
	sta pkb_src
	lda #>play_pkb
	sta pkb_src + 1
	jsr pkb_to_vram		; Write background to the first name table
	lda #$24
	sta PPUADDR
	lda #$00
	sta PPUADDR
	lda #<play_pkb
	sta pkb_src
	lda #>play_pkb
	sta pkb_src + 1
	jsr pkb_to_vram		; Write background to the second name table
	jsr gfx_init_cursor	; Initialize the cursor sprite
	lda #PLAY_NEW_PUZZLE	; Change the play state to 'new_puzzle'
	jmp change_state

play_pkb:
	.incbin "play.pkb"

.endproc



.proc play_update

	nmi_wait		; Wait for the end of the next NMI
	jsr joy_update1		; Read the current joypad state

	; If play is is not paused, continue to test input.

	lda joy_pressed
	bit play_flags
	bpl test_pause

	; Else, if the player has pressed 'Start' then unpause the game and
	; the background music.

	and #$08
	bne unpause
	jmp update_done

unpause:
	muse_toggle_music
	lda play_flags
	and #$7F
	sta play_flags
	bpl test_solver

	; Test if the player has pressed 'Start' and pause play if so.

test_pause:
	and #$08
	beq test_solver
	muse_toggle_music
	lda #SND_SFX1
	jsr muse_play
	lda play_flags
	ora #$80
	sta play_flags
	bmi update_done

	; If the auto-solver is not enabled, continue to test input.

test_solver:
	lda joy_pressed
	bit play_flags
	bvc test_solver_on

	; Else, if the player has pressed 'Select' then disable the auto-
	; solver.

	and #$04
	beq test_done
	lda play_flags		; Disable the auto-solver
	and #$BF
	sta play_flags
	lda #GFX_MSG_CLEAR	; Clear the message display area
	jsr gfx_draw_msg
	jmp test_done

	; Test if the player has pressed 'Select' and enable the auto-solver
	; if so.

test_solver_on:
	and #$04
	beq test_dir
	lda play_state		; Skip if the puzzle is already solved
	cmp #PLAY_PUZZLE_SOLVED
	beq test_dir
	jsr fifteen_init_solver	; Else, initialize the auto-solver
	lda #GFX_MSG_SOLVING	; Draw the solving message to the screen
	jsr gfx_draw_msg
	lda play_flags		; Set the auto-solver flag
	ora #$40
	sta play_flags
	bne test_done

	; Test the directional buttons and move the cursor if so.

test_dir:
	jsr joy_repeat1		; Only apply repeat for directional buttons
	lda joy_pressed		; Test for move cursor right
	bpl test_left
	ldy gfx_cursor_x
	cpy #FIFTEEN_WIDTH - 1
	beq test_left
	inc gfx_cursor_x

test_left:
	asl			; Test for move cursor left
	bpl test_down
	ldy gfx_cursor_x
	beq test_down
	dec gfx_cursor_x

test_down:
	asl			; Test for move cursor down
	bpl test_up
	ldy gfx_cursor_y
	cpy #FIFTEEN_HEIGHT - 1
	beq test_up
	inc gfx_cursor_y

test_up:
	asl			; Test for move cursor up
	bpl test_done
	ldy gfx_cursor_y
	beq test_done
	dec gfx_cursor_y

test_done:
	jsr gfx_update_cursor	; Update and position the cursor
	jsr gfx_pos_cursor
	jsr update		; Call the current state's update subroutine

update_done:

	dec nmi_draw		; Inform the NMI that its time for a redraw
	rts

update:
	lda play_state
	asl
	tax
	lda update_table + 1, x
	pha
	lda update_table, x
	pha
	rts

update_table:
	.addr new_puzzle::update - 1
	.addr wait_action::update - 1
	.addr move_tile::update - 1
	.addr puzzle_solved::update - 1

.endproc


;
; Changes the current game state and calls its initialization function.
;
; In:
;	a = The playing state to change to
;
; Destroyed: Assume everything
;
.proc change_state

	sta play_state
	asl
	tax
	lda init_table + 1, x
	pha
	lda init_table, x
	pha
	rts

init_table:
	.addr new_puzzle::init - 1
	.addr wait_action::init - 1
	.addr move_tile::init - 1
	.addr puzzle_solved::init - 1

.endproc

