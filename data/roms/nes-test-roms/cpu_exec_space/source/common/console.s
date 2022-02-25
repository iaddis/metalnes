; Scrolling text console with line wrapping, 30x29 characters.
; Buffers lines for speed. Will work even if PPU doesn't
; support scrolling (until text reaches bottom). Keeps border
; along bottom in case TV cuts it off.
;
; Defers most initialization until first newline, at which
; point it clears nametable and makes palette non-black.
;
; ** ASCII font must already be in CHR, and mirroring
; must be vertical or single-screen.

; Number of characters of margin on left and right, to avoid
; text getting cut off by common TVs
console_margin = 1

console_buf_size = 32
console_width = console_buf_size - (console_margin*2)

zp_byte console_pos
zp_byte console_scroll
zp_byte console_temp
zp_byte text_color 

bss_res console_buf,console_buf_size


; Initializes console
console_init:
	; Flag that console hasn't been initialized
	setb console_scroll,-1&$FF
	lda #0
	sta text_color
	jmp console_clear_line_


; Hides console by blacking palette and disabling PPU.
; Preserved: A, X, Y
console_hide:
	pha
	txa
	pha
	tay
	pha
	
	 jsr console_wait_vbl_
	 setb PPUMASK,0
	 lda #$0F
	 tax
	 tay
	 jsr console_load_palette_
	pla
	tay
	pla
	tax
	pla
	rts


console_wait_vbl_:
	lda console_scroll
	cmp #-1&$FF
	jne wait_vbl_optional
	
	; Deferred initialization of PPU until first use of console
	
	; In case PPU doesn't support scrolling, start a
	; couple of lines down
	setb console_scroll,16
	
	jsr console_hide
	txa
	pha
	
	; Fill nametable with spaces
	setb PPUADDR,$20
	setb PPUADDR,$00
	ldx #240
	;lda #$E0
	;sta text_color
	lda #0
:       sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	dex
	bne :-
	
	; Clear attributes
	lda #0
	ldx #$40
:       sta PPUDATA
	dex
	bne :-

	pla
	tax
	jmp console_show


; Shows console display
; Preserved: X, Y
console_show:
	pha
	
	txa
	pha
	tay
	pha
	
	jsr console_wait_vbl_
	setb PPUMASK,PPUMASK_BG0
	
	lda #$22                ; red
	ldx #$27                ; green
	ldy #$30                ; white
	jsr console_load_palette_
	
	pla
	tay
	pla
	tax
	
	jmp console_apply_scroll_


; Shows console display
; Preserved: X, Y
console_show_nowait:
	pha
	
	txa
	pha
	tay
	pha
	
	setb PPUMASK,PPUMASK_BG0
	
	lda #$22                ; red
	ldx #$27                ; green
	ldy #$30                ; white
	jsr console_load_palette_
	
	pla
	tay
	pla
	tax
	
	jmp console_apply_scroll_


console_load_palette_:
	pha
	 setb PPUADDR,$3F
	 setb PPUADDR,$00
	 setb PPUDATA,$0F        ; black
	pla
	sta PPUDATA
	stx PPUDATA
	sty PPUDATA
	rts

	
; Prints char A to console. Will not appear until
; a newline or flush occurs.
; Preserved: A, X, Y
console_print:
	cmp #10
	beq console_newline
	
	stx console_temp
	
	; Newline if buf full and next char isn't space
	ldx console_pos
	bpl :+
	cmp #' '
	beq @ignore_space
	ldx console_temp
	jsr console_newline
	stx console_temp
	ldx console_pos
:       
	; Write to buffer
	clc
	adc text_color
	sta console_buf+console_margin,x
	dex
	stx console_pos
	
@ignore_space:
	ldx console_temp
	rts




; Displays current line and starts new one
; Preserved: A, X, Y
console_newline:
	pha
	jsr console_wait_vbl_
	jsr console_flush_
	jsr console_clear_line_
	
	; Scroll up 8 pixels and clear one line AHEAD
	lda console_scroll
	jsr console_add_8_to_scroll_
	sta console_scroll
	jsr console_add_8_to_scroll_
	jsr console_flush_a
	jmp console_apply_scroll_


; A = (A + 8) % 240
console_add_8_to_scroll_:
	cmp #240-8
	bcc :+
	adc #16-1;+1 for set carry
:       adc #8
	rts


console_clear_line_:
	stx console_temp
	
	; Start new clear line
	lda #0
	ldx #console_buf_size-1
:       sta console_buf,x
	dex
	bpl :-
	ldx #console_width-1
	stx console_pos
	
	ldx console_temp
	rts


; Displays current line's contents without scrolling.
; Preserved: A, X, Y
console_flush:
	pha
	jsr console_wait_vbl_
	jsr console_flush_
console_apply_scroll_:
	lda #0
	sta PPUADDR
	sta PPUADDR
	
	sta PPUSCROLL
	lda console_scroll
	jsr console_add_8_to_scroll_
	jsr console_add_8_to_scroll_
	sta PPUSCROLL
	
	pla
	rts

console_flush_:
	lda console_scroll
console_flush_a:
	; Address line in nametable
	sta console_temp
	lda #$08
	asl console_temp
	rol a
	asl console_temp
	rol a
	sta PPUADDR
	lda console_temp
	sta PPUADDR
	
	; Copy line
	stx console_temp
	ldx #console_buf_size-1
:       lda console_buf,x
	sta PPUDATA
	dex
	bpl :-
	ldx console_temp
	
	rts

