.include "instr_test.inc"

instrs:
	entry $4C,"JMP"
	entry $20,"JSR"
instrs_size = * - instrs

instr_template:
	jsr :+
	inx
:       inx
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
.dword $4F91B466
.dword $D794E018
