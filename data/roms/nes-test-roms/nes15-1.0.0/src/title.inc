;
; File: title.inc
; Namespace: title_ / TITLE_
; Code Segment: CODE
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Title screen state module
;

.ifndef TITLE_INC
TITLE_INC = 1

;
; Initializes the title screen state.
;
; Destroyed: Assume everything
;
.global title_init

;
; Updates the title screen state.
;
; Destroyed: Assume everything
;
.global title_update

.endif

