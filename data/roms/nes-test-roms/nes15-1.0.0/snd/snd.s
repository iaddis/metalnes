;
; File: snd.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Music and sound effects data
;

.include "muse.inc"



.segment "CODE"

; Register envelopes

muse_envs_lo:
	.byte <env0
	.byte <env1
	.byte <env2
	.byte <env3
	.byte <env4

muse_envs_hi:
	.byte >env0
	.byte >env1
	.byte >env2
	.byte >env3
	.byte >env4



env0:
	.byte $42, $48, $46, $76, $45, $45, $44, $44, $44, $43, $43, $43, $43
	.byte $42, $42, $42, $42, $42, $41, $41, $41, $41, $41, $41, $00

env1:
	.byte $81, $86, $84, $B4, $83, $83, $82, $82, $82, $81, $81, $81, $81
	.byte $00

env2:
	.byte $F0, $00

env3:
	.byte $01, $02, $06, $0C, $0F, $00

env4:
	.byte $8F, $8C, $8A, $89, $88, $87, $86, $85, $85, $84, $84, $83, $83
	.byte $82, $82, $82, $81, $81, $81, $00



; Music and sound effects

.import snd_mus0
.import snd_mus1
.import snd_sfx0
.import snd_sfx1

muse_sounds_lo:
	.byte <snd_mus0
	.byte <snd_mus1
	.byte <snd_sfx0
	.byte <snd_sfx1

muse_sounds_hi:
	.byte >snd_mus0
	.byte >snd_mus1
	.byte >snd_sfx0
	.byte >snd_sfx1

