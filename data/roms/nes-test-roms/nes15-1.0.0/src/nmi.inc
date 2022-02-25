;
; File: nmi.inc
; Namespace: nmi_ / NMI_
; Code Segment: CODE
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; NMI module
;

.ifndef NMI_INC
NMI_INC = 1

; Counter incremented every NMI. This is used primarily by 'nmi_wait' to wait
; for the end of the next NMI.

.globalzp nmi_count

; Copy of PPUCTRL written during every NMI

.globalzp nmi_ppuctrl

; Copy of PPUMASK written during every NMI. Note that if you intend to turn
; on or off rendering, you should write to this, then use 'nmi_wait' to wait
; for the mirror to be copied to PPUMASK.

.globalzp nmi_ppumask

; Flag that tells the NMI that the current frame is ready to be drawn, causing
; it to draw the OAM buffer and perform VRUB updates.

.globalzp nmi_draw



;
; Waits for the end of the next NMI.
;
; Preserved: x, y
; Destroyed: a
;
.macro nmi_wait

	lda nmi_count

.local loop
loop:
	cmp nmi_count
	beq loop

.endmacro

;
; NMI routine
;
; Preserved: a, x, y
;
.global nmi

;
; Simply a lable set to the 'rti' instruction at the end of NMI routine. This
; is provided so it can be used as the IRQ routine.
;
; Preserved: a, x, y
;
.global nmi_done

.endif

