;
; File: sfx0.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Tile movement SFX
;

.include "muse.inc"

.include "snd.inc"



.segment "CODE"

.export snd_sfx0
.proc snd_sfx0

	.byte 1
	.byte MUSE_SFX3
	.addr stream0
	.byte $80



stream0:
	.byte MUSE_SET_ENV, SND1_ENV0
	.byte MUSE_SET_TRANS, 0

	.byte MUSE_DS | MUSE_D8
	.byte MUSE_END

.endproc

