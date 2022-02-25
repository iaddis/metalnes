;
; File: snd.inc
; Namespace: snd_ / SND_
; Code Segment: CODE
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Music and sound effects data module
;

.ifndef SND_INC
SND_INC = 1

; Available music and sound effects

.enum

	SND_MUS0
	SND_MUS1
	SND_NUM_MUS
	SND_SFX0 = SND_NUM_MUS
	SND_SFX1

.endenum

; Available register envelopes

.enum

	SND0_ENV0
	SND0_ENV1
	SND0_ENV2
	SND1_ENV0
	SND3_ENV0

.endenum

.endif

