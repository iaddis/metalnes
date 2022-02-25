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
.dword $8B53FA6E
.dword $63FE045F
.dword $B6C7BA63
.dword $B374C422
.dword $A0C0220A
.dword $FB4F13E9
.dword $771C915B
.dword $71675CF6
.dword $DD12400E
.dword $808A4BF5
.dword $54FC683C
.dword $46392060
.dword $6C804870
.dword $EF2A694B
.dword $BFA7B86E
.dword $AAE1A597
.dword $D37CC347
.dword $539CBA74
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
.dword $E62C1F92
.dword $A3FD5073
.dword $68875F5F
.dword $47579BB5
