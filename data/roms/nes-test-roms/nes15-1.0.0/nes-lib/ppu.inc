;
; File: ppu.inc
; Namespace: ppu_ / PPU_
; Code Segment: PPULIB
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; General purpose PPU library
;

.ifndef PPU_INC
PPU_INC = 1

; PPU I/O locations

PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
OAMADDR = $2003
OAMDATA = $2004
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007



;
; Polls PPUSTATUS until the veritical blanking flag is set.
;
; Preserved: a, x, y
;
.macro ppu_poll_vblank

.local loop
loop:
	bit PPUSTATUS
	bpl loop

.endmacro

.endif

;
; Fills all name and attribute tables with zero.
;
; Destroyed: a, x, y
;
.macro ppu_clear_nts

	ldx #$10
	lda #$20
	sta PPUADDR
	lda #0
	tay
	sta PPUADDR

.local loop
loop:
	sta PPUDATA
	iny
	bne loop
	dex
	bne loop

.endmacro

