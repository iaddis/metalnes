;CALIBRATE=1
.include "instr_test.inc"

instrs:
	entry $B1,"LDA (z),Y" ; A = (z),Y
	
	entry $91,"STA (z),Y" ; (z),Y = A
	
	entry $D1,"CMP (z),Y" ; A op (z),Y
	
	entry $11,"ORA (z),Y" ; A = A op (z),Y
	entry $F1,"SBC (z),Y"
	entry $71,"ADC (z),Y"
	entry $31,"AND (z),Y"
	entry $51,"EOR (z),Y"
.ifndef OFFICIAL_ONLY
	entry $13,"SLO (z),Y"
	entry $33,"RLA (z),Y"
	entry $53,"SRE (z),Y"
	entry $73,"RRA (z),Y"
	entry $B3,"LAX (z),Y"
	entry $D3,"DCP (z),Y"
	entry $F3,"ISC (z),Y"
.endif
instrs_size = * - instrs

address = <$FF
operand = $2FF

instr_template:
	lda (address),y
	jmp instr_done
instr_template_size = * - instr_template

.macro set_in
	lda values+1,y
	sta operand+1
	
	lda values+2,y
	sta operand+2
	
	set_paxyso
.endmacro

.macro check_out
	check_paxyso
	
	lda operand+1
	jsr update_crc_fast
	
	lda operand+2
	jsr update_crc_fast
	
	lda address
	jsr update_crc_fast
.endmacro

.include "instr_test_end.s"

test_values:
	lda #<operand
	sta address
	lda #>operand
	sta <(address+1)
	
	lda #0
	jsr :+
	lda #1
:       sta in_y
	test_normal
	rts

correct_checksums:
.dword $A70CC617
.dword $C51FB2A2
.dword $9A5FD381
.dword $7B2B686A
.dword $80320709
.dword $E04726D5
.dword $9C19B6C7
.dword $C2B50439
.dword $1A7D3BB9
.dword $5FA670D4
.dword $849D6935
.dword $12656CBF
.dword $964F3A4A
.dword $452006A5
.dword $D8F09C96
