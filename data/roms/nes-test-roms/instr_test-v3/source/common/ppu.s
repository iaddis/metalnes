; PPU utilities

bss_res ppu_not_present

; Sets PPUADDR to w
; Preserved: X, Y
.macro set_ppuaddr w
	bit PPUSTATUS
	setb PPUADDR,>w
	setb PPUADDR,<w
.endmacro


; Delays by no more than n scanlines
.macro delay_scanlines n
	.if CLOCK_RATE <> 1789773
		.error "Currently only supports NTSC"
	.endif
	delay ((n)*341)/3
.endmacro


; Waits for VBL then disables PPU rendering.
; Preserved: A, X, Y
disable_rendering:
	pha
	jsr wait_vbl_optional
	setb PPUMASK,0
	pla
	rts


; Fills first nametable with $00
; Preserved: Y
clear_nametable:
	ldx #$20
	bne clear_nametable_

clear_nametable2:
	ldx #$24
clear_nametable_:
	lda #0
	jsr fill_screen_
	
	; Clear pattern table
	ldx #64
:       sta PPUDATA
	dex
	bne :-
	rts


; Fills screen with tile A
; Preserved: A, Y
fill_screen:
	ldx #$20
	bne fill_screen_
	
; Same as fill_screen, but fills other nametable
fill_screen2:
	ldx #$24
fill_screen_:
	stx PPUADDR
	ldx #$00
	stx PPUADDR
	ldx #240
:       sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	dex
	bne :-
	rts


; Fills palette with $0F
; Preserved: Y
clear_palette:
	set_ppuaddr $3F00
	ldx #$20
	lda #$0F
:       sta PPUDATA
	dex
	bne :-


; Fills OAM with $FF
; Preserved: Y
clear_oam:
	lda #$FF

; Fills OAM with A
; Preserved: A, Y
fill_oam:
	ldx #0
	stx SPRADDR
:       sta SPRDATA
	dex
	bne :-
	rts


; Initializes wait_vbl_optional. Must be called before
; using it.
.align 32
init_wait_vbl:
	; Wait for VBL flag to be set, or ~60000
	; clocks (2 frames) to pass
	ldy #24
	ldx #1
	bit PPUSTATUS
:       bit PPUSTATUS
	bmi @set
	dex
	bne :-
	dey
	bpl :-
@set:
	; Be sure flag didn't stay set (in case
	; PPUSTATUS always has high bit set)
	tya
	ora PPUSTATUS
	sta ppu_not_present
	rts


; Same as wait_vbl, but returns immediately if PPU
; isn't working or doesn't support VBL flag
; Preserved: A, X, Y
.align 16
wait_vbl_optional:
	bit ppu_not_present
	bmi :++ 
	; FALL THROUGH

; Clears VBL flag then waits for it to be set.
; Preserved: A, X, Y
wait_vbl:
	bit PPUSTATUS
:       bit PPUSTATUS
	bpl :-
:       rts


.macro check_ppu_region_ Len
				; Delays since VBL began
	jsr wait_vbl_optional   ; 10 average
	delay Len - 18 - 200
	lda PPUSTATUS           ; 4
	bmi @ok                 ; 2
	delay 200
	; Next VBL should roughly begin here if it's the
	; one we are detecting
	delay 200
	lda PPUSTATUS           ; 2
	bpl @ok
.endmacro

check_ppu_region:
	
.ifndef REGION_FREE
.ifdef PAL_ONLY
	check_ppu_region_ 29781
	print_str {newline,"Note: This test is meant for PAL NES only.",newline,newline}
.endif

.ifdef NTSC_ONLY
	check_ppu_region_ 33248
	print_str {newline,"Note: This test is meant for NTSC NES only.",newline,newline}
.endif
.endif
@ok:    rts


; Loads ASCII font into CHR RAM and fills rest with $FF
.macro load_chr_ram
	jsr wait_vbl_optional
	mov PPUCTRL,#0
	mov PPUMASK,#0
	mov PPUADDR,#0
	mov PPUADDR,#0
	
	; Copy ascii_chr to 0
	setb addr,<ascii_chr
	ldx #>ascii_chr
	ldy #0
@page:
	stx addr+1
:       lda (addr),y
	sta PPUDATA
	iny
	bne :-
	inx
	cpx #>ascii_chr_end
	bne @page
	
	; Fill rest
	lda #$FF
:       sta PPUDATA
	iny
	bne :-
	inx
	cpx #$20
	bne :-
.endmacro
