; At power and reset, $4017, $4015, and length counters work
; immediately.

CUSTOM_RESET=1
.include "shell.inc"
.include "run_at_reset.s"

nv_res log,4

reset:  
	; Triangle linear counter
	setb $4008,$FF
	setb $4017,$80
	
	setb $4015,$0F
	
	; Setup channels
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
	
	setb $4010,$8F
	setb $4013,1
	setb $4015,$1F
	
	delay 6000
	lda $4015
	sta log+0
	delay 2000
	lda $4015
	sta log+1
	
	delay 29831*2 - 18*6 - 8016 + 14907 - 180
	lda $4015
	sta log+2
	delay 200
	lda $4015
	sta log+3
	
	jmp std_reset

main:   jsr num_resets
	bne first_reset
	
power:  set_test 2,"At power, writes should work immediately"
	jsr test
	
	jsr prompt_to_reset
	setb $4013,2
	setb $4015,$00
	setb $4017,$00
	jmp wait_reset

first_reset:
	set_test 3,"At reset, writes should work immediately"
	jsr test
	
	jmp tests_passed

test:
	lda log+0
	and #$DF
	cmp #$1F
	jne test_failed
	lda log+1
	and #$DF
	cmp #$8F
	jne test_failed
	lda log+2
	and #$4F
	cmp #$0F
	jne test_failed
	lda log+3
	and #$0F
	jne test_failed
	rts
