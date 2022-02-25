;
; File: lfsr32.inc
; Namespace: lfsr_ / LFSR_
; Code Segment: LFSRLIB
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; 32-bit Galois Linear Feedback Shift Register
;

.ifndef LFSR32_INC
LFSR32_INC = 1

; Used to hold the current state of the LFSR. It is the user's responsibility
; to set the initial state.

.globalzp lfsr32



;
; 32-bit Galois LFSR with taps at 32, 31, 29, and 1.
;
; In:
;	y = The number of states to shift through
;
; Preserved: x
; Destroyed: a, y
;
.global lfsr32_next

.endif

