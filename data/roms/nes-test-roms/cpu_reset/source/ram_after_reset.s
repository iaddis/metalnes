; Verifies that reset doesn't alter any RAM.

CUSTOM_RESET=1
.include "shell.inc"
.include "run_at_reset.s"

nv_res bad_addr,2

reset:  sei
	cld
	ldx #$FF
	txs
	
	ldx #7
	ldy #0
	
	; Check first byte, and assume just powered
	; if not as expected
	lda <0
	cmp #$DB
	jne std_reset
	iny
	
	; Check second byte
	lda <1
	cmp #$B6
	bne failed
	iny

	; Rest of internal memory
	setb <0,0
	setb <1,0
	lda #$6D
	clc
:       eor (<0),y
	bne failed
	lda (<0),y
	rol a
	iny
	bne :-
	inc <1
	dex
	bpl :-
	
	jsr init_shell
	jmp tests_passed

failed:
	sty bad_addr
	txa
	eor #$07
	sta bad_addr+1
	
	jsr init_shell
	
	print_str "Addr: "
	lda bad_addr+1
	jsr print_hex
	lda bad_addr
	jsr print_a
	
	set_test 3,"Reset shouldn't modify RAM"
	jmp test_failed

main:   
	jsr prompt_to_reset
	
	; Fill RAM with pattern
	setb <0,0
	setb <1,0
	ldx #8
	ldy #2
	lda #$6D
	clc
:       sta (<0),y
	rol a
	iny
	bne :-
	inc <1
	dex
	bne :-
	
	setb <0,$DB
	setb <1,$B6
	
	jmp wait_reset
