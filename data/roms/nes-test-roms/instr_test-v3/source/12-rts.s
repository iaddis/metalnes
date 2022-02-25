.include "instr_test.inc"

instrs:
	entry $60,"RTS"
instrs_size = * - instrs

instr_template:
	rts
	inx
	inx
	jmp instr_done
instr_template_size = * - instr_template

operand = in_a

.define check_out check_paxyso

.macro set_in
	; Put return address on stack
	ldx in_s
	inx
	lda #<(instr+1)
	sta $100,x
	inx
	lda #>(instr+1)
	sta $100,x
	
	set_paxyso
.endmacro

.include "instr_test_end.s"

test_values:
	test_normal
	rts

correct_checksums:
.dword $E1EB954A
