; Verifies timing of branch instructions
;
; Runs branch instruction in loop that counts iterations
; until APU length counter expires. Moves the loop around
; in memory to trigger page cross/no cross cases.

.include "shell.inc"

zp_byte opcode
zp_byte flags
zp_byte time_ptr
bss_res times,8

main:
	set_test 0
	for_loop test_opcode,$10,$F0,$20
	jmp tests_done

log_time:
	ldx time_ptr
	sta times,x
	inc time_ptr
	rts
	
test_opcode:
	sta opcode

	; Not taken
	ldx #$FF
	and #$20
	beq :+
	inx
:       stx flags
	setb time_ptr,0
	jsr test_addrs
	
	; Taken
	lda flags
	eor #$FF
	sta flags
	jsr test_addrs
	
	; Verify times
	ldx #8 - 1
:       lda times,x
	cmp @correct_times,x
	bne @error
	dex
	bpl :-
	
	rts

@correct_times:
	.byte 2,2,2,2,3,3,4,4

@error: lda opcode
	jsr print_a
	jsr play_byte
	ldy #0
:       lda times,y
	jsr print_dec
	jsr print_space
	iny
	cpy #8
	bne :-
	jsr print_newline
	set_test 1
	rts

; Tests instruction with page cross/no cross cases
test_addrs:
	setw addr,$6EA
	jsr test_forward
	
	setw addr,$700
	jsr test_reverse
	
	setw addr,$6EB
	jsr test_forward
	
	setw addr,$6FF
	jsr test_reverse
	
	rts

; Times code at addr
time_code:
	pha
	
	; Synchronize with APU length counter
	setb SNDMODE,$40
	setb SNDCHN,$01
	setb $4000,$10
	setb $4001,$7F
	setb $4002,$FF
	setb $4003,$18
	lda #$01
:       and SNDCHN
	bne :-
	
	; Setup length counter
	setb $4003,$18
	
	delay 29830-7120
	
	; Run instruction
	setb temp,0
	pla
	jmp (addr)
	
raw_to_cycles: ; entry i is lowest value that qualifies for i cycles
	.byte 250, 241, 233, 226, 219, 213, 206, 201, 195, 190, 0

; Jumps here when instruction has been timed
instr_done:
	; Convert iteration count to cycle count
	lda temp
	ldy #-1
:       iny
	cmp raw_to_cycles,y
	blt :-
	
	; Convert 10+ to 0
	cpy #10
	blt :+
	ldy #0
:       
	tya
	jsr log_time
	
	rts

.macro test_dir
	; Copy code
	ldy #40
:       lda @code,y
	sta (addr),y
	dey
	bpl :-
	
	; Patch branch opcode
	ldy #@branch - @code
	lda opcode
	sta (addr),y
	
	; Calculate address of @loop
	lda addr
	clc
	adc #@loop - @code
	sta addr
	lda addr+1
	adc #0
	sta addr+1
	
	jmp time_code
@code:
.endmacro

.macro instr_loop
	inc temp
	lda SNDCHN
	and #$01
	beq *+5
	jmp (addr)
	jmp instr_done
.endmacro

test_reverse:
	test_dir
:       instr_loop
@loop:  lda flags
	pha
	plp
@branch:
	bmi :-
	instr_loop

test_forward:
	test_dir
@loop:  lda flags
	pha
	plp
@branch:
	bmi :+
	instr_loop
:       instr_loop
