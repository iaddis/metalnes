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
	jsr print_nibble_
	pla
	
	pha
	and #$0F
	jsr print_nibble_
	pla
	rts
	
print_nibble_:
	cmp #10
	blt @digit
	adc #6;+1 since carry is set
@digit: adc #'0'
	jmp print_char_


; Prints low 4 bits of A as single hex character
; Preserved: A, X, Y
print_nibble:
	pha
	and #$0F
	jsr update_crc
	jsr print_nibble_
	pla
	rts
	

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
.macro print_str str,str2
	jsr print_str_
	.byte str
	.ifnblank str2
		.byte str2
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
	bne :+
	inc addr+1
:       rts


; Prints A as 1-3 digit decimal.
; In: A = MSB
; Preserved: A, X, Y
print_dec:
	sta print_temp_
	pha
	txa
	pha
	tya
	pha
	ldy print_temp_
	lda #0
	sta print_temp_
	tya
	jmp :+


; Prints 16-bit AY as 1-5 digit decimal.
; Preserved: A, X, Y
print_ay_dec:
	jsr update_crc
	sta print_temp_
	pha
	txa
	pha
	tya
	pha
:       jsr update_crc
	
	; Strip leading zeroes
	ldx #6
:       dex
	cmp @lsb-1,x
	lda print_temp_
	sbc @msb-1,x
	tya
	bcc :-
	bcs @non_zero

	; Print remaining digits
	
@more:  ; Commit subtraction
	iny
	sta print_temp_
	pla
	
	; Subtract
@digit: sbc @lsb,x
	pha
	lda print_temp_
	sbc @msb,x
	bcs @more
	
	; Print digit and undo subtraction
	tya
	jsr print_char_
	pla
	adc @lsb,x
@non_zero:
	sec
	ldy #'0'
	dex
	bne @digit

	ora #'0'
	jsr print_char_
	
	pla
	tay
	pla
	tax
	pla
	rts     

@lsb:   .byte 0,<10,<100,<1000,<10000
@msb:   .byte 0,>10,>100,>1000,>10000


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
