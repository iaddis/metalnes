;
; File: muse.inc
; Namespace: muse_ / MUSE_
; Code Segment: MUSELIB
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; MUSE - MUsic and Sound effects Engine
;
; Sound data format -
;
; Each sound is composed of one or more streams. Streams are sequences of data
; consisting of notes, rests, key-offs, ties, and opcodes. There are two sets
; of four streams available to the user, each corresponding to one of the four
; hardware sound channels (squares, triangle, and noise). The first set of
; streams is dedicated to sound effects and the second is dedicated to music.
;
; Headers -
;
; Sound data begins with the main list of sound headers. This list must be
; defined by the user at 'muse_sounds_lo/hi' and is expected to contain the
; starting addresses of each header. Each header must use the following format:
;
;	1 - Type of sound
;
;	Zero indicates music and values greater than zero indicate a sound
;	effect and its priority. If a sound effect is already playing and its
;	priority is greater than the priority of the next sound, then the new
;	sound will not be played.
;
;	Then for each stream to used by the sound -
;
;	1 - Sound stream to be used (be sure to use the correct ones)
;	2 - Address of the stream's data
;
;	Finally, the header should be terminated with a value greater than $7F.
;
; Stream data -
;
; A stream's data is divided into two categories, notes/rests/key-offs/ties
; commands and opcodes. Bytes with a value less than MUSE_OPCODE are commands
; and should be provided in the following format:
;
;	nnnnnddd
;
;	nnnnn = Type
;
;		Values less than MUSE_REST are notes. This value is added to
;		the current transposition base which can be adjusted with the
;		provided opcodes.
;
;		For the square and triangle channels, the value of the note
;		plus the transposition base is used as an index into a period
;		lookup table. This table begins at A0 and ends at E7 where
;		middle C (261.625565 Hz) is C3 for the square channels and C4
;		for the triangle channel. For the noise channel, the value of
;		the note plus the transposition base is used as the period and
;		the tone. The lower four bits are written as the period and the
;		fifth bit written as the tone.
;
;		MUSE_REST silences the stream until the next note.
;
;		MUSE_KEY_OFF disables sustaining and looping in the stream's
;		current register envelope until the next note.
;
;		MUSE_TIE continues the last note/rest/key-off command.
;
;		Note that a stream's first command should not be a tie or a
;		key-off.
;
;	ddd = Duration
;
;		The duration value is used as an index into a table of lengths
;		where:
;
;		0 = 1 tick (1/32)
;		1 = 2 ticks (1/16)
;		2 = 3 ticks (3/32)
;		3 = 4 ticks (1/8)
;		4 = 6 ticks (3/16)
;		5 = 8 ticks (1/4)
;		6 = 12 ticks (3/8)
;		7 = 16 ticks (1/2)
;
;		To create notes with a length not provided, ties must be used.
;
; Bytes with values greater than or equal to MUSE_OPCODE are opcodes. These
; are processed one after the other until the stream reader reaches either a
; new command or the end of the stream's data. The following opcodes are
; available to the user:
;
;	MUSE_SET_TRANS - Set the transposition base
;
;		1 - New transposition base
;
;	MUSE_MOVE_TRANS - Move the transposition base
;
;		1 - Value to add to the transposition base
;
;	MUSE_LOOP_TRANS - Move the transposition base with a value from a
;	lookup table indexed by the current loop count.
;
;		2 - Address of the offset lookup table
;
;	MUSE_SET_TEMPO - Set the music's tempo
;
;		1 - New tempo value.
;
;		The value needed for the tempo for NTSC systems can be found
;		with:
;
;		tempo = 128 * BPM / 225 - 1 
;
;		And for PAL systems:
;
;		tempo = 256 * BPM / 375 - 1
;
;		Where BPM is number of quarter beats per minute.
;		Note that the default tempo is $FF.
;
;	MUSE_SET_ENV - Set the current register envelope
;
;		1 - New register envelope index
;
;	MUSE_SET_SWEEP - Set the current hardware sweep value
;
;		1 - New hardware sweep value
;
;		By default the value of the hardware sweeps for the streams
;		mapped to the square channels is $08 (disabled). User defined
;		values will be used by the streams until they are changed again
;		by the user or the stream reaches the MUSE_END opcode. Note
;		that when disabling the sweep registers, you should use	the
;		value $08. Also note that this opcode should never be used with
;		the streams mapped to the triangle and noise channels.
;
;	MUSE_LOOP - Loop back to stream position
;
;		1 - Number of repetitions
;
;		2 - The address to loop back to 
;
;		Each stream has an internal loop counter that is initially
;		zero. When this opcode is encountered:
;
;		If the number of repetitions is zero, loop back
;		unconditionally.
;		Else, if the loop counter is less than the number of
;		repetitions, increment the loop counter and loop back to the
;		provided address.
;		Else, the opcode is ignored.
;
;		Note that nested loops will not work as one might expect since
;		there is only one loop counter per stream.
;
;	MUSE_END - End of stream data
;
; Register envelopes -
;
; User-defined register envelopes are strings of bytes where all but bits 4
; and 5 are written directly to the sound channel's first register (SQ1_VOL,
; SQ2_VOL, TRI_LINEAR, NOISE_VOL). The remaining bits indicate what action the
; envelope reader should take after writing the register bits:
;
;	00 = Continue to next byte
;	01 = Save current position as the loop point and continue
;	10 = Loop back to the position saved with '01' or the beginning
;	     until key-off
;	11 = Sustain current position until key-off
;
; The address of the list of register envelopes must be defined by the user at
; 'muse_envs_lo/hi'. This list must contain the starting addresses of each
; envelope. All register envelopes should be terminated with zero. Note that
; the triangle channel should be turned on with the value $C0 and muted with
; the value $80.
;
; Regional support -
;
; By default MUSE supports NTSC systems. For PAL support, simply compile with
; the PAL symbol defined. 'muse_create_tempo' will then compensate for the
; change in frame rate and the proper period table values will be used.
;

.ifndef MUSE_INC
MUSE_INC = 1

; Possible sound engine states stored in 'muse_state'

.enum
	; Initial state after calling 'muse_off'

	MUSE_OFF

	; Initial state after calling 'muse_on'

	MUSE_ON

	; State set by the user to pause music playback. Note that this should
	; only be used when the state is set to 'MUSE_ON'.

	MUSE_PAUSE

	; Set by the user to restore music playback. Note that this should
	; only be used when the state is set to 'MUSE_PAUSED'.

	MUSE_RESTORE

.endenum

; Channels used by the sound engine's streams

.enum

	MUSE_SQ1
	MUSE_SQ2
	MUSE_TRI
	MUSE_NOISE

.endenum

; Available sound engine streams. Streams 'MUS0' to 'MUS3' are mapped to the
; hardware channels 'SQ1' to 'NOISE' and are be to used to play music. Streams
; 'SFX0' to 'SFX3' are mapped to the hardware channels 'SQ1' to 'NOISE' and are
; to be used to play sound effects.

.enum

	MUSE_MUS0
	MUSE_MUS1
	MUSE_MUS2
	MUSE_MUS3
	MUSE_SFX0
	MUSE_SFX1
	MUSE_SFX2
	MUSE_SFX3
	MUSE_NUM_STREAMS

.endenum

; Sound engine commands and opcodes

.enum

	MUSE_C = $00
	MUSE_CS = $08
	MUSE_DB = MUSE_CS
	MUSE_D = $10
	MUSE_DS = $18
	MUSE_EB = MUSE_DS
	MUSE_E = $20
	MUSE_F = $28
	MUSE_FS = $30
	MUSE_GB = MUSE_FS
	MUSE_G = $38
	MUSE_GS = $40
	MUSE_AB = MUSE_GS
	MUSE_A = $48
	MUSE_AS = $50
	MUSE_BB = MUSE_AS
	MUSE_B = $58
	MUSE_CH = $60
	MUSE_CSH = $68
	MUSE_DBH = MUSE_CSH
	MUSE_DH = $70
	MUSE_DSH = $78
	MUSE_EBH = MUSE_DSH
	MUSE_EH = $80
	MUSE_FH = $88
	MUSE_FSH = $90
	MUSE_GBH = MUSE_FSH
	MUSE_GH = $98
	MUSE_GSH = $A0
	MUSE_ABH = MUSE_GSH
	MUSE_AH = $A8
	MUSE_ASH = $B0
	MUSE_BBH = MUSE_ASH
	MUSE_BH = $B8
	MUSE_REST = $C0
	MUSE_KEY_OFF = $C8
	MUSE_TIE = $D0
	MUSE_OPCODE = $D8
	MUSE_SET_TRANS = MUSE_OPCODE
	MUSE_MOVE_TRANS
	MUSE_LOOP_TRANS
	MUSE_SET_TEMPO
	MUSE_SET_ENV
	MUSE_SET_SWEEP
	MUSE_LOOP
	MUSE_END

.endenum

; Sound engine duration indexes

.enum

	MUSE_32
	MUSE_16
	MUSE_D16
	MUSE_8
	MUSE_D8
	MUSE_4
	MUSE_D4
	MUSE_2

.endenum



; List of the addresses of the user-defined sounds

.global muse_sounds_lo
.global muse_sounds_hi

; List of the addresses of the user-defined register envelopes

.global muse_envs_lo
.global muse_envs_hi

; Current state of the sound engine

.global muse_state

; Bitfield indicating which streams are active. Streams starting from
; 'MUSE_MUS0' up are mapped to bits zero and up.

.global muse_active



;
; Stops any sound effects currently playing.
;
; Preserved: x, y
; Destroyed: a
;

.macro muse_stop_sfx

	lda muse_active
	and #$0F
	sta muse_active

.endmacro

;
; Tests if a sound effect is currently being played.
;
; Out:
;	Z = Reset if a sound effect is playing, else set
;
; Preserved: x, y
; Destroyed: a
;
.macro muse_sfx_playing

	lda muse_active
	and #$F0

.endmacro

;
; Stops any music currently playing.
;
; Preserved: x, y
; Destroyed: a
;

.macro muse_stop_music

	lda muse_active
	and #$F0
	sta muse_active

.endmacro

;
; Tests if music is currently being played.
;
; Out:
;	Z = Reset if music is playing, else set
;
; Preserved: x, y
; Destroyed: a
;
.macro muse_music_playing

	lda muse_active
	and #$0F

.endmacro

;
; Toggles between the sound engines music pausing states. Note that this
; should only be used when the sound engine is active.
;
; Preserved: x, y
; Destroyed: a
;
.macro muse_toggle_music

	lda #MUSE_PAUSE
	cmp muse_state
	bne done

	lda #MUSE_RESTORE

.local done
done:
	sta muse_state

.endmacro

;
; Creates a tempo constant for use with sound engine.
;
; In:
;	tempo = The name of the symbol to created
;	bmp = The number of quarter beats (MUSE_4) per minute
;
.macro muse_create_tempo tempo, bpm

.ifndef PAL
	tempo = 128 * bpm / 225 - 1
.else
	tempo = 256 * bpm / 375 - 1
.endif

.endmacro

;
; Initializes the sound engine for use. Either this or 'muse_off' must be
; called at the start of the program. After calling 'muse_off', this subroutine
; should be called again if sound output is needed.
;
; Preserved: y
; Destroyed: a, x
;
.global muse_on

;
; Kills all sound engine activity and mutes the sound channels used by the
; sound engine. Either this or 'muse_on' must be called at the start of the 
; program.
;
; Preserved: x, y
; Destroyed: a
;
.global muse_off

;
; Plays the specified sound effect or music.
;
; In:
;	a = The index of the sound play
;
; Destroyed: a, x, y
;
.global muse_play

;
; Updates the sound engine for one frame. Preferably this should be called
; during each NMI, however that is not a requirement.
;
; Destroyed: a, x, y
;
.global muse_update

.endif

