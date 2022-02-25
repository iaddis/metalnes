; A taken non-page-crossing branch ignores IRQ during
; its last clock, so that next instruction executes
; before the IRQ. Other instructions would execute the
; NMI before the next instruction.
;
; The same occurs for NMI, though that's not tested here.
;
; test_jmp
; T+ CK PC
; 00 02 04 NOP
; 01 01 04 
; 02 03 07 JMP
; 03 02 07 
; 04 01 07 
; 05 02 08 NOP
; 06 01 08 
; 07 03 08 JMP
; 08 02 08 
; 09 01 08 
; 
; test_branch_not_taken
; T+ CK PC
; 00 02 04 CLC
; 01 01 04 
; 02 02 06 BCS
; 03 01 06 
; 04 02 07 NOP
; 05 01 07 
; 06 04 0A JMP
; 07 03 0A 
; 08 02 0A 
; 09 01 0A JMP
; 
; test_branch_taken_pagecross
; T+ CK PC
; 00 02 0D CLC
; 01 01 0D 
; 02 04 00 BCC
; 03 03 00 
; 04 02 00 
; 05 01 00 
; 06 04 03 LDA $100
; 07 03 03 
; 08 02 03 
; 09 01 03 
; 
; test_branch_taken
; T+ CK PC
; 00 02 04 CLC
; 01 01 04 
; 02 03 07 BCC
; 03 02 07 
; 04 05 0A LDA $100 *** This is the special case
; 05 04 0A 
; 06 03 0A 
; 07 02 0A 
; 08 01 0A 
; 09 03 0A JMP

CUSTOM_IRQ = 1
.include "shell.inc"
.include "sync_apu.s"

.macro test routine,crc
	print_str .string( routine ),newline
	print_str "T+ CK PC",newline
	loop_n_times routine,10
	jsr print_newline
	check_crc crc
.endmacro

main:
	test test_jmp,$2A43A4DA
	test test_branch_not_taken,$4D5A50A1
	test test_branch_taken_pagecross,$DD60A954
	test test_branch_taken,$B04DD9FC
	;test test_branch_taken_to_jmp,$5E75AD67
	;test test_lda_abs,$48539E4E
	;test test_lda_abs_ind_nocross,$96CF0268
	;test test_lda_abs_ind_cross,$A7C944D1
	jmp tests_passed

zp_byte saved_s

begin:
	jsr print_a
	tsx
	stx saved_s
	pha
	jsr sync_apu
	setb $4017,$40
	setb $4017,0
	bit $4015
	cli
	pla
	eor #$0F
	jsr delay_a_25_clocks
	delay 29788-15
	rts

.align 16
test_jmp:
	jsr begin
	nop
	; 04
	jmp :+
	; 07
:       nop
	; 08
:       jmp :-

.align 16
test_branch_not_taken:
	jsr begin
	clc
	; 04
	bcs :+
	; 06
	nop
	; 07
:       lda $100
	; 0A
:       jmp :-

.align 256
.res 256-7
test_branch_taken_pagecross:
	jsr begin
	clc
	; 0D
	bcc :+
	; 0F
	nop
	; 00
:       lda $100
	; 03
:       jmp :-

.align 16
test_branch_taken:
	jsr begin
	clc
	; 04
	bcc :+
	; 06
	nop
	; 07
:       lda $100
	; 0A
:       jmp :-

; Some other tests I also did

.align 16
test_branch_taken_to_jmp:
	jsr begin
	clc
	; 04
	bcc :+
	; 06
	nop
	; 07
:       jmp :-

.align 16
test_lda_abs:
	jsr begin
	nop
	; 04
	lda $100
	; 07
	nop
	; 08
:       jmp :-

.align 16
test_lda_abs_ind_nocross:
	jsr begin
	ldx #0
	; 05
	lda $100,x
	; 08
	nop
	; 09
:       jmp :-

.align 16
test_lda_abs_ind_cross:
	jsr begin
	ldx #1
	; 05
	lda $1FF,x
	; 08
	nop
	; 09
:       jmp :-

.align 64
irq:    delay 29830-9-6 + 2
	
	ldx #7
:       dex
	delay 29831 - 13
	bit $4015
	bit $4015
	bvc :-
	
	jsr print_x
	
	pla
	pla
	and #$0F
	jsr print_a
	jsr print_newline
	
	ldx saved_s
	inx
	inx
	txs
	rts
