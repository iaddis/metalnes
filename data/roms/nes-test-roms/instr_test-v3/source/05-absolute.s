.include "instr_test.inc"

instrs:
	entry $AD,"LDA a" ; AXY = a
	entry $AE,"LDX a"
	entry $AC,"LDY a"
	
	entry $8D,"STA a" ; a = AXY
	entry $8E,"STX a"
	entry $8C,"STY a"
	
	entry $EE,"INC a" ; a = op a
	entry $CE,"DEC a"
	entry $0E,"ASL a"
	entry $4E,"LSR a"
	entry $2E,"ROL a"
	entry $6E,"ROR a"
	
	entry $6D,"ADC a" ; A = A op a
	entry $ED,"SBC a"
	entry $0D,"ORA a"
	entry $2D,"AND a"
	entry $4D,"EOR a"
	
	entry $CD,"CMP a" ; AXY op a
	entry $2C,"BIT a"
	entry $EC,"CPX a"
	entry $CC,"CPY a"
.ifndef OFFICIAL_ONLY
	entry $0C,"TOP abs"
	
	entry $0F,"SLO abs"
	entry $2F,"RLA abs"
	entry $4F,"SRE abs"
	entry $6F,"RRA abs"
	entry $8F,"AAX abs"
	entry $AF,"LAX abs"
	entry $CF,"DCP abs"
	entry $EF,"ISC abs"
.endif
instrs_size = * - instrs

operand = $2FE

instr_template:
	lda operand
	jmp instr_done
instr_template_size = * - instr_template

.define set_in    set_paxyso
.define check_out check_paxyso

.include "instr_test_end.s"

test_values:
	test_normal
	rts

correct_checksums:
.dword $5D5728B8
.dword $EA228F76
.dword $7C0C60CB
.dword $47422599
.dword $5AC36C4F
.dword $34B566BB
.dword $2FEC251E
.dword $2D40B32D
.dword $13852B6A
.dword $53AEB6C8
.dword $5F3FDB23
.dword $DC0B06BF
.dword $49288BFC
.dword $14C7EA46
.dword $42684E66
.dword $EA1D7F06
.dword $512F9D2A
.dword $70AA1B34
.dword $59C741E9
.dword $D3DC4002
.dword $6675067C
.dword $6CB13BC0
.dword $E8A350DF
.dword $BB4C5C90
.dword $02F88F3F
.dword $9749194D
.dword $15C5F146
.dword $D311C870
.dword $F0A1F923
.dword $46252975
