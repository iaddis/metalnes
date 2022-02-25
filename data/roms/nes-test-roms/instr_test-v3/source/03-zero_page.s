.include "instr_test.inc"

instrs:
	entry $A5,"LDA z" ; AXY = z
	entry $A6,"LDX z"
	entry $A4,"LDY z"
	
	entry $85,"STA z" ; z = AXY
	entry $86,"STX z"
	entry $84,"STY z"
	
	entry $E6,"INC z" ; z = op z
	entry $C6,"DEC z"
	entry $06,"ASL z"
	entry $46,"LSR z"
	entry $26,"ROL z"
	entry $66,"ROR z"
	
	entry $65,"ADC z" ; A = A op z
	entry $E5,"SBC z"
	entry $05,"ORA z"
	entry $25,"AND z"
	entry $45,"EOR z"
	
	entry $24,"BIT z" ; AXY op z
	entry $C5,"CMP z"
	entry $E4,"CPX z"
	entry $C4,"CPY z"
.ifndef OFFICIAL_ONLY
	entry $04,"DOP z"
	entry $44,"DOP z"
	entry $64,"DOP z"
	
	entry $07,"SLO z"
	entry $27,"RLA z"
	entry $47,"SRE z"
	entry $67,"RRA z"
	entry $87,"AAX z"
	entry $A7,"LAX z"
	entry $C7,"DCP z"
	entry $E7,"ISC z"
.endif
instrs_size = * - instrs

operand = <$FE

instr_template:
	lda <operand
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
.dword $59C741E9
.dword $70AA1B34
.dword $D3DC4002
.dword $6675067C
.dword $6CB13BC0
.dword $6CB13BC0
.dword $6CB13BC0
.dword $E8A350DF
.dword $BB4C5C90
.dword $02F88F3F
.dword $9749194D
.dword $15C5F146
.dword $D311C870
.dword $F0A1F923
.dword $46252975
