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
.dword $B129E6BE
.dword $965A320E
.dword $905D41EE
.dword $51FA7AD7
.dword $A60AE5B1
.dword $8FA16B44
.dword $D311C870
.dword $453F27CD
.dword $4F91B466
.dword $604DB29C
.dword $4BCFE982
.dword $8E0D1602
.dword $26DBEBEC
.dword $49214BA2
.dword $8C4FB749
.dword $37962351
.dword $99E7216C
.dword $6408D38D
.dword $C334A2A7
.dword $55827CC6
.dword $55827CC6
.dword $55827CC6
.dword $55827CC6
.dword $55827CC6
.dword $55827CC6
.dword $55827CC6
