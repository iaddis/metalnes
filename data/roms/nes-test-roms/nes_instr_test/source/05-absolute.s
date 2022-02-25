;CALIBRATE=1
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
.dword $7DF1D50B
.dword $C0066908
.dword $751D8339
.dword $A451BD7A
.dword $ACE6BAE4
.dword $7CA30777
.dword $8254F5DE
.dword $A75B33F1
.dword $6DB4854B
.dword $466B9DCC
.dword $1D8ACEF5
.dword $E44BA262
.dword $BD2619BF
