; Expected output, and explanation:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TEST: test_cpu_exec_space_apu
; This program verifies that the
; CPU can execute code from any
; possible location that it can
; address, including I/O space.
;
; In this test, it is also
; verified that not only all
; write-only APU I/O ports
; return the open bus, but
; also the unallocated I/O
; space in $4018..$40FF.
; 
; 40FF
; Passed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Written by Joel Yliluoma - http://iki.fi/bisqwit/

.segment "LIB"
.include "shell.inc"
.include "colors.inc"
.segment "CODE"

zp_res	nmi_count
zp_res	maybe_crashed

zp_res	temp_code,8
zp_res  console_save,2

bss_res empty,$500

.macro print_str_and_ret s,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15
	print_str s,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15
	rts
.endmacro
.macro my_print_str s,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15
	.local Addr
	jsr Addr
	seg_data "RODATA",{Addr: print_str_and_ret s,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15}
.endmacro

set_vram_pos:
	ldy PPUSTATUS
	sta PPUADDR ; poke high 6 bits
	stx PPUADDR ; poke low  8 bits
	rts

test_failed_finish:
	jsr crash_proof_end
	; Re-enable screen
	jsr console_show
	text_white
	jmp test_failed

open_bus_pathological_fail:
	jmp test_failed_finish

main:   
	jsr intro
	
	ldx #>empty
	ldy #<empty
	lda #0
	sta console_save
@ram_clear_loop:
	stx console_save+1
:	sta (console_save),y
	iny
	bne :-
	inx
	cpx #8
	bne @ram_clear_loop

	text_color2
	
	lda console_pos
	sta console_save+0
	lda console_scroll
	sta console_save+1
	
	lda #>temp_code
	jsr print_hex
	lda #<temp_code
	jsr print_hex
	lda #' '
	jsr print_char
	jsr console_flush
	lda #$60
	sta temp_code
	lda #$EA
	sta temp_code+1
	jsr temp_code

	ldy #$40
	ldx #0
	
@loop:
	lda console_save+0
	sta console_pos
	lda console_save+1
	sta console_scroll
	lda #8
	jsr write_text_out
	jsr write_text_out
	jsr write_text_out
	jsr write_text_out
	jsr write_text_out

	cpx #$15
	beq :+

	tya
	jsr print_hex
	txa
	jsr print_hex
	lda #' '
	jsr print_char
	jsr console_flush

	; prepare for RTI
	lda #>(:+ )
	pha
	lda #<(:+ )
	pha
	php
	;
	lda #$4C ; jmp abs
	sta temp_code+0
	stx temp_code+1
	sty temp_code+2
	jmp temp_code
:	inx
	bne @loop

	text_white
	jsr console_show
	jsr wait_vbl
	jmp tests_passed




	.pushseg
	.segment "RODATA"
intro:	text_white
	print_str "TEST: test_cpu_exec_space_apu",newline
	text_color1
	jsr print_str_
	;       0123456789ABCDEF0123456789ABCD
	 .byte "This program verifies that the",newline
	 .byte "CPU can execute code from any",newline
	 .byte "possible location that it can",newline
	 .byte "address, including I/O space.",newline
	 .byte newline
	 .byte "In this test, it is also",newline
	 .byte "verified that not only all",newline
	 .byte "write-only APU I/O ports",newline
	 .byte "return the open bus, but",newline
	 .byte "also the unallocated I/O",newline
	 .byte "space in $4018..$40FF.",newline
	 .byte newline,0
	text_white
	rts
	.popseg





nmi:
	pha
	 lda maybe_crashed
	 beq :+
	 inc nmi_count
	 lda nmi_count
	 cmp #4
	 bcc :+
	 jmp test_failed_finish
:
	pla
	rti

crash_proof_begin:
	lda #$FF
	sta nmi_count
	sta maybe_crashed
	
	; Enable NMI
	lda #$80
	sta $2000
	rts

crash_proof_end:
	; Disable NMI
	lda #0
	sta $2000
	sta maybe_crashed
	rts

irq:
	; Presume we got here through a BRK opcode.
	; Presumably, that opcode was placed in $8000..$E000 to trap wrong access.
wrong_code_executed_somewhere:
	text_white
	print_str "ERROR",newline
	text_color1
	;          0123456789ABCDEF0123456789ABC|
	print_str "Mysteriously Landed at $"
	pla
	tax
	pla
	jsr print_hex
	txa
	jsr print_hex
	text_white
	jsr print_str_
	 .byte newline
	;       0123456789ABCDEF0123456789ABCD
	 .byte "Program flow did not follow",newline
	 .byte "the planned path, for a number",newline
	 .byte "of different possible reasons.",newline
	 .byte 0
	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 2,"Failure To Obey Predetermined Execution Path"
	jmp test_failed_finish

.pushseg
.segment "WRONG_CODE_8000"
	.repeat $6200
		brk
	.endrepeat
	; zero-fill
.popseg
