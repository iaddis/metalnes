; Reads controller into A and temp.
; Unreliable if DMC is playing.
; Preserved: X, Y
; Time: 153 clocks
.align 32
read_joy_fast:
	; Strobe controller
	lda #1          ; 2
	sta $4016       ; 4
	lda #0          ; 2
	sta $4016       ; 4
	
	; Read 8 bits
	lda #$80        ; 2
	sta <temp       ; 3
:       lda $4016       ; *4
	
	; Merge bits 0 and 1 into carry. Normal
	; controllers use bit 0, and Famicom
	; external controllers use bit 1.
	and #$03        ; *2
	cmp #$01        ; *2
	
	ror <temp       ; *5
	bcc :-          ; *3
			; -1
	lda <temp       ; 3
	rts             ; 6


; Reads controller into A.
; Reliable even if DMC is playing.
; Preserved: X, Y
; Time: ~660 clocks
read_joy:
	jsr read_joy_fast
	sta <temp3
	jsr read_joy_fast
	pha
	jsr read_joy_fast
	sta <temp2
	jsr read_joy_fast
	
	; All combinations of one controller
	; change and one DMC DMA corruption
	; leave at least two matching readings,
	; and never just the first and last
	; matching. No more than one DMC DMA
	; corruption can occur.
	
			; X--X can't occur
	pla
	cmp <temp3
	beq :+          ; XX--
	cmp <temp
	beq :+          ; -X-X
	
	lda <temp2      ; X-X-
			; -XX-
			; --XX
:       cmp #0
	rts
