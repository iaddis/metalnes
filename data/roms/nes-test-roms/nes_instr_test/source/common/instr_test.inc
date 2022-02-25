.include "shell.inc"
.include "crc_fast.s"

; Instructions to test
.macro entry op,name
	.byte op,0
	.local Addr
	.word Addr
	seg_data "STRINGS",{Addr: .byte name,0}
.endmacro

zp_byte in_p
zp_byte in_a
zp_byte in_x
zp_byte in_y
zp_byte in_s

values:
	.byte 0,1,2,$40,$7F,$80,$81,$FF
values_size = * - values
	.byte 0,1,2,$40,$7F,$80,$81,$FF

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

.macro check_paxyso
	php
	cld ; limits effect of buggy emulator
	jsr update_crc_fast
	pla
	jsr update_crc_fast
	txa
	jsr update_crc_fast
	tya
	jsr update_crc_fast
	tsx
	txa
	jsr update_crc_fast
	lda operand
	jsr update_crc_fast
.endmacro
