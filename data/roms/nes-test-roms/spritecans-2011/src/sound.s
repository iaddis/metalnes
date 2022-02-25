; sound.s
; part of sound engine for LJ65

;;; Copyright (C) 2009-2011 Damian Yerrick
;
;   This program is free software; you can redistribute it and/or
;   modify it under the terms of the GNU General Public License
;   as published by the Free Software Foundation; either version 3
;   of the License, or (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program; if not, write to 
;     Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;     Boston, MA  02111-1307, USA.
;
;   Visit http://www.pineight.com/ for more information.

.import periodTableLo, periodTableHi
.importzp psg_sfx_state  ; a 32 byte buffer in zp?
.importzp tvSystem
.import update_music, update_music_ch, music_playing
.export init_sound, start_sound, update_sound, soundBSS

; Ordinarily, the effect engine will move a pulse sound effect from
; $4000 to $4004 if $4004 is idle and $4000 is not, or if $4004 has
; less sfx data left to play than $4000.  Turn this off to force all
; pulse sfx to be played on $4000.
SQUARE_POOLING = 1

; As of 2011-03-10, a sound effect interrupts a musical instrument on
; the same channel only if the volume of the sfx is greater than that
; of the instrument.  Turn this off to force sound fx to interrupt
; the music whenever sfx data remains on that channel, even if the
; music is louder.
KEEP_MUSIC_IF_LOUDER = 1

SNDCHN = $4015

.segment "BSS"
soundBSS: .res 64

psg_sfx_datalo = psg_sfx_state + 0
psg_sfx_datahi = psg_sfx_state + 1
psg_sfx_lastfreqhi = psg_sfx_state + 18
psg_sfx_remainlen = psg_sfx_state + 19
psg_sfx_rate = soundBSS + 3
psg_sfx_ratecd = soundBSS + 19

.segment "CODE"

;;
; Initializes all sound channels.
;
.proc init_sound
  lda #$0F
  sta SNDCHN
  lda #$30
  sta $4000
  sta $4004
  sta $400C
  sta psg_sfx_lastfreqhi+0
  sta psg_sfx_lastfreqhi+8
  sta psg_sfx_lastfreqhi+4
  lda #8
  sta $4001
  sta $4005
  lda #0
  sta $4003
  sta $4007
  sta $400F
  sta psg_sfx_remainlen+0
  sta psg_sfx_remainlen+4
  sta psg_sfx_remainlen+8
  sta psg_sfx_remainlen+12
  sta music_playing
  lda #0
  sta $4011
  rts
.endproc

;;
; Starts a sound effect.
; (Trashes $0000-$0004 and X.)
;
; @param A sound effect number (0-63)
;
.proc start_sound
snddatalo = 0
snddatahi = 1
sndchno = 2
sndlen = 3
sndrate = 4

  asl a
  asl a
  tax
  lda psg_sound_table,x
  sta snddatalo
  lda psg_sound_table+1,x
  sta snddatahi
  lda psg_sound_table+2,x
  and #$0C
  sta sndchno
  lda psg_sound_table+2,x
  lsr a
  lsr a
  lsr a
  lsr a
  sta sndrate
  
  lda psg_sound_table+3,x
  sta sndlen

  ; split up square wave sounds between $4000 and $4004
  .if ::SQUARE_POOLING
    lda sndchno
    bne not_ch0to4  ; if not ch 0, don't try moving it
      lda psg_sfx_remainlen+4
      cmp psg_sfx_remainlen
      bcs not_ch0to4
      lda #4
      sta sndchno
    not_ch0to4:
  .endif 

  ldx sndchno
  lda sndlen
  cmp psg_sfx_remainlen,x
  bcs ch_not_full
  rts
ch_not_full:

  lda snddatalo
  sta psg_sfx_datalo,x
  lda snddatahi
  sta psg_sfx_datahi,x
  lda sndlen
  sta psg_sfx_remainlen,x
  lda sndrate
  sta psg_sfx_rate,x
  lda #0
  sta psg_sfx_ratecd,x
  rts
.endproc


;;
; Updates sound effect channels.
;
.proc update_sound
  jsr update_music
  ldx #12
loop:
  jsr update_music_ch
  jsr update_one_ch
  dex
  dex
  dex
  dex
  bpl loop
  rts
.endproc

.proc update_one_ch

  ; At this point, the music engine should have left duty and volume
  ; in 2 and pitch in 3.
  lda psg_sfx_remainlen,x
  bne ch_not_done
  lda 2
  bne update_channel_hw

  ; Turn off the channel and force a reinit of the length counter.
  cpx #8
  beq not_triangle_kill
    lda #$30
  not_triangle_kill:
  sta $4000,x
  lda #$FF
  sta psg_sfx_lastfreqhi,x
  rts
ch_not_done:

  ; playback rate divider
  dec psg_sfx_ratecd,x
  bpl rate_divider_cancel
  lda psg_sfx_rate,x
  sta psg_sfx_ratecd,x

  ; fetch the instruction
  lda psg_sfx_datalo+1,x
  sta 1
  lda psg_sfx_datalo,x
  sta 0
  clc
  adc #2
  sta psg_sfx_datalo,x
  bcc :+
  inc psg_sfx_datahi,x
:
  ldy #0
  .if ::KEEP_MUSIC_IF_LOUDER
    lda 2
    and #$0F
    sta 4
    lda (0),y
    and #$0F
    
    ; At this point: A = sfx volume; 4 = musc volume
    cmp 4
    bcc music_was_louder
  .endif
  lda (0),y
  sta 2
  iny
  lda (0),y
  sta 3
music_was_louder:
  dec psg_sfx_remainlen,x

update_channel_hw:
  lda 2
  ora #$30
  cpx #12
  bne notnoise
  sta $400C
  lda 3
  sta $400E
rate_divider_cancel:
  rts

notnoise:
  sta $4000,x
  ldy 3
  lda tvSystem
  beq :+
  iny
:
  lda periodTableLo,y
  sta $4002,x
  lda periodTableHi,y
  cmp psg_sfx_lastfreqhi,x
  beq no_change_to_hi_period
  sta psg_sfx_lastfreqhi,x
  sta $4003,x
no_change_to_hi_period:

  rts
.endproc

.segment "RODATA"
psg_sound_table:
  .addr turn_snd
  .byt 0, 18
  .addr shift_snd
  .byt 0, 2
  .addr land_snd
  .byt 16+0, 15
  .addr lock_snd
  .byt 12, 2
  .addr threat1_snd
  .byt 0, 21

  .addr threat2_snd
  .byt 16+0, 10
  .addr shoot_snd
  .byt 64+12, 7
  .addr die1_snd
  .byt 48+0, 17
  .addr die2_snd
  .byt 48+12, 16
  .addr snare_snd
  .byt 12, 7

  .addr kick_snd
  .byt 12, 3

; alternating duty/volume and pitch bytes

turn_snd:
  .byt $4F, $24, $44, $24
  .byt $4F, $29, $44, $29
  .byt $4F, $2E, $44, $2E
  .byt $44, $24, $42, $24
  .byt $44, $29, $42, $29
  .byt $44, $2E, $42, $2E
  .byt $42, $24, $41, $24
  .byt $42, $29, $41, $29
  .byt $42, $2E, $41, $2E
shift_snd:
  .byt $4F, $30, $44, $30
land_snd:
  .byt $8F, $12, $4F, $0F, $8E, $0C
  .byt $0E, $0E, $8D, $0C, $4C, $0A
  .byt $8B, $0B, $0A, $09, $89, $06
  .byt $48, $08, $87, $07, $06, $05
  .byt $84, $06, $42, $04, $81, $03
lock_snd:
  .byt $06, $03, $03, $03
threat1_snd:
  .byt $46, $1F
  .byt $4C, $1F, $4C, $1F, $4C, $25, $4C, $25
  .byt $4C, $2B, $4C, $2B, $4C, $31, $4C, $31
  .byt $4C, $31, $4C, $31, $4C, $31, $4C, $31, $4C, $31, $4C, $31
  .byt $4C, $31, $4B, $31, $4A, $31, $49, $31, $47, $31, $45, $31
threat2_snd:
  .byt $4C, $1C, $4C, $22
  .byt $4C, $28, $4C, $2E
  .byt $4C, $2E, $4C, $2E, $4C, $2E, $4B, $2E, $49, $2E, $46, $2E
shoot_snd:
  .byt $0A, $03, $08, $04, $07, $04, $06, $05
  .byt $04, $06, $03, $06, $02, $06
die1_snd:
  .byt $0F, $07
  .byt $0F, $07
  .byt $0E, $07
  .byt $0D, $07
  .byt $0C, $07
  .byt $0B, $07
  .byt $0A, $07
  .byt $09, $07
  .byt $08, $07
  .byt $07, $07
  .byt $06, $07
  .byt $05, $07
  .byt $04, $07
  .byt $03, $07
  .byt $02, $07, $01, $07, $01, $07
die2_snd:
  .byt $0F, $0E
  .byt $0E, $0D
  .byt $0D, $0E
  .byt $0C, $0E
  .byt $0B, $0E
  .byt $0A, $0F
  .byt $09, $0E
  .byt $08, $0E
  .byt $07, $0F
  .byt $06, $0E
  .byt $05, $0F
  .byt $04, $0E
  .byt $03, $0F
  .byt $02, $0E, $01, $0F, $01, $0F
snare_snd:
  .byt $0A, $05, $08, $04, $06, $04
  .byt $04, $04, $03, $04, $02, $04, $01, $04
kick_snd:
  .byt $08,$04,$08,$0E,$04,$0E
  .byt $05,$0E,$04,$0E,$03,$0E,$02,$0E,$01,$0E
