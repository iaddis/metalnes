;
; File: mus1.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Puzzle solved music
;

.include "muse.inc"

.include "snd.inc"



muse_create_tempo TEMPO, 95



.segment "CODE"

.export snd_mus1
.proc snd_mus1

	.byte 0
	.byte MUSE_MUS0
	.addr stream0
	.byte MUSE_MUS1
	.addr stream1
	.byte MUSE_MUS2
	.addr stream2
	.byte $80



stream0:
	.byte MUSE_SET_ENV, SND0_ENV0
	.byte MUSE_SET_TEMPO, TEMPO
	.byte MUSE_SET_TRANS, 12 * 2 + 3
	.byte MUSE_REST | MUSE_8
	.byte MUSE_F | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_F | MUSE_8

	.byte MUSE_BB | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2
	.byte MUSE_END



stream1:
	.byte MUSE_SET_ENV, SND0_ENV1
	.byte MUSE_SET_TRANS, 12 * 1 + 3

	.byte MUSE_CH | MUSE_4
	.byte MUSE_TIE | MUSE_2
	.byte MUSE_BB | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2
	.byte MUSE_END



stream2:
	.byte MUSE_SET_ENV, SND0_ENV2
	.byte MUSE_SET_TRANS, 12 * 1 + 3

	.byte MUSE_F | MUSE_4
	.byte MUSE_TIE | MUSE_2
	.byte MUSE_BB | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2
	.byte MUSE_END

.endproc

