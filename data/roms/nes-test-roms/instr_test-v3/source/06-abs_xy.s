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
.dword $8B53FA6E
.dword $ED606C6A
.dword $63FE045F
.dword $B6C7BA63
.dword $B374C422
.dword $CE7ABA24
.dword $771C915B
.dword $71675CF6
.dword $DD12400E
.dword $808A4BF5
.dword $54FC683C
.dword $46392060
.dword $6C804870
.dword $CD587E36
.dword $EF2A694B
.dword $E0D6DFA5
.dword $BFA7B86E
.dword $D37908FE
.dword $AAE1A597
.dword $7F54BFF0
.dword $D37CC347
.dword $94C851D4
.dword $539CBA74
.dword $56D05064
.dword $FEBE0BFF
.dword $FEBE0BFF
.dword $FEBE0BFF
.dword $FEBE0BFF
.dword $FEBE0BFF
.dword $FEBE0BFF
.dword $14AA08E6
.dword $BF4BF92E
.dword $C2207461
.dword $F34758B1
.dword $7DA6ABE2
.dword $E62C1F92
.dword $A3FD5073
.dword $234A2B6E
.dword $84467B6B
.dword $CED1ADC0
.dword $6655FFC6
.dword $9E821698
.dword $47579BB5
.dword $49B176EB
.dword $A72DC04B
