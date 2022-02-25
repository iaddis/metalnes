; CRC-32 checksum calculation

zp_res  checksum,4
zp_byte checksum_temp
zp_byte checksum_off_

; Turns CRC updating on/off. Allows nesting.
; Preserved: X, Y
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
	; FALL THROUGH
; Clears checksum and turns it on
; Preserved: X, Y
reset_crc:
	lda #0
	sta checksum_off_
	lda #$FF
	sta checksum
	sta checksum + 1
	sta checksum + 2
	sta checksum + 3
	rts


; Updates checksum with byte in A (unless disabled via crc_off)
; Preserved: X, Y
; Time: 350 clocks average
update_crc:
	bit checksum_off_
	bmi update_crc_off
update_crc_:
	stx checksum_temp
	eor checksum
	ldx #8
@bit:   lsr checksum+3
	ror checksum+2
	ror checksum+1
	ror a
	bcc :+
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
:       dex
	bne @bit
	sta checksum
	ldx checksum_temp
update_crc_off:
	rts


; Prints checksum as 8-character hex value
print_crc:
	jsr crc_off
	
	; Print complement
	ldx #3
:       lda checksum,x
	eor #$FF
	jsr print_hex
	dex
	bpl :-
	
	jmp crc_on
