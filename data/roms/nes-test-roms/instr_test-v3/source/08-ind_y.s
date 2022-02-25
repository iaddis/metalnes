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
.dword $C34014B1
.dword $AD463B54
.dword $7CAFE848
.dword $95D8B24C
.dword $0899C34E
.dword $7628348A
.dword $43F06A17
.dword $9908C2BA
.dword $539E725A
.dword $6C3D4FCF
.dword $459EFD3F
.dword $189E2939
.dword $B1EC2D77
.dword $2B0E7B04
.dword $43FB4CDE
