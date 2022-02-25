; Delays in clocks and milliseconds. All routines re-entrant
; (no global data).

; Delays n milliseconds (1/1000 second)
; n can range from 0 to 1100.
; Preserved: X, Y
.macro delay_msec n
    .if (n) < 0 .or (n) > 1100
	.error "time out of range"
    .endif
    delay ((n)*CLOCK_RATE+500)/1000
.endmacro


; Delays n microseconds (1/1000000 second).
; n can range from 0 to 100000.
; Preserved: X, Y
.macro delay_usec n
    .if (n) < 0 .or (n) > 100000
	.error "time out of range"
    .endif
    delay ((n)*((CLOCK_RATE+50)/100)+5000)/10000
.endmacro


; Delays n clocks, from 2 to 16777215
; Preserved: X, Y
.macro delay n
    .if (n) < 0 .or (n) = 1 .or (n) > 16777215
	.error "Delay out of range"
    .endif
    .if (n) < 14 .and (n) <> 12
	delay_inline (n)
    .elseif (n) < 27
	delay_unrolled (n)
    .elseif <(n) = 0
	delay_256 (n)
    .else
	lda #<((n)-27)
	jsr delay_a_25_clocks
	delay_256 ((n)-27)
    .endif
.endmacro


; Delays A+25 clocks (including JSR)
; Preserved: X, Y
.align 64
:       sbc #7          ; carry set by CMP
delay_a_25_clocks:
	cmp #7
	bcs :-          ; do multiples of 7
	lsr a           ; bit 0
	bcs :+
:                       ; A=clocks/2, either 0,1,2,3
	beq @zero       ; 0: 5
	lsr a
	beq :+          ; 1: 7
	bcc :+          ; 2: 9
@zero:  bne :+          ; 3: 11
:       rts             ; (thanks to dclxvi for the algorithm)


; Delays A*256+16 clocks (including JSR)
; Preserved: X, Y
delay_256a_16_clocks:
	cmp #0
	bne :+
	rts
delay_256a_clocks_:
	pha
	lda #256-19-22-16
	bne @first ; always branches
:       pha
	lda #256-19-22
@first: jsr delay_a_25_clocks
	pla
	clc
	adc #-1
	bne :-
	rts


; Delays A*65536+16 clocks (including JSR)
; Preserved: X, Y
delay_65536a_16_clocks:
	cmp #0
	bne :+
	rts
delay_65536a_clocks_:
	pha
	lda #256-19-22-16
	bne @first
:       pha
	lda #256-19-22
@first: jsr delay_a_25_clocks
	lda #255
	jsr delay_256a_clocks_
	pla
	clc
	adc #-1
	bne :-
	rts

.macro delay_inline n
    .if n = 7 .or n >= 9
	pha
	pla
	delay_inline (n-7)
    .elseif n >= 3 .and n & 1
	lda <0
	delay_inline (n-3)
    .elseif n >= 2
	nop
	delay_inline (n-2)
    .elseif n > 0
	.error "delay_short internal error"
    .endif
.endmacro

.macro delay_unrolled n
    .if n & 1
	lda <0
	jsr delay_unrolled_-((n-15)/2)
    .else
	jsr delay_unrolled_-((n-12)/2)
    .endif
.endmacro
	
	.res 7,$EA ; NOP
delay_unrolled_:
	rts

.macro delay_256 n
    .if >n
	lda #>n
	jsr delay_256a_clocks_
    .endif
    .if ^n
	lda #^n
	jsr delay_65536a_clocks_
    .endif
.endmacro

