;CALIBRATE=1
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
.dword $AB3E4F82
.dword $7B121231
.dword $E544DF3D
.dword $6C920797
.dword $D813DA7E
.dword $B656C54F
.dword $E6708F26
.dword $E7A8F852
.dword $2980FD5C
.dword $5CA561A6
.dword $354CDEB5
.dword $6C7D266C
.dword $86046BF5
.dword $999E9E48
.dword $DC562F7E
.dword $6BF08A00
.dword $D2A32FD6
.dword $C0066908
.dword $7DF1D50B
.dword $751D8339
.dword $A451BD7A
.dword $ACE6BAE4
.dword $ACE6BAE4
.dword $ACE6BAE4
.dword $7CA30777
.dword $8254F5DE
.dword $A75B33F1
.dword $6DB4854B
.dword $466B9DCC
.dword $1D8ACEF5
.dword $E44BA262
.dword $BD2619BF
