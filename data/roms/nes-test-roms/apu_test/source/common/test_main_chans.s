zp_byte chan_idx
zp_byte chan_off
zp_byte chan_bit

; Calls routine for the four main channels
.macro test_main_chans routine
	ldy #0          ; channel index:  0-3
:       sty chan_idx
	
	tya
	asl a
	asl a
	tax
	stx chan_off
	
	setb {$4000,x},$11      ; near-silent
	lda chan_bits,y
	sta chan_bit
	sta SNDCHN
	
	; A = chan_bit
	; X = chan_off
	; Y = chan_idx
	jsr routine
	
	ldy chan_idx
	iny
	cpy #4
	bne :-
.endmacro

.align 4
chan_bits:
	.byte $01,$02,$04,$08
