;
; File: mus0.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Prelude from BWV 558 by J.S. Bach (possibly by J. T. Krebs), preceded by the
; new puzzle SFX
;

.include "muse.inc"

.include "snd.inc"



muse_create_tempo TEMPO, 95



.segment "CODE"

.export snd_mus0
.proc snd_mus0

	.byte 0
	.byte MUSE_MUS0
	.addr stream0
	.byte MUSE_MUS1
	.addr stream1
	.byte MUSE_MUS2
	.addr stream2
	.byte MUSE_MUS3
	.addr stream3
	.byte $80



stream0:
	.byte MUSE_SET_ENV, SND0_ENV0
	.byte MUSE_REST | MUSE_D4
	.byte MUSE_TIE | MUSE_D4
	.byte MUSE_SET_TEMPO, TEMPO

stream0_loop0:
	.byte MUSE_SET_TRANS, 12 * 2 + 3
	.byte MUSE_REST | MUSE_8
	.byte MUSE_G | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_DH | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_G | MUSE_8
	.byte MUSE_EBH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_KEY_OFF | MUSE_8
	.byte MUSE_F | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_F | MUSE_8
	.byte MUSE_DH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_KEY_OFF | MUSE_8
	.byte MUSE_DH | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_A | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_G | MUSE_8
	.byte MUSE_FS | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_G | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_FS | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_KEY_OFF | MUSE_16

stream0_loop1:
	.byte MUSE_GH | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_GH | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_LOOP, 1
	.addr stream0_loop1
	.byte MUSE_GH | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_GH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_GH | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_GH | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_G | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_CH | MUSE_16

	.byte MUSE_A | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_BB | MUSE_16

	.byte MUSE_G | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_G | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_F | MUSE_16

	.byte MUSE_BB | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_G | MUSE_8
	.byte MUSE_EBH | MUSE_8

stream0_loop2:
	.byte MUSE_CH | MUSE_32
	.byte MUSE_DH | MUSE_32
	.byte MUSE_LOOP, 5
	.addr stream0_loop2
	.byte MUSE_BB | MUSE_8

	.byte MUSE_BB | MUSE_D4
	.byte MUSE_CH | MUSE_8
	.byte MUSE_DH | MUSE_8
	.byte MUSE_EH | MUSE_8
	.byte MUSE_FH | MUSE_2
	.byte MUSE_TIE | MUSE_D4

	.byte MUSE_FH | MUSE_8
	.byte MUSE_EH | MUSE_8
	.byte MUSE_DH | MUSE_8
	.byte MUSE_CSH | MUSE_8
	.byte MUSE_B | MUSE_8

stream0_loop3:
	.byte MUSE_CSH | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_EH | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_AH | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_LOOP, 1
	.addr stream0_loop3

stream0_loop4:
	.byte MUSE_DH | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_AH | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_LOOP, 1
	.addr stream0_loop4

	.byte MUSE_GH | MUSE_16
	.byte MUSE_AH | MUSE_16
	.byte MUSE_FH | MUSE_8

stream0_loop5:
	.byte MUSE_EH | MUSE_32
	.byte MUSE_FH | MUSE_32
	.byte MUSE_LOOP, 5
	.addr stream0_loop5
	.byte MUSE_DH | MUSE_8

	.byte MUSE_DH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_8
	.byte MUSE_G | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_DH | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_G | MUSE_8

	.byte MUSE_EBH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_8
	.byte MUSE_F | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_F | MUSE_8

	.byte MUSE_DH | MUSE_2
	.byte MUSE_TIE | MUSE_D4
	.byte MUSE_DH | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_A | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_G | MUSE_8

stream0_loop6:
	.byte MUSE_FS | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_FS | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_D | MUSE_16

	.byte MUSE_G | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_G | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_D | MUSE_16
	.byte MUSE_LOOP, 1
	.addr stream0_loop6

	.byte MUSE_CH | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_BB | MUSE_8

stream0_loop7:
	.byte MUSE_A | MUSE_32
	.byte MUSE_BB | MUSE_32
	.byte MUSE_LOOP, 5
	.addr stream0_loop7
	.byte MUSE_G | MUSE_8
	.byte MUSE_G | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_KEY_OFF | MUSE_4
	.byte MUSE_G | MUSE_2
	.byte MUSE_TIE | MUSE_8
	.byte MUSE_A | MUSE_8

stream0_loop8:
	.byte MUSE_FS | MUSE_32
	.byte MUSE_G | MUSE_32
	.byte MUSE_LOOP, 5
	.addr stream0_loop8
	.byte MUSE_G | MUSE_8

	.byte MUSE_G | MUSE_4
	.byte MUSE_TIE | MUSE_2
	.byte MUSE_FS | MUSE_4
	.byte MUSE_TIE | MUSE_2
	.byte MUSE_LOOP, 0
	.addr stream0_loop0



stream1:
	.byte MUSE_SET_ENV, SND0_ENV1
	.byte MUSE_REST | MUSE_D4
	.byte MUSE_TIE | MUSE_D4

stream1_loop0:
	.byte MUSE_SET_TRANS, 12 * 0 + 3
	.byte MUSE_GH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_EBH | MUSE_8
	.byte MUSE_GH | MUSE_8
	.byte MUSE_MOVE_TRANS, 12
	.byte MUSE_CH | MUSE_8
	.byte MUSE_MOVE_TRANS, -12
	.byte MUSE_CH | MUSE_8

	.byte MUSE_FH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_DH | MUSE_8
	.byte MUSE_FH | MUSE_8
	.byte MUSE_BBH | MUSE_8
	.byte MUSE_BB | MUSE_8

	.byte MUSE_GH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_MOVE_TRANS, 12
	.byte MUSE_CH | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_DH | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_A | MUSE_8

	.byte MUSE_BB | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_DH | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_EBH | MUSE_8
	.byte MUSE_CH | MUSE_8

stream1_loop1:
	.byte MUSE_A | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_LOOP, 2
	.addr stream1_loop1

	.byte MUSE_DH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_CH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_A | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_BB | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_G | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_CH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_BB | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2
	.byte MUSE_BB | MUSE_2
	.byte MUSE_A | MUSE_4

	.byte MUSE_KEY_OFF | MUSE_16
	.byte MUSE_GH | MUSE_16
	.byte MUSE_FH | MUSE_16
	.byte MUSE_EBH | MUSE_16
	.byte MUSE_DH | MUSE_8
	.byte MUSE_EBH | MUSE_8
	.byte MUSE_FH | MUSE_8
	.byte MUSE_GH | MUSE_8
	.byte MUSE_KEY_OFF | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_A | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_F | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_CH | MUSE_16

	.byte MUSE_DH | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2
	.byte MUSE_EH | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2

	.byte MUSE_DH | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2
	.byte MUSE_DH | MUSE_4
	.byte MUSE_A | MUSE_4
	.byte MUSE_CSH | MUSE_4

stream1_loop2:
	.byte MUSE_KEY_OFF | MUSE_8
	.byte MUSE_D | MUSE_8
	.byte MUSE_F | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_F | MUSE_8
	.byte MUSE_D | MUSE_8
	.byte MUSE_G | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_MOVE_TRANS, -2
	.byte MUSE_LOOP, 1
	.addr stream1_loop2
	.byte MUSE_SET_TRANS, 12 * 0 + 3

	.byte MUSE_KEY_OFF | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_DH | MUSE_8
	.byte MUSE_FH | MUSE_8
	.byte MUSE_BBH | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_GH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_AH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_BBH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_AH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_GH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_GH | MUSE_2
	.byte MUSE_FSH | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_16
	.byte MUSE_GH | MUSE_16
	.byte MUSE_FSH | MUSE_16
	.byte MUSE_GH | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_GH | MUSE_16
	.byte MUSE_FSH | MUSE_16
	.byte MUSE_GH | MUSE_16
	.byte MUSE_BB | MUSE_16
	.byte MUSE_DH | MUSE_16
	.byte MUSE_CH | MUSE_16
	.byte MUSE_DH | MUSE_16

	.byte MUSE_KEY_OFF | MUSE_4
	.byte MUSE_GH | MUSE_2
	.byte MUSE_MOVE_TRANS, 12
	.byte MUSE_DH | MUSE_4
	.byte MUSE_A | MUSE_4
	.byte MUSE_CH | MUSE_4

	.byte MUSE_DH | MUSE_D4
	.byte MUSE_TIE | MUSE_2
	.byte MUSE_DH | MUSE_8
	.byte MUSE_CH | MUSE_8
	.byte MUSE_BB | MUSE_8
	.byte MUSE_A | MUSE_8
	.byte MUSE_FS | MUSE_8
	.byte MUSE_LOOP, 0
	.addr stream1_loop0



stream2:
	.byte MUSE_SET_ENV, SND0_ENV2
	.byte MUSE_REST | MUSE_D4
	.byte MUSE_TIE | MUSE_D4

stream2_loop0:
	.byte MUSE_SET_TRANS, 12 * 1 + 3
	.byte MUSE_G | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_CH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_F | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_BB | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_EBH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_DH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_G | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_DH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_B | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_CH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_FH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_BB | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_EBH | MUSE_2
	.byte MUSE_TIE | MUSE_2
	.byte MUSE_KEY_OFF | MUSE_2

	.byte MUSE_DH | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2
	.byte MUSE_EBH | MUSE_4
	.byte MUSE_FH | MUSE_4
	.byte MUSE_F | MUSE_4

	.byte MUSE_BB | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_A | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_G | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2
	.byte MUSE_G | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2

	.byte MUSE_F | MUSE_4
	.byte MUSE_KEY_OFF | MUSE_2
	.byte MUSE_G | MUSE_4
	.byte MUSE_A | MUSE_2

	.byte MUSE_DH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_BB | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_CH | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_F | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_BB | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_EBH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_DH | MUSE_2
	.byte MUSE_TIE | MUSE_2
	.byte MUSE_TIE | MUSE_2

	.byte MUSE_TIE | MUSE_2
	.byte MUSE_TIE | MUSE_4
	.byte MUSE_BB | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_CH | MUSE_4
	.byte MUSE_DH | MUSE_4
	.byte MUSE_D | MUSE_4
	.byte MUSE_G | MUSE_2
	.byte MUSE_TIE | MUSE_2

	.byte MUSE_EH | MUSE_2
	.byte MUSE_DH | MUSE_2
	.byte MUSE_TIE | MUSE_4

	.byte MUSE_G | MUSE_4
	.byte MUSE_TIE | MUSE_2
	.byte MUSE_DH | MUSE_4
	.byte MUSE_TIE | MUSE_2
	.byte MUSE_LOOP, 0
	.addr stream2_loop0



stream3:
	.byte MUSE_SET_ENV, SND1_ENV0
	.byte MUSE_SET_TRANS, 0

	.byte MUSE_DS | MUSE_D16
	.byte MUSE_REST | MUSE_D16
	.byte MUSE_DS | MUSE_D8
	.byte MUSE_END

.endproc

