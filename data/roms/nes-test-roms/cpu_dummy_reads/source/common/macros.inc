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

; Reserves size bytes in zeropage/bss for name
.macro zp_res name,size
	seg_data "ZEROPAGE",{name: .res size}
.endmacro

.macro bss_res name,size
	seg_data "BSS",{name: .res size}
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
	seg_data "STRINGS",{Addr: data}
.endmacro

; If name isn't yet defined, defines it with value
.macro SET_DEFAULT name,value
    .ifndef name
	name=value
    .endif
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
