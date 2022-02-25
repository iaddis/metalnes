; jxx equivalents to bxx
.macpack longbranch

; blt, bge equivalents to bcc, bcs
.define blt bcc
.define bge bcs
.define jge jcs
.define jlt jcc

; Puts data in another segment
.macro seg_data seg,data
	.pushseg
	.segment seg
	data
	.popseg
.endmacro

; Reserves size bytes in zeropage/bss for name.
; If size is omitted, reserves one byte.
.macro zp_res name,size
	.ifblank size
		zp_res name,1
	.else
		seg_data "ZEROPAGE",{name: .res size}
	.endif
.endmacro

.macro bss_res name,size
	.ifblank size
		bss_res name,1
	.else
		seg_data "BSS",{name: .res size}
	.endif
.endmacro

.macro nv_res name,size
	.ifblank size
		nv_res name,1
	.else
		seg_data "NVRAM",{name: .res size}
	.endif
.endmacro

; Reserves one byte in zeropage for name (very common)
.macro zp_byte name
	seg_data "ZEROPAGE",{name: .res 1}
.endmacro

; Passes constant data to routine in addr
; Preserved: A, X, Y
.macro jsr_with_addr routine,data
	.local Addr
	pha
	lda #<Addr
	sta addr
	lda #>Addr
	sta addr+1
	pla
	jsr routine
	seg_data "RODATA",{Addr: data}
.endmacro

; Calls routine multiple times, with A having the
; value 'start' the first time, 'start+step' the
; second time, up to 'end' for the last time.
.macro for_loop routine,start,end,step
	lda #start
:   pha
	jsr routine
	pla
	clc
	adc #step
	cmp #<((end)+(step))
	bne :-
.endmacro

; Calls routine n times. The value of A in the routine
; counts from 0 to n-1.
.macro loop_n_times routine,n
	for_loop routine,0,n-1,+1
.endmacro

; Same as for_loop, except uses 16-bit value in YX.
; -256 <= step <= 255
.macro for_loop16 routine,start,end,step
.if (step) < -256 || (step) > 255
	.error "Step must be within -256 to 255"
.endif
	ldy #>(start)
	lda #<(start)
:   tax
	pha
	tya
	pha
	jsr routine
	pla
	tay
	pla
	clc
	adc #step
.if (step) > 0
	bcc :+
	iny
.else
	bcs :+
	dey
.endif
:   cmp #<((end)+(step))
	bne :--
	cpy #>((end)+(step))
	bne :--
.endmacro

; Copies byte from in to out
; Preserved: X, Y
.macro mov out, in
	lda in
	sta out
.endmacro

; Stores byte at addr
; Preserved: X, Y
.macro setb addr, byte
	lda #byte
	sta addr
.endmacro

; Stores word at addr
; Preserved: X, Y
.macro setw addr, word
	lda #<(word)
	sta addr
	lda #>(word)
	sta addr+1
.endmacro

; Loads XY with 16-bit immediate or value at address
.macro ldxy Arg
	.if .match( .left( 1, {Arg} ), # )
		ldy #<(.right( .tcount( {Arg} )-1, {Arg} ))
		ldx #>(.right( .tcount( {Arg} )-1, {Arg} ))
	.else
		ldy (Arg)
		ldx (Arg)+1
	.endif
.endmacro

; Increments word at Addr and sets Z flag appropriately
; Preserved: A, X, Y
.macro incw Addr
	.local @incw_skip ; doesn't work, so HOW THE HELL DO YOU MAKE A LOCAL LABEL IN A MACRO THAT DOESN"T DISTURB INVOKING CODE< HUH?????? POS
	inc Addr
	bne @incw_skip
	inc Addr+1
@incw_skip:
.endmacro

; Increments XY as 16-bit register, in CONSTANT time.
; Z flag set based on entire result.
; Preserved: A
; Time: 7 clocks
.macro inxy
	iny ; 2
	beq *+4 ; 3
		; -1
	bne *+3 ; 3
		; -1
	inx ; 2
.endmacro
