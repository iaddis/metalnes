;
; File: nmi.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; NMI subroutines and data
;

.include "muse.inc"
.include "oam.inc"
.include "ppu.inc"
.include "vrub.inc"

.include "nmi.inc"



.segment "ZEROPAGE"

nmi_count:			.res 1
nmi_ppuctrl:			.res 1
nmi_ppumask:			.res 1
nmi_draw:			.res 1



.segment "CODE"

.proc nmi

	pha
	txa
	pha
	tya
	pha

	bit nmi_draw		; Test if the frame is ready to be displayed
	bpl no_draw
	oam_copy		; Update OAM
	vrub_update nmi_ppuctrl ; Perform VRUB updates
	inc nmi_draw		; Reset the frame ready flag

no_draw:
	lda nmi_ppuctrl		; Update PPUCTRL
	sta PPUCTRL
	lda #0
	sta PPUSCROLL		; Update PPUSCROLL
	sta PPUSCROLL
	lda nmi_ppumask		; Update PPUMASK
	sta PPUMASK
	inc nmi_count		; Update the NMI counter used for waiting
	jsr muse_update		; Update the sound engine

	pla
	tay
	pla
	tax
	pla

done:
	rti

.endproc

nmi_done = nmi::done

