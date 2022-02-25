;CALIBRATE=1
.include "instr_test.inc"

instrs:
	entry $48,"PHA"
	entry $08,"PHP"
	
	entry $68,"PLA"
	entry $28,"PLP"
	
	entry $9A,"TXS"
	entry $BA,"TSX"
instrs_size = * - instrs

instr_template:
	pha
	jmp instr_done
instr_template_size = * - instr_template

values2:
	.byte 0,$FF,$01,$02,$04,$08,$10,$20,$40,$80
values2_size = * - values2

zp_byte operand

.macro set_in
	sta in_p
	set_paxyso
	
	; Clear bytes on stack
	stx $17F
	sty $180
	stx $181
	
	sty $1FE
	stx $1FF
	sty $100
	stx $101
	sty $102
.endmacro

zp_byte save
zp_byte save2
zp_byte save3
zp_byte save4
zp_byte save5

.macro check_out
	php
	sta save  ; A
	pla
	sta save2 ; P
	pla
	sta save3 ; PLA
	stx save4 ; X
	tsx
	stx save5 ; S
	
	ldx saved_s
	txs
	
	; Output
	tya
	jsr update_crc_fast
	
	lda save
	jsr update_crc_fast
	
	lda save2
	jsr update_crc_fast
	
	lda save3
	jsr update_crc_fast
	
	lda save4
	jsr update_crc_fast
	
	lda save5
	jsr update_crc_fast
	
	ldx in_s
	dex
	lda $100,x
	jsr update_crc_fast
	
	inx
	lda $100,x
	jsr update_crc_fast
	
	inx
	lda $100,x
	jsr update_crc_fast
.endmacro

.include "instr_test_end.s"

test_values:
	; Values for SP
	lda #$80
	jsr :+
	lda #$00
	jsr :+
	lda #$01
	jsr :+
	lda #$FF
	jsr :+
	lda #$FE
:       sta in_s
	test_normal
	rts

correct_checksums:
.dword $AA53E72F
.dword $F46D6C3F
.dword $4B0D5E27
.dword $A1AB7B53
.dword $8A5B86A7
.dword $6157E3AF
