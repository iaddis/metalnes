; Randomly reads and writes to OAM, ensuring that
; all reads match predicted, and that final content
; also matches. Refreshes OAM periodically while
; running to avoid DRAM fade.

.include "shell.inc"
.include "crc_fast.s"

refresh_period = 150

zp_byte counter
bss_res mirror,256

main:
	lda #1
	jsr init_random
	jsr wait_vbl
	setb PPUCTRL,0
	setb PPUMASK,0
	
	; Fill with initial data
	ldx #0
	stx SPRADDR
:       lda #$FF
	sta SPRDATA
	and masks,x
	sta mirror,x
	inx
	bne :-
	
	; Do hundreds of runs of random operations,
	; with refresh of OAM between each
	loop_n_times do_rand,255
	
	jsr reset_crc
	
print_final:
	
	; Verify final data
	ldx #0
:       stx SPRADDR
	lda SPRDATA
	eor mirror,x
	sta mirror,x
	dex
	bne :-
	
	; Print log
	ldx #0
@loop:  lda mirror,x
	print_cc beq,'-','*'
	
	txa
	and #$0F
	cmp #$0F
	bne :+
	jsr print_newline
:
	inx
	bne @loop
	
	check_crc $22FBFEC7
	jmp tests_passed

do_rand:
	; Refresh data
	ldx #0
	stx SPRADDR
:       lda SPRDATA
	sta SPRDATA
	inx
	bne :-
	
	; Randomly set addr, write, and read,
	; verifying reads against mirror
	setb counter,refresh_period
@loop:  jsr next_random
	and #$0F
	tax
	stx SPRADDR
	jsr next_random
	and #$87
	tay
	bmi @read
:       jsr next_random
	sta SPRDATA
	and masks,x
	sta mirror,x
	inx
	dey
	bpl :-
	jmp @next
@read:
:       lda SPRDATA
	cmp mirror,x
	bne print_final
	iny
	bmi :-
@next:  dec counter
	bne @loop
	
	rts
	
masks:
	.repeat $100/4
		.byte $FF,$FF,$E3,$FF
	.endrepeat
	
init_random:
	pha
	jsr init_crc_fast
	pla
	jsr update_crc_fast
	rts

next_random:
	lda #$55
	jmp update_crc_fast
