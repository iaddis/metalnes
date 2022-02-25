; Prints values in various ways to output,
; including numbers and strings.

newline = 10

zp_byte print_temp_

; Prints indicated register to console as two hex
; chars and space
; Preserved: A, X, Y, flags
print_a:
	php
	pha
print_reg_:
	jsr print_hex
	lda #' '
	jsr print_char_
	pla
	plp
	rts

print_x:
	php
	pha
	txa
	jmp print_reg_

print_y:
	php
	pha
	tya
	jmp print_reg_

print_p:
	php
	pha
	php
	pla
	jmp print_reg_

print_s:
	php
	pha
	txa
	tsx
	inx
	inx
	inx
	inx
	jsr print_x
	tax
	pla
	plp
	rts


; Prints A as two hex characters, NO space after
; Preserved: A, X, Y
print_hex:
	jsr update_crc
	
	pha
	lsr a
	lsr a
	lsr a
	lsr a
	jsr print_hex_nibble
	pla
	
	pha
	and #$0F
	jsr print_hex_nibble
	pla
	rts
	
print_hex_nibble:
	cmp #10
	blt @digit
	adc #6;+1 since carry is set
@digit: adc #'0'
	jmp print_char_


; Prints character and updates checksum UNLESS
; it's a newline.
; Preserved: A, X, Y
print_char:
	cmp #newline
	beq :+
	jsr update_crc
:       pha
	jsr print_char_
	pla
	rts


; Prints space. Does NOT update checksum.
; Preserved: A, X, Y
print_space:
	pha
	lda #' '
	jsr print_char_
	pla
	rts


; Advances to next line. Does NOT update checksum.
; Preserved: A, X, Y
print_newline:
	pha
	lda #newline
	jsr print_char_
	pla
	rts


; Prints string
; Preserved: A, X, Y
.macro print_str str,str2,str3,str4,str5,str6,str7,str8,str9,str10,str11,str12,str13,str14,str15
	jsr print_str_
	.byte str
	.ifnblank str2
		.byte str2
	.endif
	.ifnblank str3
		.byte str3
	.endif
	.ifnblank str4
		.byte str4
	.endif
	.ifnblank str5
		.byte str5
	.endif
	.ifnblank str6
		.byte str6
	.endif
	.ifnblank str7
		.byte str7
	.endif
	.ifnblank str8
		.byte str8
	.endif
	.ifnblank str9
		.byte str9
	.endif
	.ifnblank str10
		.byte str10
	.endif
	.ifnblank str11
		.byte str11
	.endif
	.ifnblank str12
		.byte str12
	.endif
	.ifnblank str13
		.byte str13
	.endif
	.ifnblank str14
		.byte str14
	.endif
	.ifnblank str15
		.byte str15
	.endif
	.byte 0
.endmacro


print_str_:
	sta print_temp_
	
	pla
	sta addr
	pla
	sta addr+1
	
	jsr inc_addr
	jsr print_str_addr
	
	lda print_temp_
	jmp (addr)


; Prints string at addr and leaves addr pointing to
; byte AFTER zero terminator.
; Preserved: A, X, Y
print_str_addr:
	pha
	tya
	pha
	
	ldy #0
	beq :+ ; always taken
@loop:  jsr print_char
	jsr inc_addr
:       lda (addr),y
	bne @loop
	
	pla
	tay
	pla
	; FALL THROUGH

; Increments 16-bit value in addr.
; Preserved: A, X, Y
inc_addr:
	inc addr
	beq :+
	rts
:       inc addr+1
	rts



.pushseg
.segment "RODATA"
	; >= 60000 ? (EA60)
	; >= 50000 ? (C350)
	; >= 40000 ? (9C40)
	; >= 30000 ? (7530)
	; >= 20000 ? (4E20)
	; >= 10000 ? (2710)
digit10000_hi: .byte $27,$4E,$75,$9C,$C3,$EA
digit10000_lo: .byte $10,$20,$30,$40,$50,$60
	; >= 9000 ? (2328 (hex))
	; >= 8000 ? (1F40 (hex))
	; >= 7000 ? (1B58 (hex))
	; >= 6000 ? (1770 (hex))
	; >= 5000 ? (1388 (hex))
	; >= 4000 ? (FA0 (hex))
	; >= 3000 ? (BB8 (hex))
	; >= 2000 ? (7D0 (hex))
	; >= 1000 ? (3E8 (hex))
digit1000_hi: .byte $03,$07,$0B,$0F,$13,$17,$1B,$1F,$23
digit1000_lo: .byte $E8,$D0,$B8,$A0,$88,$70,$58,$40,$28
; >= 900 ? (384 (hex))
; >= 800 ? (320 (hex))
; >= 700 ? (2BC (hex))
; >= 600 ? (258 (hex))
; >= 500 ? (1F4 (hex))
; >= 400 ? (190 (hex))
; >= 300 ? (12C (hex))
; >= 200 ? (C8 (hex))
; >= 100 ? (64 (hex))
digit100_hi: .byte $00,$00,$01,$01,$01,$02,$02,$03,$03
digit100_lo: .byte $64,$C8,$2C,$90,$F4,$58,$BC,$20,$84
.popseg

.macro dec16_comparew table_hi, table_lo
	.local @lt
	cmp table_hi-1,y
	bcc @lt
	pha
	 txa
	 cmp table_lo-1,y
	pla
@lt:
.endmacro
.macro do_digit table_hi, table_lo
	pha
	 jsr @print_dec16_helper
	 sbc table_lo-1,y
	 tax
	pla
	sbc table_hi-1,y
.endmacro

; Prints A:X as 2-5 digit decimal value, NO space after.
; A = high 8 bits, X = low 8 bits.
print_dec16:
	ora #0
	beq @less_than_256
	
	ldy #6
	sty print_temp_

	; TODO: Use binary search?
:	dec16_comparew digit10000_hi,digit10000_lo
	bcs @got10000
	dey
	bne :-
	;cpy print_temp_
	;beq @got10000
@cont_1000:
	ldy #9
:	dec16_comparew digit1000_hi,digit1000_lo
	bcs @got1000
	dey
	bne :-
	cpy print_temp_
	beq @got1000
@cont_100:
	ldy #9
:	dec16_comparew digit100_hi,digit100_lo
	bcs @got100
	dey
	bne :-
	cpy print_temp_
	beq @got100
@got10000:
	do_digit digit10000_hi,digit10000_lo
	; value is now 0000..9999
	ldy #0
	sty print_temp_
	beq @cont_1000
@got1000:
	do_digit digit1000_hi,digit1000_lo
	; value is now 000..999
	ldy #0
	sty print_temp_
	beq @cont_100
@got100:
	do_digit digit100_hi,digit100_lo
	; value is now 00..99
	txa
	jmp print_dec_00_99
@print_dec16_helper:
	 tya
	 jsr print_digit
	 txa
	 sec
	rts
@less_than_256:
	txa
	;jmp print_dec
; Prints A as 2-3 digit decimal value, NO space after.
; Preserved: Y
print_dec:
	; Hundreds
	cmp #10
	blt print_digit
	cmp #100
	blt print_dec_00_99
	ldx #'0'-1
:       inx
	sbc #100
	bge :-
	adc #100
	jsr print_char_x
	
	; Tens
print_dec_00_99:
	sec
	ldx #'0'-1
:       inx
	sbc #10
	bge :-
	adc #10
	jsr print_char_x
	; Ones
print_digit:
	ora #'0'
	jmp print_char
	; Print a single digit
print_char_x:
	pha
	txa
	jsr print_char
	pla
	rts


; Prints one of two characters based on condition.
; SEC; print_cc bcs,'C','-' prints 'C'.
; Preserved: A, X, Y, flags
.macro print_cc cond,yes,no
	; Avoids labels since they're not local
	; to macros in ca65.
	php
	pha
	cond *+6
	lda #no
	bne *+4
	lda #yes
	jsr print_char
	pla
	plp
.endmacro

