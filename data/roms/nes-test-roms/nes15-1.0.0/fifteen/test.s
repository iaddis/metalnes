;
; File: test.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Test program for the fifteen puzzle library
;

.include "lfsr32.inc"
.include "fifteen.inc"



NUM_TESTS = 10000



.segment "ZEROPAGE"

failed:		.res 1
count:		.res 2



.segment "CODE"

;
; Reset routine used to test the fifteen puzzle library. If all tests were
; successful, then 'failed' will be set to zero, else 'failed' will be set to
; one.
;
.proc reset

	cld
	ldx #$FF
	txs
	lda #1
	sta failed
	lda #<($10000 - NUM_TESTS)
	sta count
	lda #>($10000 - NUM_TESTS)
	sta count + 1

	lda #53
	sta lfsr32
	sta lfsr32 + 1
	sta lfsr32 + 2
	sta lfsr32 + 3

loop:
	; Ensure the puzzle generator is providing solvable puzzles.

	jsr fifteen_gen
	jsr fifteen_solvable
	bcc done

	; Test the puzzle solver.

	jsr fifteen_init_solver

solve_loop:
	jsr fifteen_solved
	beq next
	jsr fifteen_solve
	jsr fifteen_move
	jmp solve_loop

next:
	inc count
	bne loop
	inc count + 1
	bne loop
	dec failed

done:
	jmp done

.endproc



;
; Dummy NMI and IRQ routines
;
; Preserved: a, x, y
;
nmi:
irq:
	rti



.segment "VECTORS"

	.addr nmi
	.addr reset
	.addr irq

