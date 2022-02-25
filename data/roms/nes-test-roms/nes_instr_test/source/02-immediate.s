;CALIBRATE=1
.include "instr_test.inc"

instrs:
	entry $A9,"LDA #n" ; AXY = #n
	entry $A2,"LDX #n"
	entry $A0,"LDY #n"
	
	entry $69,"ADC #n" ; A = A op #n
	entry $E9,"SBC #n"
	entry $09,"ORA #n"
	entry $29,"AND #n"
	entry $49,"EOR #n"
	
	entry $C9,"CMP #n" ; AXY op #n
	entry $E0,"CPX #n"
	entry $C0,"CPY #n"
.ifndef OFFICIAL_ONLY
	entry $EB,"SBC #n"
	
	entry $80,"DOP #n"
	entry $82,"DOP #n"
	entry $89,"DOP #n"
	entry $C2,"DOP #n"
	entry $E2,"DOP #n"
	
	entry $0B,"AAC #n"
	entry $2B,"AAC #n"
	entry $4B,"ASR #n"
	entry $6B,"ARR #n"
	entry $AB,"ATX #n"
	entry $CB,"AXS #n"
.endif
instrs_size = * - instrs

operand = instr+1

instr_template:
	lda #0
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
.dword $86046BF5
.dword $999E9E48
.dword $DC562F7E
.dword $6BF08A00
.dword $D2A32FD6
.dword $7DF1D50B
.dword $751D8339
.dword $A451BD7A
.dword $999E9E48
.dword $ACE6BAE4
.dword $ACE6BAE4
.dword $ACE6BAE4
.dword $ACE6BAE4
.dword $ACE6BAE4
.dword $DC37BE89
.dword $DC37BE89
.dword $C07C3593
.dword $49618FA8
.dword $1D8ACEF5
.dword $1240499F
