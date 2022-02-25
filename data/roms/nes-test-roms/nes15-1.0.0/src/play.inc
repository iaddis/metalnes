;
; File: play.inc
; Namespace: play_ / PLAY_
; Code Segment: CODE
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Playing game state module
;

.ifndef PLAY_INC
PLAY_INC = 1

;
; Initializes the playing game state.
;
; Destroyed: Assume everything
;
.global play_init

;
; Updates the playing game state.
;
; Destroyed: Assume everything
;
.global play_update

.endif

