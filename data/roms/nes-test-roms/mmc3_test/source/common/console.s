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

.ifndef CONSOLE_COLOR
	CONSOLE_COLOR = $30     ; white
.endif

console_screen_width = 32 ; if lower than 32, left-justifies

; Number of characters of margin on left and right, to avoid
; text getting cut off by common TVs. OK if either/both are 0.
console_left_margin  = 1
console_right_margin = 1

console_width = console_screen_width - console_left_margin - console_right_margin

zp_byte console_pos ; 0 to console_width
zp_byte console_scroll
zp_byte console_temp
bss_res console_buf,console_width


; Initializes console
console_init:
	; Flag that console hasn't been initialized
	setb console_scroll,-1
	
	setb console_pos,0
	rts


; Hides console by disabling PPU rendering and blacking out
; first four entries of palette.
; Preserved: A, X, Y
console_hide:
	pha
	jsr console_wait_vbl_
	setb PPUMASK,0
	lda #$0F
	jsr console_load_palette_
	pla
	rts


; Shows console display
; Preserved: X, Y
console_show:
	pha
	lda #CONSOLE_COLOR
	jsr console_show_custom_color_
	pla
	rts


; Prints char A to console. Will not appear until
; a newline or flush occurs.
; Preserved: A, X, Y
console_print:
	cmp #10
	beq console_newline
	
	sty console_temp
	
	ldy console_pos
	cpy #console_width
	beq console_full_
	sta console_buf,y
	iny
	sty console_pos
	
	ldy console_temp
	rts
	

; Displays current line and starts new one
; Preserved: A, X, Y
console_newline:
	pha
	jsr console_wait_vbl_
	jsr console_flush_
	jsr console_scroll_up_
	setb console_pos,0
	pla
	rts


; Displays current line's contents without scrolling.
; Preserved: A, X, Y
console_flush:
	pha
	jsr console_wait_vbl_
	jsr console_flush_
	jsr console_apply_scroll_
	pla
	rts


;**** Internal routines ****

console_full_:
	ldy console_temp

	; Line is full
	
	; If space, treat as newline
	cmp #' '
	beq console_newline

	; Wrap current line at appropriate point
	pha
	tya
	pha
	jsr console_wrap_
	pla
	tay
	pla
	
	jmp console_print
	

; Inserts newline into buffer at appropriate position, leaving
; next line ready in buffer
; Preserved: X, console_temp
console_wrap_:
	; Find beginning of last word
	ldy #console_width
	lda #' '
:       dey
	bmi console_newline
	cmp console_buf,y
	bne :-
	
	; y = 0 to console_width-1
	
	; Flush through current word and put remaining
	; in buffer for next line
	jsr console_wait_vbl_
	
	; Time to last PPU write: 207 + 32*(26 + 10)
	
	lda console_scroll
	jsr console_set_ppuaddr_
	
	stx console_pos         ; save X
	
	ldx #0
	
	; Print everything before last word
:       lda console_buf,x
	sta PPUDATA
	inx
	dey
	bpl :-
	
	; x = 1 to console_width
	
	; Move last word to beginning of buffer, and
	; print spaces for rest of line
	ldy #0
	beq :++
:       lda #' '
	sta PPUDATA
	lda console_buf,x
	inx
	sta console_buf,y
	iny
:       cpx #console_width
	bne :--
	
	ldx console_pos         ; restore X
	
	; Append new text after that
	sty console_pos
	
	; FALL THROUGH


; Scrolls up 8 pixels and clears one line BELOW new line
; Preserved: X, console_temp
console_scroll_up_:
	; Scroll up 8 pixels
	lda console_scroll
	jsr console_add_8_to_scroll_
	sta console_scroll
	
	; Clear line AFTER that on screen
	jsr console_add_8_to_scroll_
	jsr console_set_ppuaddr_
	
	ldy #console_width
	lda #' '
:       sta PPUDATA
	dey
	bne :-
	; FALL THROUGH


; Applies current scrolling position to PPU
; Preserved: X, Y, console_temp
console_apply_scroll_:
	lda #0
	sta PPUADDR
	sta PPUADDR
	
	sta PPUSCROLL
	lda console_scroll
	jsr console_add_8_to_scroll_
	jsr console_add_8_to_scroll_
	sta PPUSCROLL
	rts


; Sets PPU address for row
; In: A = scroll position
; Preserved: X, Y
console_set_ppuaddr_:
	sta console_temp
	lda #$08
	asl console_temp
	rol a
	asl console_temp
	rol a
	sta PPUADDR
	lda console_temp
	ora #console_left_margin
	sta PPUADDR
	rts
	

; A = (A + 8) % 240
; Preserved: X, Y
console_add_8_to_scroll_:
	cmp #240-8
	bcc :+
	adc #16-1;+1 for set carry
:       adc #8
	rts


console_show_custom_color_:
	pha
	jsr console_wait_vbl_
	setb PPUMASK,PPUMASK_BG0
	pla
	jsr console_load_palette_
	jmp console_apply_scroll_


console_load_palette_:
	pha
	setb PPUADDR,$3F
	setb PPUADDR,$00
	setb PPUDATA,$0F        ; black
	pla
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	rts


; Initializes PPU if necessary, then waits for VBL
; Preserved: A, X, Y, console_temp
console_wait_vbl_:
	lda console_scroll
	cmp #-1
	bne @already_initialized
	
	; Deferred initialization of PPU until first use of console
	
	; In case PPU doesn't support scrolling, start a
	; couple of lines down
	setb console_scroll,16
	
	jsr console_hide
	tya
	pha
	
	; Fill nametable with spaces
	setb PPUADDR,$20
	setb PPUADDR,$00
	ldy #240
	lda #' '
:       sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	dey
	bne :-
	
	; Clear attributes
	lda #0
	ldy #$40
:       sta PPUDATA
	dey
	bne :-

	pla
	tay
	
	jsr console_show
@already_initialized:
	jmp wait_vbl_optional


; Flushes current line
; Preserved: X, Y
console_flush_:
	lda console_scroll
	jsr console_set_ppuaddr_
	
	sty console_temp
	
	; Copy line
	ldy #0
	beq :++
:       lda console_buf,y
	sta PPUDATA
	iny
:       cpy console_pos
	bne :--
	
	ldy console_temp
	rts
