.include "instr_test.inc"

instrs:
	entry $A1,"LDA (z,X)" ; A = (z,X)
	
	entry $81,"STA (z,X)" ; (z,X) = A
	
	entry $C1,"CMP (z,X)" ; A op (z,X)
	
	entry $61,"ADC (z,X)" ; A = A op (z,X)
	entry $E1,"SBC (z,X)"
	entry $01,"ORA (z,X)"
	entry $21,"AND (z,X)"
	entry $41,"EOR (z,X)"
.ifndef OFFICIAL_ONLY
	entry $03,"SLO (z,X)"
	entry $23,"RLA (z,X)"
	entry $43,"SRE (z,X)"
	entry $63,"RRA (z,X)"
	entry $83,"AAX (z,X)"
	entry $A3,"LAX (z,X)"
	entry $C3,"DCP (z,X)"
	entry $E3,"ISC (z,X)"
.endif
instrs_size = * - instrs

address = <$FF
operand = $2FF

instr_template:
	lda (address,x)
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
	
	lda #<(operand+1)
	sta <(address+2)
	lda #>(operand+1)
	sta <(address+3)
	
	; Be sure X doesn't have values other than
	; 0 or 2
	lda #0
	jsr :+
	lda #2
:       sta in_x
	lda #$A5
	sta address+1
	sta address+2
	sta address+3
	test_normal
	rts

correct_checksums:
.dword $C7123EFB
.dword $A914111E
.dword $78FDC202
.dword $727A1EC0
.dword $0CCBE904
.dword $918A9806
.dword $47A2405D
.dword $9D5AE8F0
.dword $57CC5810
.dword $686F6585
.dword $41CCD775
.dword $1CCC0373
.dword $54931D9E
.dword $D221ACE3
.dword $2F5C514E
.dword $47A96694
