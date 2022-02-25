;CALIBRATE=1
.include "instr_test.inc"

instrs:
	entry $BD,"LDA a,X" ; AXY = a,XY
	entry $B9,"LDA a,Y"
	entry $BC,"LDY a,X"
	entry $BE,"LDX a,Y"
	
	entry $9D,"STA a,X" ; a,XY = A
	entry $99,"STA a,Y"
	
	entry $FE,"INC a,X" ; a,XY = op a,XY
	entry $DE,"DEC a,X"
	entry $1E,"ASL a,X"
	entry $5E,"LSR a,X"
	entry $3E,"ROL a,X"
	entry $7E,"ROR a,X"
	
	entry $7D,"ADC a,X" ; A = A op a,XY
	entry $79,"ADC a,Y"
	entry $FD,"SBC a,X"
	entry $F9,"SBC a,Y"
	entry $1D,"ORA a,X"
	entry $19,"ORA a,Y"
	entry $3D,"AND a,X"
	entry $39,"AND a,Y"
	entry $5D,"EOR a,X"
	entry $59,"EOR a,Y"
	
	entry $DD,"CMP a,X" ; A op a,XY
	entry $D9,"CMP a,Y"
.ifndef OFFICIAL_ONLY
	entry $1C,"TOP abs,X"
	entry $3C,"TOP abs,X"
	entry $5C,"TOP abs,X"
	entry $7C,"TOP abs,X"
	entry $DC,"TOP abs,X"
	entry $FC,"TOP abs,X"

	entry $1F,"SLO abs,X"
	entry $3F,"RLA abs,X"
	entry $5F,"SRE abs,X"
	entry $7F,"RRA abs,X"
	entry $9C,"SYA abs,X"
	entry $DF,"DCP abs,X"
	entry $FF,"ISC abs,X"

	entry $1B,"SLO abs,Y"
	entry $3B,"RLA abs,Y"
	entry $5B,"SRE abs,Y"
	entry $7B,"RRA abs,Y"
	entry $9E,"SXA abs,Y"
	entry $BF,"LAX abs,Y"
	entry $DB,"DCP abs,Y"
	entry $FB,"ISC abs,Y"
.endif
instrs_size = * - instrs

operand = $2FE

instr_template:
	lda operand
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
.dword $7EE7005C
.dword $4FA75F54
.dword $19F17935
.dword $D7775153
.dword $A7756BFC
.dword $1DD34BF8
.dword $4CF654EB
.dword $167DC608
.dword $7989FBE2
.dword $70451E61
.dword $ED3AA6EF
.dword $E5328CF1
.dword $D287638B
.dword $6FC54B7A
.dword $8774BACC
.dword $05331E96
.dword $8DF442A1
.dword $71FB6ACE
.dword $5396E16A
.dword $0CA28045
.dword $C1F44777
.dword $A8D5E376
.dword $C32624B7
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
.dword $973A2CEA
.dword $3203662F
.dword $92BD9042
.dword $BE321B27
.dword $72EDF2C3
.dword $98728C4F
.dword $0BD391C9
.dword $CAA64F06
.dword $F6E1B339
.dword $577C9968
.dword $980F0B56
