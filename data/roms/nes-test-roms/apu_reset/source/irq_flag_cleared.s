; At power and reset, IRQ flag is clear.

CUSTOM_RESET=1
.include "shell.inc"
.include "run_at_reset.s"

nv_res flag

reset:  lda $4015
	sta flag
	jmp std_reset

main:   jsr num_resets
	bne was_reset
	
power:  set_test 2,"At power, flag should be clear"
	lda flag
	and #$40
	jne test_failed
	
	jsr prompt_to_reset
	setb $4017,$00  ; get flag set
	delay 29850
	setb $4017,$80  ; stop setting flag
	jmp wait_reset

was_reset:
	set_test 3,"At reset, flag should be clear"
	lda flag
	and #$40
	jne test_failed
	
	jmp tests_passed
