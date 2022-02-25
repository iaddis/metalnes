;CALIBRATE=1
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
	
	lda #0
	jsr :+
	lda #2
:       sta in_x
	test_normal
	rts

correct_checksums:
.dword $B9D16BC6
.dword $DBC21F73
.dword $84827E50
.dword $FE9A8B04
.dword $9EEFAAD8
.dword $65F6C5BB
.dword $82C41B16
.dword $DC68A9E8
.dword $04A09668
.dword $417BDD05
.dword $9A40C4E4
.dword $0CB8C16E
.dword $EC8492F8
.dword $AFC77201
.dword $5BFDAB74
.dword $C62D3147
