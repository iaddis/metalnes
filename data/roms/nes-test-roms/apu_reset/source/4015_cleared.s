; At power and reset, $4015 is cleared.

CUSTOM_RESET=1
.include "shell.inc"
.include "run_at_reset.s"

nv_res log

reset:  
	; Begin mode 0
	setb $4017,$00
	
	; Start channels with zero volume
	
	setb $4000,$00
	setb $4001,$7F
	setb $4002,$FF
	setb $4003,$28
	
	setb $4004,$00
	setb $4005,$7F
	setb $4006,$FF
	setb $4007,$28
	
	setb $4008,$7F
	setb $400A,$FF
	setb $400B,$28
	
	setb $400C,$00
	setb $400E,$00
	setb $400F,$28
	
	; If any of the low 4 bits of $4015 were set, then
	; length counter of that channel would be non-zero,
	; and that bit would read back as non-zero here:
	
	lda $4015
	sta log
	
	jmp std_reset

main:   jsr num_resets
	bne first_reset
	
power:  set_test 2,"At power, $4015 should be cleared"
	lda log
	and #$0F
	jne test_failed
	
	jsr prompt_to_reset
	setb $4015,$0F
	jmp wait_reset

first_reset:
	set_test 3,"At reset, $4015 should be cleared"
	lda log
	and #$0F
	jne test_failed
	
	jmp tests_passed
