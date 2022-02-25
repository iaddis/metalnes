; Synchronizes EXACTLY to VBL, to accuracy of 1/3 CPU clock
; (1/2 CPU clock if PPU is enabled). Reading PPUSTATUS
; 29768 clocks or later after return will have bit 7 set.
; Reading PPUSTATUS immediately will have bit 7 clear.
; Preserved: A, X, Y
; Time: 120-330 msec
.align 128
sync_vbl:
	pha
	
	; Disable interrupts
	sei
	lda #0
	sta PPUCTRL
	
	; Coarse synchronize
	bit $2002
:       bit $2002
	bpl :-
	
	delay 29771
	
	; Divide possible cases into two groups, and optimize
	; for each, halving time this routine takes.
	bit $2002
	bmi :+
	delay 4         ; max=4, lower=slower
:       delay 24        ; max=24, lower=slower
	
	; Synchronize precisely to VBL. VBL occurs every 29780.67
	; CPU clocks. Loop takes 27 clocks. Every 1103 iterations,
	; the second LDA $2002 will read exactly 29781 clocks
	; after a previous read. Thus, the loop will effectively
	; read $2002 one PPU clock later each frame. It starts out
	; with VBL beginning sometime after this read, so that
	; eventually VBL will begin just before the $2002 read,
	; and thus leave CPU exactly synchronized to VBL.
:       delay 27 - 11
	bit $2002
	bit $2002
	bpl :-
	
	pla
	rts


; Same as sync_vbl, but additionally ensures that next frame
; will skip PPU clock at end of VBL if rendering is enabled.
; Preserved: A, X, Y
sync_vbl_odd:
	pha
	
	; Rendering must be disabled
	jsr wait_vbl
	lda #0
	sta PPUMASK
	
	jsr sync_vbl
	jsr @render_frame
	
	; See whether frame was short
	; If not, frames totaled 59561+1/3 CPU clocks
	delay 29781-17-1
	lda PPUSTATUS
	bmi :+
	jmp @end
:
	; If frame was short, first frame was
	; one clock shorter. Wait another frame to
	; toggle even/odd flag. Rendering enabled
	; for frame so total of all three frames
	; is 89341+1/3 CPU clocks, which has the
	; same fraction as the other case, thus
	; ensuring the same CPU-PPU synchronization.
	jsr @render_frame
	
@end:   ; Establish same timing as sync_vbl
	delay 29781-7
	
	; Be sure VBL flag is clear for this frame, as the
	; other sync routines do.
	bit PPUSTATUS
	
	pla
	rts

@render_frame:
	lda #PPUMASK_BG0
	sta PPUMASK
	delay 29781-6-6-6-6+1
	lda #0
	sta PPUMASK
	rts
	

; Same as sync_vbl_odd, but next frame will NOT skip PPU clock
; Preserved: A, X, Y
sync_vbl_even:
	jsr sync_vbl_odd
	delay 341*262*3 / 3 - 10; get to even frame without affecting sync
	
	; Be sure VBL flag is clear for this frame, as the
	; other sync routines do.
	bit PPUSTATUS
	rts


; Same as sync_vbl_even, but also writes A to SPRDMA without
; affecting timing (in particular, SPRDMA's optional extra clock
; is dealt with).
; Preserved: A, X, Y
sync_vbl_even_dma:
	jsr sync_vbl_odd
	delay 341*262 - 534
	sta SPRDMA
	bit PPUSTATUS
	
	; Delay extra clock if ncessary. Unaffected by code
	; alignment since it branches to next instr.
	bpl :+
:       
	; Be sure VBL flag is clear for this frame, as the
	; other sync routines do.
	bit PPUSTATUS
	rts


; Same as sync_vbl, but then delays A additional PPU clocks.
; Preserved: X, Y
.align 32
sync_vbl_delay:
	jsr sync_vbl
	
	; VBL occurs every 29780.67 clocks, therefore
	; each iteration of the loop is like delaying
	; 1/3 CPU clock (1 PPU clock).
:       delay 29781-7
	clc
	adc #-1
	bcs :-
	
	delay 29781*2-10
	
	; Be sure VBL flag is clear for this frame, as the
	; other sync routines do.
	bit PPUSTATUS
	rts


; Effectively delays n PPU clocks, while maintaing
; even/odd frame (i.e. never delays an odd number of
; frames). PPU rendering must be off.
; Preserved: A, X, Y
.macro delay_ppu_even n
	.if (n) < 8
		.error "time out of range"
	.endif
	.if (n) .MOD 3 = 1
		.if (n) > 4
			delay (n)/3-1
		.endif
		delay 29781*4
	.elseif (n) .MOD  3 = 2
		delay (n)/3
		delay 29781*2
	.else
		delay (n)/3
	.endif
.endmacro
