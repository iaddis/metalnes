;
; File: oam.inc
; Namespace: oam_ / OAM_
; Code Segment: OAMLIB
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; General purpose OAM library
;

.ifndef OAM_INC
OAM_INC = 1

; OAM I/O location

OAM_DMA = $4014

; OAM data offsets

.enum

	OAM_Y
	OAM_TILE
	OAM_ATT
	OAM_X
	OAM_SIZE

.endenum



; RAM location of the OAM buffer
;
; Bytes: 256

.global oam_buff



;
; Copies the contents of the OAM buffer to OAM using OAM_DMA.
;
; Preserved: x, y
; Destroyed: a
;
.macro oam_copy

	lda #0
	sta OAMADDR
	lda #>oam_buff
	sta OAM_DMA

.endmacro



;
; Sets all sprites in the OAM buffer to a non-visible state.
;
; Preserved: y
; Destroyed: a, x
;
.global oam_clear

.endif

