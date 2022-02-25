zp_byte instrs_idx
zp_byte failed_count

main:   ldx #$A2
	txs
	
	jsr init_crc_fast
	
	; Test each instruction
	lda #0
@loop:  sta instrs_idx
	tay
	
	jsr reset_crc
	lda instrs,y
	jsr test_instr
	jsr check_result
	
	lda instrs_idx
	clc
	adc #4
	cmp #instrs_size
	bne @loop
	
	lda failed_count
	jne test_failed
	jmp tests_passed

; Check result of test
check_result:
.ifdef CALIBRATE
	; Print correct CRC
	jsr crc_off
	print_str ".dword $"
	ldx #0
:       lda checksum,x
	jsr print_hex
	inx
	cpx #4
	bne :-
	jsr print_newline
	jsr crc_on
.else
	; Verify CRC
	ldx #3
	ldy instrs_idx
:       lda checksum,x
	cmp correct_checksums,y
	bne @wrong
	iny
	dex
	bpl :-
.endif
	rts

; Print failed opcode and name
@wrong: 
	ldy instrs_idx
	lda instrs,y
	jsr print_a
	jsr play_byte
	lda instrs+2,y
	sta addr
	lda instrs+3,y
	sta addr+1
	jsr print_str_addr
	jsr print_newline
	inc failed_count
	rts

bss_res instr,instr_template_size

; Tests instr A
test_instr:
	sta instr
	jsr avoid_silent_nsf
	
	; Copy rest of template
	ldx #instr_template_size - 1
:       lda instr_template,x
	sta instr,x
	dex
	bne :-
	
	; Disable and clear frame IRQ
	lda #$40
	sta SNDMODE
	
	; Default stack
	lda #$90
	sta in_s
	
	; Test with different flags
	lda #$00
	jsr test_flags
	lda #$FF
	jsr test_flags
	
	rts

zp_byte operand_idx

test_flags:
	sta in_p
	
	ldy #values_size-1
:       sty operand_idx

	lda values,y
	sta in_a
	
	lda values+1,y
	sta in_x
	
	lda values+2,y
	sta in_y
	
	jsr test_values
	
	ldy operand_idx
	dey
	bpl :-
	
	rts

.ifndef values2
	values2 = values
	values2_size = values_size
.endif

.macro test_normal
zp_byte a_idx
zp_byte saved_s
	
	tsx
	stx saved_s
	
	ldy #values2_size-1
inner:  sty a_idx
	
	lda values2,y
	sta operand
	
	set_in
	
.if 0
	; P A X Y S O (z,x) (z),y
	jsr print_p
	jsr print_a
	jsr print_x
	jsr print_y
	jsr print_s
	lda operand
	jsr print_a
.ifdef address
	lda (address,x)
	jsr print_a
	lda (address),y
	jsr print_a
.else
	lda operand,x
	jsr print_a
	lda operand,y
	jsr print_a
.endif
	jsr print_newline
.endif

	jmp instr
instr_done:
	
	check_out
	
	ldy a_idx
	dey
	bpl inner
	
	ldx saved_s
	txs
.endmacro
