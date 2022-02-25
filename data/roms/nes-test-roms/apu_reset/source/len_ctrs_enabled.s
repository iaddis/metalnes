; At power and reset, length counters are enabled.

CUSTOM_RESET=1
.include "shell.inc"
.include "run_at_reset.s"

nv_res log

reset:
	; Begin mode 0 and enable channels
	setb $4017,$00
	setb $4015,$0F
	
	; Try to load length counters
	
	setb $4001,$7F
	setb $4002,$FF
	setb $4003,$18
	
	setb $4005,$7F
	setb $4006,$FF
	setb $4007,$18
	
	setb $400A,$FF
	setb $400B,$18
	
	setb $400C,$00
	setb $400E,$00
	setb $400F,$18
	
	; Delay and see whether they decremented to zero
	delay 29830*2
	
	lda $4015
	sta log
	
	jmp std_reset

main:   jsr num_resets
	bne first_reset
	
power:  set_test 2,"At power, length counters should be enabled"
	lda log
	and #$0F
	jne test_failed
	
	jsr prompt_to_reset
	setb $4000,$00
	setb $4004,$00
	setb $4008,$FF  ; disable triangle's counter
	setb $400B,$FF
	setb $400C,$00
	jmp wait_reset

first_reset:
	set_test 3,"At reset, length counters should be enabled, triangle unaffected"
	lda log
	and #$0F
	cmp #$04
	jne test_failed
	
	jmp tests_passed
