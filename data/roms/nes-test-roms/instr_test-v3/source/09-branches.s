.include "instr_test.inc"

instrs:
	entry $90,"BCC r" ; PC = PC op flags
	entry $50,"BVC r"
	entry $D0,"BNE r"
	entry $30,"BMI r"
	entry $10,"BPL r"
	entry $F0,"BEQ r"
	entry $B0,"BCS r"
	entry $70,"BVS r"
instrs_size = * - instrs

zp_byte operand

instr_template:
	bne :+
	sta operand
:       jmp instr_done
instr_template_size = * - instr_template

values2:
	.byte 0,$FF,$01,$02,$04,$08,$10,$20,$40,$80
values2_size = * - values2

.macro set_in
	sta in_p
	set_paxyso
.endmacro

.define check_out check_paxyso

.include "instr_test_end.s"

test_values:
	test_normal
	rts

correct_checksums:
.dword $70FED976
.dword $423DD402
.dword $EFA864F5
.dword $987425C4
.dword $3095ECE9
.dword $4749ADD8
.dword $D81F105B
.dword $EADC1D2F
