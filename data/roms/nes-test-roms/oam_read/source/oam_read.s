; Tests each OAM location for proper reading.
; Displays 16x16 map of which ones work.
; -: works
; *: fails

.include "shell.inc"

bss_res log,256

main:
	; Disable rendering
	jsr wait_vbl
	setb PPUCTRL,0
	setb PPUMASK,0
	
	ldx #0
:       ; Set address and read from OAM
	stx SPRADDR
	lda SPRDATA
	
	; Set address and write complement
	eor #$E3
	stx SPRADDR
	sta SPRDATA
	
	; Write 7 extra bytes, necessary
	; to trigger failure in some cases.
	sta SPRDATA
	sta SPRDATA
	sta SPRDATA
	sta SPRDATA
	sta SPRDATA
	sta SPRDATA
	sta SPRDATA
	
	; Set address and log whether read
	; back was correct
	stx SPRADDR
	eor SPRDATA
	sta log,x
	
	inx
	bne :-
	
	; Print log
	ldx #0
@loop:  lda log,x
	print_cc beq,'-','*'
	
	txa
	and #$0F
	cmp #$0F
	bne :+
	jsr print_newline
:
	inx
	bne @loop
	
	check_crc $22FBFEC7
	jmp tests_passed
