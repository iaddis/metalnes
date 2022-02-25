;
; File: sfx1.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Play paused SFX
;

.include "muse.inc"

.include "snd.inc"



.segment "CODE"

.export snd_sfx1
.proc snd_sfx1

	.byte 1
	.byte MUSE_SFX1
	.addr stream0
	.byte $80



stream0:
	.byte MUSE_SET_ENV, SND3_ENV0
	.byte MUSE_SET_TRANS, 12 * 2 + 3

	.byte MUSE_BB | MUSE_8
	.byte MUSE_FH | MUSE_8
	.byte MUSE_DH | MUSE_8
	.byte MUSE_BBH | MUSE_2
	.byte MUSE_END

.endproc

