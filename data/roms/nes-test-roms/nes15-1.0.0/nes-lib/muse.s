;
; File: muse.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; MUSE sound engine subroutines and data
;

.include "apu.inc"

.include "muse.inc"



.segment "ZEROPAGE"

; Temporary storage used by 'muse_play'

temp:				.res 3

; Temporary storage used by 'muse_update'. Note that separate temporary
; storage is used since the user is allowed to call 'muse_update' during the
; NMI.

update_temp:			.res 4

; Current channel being updated by 'muse_update' multiplied by four

curr_chn:			.res 1



.segment "BSS"

muse_state:			.res 1
muse_active = stream_sweep + 2

; Current sound effect's priority rating

sfx_priority = stream_sweep + 3

; Current global music tempo

curr_tempo = stream_sweep + 6

; The current tempo plus one is added to this and stored back in each frame.
; When a carry occurs, each active music stream's timer is updated.

tempo_sum = stream_sweep + 7

; Address of the next byte in the stream's data

stream_lo:			.res MUSE_NUM_STREAMS
stream_hi:			.res MUSE_NUM_STREAMS

; Stream's command timer

stream_timer:			.res MUSE_NUM_STREAMS

; Stream's loop counter

stream_loop:			.res MUSE_NUM_STREAMS

; Note and note state: rk-nnnnn
;
; r = Rest
;	0: Note is playing
;	1: Rest command active
;
; k = Key-off
;	0: Note is in key-on state
;	1: Note is in key-off state
;
; nnnnn = Value of the last note read

stream_note:			.res MUSE_NUM_STREAMS

; Stream's current transposition base

stream_trans:			.res MUSE_NUM_STREAMS

; Stream's current hardware sweep value. Note that this is only used by the
; streams mapped to the square channels.

stream_sweep:			.res MUSE_NUM_STREAMS

; Index of the stream's current register envelope

stream_env:			.res MUSE_NUM_STREAMS

; Stream's current position in its register envelope

stream_env_pos:			.res MUSE_NUM_STREAMS

; Stream's current loop back point in its register envelope

stream_env_loop:		.res MUSE_NUM_STREAMS



.segment "MUSELIB"

.proc muse_on

	ldx #MUSE_ON		; Set the sound engine state to active
	stx muse_state
	dex
	stx muse_active		; Reset all active stream flags
	lda #$0F		; Enable sound for the four channels used
	sta SND_CHN
	lda #$30		; Mute all sound channels used
	sta SQ1_VOL
	sta SQ2_VOL
	sta NOISE_VOL
	lda #$80
	sta TRI_LINEAR
	rts

.endproc



.proc muse_off

	lda #MUSE_OFF
	sta muse_state		; Set the sound engine state to inactive
	sta muse_active		; Set all streams to inactive
	sta SND_CHN		; Silence all sound channels
	rts

.endproc



.proc muse_play

addr = temp
active = temp + 2

	; Load the first header byte for the sound to be played.

	tay
	lda muse_sounds_lo, y
	sta addr
	lda muse_sounds_hi, y
	sta addr + 1
	ldy #0
	lda (addr), y
	beq play_music

	; If the sound is a sound effect, play if either no other sound effect
	; is playing or the sound effect playing has a priority less than or
	; equal to the priority of the new sound.

	tax
	muse_sfx_playing
	beq play_sfx
	cpx sfx_priority
	bcc done

play_sfx:
	stx sfx_priority	; Save the sound effect's priority
	lda muse_active		; Disable all SFX streams to prevent updates
	and #$0F		; while setting up new SFX
	bpl start

play_music:
	lda #$FF		; Reset the global music tempo to its default
	sta curr_tempo
	sty tempo_sum
	lda #MUSE_ON		; Set the sound engine state to active in case
	sta muse_state		; music was paused
	lda muse_active		; Disable all music channels to prevent
	and #$F0		; updates while setting up the new music

start:
	sta muse_active		; Save the updated stream states
	sta active

loop:
	iny

	; Read the stream's index. If a terminating value was read, then
	; reading is done.

	lda (addr), y
	bmi update_active
	tax
	iny

	; Read the address of the stream's data.

	lda (addr), y
	sta stream_lo, x
	iny
	lda (addr), y
	sta stream_hi, x
	lda #0			; Reset the stream's loop counter
	sta stream_loop, x
	lda #1			; Set the stream's timer to one so it is
	sta stream_timer, x	; updated on the next 'muse_update' call
	lda stream_masks, x	; Set the stream's active flag in temporary
	ora active		; memory
	sta active

	; If the stream being initialized is mapped to one of the square
	; channels, then reset its hardware sweep value.

	txa
	and #$03
	cmp #MUSE_TRI
	bcs loop
	lda #$08
	sta stream_sweep, x
	bne loop

	; Copy over the new set of stream active flags from temporary memory
	; since we are ready for 'muse_update' to begin using them.

update_active:
	lda active
	sta muse_active

done:
	rts

.endproc



.proc muse_update

	; If the sound engine is inactive, then return.

        lda muse_state
        beq done

	; Update 'tempo_sum' with the current tempo plus one. Whenever a carry
	; occurs, music streams will be updated.

        lda tempo_sum
        sec
        adc curr_tempo
        sta tempo_sum

	; Update each stream starting from sound effects down to music.

        ldx #MUSE_NUM_STREAMS - 1

loop:
        txa			; Save the channel the stream is mapped to for
        and #$03		; later subroutines
        asl
        asl
        sta curr_chn

	; Update the stream if it is active.

        lda stream_masks, x
        and muse_active
        beq volume
	jsr update_stream

	; Write the stream's volume if necessary.

volume:
	jsr write_vol

	; Update the stream's register envelope if it is still active.

	lda stream_masks, x
	and muse_active
	beq cont
        jsr update_env

cont:
        dex
        bpl loop

	; If music was just restored, reset the sound engine's state to
	; 'MUSE_ON'.

        lda #MUSE_RESTORE
        cmp muse_state
        bne done
        lda #MUSE_ON
        sta muse_state

done:
        rts

.endproc



;
; Reads a stream's data and performs any updates. This should only be called
; for active streams.
;
; In:
;	x = Index of stream to update
;	curr_chn = Index of the stream's channel multiplied by four
;
; Preserved: x
; Destroyed: a, y, update_temp/+1/+2/+3
;
.proc update_stream

addr = update_temp
addr2 = update_temp + 2

        cpx #MUSE_SFX0		; If updating a sound effect stream, skip to
        bcs update_timer	; the timer update
        lda muse_state		; Else, if music is paused, then return
        cmp #MUSE_PAUSE
        beq done
        cmp #MUSE_RESTORE	; Else, if restoring music, write the current
        bne test_tempo		; period of the stream and continue
        jsr restore_period

test_tempo:
        lda curr_tempo		; If 'tempo_sum' did not carry this frame, then
        cmp tempo_sum		; return
        bcc done

update_timer:
        dec stream_timer, x	; If the timer is not finished counting down,
	bne done		; then return

	lda stream_lo, x	; Set the address to read the stream's data
	sta addr		; from
	lda stream_hi, x
	sta addr + 1

	; Load the next byte from the stream's data and advance forward.

loop:
	ldy #0
	lda (addr), y
	inc addr
	bne test_byte
	inc addr + 1

test_byte:
	cmp #MUSE_OPCODE
	bcc test_cmd

	; If the byte read is an opcode, perform the opcode.

	sbc #MUSE_OPCODE
	jsr perform_opcode
	lda stream_masks, x	; Ensure the stream is still active, if not
	and muse_active		; then return
	beq done

	; Advance the current position in the stream's data past the opcode's
	; data and continue to process the stream's data.

	tya
	clc
	adc addr
	sta addr
	bcc loop
	inc addr + 1
	bne loop

	; Else, the byte read is a command. Regardless of the command read,
	; set the stream's timer to the length provided by the command.

test_cmd:
	pha
	and #$07
	tay
	lda length_table, y
	sta stream_timer, x

	; Save the current stream position back into the stream.

	lda addr
	sta stream_lo, x
	lda addr + 1
	sta stream_hi, x
	pla
	cmp #MUSE_TIE		; If a tie command was read, then return
	bcs done
	cmp #MUSE_KEY_OFF	; If a key-off command was read, then continue
	bcs key_off_cmd
	cmp #MUSE_REST		; If a rest command was read, then continue
	bcs rest_cmd

	; Else, this is note command and we must save the note read, initialize
	; the stream's register envelope, and write the new period to the APU.

	lsr
	lsr
	lsr
	sta stream_note, x
	lda #0
	sta stream_env_pos, x
	sta stream_env_loop, x
	jmp write_period

key_off_cmd:
	lda #$40		; On key-offs, set the stream's key-off flag
	bne finish_rest

done:
	rts

rest_cmd:
	lda #$80		; On rests, set the stream's rest flag

finish_rest:
	ora stream_note, x
	sta stream_note, x
	rts

;
; Performs an opcode read from the specified stream's data.
;
; In:
;	a = Value of the opcode to perform
;	x = Index of the stream being updated
;	curr_chn = Index of the stream's channel multiplied by four
;	addr = Address of the current position in the stream's data
; Out:
;	y = Number of bytes used as the opcode's parameters
;
; Preserved: x
; Destroyed: a, update_temp+2/+3
;
.proc perform_opcode

	asl
	tay
	lda opcode_table + 1, y
	pha
	lda opcode_table, y
	pha
	ldy #0
	rts

opcode_table:
	.addr opcode_set_trans - 1
	.addr opcode_move_trans - 1
	.addr opcode_loop_trans - 1
	.addr opcode_set_tempo - 1
	.addr opcode_set_env - 1
	.addr opcode_set_sweep - 1
	.addr opcode_loop - 1
	.addr opcode_end - 1

.endproc

;
; Opcode subroutines called by 'perform_opcode'. Note that y is initially set
; to zero when these are called and it is their responsibility to set y to the
; number of bytes to advance in the current stream's data.
;
.proc opcode_set_trans

	; Save the new transposition base and return.

	lda (addr), y
	sta stream_trans, x
	iny
	rts

.endproc

.proc opcode_move_trans

	; Add the next value read to the transposition base and return.

	lda (addr), y
	clc
	adc stream_trans, x
	sta stream_trans, x
	iny
	rts

.endproc

.proc opcode_loop_trans

	; Load the transposition table's address and read the byte offset by
	; the stream's current loop count.

	lda (addr), y
	sta addr2
	iny
	lda (addr), y
	sta addr2 + 1
	ldy stream_loop, x

	; Add the value read to the stream's current transposition base.

	lda (addr2), y
	clc
	adc stream_trans, x
	sta stream_trans, x
	ldy #2
	rts

.endproc

.proc opcode_set_tempo

	; Save the new tempo and reset 'tempo_sum'.

	lda (addr), y
	sta curr_tempo
	sty tempo_sum
	iny
	rts

.endproc

.proc opcode_set_env

	; Save the index of the register envelope to be used and reinitialize
	; the stream.

	lda (addr), y
	sta stream_env, x
	tya
	sta stream_env_pos, x
	sta stream_env_loop, x
	iny
	rts

.endproc

.proc opcode_set_sweep

	; Save the new value of the hardware sweep register to be used and
	; return.

	lda (addr), y
	sta stream_sweep, x
	iny
	rts

.endproc

.proc opcode_loop

	lda (addr), y		; Read the number of repetitions
	beq save_addr		; If zero, then loop back indefinitely
	cmp stream_loop, x	; Else, if the stream's loop counter is equal
	beq loop_done		; to the number repetitions, the loop is done
	inc stream_loop, x	; Else, increment the stream's loop counter

save_addr:
	iny			; Save the address read as the new address to
	lda (addr), y		; read from and return
	pha
	iny
	lda (addr), y
	sta addr + 1
	pla
	sta addr
	ldy #0
	rts

loop_done:
	tya			; Else, reset the stream's loop counter and
	sta stream_loop, x	; return
	ldy #3
	rts

.endproc

.proc opcode_end

	lda muse_active		; Reset the stream's active flag
	eor stream_masks, x
	sta muse_active
	
	; If ending a sound effect stream while it is overridding an active
	; music stream, then restore the music stream's period.

	cpx #MUSE_SFX0
	bcc done
	lda stream_masks - 4, x
	and muse_active
	beq done
	txa
	and #$03
	tax
	jsr restore_period
	txa
	ora #$04
	tax

done:
	rts

.endproc

.endproc



;
; Updates a stream's position in its current register envelope. This should
; only be called for active streams.
;
; In:
;	x = Index of stream to update
;	curr_chn = Index of the stream's channel multiplied by four
;
; Preserved: x
; Destroyed: a, y, update_temp/+1
;
.proc update_env

addr = update_temp

	; Skip updating the register envelopes of either stream's in the middle
	; of rest command or paused music streams.

	lda stream_note, x
	bmi done
        cpx #MUSE_SFX0
        bcs update
        lda muse_state
        cmp #MUSE_PAUSE
        beq done

update:

	; Load the next byte to be read from the register envelope data.

	ldy stream_env, x
	lda muse_envs_lo, y
	sta addr
	lda muse_envs_hi, y
	sta addr + 1
	ldy stream_env_pos, x

	lda (addr), y		; If the next byte is zero, then the envelope
	beq done		; is done
	and #$30		; Else, handle the control bits
	beq env_cont
	cmp #$10
	beq env_loop_point
	cmp #$20
	beq env_loop

	; Sustain current position until key-off command.

	lda stream_note, x
	asl
	bmi env_cont
	rts

	; Loop back to saved loop point until key-off.

env_loop:
	lda stream_note, x
	asl
	bmi env_cont
	lda stream_env_loop, x
	sta stream_env_pos, x
	rts

	; Save current position as loop point and continue.

env_loop_point:
	tya
	sta stream_env_loop, x

env_cont:
	inc stream_env_pos, x

done:
	rts

.endproc



;
; Makes the necessary APU period and sweep writes for the specified stream.
;
; In:
;	x = Stream to write from
;	curr_chn = Index of the stream's channel multiplied by four
;
; Preserved: x
; Destroyed: a, y, update_temp+2/+3
;
.proc write_period

period = update_temp + 2

	; Skip writing to the APU for a music stream that is currently being
	; overridden by a sound effect stream.

	cpx #MUSE_SFX0
	bcs cont
	lda stream_masks + 4, x
	and muse_active
	bne done

cont:

	; Add the current note to the transposition base to determine the
	; actual note to be played.

	lda stream_note, x
	and #$1F
	clc
	adc stream_trans, x
	tay
	lda curr_chn		; If writing to the noise channel, continue
	cmp #MUSE_NOISE * 4
	beq write_noise

	; Lookup the period to be written from the period lookup table.

	lda period_table_lo, y
	sta period
	lda period_table_hi, y
	sta period + 1
	ldy curr_chn		; If writing to the triangle channel, continue
	cpy #MUSE_TRI * 4
	beq write_tri
	lda stream_sweep, x	; Else, write the sweep and period for the
	sta SQ1_SWEEP, y	; square channel and return
	lda period
	sta SQ1_LO, y
	lda period + 1
	sta SQ1_HI, y
	rts

write_tri:
	lda period		; Else, set the triangle channel's period and
	sta TRI_LO		; return
	lda period + 1
	sta TRI_HI
	rts

	; Else, set the noise channel's period and tone and then return.

write_noise:
	tya
	and #$1F
	cmp #$10
	bcc write_noise_lo
	and #$0F
	ora #$80

write_noise_lo:
	sta NOISE_LO
	lda #$00
	sta NOISE_HI

done:
	rts

.endproc



;
; Restores the period of the specified interrupted stream.
;
; In:
;	x = Stream to restore
;	curr_chn = Index of the stream's channel multiplied by four
;
; Preserved: x
; Destroyed: a, y, update_temp+2/+3
;
.proc restore_period

	; Mute any interrupted square channel streams using the hardware
	; sweep. Silence is better than hearing an incorrect period.

	ldy curr_chn
	cpy #MUSE_TRI * 4
	bcs write
	lda stream_sweep, x
	bpl write
	lda stream_note, x
	ora #$80
	sta stream_note, x
	rts

write:
	jmp write_period	; Else, rewrite the stream's current period

.endproc



;
; Makes the necessary APU volume/duty writes for the specified stream.
;
; In:
;	x = Stream to write from
;	curr_chn = Index of the stream's channel multiplied by four
;
; Preserved: x
; Destroyed: a, y, update_temp/+1
;
.proc write_vol

addr = update_temp

	lda stream_masks, x	; If the stream is active, continue
	and muse_active
	bne active
	cpx #MUSE_SFX0		; Else, do not make any writes for inactive
	bcs done		; sound effect streams
	lda stream_masks + 4, x	; Else, silence the channel if writing for an
	and muse_active		; inactive non-overridden music stream
	bne done

	; Silence the stream and return.

silence:
	ldy curr_chn
	cpy #MUSE_TRI * 4
	beq silence_tri
	lda #$30
	bne update_apu

silence_tri:
	lda #$80
	bne update_apu

active:
	cpx #MUSE_SFX0		; If active sound effect, continue to write
	bcs write
	lda stream_masks + 4, x	; Else, skip writing if overridden music
	and muse_active
	bne done
	lda muse_state		; Else, silence if music is paused
	cmp #MUSE_PAUSE
	beq silence

	; If the stream is note in the middle of a rest command, then write the
	; stream's current duty/volume from its register envelope.

write:
	lda stream_note, x
	bmi silence
	ldy stream_env, x
	lda muse_envs_lo, y
	sta addr
	lda muse_envs_hi, y
	sta addr + 1
	ldy stream_env_pos, x
	lda (addr), y		; If the stream is at the end of its register
	beq silence		; envelope, then silence and return.
	and #$CF
	ldy curr_chn
	cpy #MUSE_TRI * 4
	beq update_apu
	ora #$30

update_apu:
	sta SQ1_VOL, y

done:
	rts

.endproc


; Period tables generated with the Python program 'mktables.py' found at:
; http://wiki.nesdev.com/w/index.php/APU_period_table

.ifndef PAL

; NTSC period lookup table

period_table_lo:
	.byte $f1, $7f, $13, $ad, $4d, $f3, $9d, $4c, $00, $b8, $74, $34
	.byte $f8, $bf, $89, $56, $26, $f9, $ce, $a6, $80, $5c, $3a, $1a
	.byte $fb, $df, $c4, $ab, $93, $7c, $67, $52, $3f, $2d, $1c, $0c
	.byte $fd, $ef, $e1, $d5, $c9, $bd, $b3, $a9, $9f, $96, $8e, $86
	.byte $7e, $77, $70, $6a, $64, $5e, $59, $54, $4f, $4b, $46, $42
	.byte $3f, $3b, $38, $34, $31, $2f, $2c, $29, $27, $25, $23, $21
	.byte $1f, $1d, $1b, $1a, $18, $17, $15, $14

period_table_hi:
	.byte $07, $07, $07, $06, $06, $05, $05, $05, $05, $04, $04, $04
	.byte $03, $03, $03, $03, $03, $02, $02, $02, $02, $02, $02, $02
	.byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00

.else

; PAL period lookup table

period_table_lo:
	.byte $60, $f6, $92, $34, $db, $86, $37, $ec, $a5, $62, $23, $e8
	.byte $b0, $7b, $49, $19, $ed, $c3, $9b, $75, $52, $31, $11, $f3
	.byte $d7, $bd, $a4, $8c, $76, $61, $4d, $3a, $29, $18, $08, $f9
	.byte $eb, $de, $d1, $c6, $ba, $b0, $a6, $9d, $94, $8b, $84, $7c
	.byte $75, $6e, $68, $62, $5d, $57, $52, $4e, $49, $45, $41, $3e
	.byte $3a, $37, $34, $31, $2e, $2b, $29, $26, $24, $22, $20, $1e
	.byte $1d, $1b, $19, $18, $16, $15, $14, $13

period_table_hi:
	.byte $07, $06, $06, $06, $05, $05, $05, $04, $04, $04, $04, $03
	.byte $03, $03, $03, $03, $02, $02, $02, $02, $02, $02, $02, $01
	.byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00

.endif

; Command length lookup table

length_table:
	.byte 1, 2, 3, 4, 6, 8, 12, 16

; Stream bitmask lookup table

stream_masks:
	.byte $01, $02, $04, $08, $10, $20, $40, $80

