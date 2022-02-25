.include "instr_test.inc"

instrs:
	entry $40,"RTI"
instrs_size = * - instrs

instr_template:
	rti
	inx
	inx
	jmp instr_done
instr_template_size = * - instr_template

zp_res operand

.define check_out check_paxyso

.macro set_in
	; Put return address and P on stack
	ldx in_s
	inx
	lda operand
	sta $100,x
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
.dword $F4B30222
