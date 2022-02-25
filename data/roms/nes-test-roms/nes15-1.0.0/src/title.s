;
; File: title.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Title screen state subroutines and data
;

.include "joy.inc"
.include "lfsr32.inc"
.include "pkb.inc"
.include "ppu.inc"

.include "game.inc"
.include "nmi.inc"

.include "title.inc"



.segment "CODE"

.proc title_init

	lda #$20		; Draw the title screen's Packbit encoded name
	sta PPUADDR		; table data
	lda #$00
	sta PPUADDR
	lda #<title_pkb
	sta pkb_src
	lda #>title_pkb
	sta pkb_src + 1
	jsr pkb_to_vram
	jsr joy_update1		; Initial read to clear out pressed buttons
	lda #$1E		; Enable sprite and background rendering
	sta nmi_ppumask
	nmi_wait
	rts

title_pkb:
	.incbin "title.pkb"


.endproc



.proc title_update

	jsr joy_update1		; Continue waiting until the player presses any
	lda joy_pressed		; button
	beq cont
	lda #$00		; Else, disable rendering
	sta nmi_ppumask
	nmi_wait
	lda #82			; Seed LFSR with the only available entropy
	eor nmi_count
	sta lfsr32
	sta lfsr32 + 1
	eor nmi_count
	sta lfsr32 + 2
	sta lfsr32 + 3
	lda #GAME_PLAY		; Change the state to 'play'
	jmp game_change_state

cont:
	rts

.endproc

