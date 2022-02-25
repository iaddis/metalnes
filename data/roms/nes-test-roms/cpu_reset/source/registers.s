; At power, A,X,Y=0 P=$34 S=$FD
; At reset, I flag set, S decreased by 3, no other change

CUSTOM_RESET=1
.include "shell.inc"
.include "run_at_reset.s"

nv_res log,8

reset:  ; Save current registers and stack
	php
	sta log+0
	stx log+1
	sty log+2
	pla
	sta log+3
	tsx
	stx log+4
	lda $112
	sta log+5
	lda $111
	sta log+6
	lda $110
	sta log+7
	
	jmp std_reset

main:   jsr num_resets
	beq power
	
	set_test 3,"Reset should set I flag, subtract 3 from S, nothing more"
	jsr print_log
	check_crc $717C409F
	
	set_test 4,"Reset shouldn't write to stack"
	lda log+5
	cmp #$FB
	jne test_failed
	lda log+6
	cmp #$9A
	jne test_failed
	lda log+7
	cmp #$BC
	jne test_failed
	
	jmp tests_passed
	
power:  set_test 2,"At power A,X,Y=0 P=$34 S=$FD"
	jsr print_log
	check_crc $EAE4AAFA
	
	jsr prompt_to_reset
	
	; Clear interrupt sources
	setb SNDCHN,0
	setb SNDMODE,$C0
	setb PPUCTRL,0
	bit SNDCHN
	
	; Set initial stack bytes and registers
	setb $111,$9A
	setb $110,$BC
	ldx #$12
	txs
	lda #$FB
	pha
	lda #$34
	ldx #$56
	ldy #$78
	plp
	
	jmp wait_reset

print_log:
	print_str "A  X  Y  P  S",newline
	ldx #0
:       lda log,x
	jsr print_a
	inx
	cpx #5
	bne :-
	
	jsr print_newline
	
	rts
