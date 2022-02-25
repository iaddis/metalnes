;
; File: game.inc
; Namespace: game / GAME_
; Code Segment: CODE
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Main game module
;

.ifndef GAME_INC
GAME_INC = 1

; Main game states

.enum

	; Title screen state
	;
	; Preconditions:
	;
	; Rendering must be turned off via 'nmi_ppumask'.
	; The OAM buffer must be cleared.

	GAME_TITLE

	; Playing game state
	;
	; Preconditions:
	;
	; Rendering must be turned off via 'nmi_ppumask'.
	; The base name table in 'nmi_ppuctrl' must be $2000.
	; The OAM buffer must be cleared.
	; The LFSR must be seeded.

	GAME_PLAY

.endenum



; Temporary storage used by the game modules

.globalzp game_temp



;
; Changes the current game state and calls its initialization function.
;
; In:
;	a = The game state to change to
;
; Destroyed: Assume everything
;
.global game_change_state

.endif

