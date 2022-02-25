;
; File: game.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Main game subroutines and data
;

.include "apu.inc"
.include "joy.inc"
.include "muse.inc"
.include "oam.inc"
.include "ppu.inc"
.include "vrub.inc"

.include "fifteen.inc"
.include "gfx.inc"
.include "nmi.inc"
.include "play.inc"
.include "title.inc"

.include "game.inc"



JOY_REP_DELAY = 30
JOY_REP_SPEED = 3



vrub_buff = $100
oam_buff = $200

.segment "ZEROPAGE"

game_temp:		.res 4

; The current game state

game_state:		.res 1



.segment "CODE"

;
; Reset routine
;
.proc reset

	sei
	cld
	ldx #$FF
	txs
	inx
	stx PPUCTRL		; Disable NMI
	stx PPUMASK		; Disable rendering
	stx DMC_FREQ		; Disable DMC IRQs

	bit PPUSTATUS		; Clear the vblank flag
	ppu_poll_vblank		; First of two waits for vblanks to ensure that
				; the PPU has stabilized

	stx nmi_ppumask		; Reset PPUMASK mirror
	stx nmi_draw		; Reset NMI draw flag
	stx vrub_buff		; Reset VRUB buffer and end position
	stx vrub_end
	stx joy_held		; Initialize read joypad states
	stx joy_pressed
	stx joy_released
	joy_init1		; Initialize the joypad state
	jsr oam_clear		; Initialize the OAM buffer
	jsr muse_on		; Initialize the sound engine

	ppu_poll_vblank		; Second vblank wait

	lda #$80		; Enable NMIs, set pattern and name tables
	sta nmi_ppuctrl
	sta PPUCTRL

	jsr gfx_write_pals	; Write the sprite and background palettes
	dec nmi_draw		; Enable NMI drawing so OAM is cleared and the
				; palettes are written

	lda #GAME_TITLE		; Set game state to the title screen
	jsr game_change_state

	; Main loop

loop:
	jsr update
	jmp loop

.endproc



.proc game_change_state

	sta game_state
	asl
	tax
	lda init_table + 1, x
	pha
	lda init_table, x
	pha
	rts

init_table:
	.addr title_init - 1
	.addr play_init - 1

.endproc



;
; Calls the current state's update subroutine.
;
; Destroyed: Assume everything
;
.proc update

	lda game_state
	asl
	tax
	lda update_table + 1, x
	pha
	lda update_table, x
	pha
	rts

update_table:
	.addr title_update - 1
	.addr play_update - 1

.endproc



.byte $48, $41, $50, $50, $59, $20, $45, $41, $53, $54, $45, $52, $21



.segment "VECTORS"

	.addr nmi
	.addr reset
	.addr nmi_done

