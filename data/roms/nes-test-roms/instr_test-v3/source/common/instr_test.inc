REGION_FREE = 1
.include "shell.inc"
.include "crc_fast.s"

; Defines instruction to test
.macro entry op,name
	.byte op,0
	.local Addr
	.word Addr
	seg_data RODATA,{Addr: .byte name,0}
.endmacro

; Values set_paxyso sets registers to. Set
; before calling test_values, which can then
; overwrite them if desired.
zp_byte in_p
zp_byte in_a
zp_byte in_x
zp_byte in_y
zp_byte in_s

; Temporary space for check_paxyso
zp_byte out_a
zp_byte out_x
zp_byte out_s

; Values to cycle through for registers
values:
	.byte 0,1,2,$40,$7F,$80,$81,$FF
values_size = * - values
	.byte 0,1,2,$40,$7F,$80,$81,$FF

; Sets bytes on stack around in_s
.macro set_stack
	ldx in_s
	inx
	inx
	ldy #6
:       txa
	asl
	eor #$A5
	sta $100,x
	dex
	dey
	bne :-
.endmacro

; Checksums bytes on stack around in_s
.macro check_stack
	ldx in_s
	inx
	inx
	ldy #6
:       lda $100,x
	dex
	jsr update_crc
	dey
	bne :-
.endmacro

; Sets P, A, X, Y, S, and operand
.macro set_paxyso
	ldx in_s
	txs
	lda values,y
	sta operand
	lda in_p
	pha
	lda in_a
	ldx in_x
	ldy in_y
	plp
.endmacro

; Checksums P, A, X, Y, S, and operand
.macro check_paxyso
	php
	sta out_a
	pla
	
	stx out_x
	tsx
	stx out_s
	ldx saved_s
	txs
	
	cld
	jsr update_crc_fast
	lda out_a
	jsr update_crc_fast
	lda out_x
	jsr update_crc_fast
	tya
	jsr update_crc_fast
	lda out_s
	jsr update_crc_fast
	lda operand
	jsr update_crc_fast
.endmacro
