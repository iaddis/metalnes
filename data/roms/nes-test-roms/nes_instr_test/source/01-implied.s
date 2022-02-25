;CALIBRATE=1
.include "instr_test.inc"
instrs:
	entry $2A,"ROL A" ; A = op A
	entry $0A,"ASL A"
	entry $6A,"ROR A"
	entry $4A,"LSR A"
	
	entry $8A,"TXA" ; AXY = AXY
	entry $98,"TYA"
	entry $AA,"TAX"
	entry $A8,"TAY"
	
	entry $E8,"INX" ; XY = op XY
	entry $C8,"INY"
	entry $CA,"DEX"
	entry $88,"DEY"
	
	entry $38,"SEC" ; flags = op flags
	entry $18,"CLC"
	entry $F8,"SED"
	entry $D8,"CLD"
	entry $78,"SEI"
	entry $58,"CLI"
	entry $B8,"CLV"
	
	entry $EA,"NOP"
	
.ifndef OFFICIAL_ONLY
	entry $1A,"NOP"
	entry $3A,"NOP"
	entry $5A,"NOP"
	entry $7A,"NOP"
	entry $DA,"NOP"
	entry $FA,"NOP"
.endif
instrs_size = * - instrs

instr_template:
	nop
	jmp instr_done
instr_template_size = * - instr_template

operand = in_a

.define set_in    set_paxyso
.define check_out check_paxyso

.include "instr_test_end.s"

test_values:
	test_normal
	rts

correct_checksums:
.dword $013A2933
.dword $A38733B0
.dword $6EC2BCA6
.dword $763FEBC5
.dword $0FF1C1E6
.dword $5B2EB5B7
.dword $1D8ACEF5
.dword $83DC03F9
.dword $8EBDF63B
.dword $F34CAA18
.dword $9123FF08
.dword $48897445
.dword $4BE14840
.dword $E7C7ECC0
.dword $408EF097
.dword $A6AEF749
.dword $8F06AD7B
.dword $FC96AE14
.dword $28F10ADA
.dword $CA7E6620
.dword $CA7E6620
.dword $CA7E6620
.dword $CA7E6620
.dword $CA7E6620
.dword $CA7E6620
.dword $CA7E6620
