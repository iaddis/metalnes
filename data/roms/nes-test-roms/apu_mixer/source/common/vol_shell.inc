; Shell for mixer tests

CUSTOM_PLAY=1
.include "shell.inc"

.ifndef CUSTOM_TEXT
	text:   .byte "2. Should be nearly silent.",0
.endif

main:
	jsr dmc_dac_to_127
	jsr make_triangle_zero
	jsr show_instructions
	jsr quiet_ppu
	jsr short_tone
	jsr test_main
	jsr short_tone
	jsr console_show
	rts


dmc_dac_to_127:
	ldx #0
:       dey
	bne :-
	ldy #20
	stx $4011
	inx
	bpl :-
	rts


; Runs triangle until its output is zero, avoiding its
; attenuating effect on tests (at power, it starts with
; its DAC at 15).
make_triangle_zero:
.ifndef USING_DEVCART
	setb $4015,0    ; off
	setb $4008,$04  ; lin ctr
	setb $400A,$FF  ; period=256
	setb $400B,$08
	delay_msec 10   ; wait for lin ctr to load
	setb $4015,$04  ; on
	setb $400B,$08  ; start
	delay 256*16-12 ; allow 16 clocks
	setb $4015,0    ; off
.endif
	rts


; Prints instructions for test
show_instructions:
	.ifdef USING_DEVCART
		rts
	.endif
	
	setw addr,filename
	jsr print_str_addr
	print_str " channel mixing test",{newline,newline}
	
	print_str "1. Should play short tone.",{newline,newline}
	
	setw addr,text
	jsr print_str_addr
	print_str {newline,newline}
	
	print_str "3. Should play short tone.",{newline,newline}
	
	print_str "Some clicking might occur between the two tones."
	print_str "Also, a faint tone might be audible through headphones."
	print_str newline,newline
	
	.ifndef BUILD_NSF
		delay_msec 1000
		delay_msec 1000
		delay_msec 1000
	.endif
	
	rts


; Disables PPU rendering and sets color to blacker-than-black,
; to reduce background sound
quiet_ppu:
.ifndef BUILD_NSF
	jsr wait_vbl
	setb PPUMASK,0
	setb PPUADDR,$3F
	setb PPUADDR,$00
	setb PPUDATA,$0D; thanks to tepples for $0D idea
	setb PPUADDR,$3F
	setb PPUADDR,$00
.endif
	rts


; Makes short tone, with silence on either side
short_tone:
	setb $4015,0
	delay_msec 300
	setb $4015,$01
	setb $4000,$BF
	setb $4001,$7F
	setb $4002,$6F
	setb $4003,$00
	delay_msec 300
	setb $4015,0
	delay_msec 300
	rts


; Decrements 16-bit temp in constant time
; Time: 18 cycles
.macro dec_tempw
	lda temp
	sec
	sbc #1
	sta temp
	lda temp+1
	sbc #0
	sta temp+1
.endmacro


; Be sure user code doesn't cross pages, affecting timing
.align 256
