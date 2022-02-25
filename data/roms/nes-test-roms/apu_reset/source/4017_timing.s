; At power, it is as if $00 were written to $4017,
; then a 9-12 clock delay, then execution from address
; in reset vector.
;
; At reset, same as above, except last value written
; to $4017 is written again, rather than $00.
;
; The delay from when $00 was written to $4017 is
; printed. Delay after NES being powered off for a
; minute is usually 9.

CUSTOM_RESET=1
.include "shell.inc"
.include "run_at_reset.s"

nv_res count

reset:  delay 29814-2
	ldx #14
:       lda $4015
	and #$40
	bne :+
	delay 29831-4-2-2-4-2-3
	lda $4015
	dex
	bne :-
:       stx count
	jmp std_reset

main:   print_str "Delay after effective $4017 write: "
	lda count
	jsr print_dec
	jsr print_newline
	
	set_test 2,"Frame IRQ flag should be set later after power/reset"
	lda count
	cmp #13
	jge test_failed
	
	set_test 3,"Frame IRQ flag should be set sooner after power/reset"
	lda count
	cmp #6
	jlt test_failed
	
	jsr num_resets
	jne tests_passed
	
	jsr prompt_to_reset
	jmp wait_reset
