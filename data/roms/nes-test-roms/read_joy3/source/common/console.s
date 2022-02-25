; Scrolling text console with line wrapping, 30x30 characters.
; Buffers lines for speed. Will work even if PPU doesn't
; support scrolling (until text reaches bottom).
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
bss_res console_buf,console_buf_size


; Waits for beginning of VBL
; Preserved: A, X, Y
console_wait_vbl:
	bit PPUSTATUS
:       bit PPUSTATUS
	bpl :-
	rts


; Initializes console
console_init:
	jsr console_hide
	lda #0
	sta PPUCTRL
	
	; Load palette
	lda #$3F
	sta PPUADDR
	lda #0
	sta PPUADDR
	lda #$0F        ; black background
	sta PPUDATA
	lda #$30        ; white text
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	
	; Fill nametable with spaces
	lda #$20
	sta PPUADDR
	ldx #0
	stx PPUADDR
	ldx #240
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
	
	; In case PPU doesn't support scrolling, start a
	; couple of lines down
	lda #8
	sta console_scroll
	jsr console_scroll_up_
	jmp console_show

	
; Shows console display
; Preserved: X, Y
console_show:
	pha
	jsr console_wait_vbl
	lda #PPUMASK_BG0
	sta PPUMASK
	jmp console_apply_scroll_


; Hides console display and makes screen black
; Preserved: X, Y
console_hide:
	jsr console_wait_vbl
	lda #0
	sta PPUMASK
	rts

	
; Prints char A to console. Will not appear until
; a newline or flush occurs.
; Preserved: A, X, Y
console_print:
	cmp #10
	beq console_newline
	
	; Write to buffer
	stx console_temp
	ldx console_pos
	sta console_buf+console_margin,x
	ldx console_temp
	
	; Update pos and print newline if buf full
	dec console_pos
	bmi console_newline     ; reached end of line
	
	rts


; Displays current line and starts new one
; Preserved: A, X, Y
console_newline:
	pha
	jsr console_wait_vbl
	jsr console_flush_
	jsr console_scroll_up_
	jsr console_flush_
	jmp console_apply_scroll_


console_get_scroll_:
	; A = (console_scroll+8)%240
	lda console_scroll
	cmp #240-8
	bcc :+
	adc #16-1;+1 for set carry
:       adc #8
	rts


console_scroll_up_:
	; Scroll up 8 pixels
	jsr console_get_scroll_
	sta console_scroll
	
	stx console_temp
	
	; Start new clear line
	lda #' '
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
	jsr console_wait_vbl
	jsr console_flush_
console_apply_scroll_:
	lda #0
	sta PPUADDR
	sta PPUADDR
	
	sta PPUSCROLL
	jsr console_get_scroll_
	sta PPUSCROLL
	
	pla
	rts

console_flush_:
	; Address line in nametable
	lda console_scroll
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

