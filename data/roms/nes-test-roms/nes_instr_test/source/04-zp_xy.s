;CALIBRATE=1
.include "instr_test.inc"

instrs:
	entry $B5,"LDA z,X" ; AXY = z,XY
	entry $B4,"LDY z,X"
	entry $B6,"LDX z,Y"
	
	entry $95,"STA z,X" ; z,XY = AXY
	entry $94,"STY z,X"
	entry $96,"STX z,Y"
	
	entry $F6,"INC z,X" ; z,XY = op z,XY
	entry $D6,"DEC z,X"
	entry $16,"ASL z,X"
	entry $56,"LSR z,X"
	entry $36,"ROL z,X"
	entry $76,"ROR z,X"
	
	entry $75,"ADC z,X" ; A = A op z,XY
	entry $F5,"SBC z,X"
	entry $15,"ORA z,X"
	entry $35,"AND z,X"
	entry $55,"EOR z,X"
	
	entry $D5,"CMP z,X" ; A op z,XY
		
.ifndef OFFICIAL_ONLY
	entry $14,"DOP z,X"
	entry $34,"DOP z,X"
	entry $54,"DOP z,X"
	entry $74,"DOP z,X"
	entry $D4,"DOP z,X"
	entry $F4,"DOP z,X"

	entry $17,"SLO z,X"
	entry $37,"RLA z,X"
	entry $57,"SRE z,X"
	entry $77,"RRA z,X"
	entry $D7,"DCP z,X"
	entry $F7,"ISC z,X"
	
	entry $97,"AAX z,Y"
	entry $B7,"LAX z,Y"
.endif
instrs_size = * - instrs

operand = <$FE

instr_template:
	lda <operand
	jmp instr_done
instr_template_size = * - instr_template

.macro set_in
	lda values+1,y
	sta <(operand+1)
	
	lda values+2,y
	sta <(operand+2)
	
	set_paxyso
.endmacro

.macro check_out
	check_paxyso
	
	lda <(operand+1)
	jsr update_crc_fast
	
	lda <((operand+2)&$FF)
	jsr update_crc_fast
.endmacro

.include "instr_test_end.s"

test_values:
	lda #1
	jsr :+
	lda #2
:       sta in_x
	eor #3
	sta in_y
	test_normal
	rts

correct_checksums:
.dword $E9468A6E
.dword $4FA75F54
.dword $19F17935
.dword $D7775153
.dword $5054FA78
.dword $026E0DE7
.dword $1DD34BF8
.dword $4CF654EB
.dword $167DC608
.dword $7989FBE2
.dword $70451E61
.dword $ED3AA6EF
.dword $E5328CF1
.dword $6FC54B7A
.dword $05331E96
.dword $71FB6ACE
.dword $0CA28045
.dword $A8D5E376
.dword $EE62210F
.dword $EE62210F
.dword $EE62210F
.dword $EE62210F
.dword $EE62210F
.dword $EE62210F
.dword $E893AB95
.dword $8946938D
.dword $5C5BC0E7
.dword $2B4CFDCF
.dword $3203662F
.dword $92BD9042
.dword $27A8A6AF
.dword $F6E1B339
