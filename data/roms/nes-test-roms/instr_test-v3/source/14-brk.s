CUSTOM_IRQ = 1
.include "instr_test.inc"

zp_byte p_inside_brk

irq:    pha
	php
	pla
	sta p_inside_brk
	pla
	rti
	
instrs:
	entry $00,"BRK"
instrs_size = * - instrs

instr_template:
	brk
	inx
	inx
	jmp instr_done
instr_template_size = * - instr_template

operand = in_a

.macro set_in
	set_stack
	set_paxyso
.endmacro

.macro check_out
	; By looking at stack, we verify
	; values BRK pushed on it
	check_paxyso
	check_stack
	lda p_inside_brk
	jsr update_crc_fast
.endmacro

.include "instr_test_end.s"

test_values:
	test_normal
	rts

correct_checksums:
.dword $1392F39C
