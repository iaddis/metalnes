; CRC-32 checksum calculation

zp_res  checksum,4      ; Current CRC-32; no need to invert
zp_byte checksum_temp
zp_byte checksum_off_

; Turns CRC updating on/off. Allows nesting.
; Preserved: A, X, Y
crc_off:
	dec checksum_off_
	rts

crc_on: inc checksum_off_
	beq :+
	jpl internal_error ; catch unbalanced crc calls
:       rts


; Initializes checksum module. Might initialize tables
; in the future.
init_crc:
	jmp reset_crc


; Clears checksum and turns it on
; Preserved: X, Y
reset_crc:
	lda #0
	sta checksum_off_
	sta checksum
	sta checksum + 1
	sta checksum + 2
	sta checksum + 3
	rts


; Updates checksum with byte in A (unless disabled via crc_off)
; Preserved: A, X, Y
; Time: 360 clocks average
update_crc:
	bit checksum_off_
	bmi update_crc_off
update_crc_:
	pha
	stx checksum_temp
	eor checksum
	ldx #8
	sec
@bit:   ror checksum+3
	ror checksum+2
	ror checksum+1
	ror a
	bcs :+
	sta checksum
	lda checksum+3
	eor #$ED
	sta checksum+3
	lda checksum+2
	eor #$B8
	sta checksum+2
	lda checksum+1
	eor #$83
	sta checksum+1
	lda checksum
	eor #$20
	sec
:       dex
	bne @bit
	sta checksum
	ldx checksum_temp
	pla
update_crc_off:
	rts


; Prints checksum as 8-character hex value
print_crc:
	jsr crc_off
	
	ldx #3
:       lda checksum,x
	jsr print_hex
	dex
	bpl :-
	
	jmp crc_on


; EQ if checksum matches CRC
; Out: A=0 and EQ if match, A>0 and NE if different
; Preserved: X, Y
.macro is_crc crc
	jsr_with_addr is_crc_,{.dword crc}
.endmacro

is_crc_:
	tya
	pha
	
	ldy #3
:       lda (ptr),y
	cmp checksum,y
	bne @wrong
	dey
	bpl :-
	pla
	tay
	lda #0
	rts
	
@wrong:
	pla
	tay
	lda #1
	rts
