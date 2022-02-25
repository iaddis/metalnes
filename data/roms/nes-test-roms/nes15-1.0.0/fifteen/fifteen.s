;
; File: fifteen.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Fifteen puzzle subroutines and data
;
; The solver used is based on documentation and source code by 'Karl Hornell'
; found at:
; http://www.javaonthebrain.com/java/puzz15/
;

.include "lfsr32.inc"

.include "fifteen.inc"



.segment "ZEROPAGE"

fifteen_gap_x:			.res 1
fifteen_gap_y:			.res 1

; Temporary storage used by the module

temp:				.res 6

; Current position of the gap in the solver's copy of the puzzle's state

solver_gap:			.res 1

; Current position of the next move in 'solver_moves' that will be returned
; when 'fifteen_solve' is called. This is also used by the move generator to
; keep track of the end of the moves list.

solver_end:			.res 1

; Current goal the solver is trying to accomplish

solver_goal:			.res 1



.segment "BSS"

fifteen_board:			.res FIFTEEN_SIZE

; The solver's copy of the current state of the puzzle. Values greater than $7F
; are used to mark locked tiles that should not be moved by the solver.

solver_board:			.res FIFTEEN_SIZE

; List of moves to be used by the solver to accomplish its current goal. The
; end of the list is marked with a value greater than $7F. Note the size is an
; arbitrary estimate.

solver_moves:			.res 64



.segment "FIFTEENLIB"

.proc fifteen_gen

divisor = temp + 1
last_tiles = temp + 1

	; Initialize the board with the goal state randomly shuffled.

	lda fifteen_goal
	sta fifteen_board
	ldx #2

shuffle_loop:
	ldy #4
	jsr lfsr32_next
	lda lfsr32
	stx divisor
	sec

mod_loop:
	sbc divisor
	bcs mod_loop
	adc divisor		; Carry is already cleared
	tay
	lda fifteen_board, y
	sta fifteen_board - 1, x
	lda fifteen_goal - 1, x
	sta fifteen_board, y
	inx
	cpx #FIFTEEN_SIZE + 1
	bne shuffle_loop

	; Find the location of the gap and save it.

	ldx #FIFTEEN_SIZE

gap_loop:
	dex
	lda fifteen_board, x
	bne gap_loop
	txa
	and #$03
	sta fifteen_gap_x
	txa
	lsr
	lsr
	sta fifteen_gap_y

	; Find the last two tiles from the bottom-right corner backwards.

	ldx #FIFTEEN_SIZE
	ldy #2

last_loop:
	dex
	lda fifteen_board, x
	beq last_loop
	stx last_tiles - 1, y
	dey
	bne last_loop

	; If the puzzle is in an unsolvable state, reverse the last two tiles
	; on the board. This inverts the permutation's parity, thus leaving the
	; puzzle in a solvable state.

	jsr fifteen_solvable
	bcs done
	ldx last_tiles
	lda fifteen_board, x
	pha
	ldy last_tiles + 1
	lda fifteen_board, y
	sta fifteen_board, x
	pla
	sta fifteen_board, y

done:
	rts

.endproc



.proc fifteen_solvable

perm_parity = temp

	; Initialize the parity and check for inversions from the first tile
	; forward to the second to the last.

	ldx #0
	stx perm_parity

outer:

	; Count the inversions forward from the current tile. Note that we
	; don't count inversions from the puzzle's gap.

	lda fifteen_board, x
	beq cont_outer
	txa
	tay
	iny

inner:

	; If an inversion with a tile was found, invert the current parity.

	lda fifteen_board, y
	beq cont_inner
	cmp fifteen_board, x
	bcs cont_inner
	inc perm_parity

cont_inner:
	iny
	cpy #FIFTEEN_SIZE
	bne inner

cont_outer:
	inx
	cpx #FIFTEEN_SIZE - 1
	bne outer

	; Return solvability in the carry flag
	; (bit 0 of perm_parity ^ fifteen_gap_y).

	lda perm_parity
	eor fifteen_gap_y
	lsr
	rts

.endproc



.proc fifteen_move

tile_x = temp

	sta tile_x

	; If the tile to move is lined up with the gap horizontally, then that
	; tile's vertical position must be directly adjacent to the gap.

	cmp fifteen_gap_x
	bne test_ver
	tya
	sbc fifteen_gap_y		; Carry is already set
	cmp #1
	beq valid
	cmp #-1
	beq valid
	rts

	; Else, if the tile to move is lined up with the gap vertically, then
	; that tile's horizontal position must be directly adjacent to the gap.

test_ver:
	cpy fifteen_gap_y
	bne done
	sbc fifteen_gap_x		; Carry is already set
	cmp #1
	beq valid
	cmp #-1
	beq valid
	rts

	; If the move is valid, swap the tile with the gap and set the gap's
	; new position.

valid:
	tya
	asl
	asl
	adc tile_x		; Carry is already cleared
	tax
	lda fifteen_gap_y
	sty fifteen_gap_y
	asl
	asl
	adc fifteen_gap_x	; Carry is already cleared
	tay
	lda tile_x
	sta fifteen_gap_x
	lda fifteen_board, x
	sta fifteen_board, y
	lda #0			; Done last to ensure Z = 0
	sta fifteen_board, x

done:
	rts

.endproc



.proc fifteen_solved

	ldy #FIFTEEN_SIZE

loop:
	lda fifteen_board - 1, y
	cmp fifteen_goal - 1, y
	bne done
	dey
	bne loop

done:
	rts

.endproc



.proc fifteen_init_solver

lock_pos = temp

	; Copy the puzzle state to the solver's puzzle state copy.

	ldx #FIFTEEN_SIZE

copy_loop:
	lda fifteen_board - 1, x
	sta solver_board - 1, x
	dex
	bne copy_loop

	; Set the solver's current position of the gap.

	lda fifteen_gap_y
	asl
	asl
	ora fifteen_gap_x
	sta solver_gap

	; Find the goal the solver should start from, keeping track of the last
	; position read from in 'goal_table'.

	ldx #0
	stx lock_pos
	stx solver_goal

goal_loop:
	ldy goal_table, x
	lda solver_board - 1, y
	cmp goal_table, x
	bne lock_tiles
	inx
	lda goal_table, x
	bne goal_loop
	inc solver_goal
	stx lock_pos		; Save current position for lock marking
	inx
	bne goal_loop

	; Mark any tiles that are in their destination positions as locked.

lock_tiles:
	ldx lock_pos

lock_loop:
	dex
	bmi done
	ldy goal_table, x
	beq lock_loop
	lda #$FF
	sta solver_board - 1, y
	bne lock_loop

	; Finally, build the list of moves for the first goal that needs to be
	; accomplished and return.

done:
	jmp build_moves

; List of all tiles needed by each of the solver's goals

goal_table:
	.byte 1, 0
	.byte 2, 0
	.byte 3, 4, 0
	.byte 5, 0
	.byte 6, 0
	.byte 7, 8, 0
	.byte 9, 13, 0
	.byte 10, 14, 0
	.byte 11, 12, 15, 0

.endproc



.proc fifteen_solve

	; If another move is waiting on the moves list, then return it.

	ldx solver_end
	lda solver_moves, x
	bmi next_goal
	inc solver_end
	tax
	lsr
	lsr
	tay
	txa
	and #$03
	rts

	; Else, reinitialize the solver for the next goal and try again. Note
	; that 'fifteen_init_solver' is used to skip over any new goals that
	; might already be accomplished.

next_goal:
	jsr fifteen_init_solver
	jmp fifteen_solve

.endproc



;
; Fills 'solver_moves' with the moves needed to accomplish the solver's current
; goal.
;
; Out:
;	solver_end = 0
;
; Destroyed: a, x, y
;
.proc build_moves

	lda #0
	sta solver_end
	jsr build
	ldx solver_end
	lda #0
	sta solver_end
	lda #$FF
	sta solver_moves, x
	rts

build:
	lda solver_goal
	asl
	tax
	lda build_table + 1, x
	pha
	lda build_table, x
	pha
	rts

build_table:
	.addr build_1 - 1
	.addr build_2 - 1
	.addr build_3_4 - 1
	.addr build_5 - 1
	.addr build_6 - 1
	.addr build_7_8 - 1
	.addr build_9_13 - 1
	.addr build_10_14 - 1
	.addr build_15 - 1

;
; Builds the moves needed to move a tile to a specified destination, avoiding
; any locked tiles. After the tile is placed at its destination it is locked
; into place. Note that this should not be called to move a locked tile.
;
; In:
;	a = The tile to move
;	y = The position to move the tile to
; Out:
;	solver_end = The position ahead of the last move in the list
;
; Destroyed: a, x, y, temp.../+6
;
.proc move_tile

; Current position of the tile being moved

tile_pos = temp + 1

; Position the tile should be moved to

tile_goal = temp + 2

; Position the gap should be moved to

gap_goal = temp + 3

; Counters used to hold the weights of the gap's path clockwise and counter-
; clockwise around the tile being moved.

cw_weight = temp + 4
ccw_weight = temp + 5

	sty tile_goal

	; Find the position of the tile to be moved.

	ldx #$FF

find_loop:
	inx
	cmp solver_board, x
	bne find_loop
	stx tile_pos
	lda #$FF		; Lock the tile to be moved
	sta solver_board, x

move_loop:

	; If the current tile has reached its goal, then return.

	lda tile_pos
	cmp tile_goal
	bne test_goal
	rts

	; Determine the position the gap should move toward.

test_goal:
	lda tile_pos		; Reset the gap's goal
	sta gap_goal
	lda tile_goal		; Test if the gap's goal should be moved
	and #$03		; horizontally
	sta temp
	lda tile_pos
	and #$03
	cmp temp
	bcs test_goal_left	; If the tile is to the right, test left
	inc gap_goal		; Else, move the goal right
	bne move_gap_loop

test_goal_left:
	beq test_goal_y		; If lined up, test for vertical movement
	dec gap_goal		; Else, move the goal left
	bpl move_gap_loop

test_goal_y:
	lda tile_goal
	lsr
	lsr
	sta temp
	lda tile_pos
	lsr
	lsr
	cmp temp
	bcs move_goal_up	; If the tile is above, move the goal up
	lda gap_goal		; Else, move the goal down
	adc #4			; Carry is already cleared
	sta gap_goal
	bne move_gap_loop

move_goal_up:
	lda gap_goal
	sbc #4			; Carry is already set
	sta gap_goal

	; Move the gap until it is orthogonally or diagonally adjacent to the
	; tile to be moved.

move_gap_loop:

	; If the gap is adjacent to the tile to be moved, then continue on to
	; test for rotational movement.

	lda tile_pos		; Find the displacement from the tile
	sec
	sbc solver_gap
	tay
	ldx #8

gap_adj_loop:
	tya			; If the displacement is listed and is not out
	cmp round_disp - 1, x	; of bounds, then the gap is adjacent
	bne gap_adj_cont
	lda solver_gap
	and #$03
	clc
	adc round_dx - 1, x
	cmp #4
	bcc rotate_gap

gap_adj_cont:
	dex			; Else, continue backwards in the table
	bne gap_adj_loop

	; Else, move the gap closer to the current tile.

	lda gap_goal		; Test for horizontal movement
	and #$03
	sta temp
	lda solver_gap
	and #$03
	cmp temp
	bcc move_gap_right	; If the gap is to left, try right
	beq test_gap_y		; Else, if lined up, test for vertical movement
	ldx solver_gap		; Else, try to move the gap left
	dex
	lda solver_board, x
	bpl move_gap		; If not blocked by a locked tile, move left
	bmi test_gap_y		; Else, test for vertical movement

move_gap_right:
	ldx solver_gap
	inx
	lda solver_board, x
	bpl move_gap		; If not blocked by a locked tile, move right

test_gap_y:
	lda solver_gap		; Test for vertical movement
	lsr
	lsr
	sta temp
	lda gap_goal
	lsr
	lsr
	cmp temp
	bcs move_gap_down	; If the gap is above, move down
	lda solver_gap		; Else, try to move up
	sbc #3			; Carry is already cleared
	tax
	lda solver_board, x
	bpl move_gap		; If not blocked by a locked tile, move up

move_gap_down:
	lda solver_gap		; Else, just move down
	adc #3			; Carry is already set
	tax

	; Exchange the gap with the tile at its goal position and continue.

move_gap:
	ldy solver_end
	txa
	sta solver_moves, y
	inc solver_end
	ldy solver_gap
	lda solver_board, x
	sta solver_board, y
	lda #0
	sta solver_board, x
	stx solver_gap
	beq move_gap_loop
	
	; Move the gap along the shortest path either clockwise or counter-
	; clockwise around the tile to be moved.

rotate_gap:
	lda solver_gap		; If the gap is already at its goal, skip past
	cmp gap_goal		; rotational movement
	bne init_weights
	jmp cont_move

init_weights:
	lda #0			; Reset the path weight counters
	sta cw_weight
	sta ccw_weight

	; Find the gap's current displacement from the current tile starting in
	; the middle of the displacement table.

	ldx #8

find_disp_loop:
	lda tile_pos
	clc
	adc round_disp, x
	cmp solver_gap
	beq test_cw
	inx
	bne find_disp_loop

	; Test the clockwise path around the current tile.

test_cw:
	stx temp

cw_loop:
	lda tile_pos		; If the current position is over the goal,
	clc			; then the path if fully tested
	adc round_disp, x
	cmp gap_goal
	beq test_ccw
	inx
	cmp #FIFTEEN_SIZE	; If out of bounds, add highest value
	bcs cw_blocked
	tay
	lda tile_pos
	and #$03
	adc round_dx, x		; Carry is already clear
	cmp #4
	bcs cw_blocked
	lda solver_board, y	; If blocked by locked tile, add highest value
	bmi cw_blocked
	inc cw_weight		; Else, add the lowest value to the weight for
	bne cw_loop		; this path, making it more desirable

cw_blocked:
	lda cw_weight
	clc
	adc #8
	sta cw_weight
	bne cw_loop

	; Test the counter-clockwise path around the current tile.

test_ccw:
	ldx temp

ccw_loop:
	lda tile_pos		; If the current position is over the goal,
	clc			; then the path if fully tested
	adc round_disp, x
	cmp gap_goal
	beq rotate_loop
	dex
	cmp #FIFTEEN_SIZE	; If out of bounds, add highest value
	bcs ccw_blocked
	tay
	lda tile_pos
	and #$03
	adc round_dx, x		; Carry is already clear
	cmp #4
	bcs ccw_blocked
	lda solver_board, y	; If blocked by locked tile, add highest value
	bmi ccw_blocked
	inc ccw_weight		; Else, add the lowest value to the weight for
	bne ccw_loop		; this path, making it more desirable

ccw_blocked:
	lda ccw_weight
	clc
	adc #8
	sta ccw_weight
	bne ccw_loop

	; Move the gap along the shortest path found.

rotate_loop:
	lda cw_weight
	cmp ccw_weight
	bcc rotate_cw
	dec temp
	bpl cont_rotate

rotate_cw:
	inc temp

cont_rotate:
	ldx temp
	lda tile_pos
	clc
	adc round_disp, x
	ldy solver_end		; Save the move to the moves list
	sta solver_moves, y
	inc solver_end
	tay
	ldx solver_gap		; Exchange the gap with the tile to be moved
	lda solver_board, y
	sta solver_board, x
	lda #0
	sta solver_board, y
	sty solver_gap
	cpy gap_goal		; Repeat until the gap has reached its goal
	bne rotate_loop

	; Add the final move to the list and continue moving.

cont_move:
	ldy solver_end
	lda tile_pos
	sta solver_moves, y
	inc solver_end
	tay
	lda #0
	sta solver_board, y
	lda #$FF
	ldx gap_goal
	sta solver_board, x
	stx tile_pos
	sty solver_gap
	jmp move_loop

; Rotational displacement lookup table stored from the top-left going forward
; clockwise

round_disp:
	.byte -4, -3, 1, 5, 4, 3, -1, -5
	.byte -4, -3, 1, 5, 4, 3, -1, -5
	.byte -4, -3, 1, 5, 4, 3, -1, -5
	.byte -4

; Horizontal change lookup table stored from the top-left going forward
; clockwise

round_dx:
	.byte 0, 1, 1, 1, 0, -1, -1, -1
	.byte 0, 1, 1, 1, 0, -1, -1, -1
	.byte 0, 1, 1, 1, 0, -1, -1, -1
	.byte 0

.endproc

;
; Copies a predefined list of moves from memory into 'solver_moves', adjusting
; the solver's copy of the puzzle state as needed. The list provided should be
; followed by a value greater than $7F.
;
; In:
;	a = The low byte of the address of the move list
;	y = The high byte of the address of the move list
;
; Out:
;	solver_end = The position ahead of the last move in the list
;
; Destroyed: a, x, y, temp/+1
;
.proc read_moves

addr = temp

	sta addr
	sty addr + 1

loop:
	ldy #0			; Read moves until a terminating value is found
	lda (addr), y
	bmi done
	tax			; Exchange the tile to move with the gap
	ldy solver_gap
	lda solver_board, x
	sta solver_board, y
	lda #0
	sta solver_board, x
	stx solver_gap
	ldy solver_end		; Save the move to the moves list
	txa
	sta solver_moves, y
	inc solver_end
	inc addr		; Advance to the next byte and continue
	bne loop
	inc addr + 1
	bne loop

done:
	rts

.endproc



;
; Move building subroutines for each solver goal.
;
.proc build_1

	lda #1
	ldy #0
	jmp move_tile

.endproc

.proc build_2

	lda #2
	ldy #1
	jmp move_tile

.endproc

.proc build_3_4

	lda #3
	ldy #3
	jsr move_tile

	; Corner case #1:
	;	 x  x  4  3
	;	 x  x  x  x
	;	 x  x  x  x
	;	 x  x  x  x

	lda solver_board + 2
	beq test_case2
	cmp #4
	bne move4
	ldy #6
	jsr move_tile
	jmp case2

	; Corner case #2:
	;	 x  x  0  3
	;	 x  x  4  x
	;	 x  x  x  x
	;	 x  x  x  x

test_case2:
	lda solver_board + 6
	cmp #4
	bne move4

case2:
	lda #<moves0
	ldy #>moves0
	jsr read_moves
	jmp finish

move4:
	lda #4
	ldy #7
	jsr move_tile

finish:
	lda #$FF		; Lock tile 4
	sta solver_board + 7
	lda #3			; Unlock and move tile 3
	sta solver_board + 3
	ldy #2
	jsr move_tile
	lda #4			; Unlock and move tile 4
	sta solver_board + 7
	ldy #3
	jmp move_tile

moves0:
	.byte 3, 7, 11, 10, 6, 7, 11, 10, 6, 7, 3, 2, 6, 7, 11, $FF

.endproc

.proc build_5

	lda #5
	ldy #4
	jmp move_tile

.endproc

.proc build_6

	lda #6
	ldy #5
	jmp move_tile

.endproc

.proc build_7_8

	lda #7
	ldy #7
	jsr move_tile

	; Corner case #1:
	;	 x  x  x  x
	;	 x  x  8  7
	;	 x  x  x  x
	;	 x  x  x  x

	lda solver_board + 6
	beq test_case2
	cmp #8
	bne move8
	ldy #10
	jsr move_tile
	jmp case2

	; Corner case #2:
	;	 x  x  x  x
	;	 x  x  0  7
	;	 x  x  8  x
	;	 x  x  x  x

test_case2:
	lda solver_board + 10
	cmp #8
	bne move8

case2:
	lda #<moves0
	ldy #>moves0
	jsr read_moves
	jmp finish

move8:
	lda #8
	ldy #11
	jsr move_tile

finish:
	lda #$FF		; Lock tile 8
	sta solver_board + 11
	lda #7			; Unlock and move tile 7
	sta solver_board + 7
	ldy #6
	jsr move_tile
	lda #8			; Unlock and move tile 8
	sta solver_board + 11
	ldy #7
	jmp move_tile

moves0:
	.byte 7, 11, 15, 14, 10, 11, 15, 14, 10, 11, 7, 6, 10, 11, 15, $FF

.endproc

.proc build_9_13

	lda #13
	ldy #8
	jsr move_tile

	; Corner case #1:
	;	 x  x  x  x
	;	 x  x  x  x
	;	13  x  x  x
	;	 9  x  x  x

	lda solver_board + 12
	beq test_case2
	cmp #9
	bne move9
	ldy #13
	jsr move_tile
	jmp case2

	; Corner case #2:
	;	 x  x  x  x
	;	 x  x  x  x
	;	13  x  x  x
	;	 0  9  x  x

test_case2:
	lda solver_board + 13
	cmp #9
	bne move9

case2:
	lda #<moves0
	ldy #>moves0
	jsr read_moves
	jmp finish

move9:
	lda #9
	ldy #9
	jsr move_tile

finish:
	lda #$FF		; Lock tile 9
	sta solver_board + 9
	lda #13			; Unlock and move tile 13
	sta solver_board + 8
	ldy #12
	jsr move_tile
	lda #9			; Unlock and move tile 9
	sta solver_board + 9
	ldy #8
	jmp move_tile

moves0:
	.byte 8, 9, 10, 14, 13, 9, 10, 14, 13, 9, 8, 12, 13, 9, 10, $FF

.endproc

.proc build_10_14

	lda #14
	ldy #9
	jsr move_tile

	; Corner case #1:
	;	 x  x  x  x
	;	 x  x  x  x
	;	 x 14  x  x
	;	 x 10  x  x

	lda solver_board + 13
	beq test_case2
	cmp #10
	bne move10
	ldy #14
	jsr move_tile
	jmp case2

	; Corner case #2:
	;	 x  x  x  x
	;	 x  x  x  x
	;	 x 14  x  x
	;	 x  0 10  x

test_case2:
	lda solver_board + 14
	cmp #10
	bne move10

case2:
	lda #<moves0
	ldy #>moves0
	jsr read_moves
	jmp finish

move10:
	lda #10
	tay
	jsr move_tile

finish:
	lda #$FF		; Lock tile 10
	sta solver_board + 10
	lda #14			; Unlock and move tile 14
	sta solver_board + 9
	ldy #13
	jsr move_tile
	lda #10			; Unlock and move tile 10
	sta solver_board + 10
	ldy #9
	jmp move_tile

moves0:
	.byte 9, 10, 11, 15, 14, 10, 11, 15, 14, 10, 9, 13, 14, 10, 11, $FF

.endproc

.proc build_15

	; Rotate the last tiles counter-clockwise until the puzzle is solved.

loop:
	lda solver_board + 15
	bne test11
	lda solver_board + 14
	cmp #15
	beq done
	lda #<moves0
	ldy #>moves0
	jsr read_moves
	jmp loop

test11:
	lda solver_board + 11
	bne test10
	lda #<moves1
	ldy #>moves1
	jsr read_moves
	jmp loop

test10:
	lda solver_board + 10
	bne move15
	lda #<moves2
	ldy #>moves2
	jsr read_moves
	jmp loop

move15:
	lda #<moves3
	ldy #>moves3
	jsr read_moves
	jmp loop

done:
	rts

moves0:
	.byte 11

moves1:
	.byte 10

moves2:
	.byte 14

moves3:
	.byte 15, $FF

.endproc

.endproc



; Goal state of the board

fifteen_goal:
	.byte 1, 2, 3, 4
	.byte 5, 6, 7, 8
	.byte 9, 10, 11, 12
	.byte 13, 14, 15, 0

