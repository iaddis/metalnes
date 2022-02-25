; music.s
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

.importzp psg_sfx_state
.import soundBSS
.import start_sound
.importzp tvSystem
.export music_playing
.export init_music, stop_music, update_music, update_music_ch
.include "src/musicseq.h"

musicPatternPos = psg_sfx_state + 2
conductorPos = psg_sfx_state + 16
noteEnvVol = soundBSS + 0
notePitch = soundBSS + 1
noteRowsLeft = soundBSS + 2
; 3 is in sound.s
musicPattern = soundBSS + 16
patternTranspose = soundBSS + 17
noteInstrument = soundBSS + 18
; 19 is in sound.s
tempoCounterLo = soundBSS + 48
tempoCounterHi = soundBSS + 49
music_tempoLo = soundBSS + 50
music_tempoHi = soundBSS + 51
conductorSegno = soundBSS + 52

conductorWaitRows = soundBSS + 62
music_playing = soundBSS + 63

FRAMES_PER_MINUTE_PAL = 3000
FRAMES_PER_MINUTE_NTSC = 3606


.segment "RODATA"

fpmLo:
  .byt <FRAMES_PER_MINUTE_NTSC, <FRAMES_PER_MINUTE_PAL
fpmHi:
  .byt >FRAMES_PER_MINUTE_NTSC, >FRAMES_PER_MINUTE_PAL

silentPattern:
  .byt 26*8+7, 255
  
durations:
  .byt 1, 2, 3, 4, 6, 8, 12, 16

.segment "CODE"
.proc init_music
  asl a
  tax
  lda songTable,x
  sta conductorPos
  sta conductorSegno
  lda songTable+1,x
  sta conductorPos+1
  sta conductorSegno+1
  ldx #12
  stx music_playing
  channelLoop:
    lda #$FF
    sta musicPattern,x
    lda #<silentPattern
    sta musicPatternPos,x
    lda #>silentPattern
    sta musicPatternPos+1,x
    lda #0
    sta patternTranspose,x
    sta noteInstrument,x
    sta noteEnvVol,x
    sta noteRowsLeft,x
    dex
    dex
    dex
    dex
    bpl channelLoop
  lda #0
  sta conductorWaitRows
  lda #$FF
  sta tempoCounterLo
  sta tempoCounterHi
  lda #<300
  sta music_tempoLo
  lda #>300
  sta music_tempoHi
  rts
.endproc

.proc stop_music
  lda #0
  sta music_playing
  rts
.endproc

.proc update_music
  lda music_playing
  beq music_not_playing
  lda music_tempoLo
  clc
  adc tempoCounterLo
  sta tempoCounterLo
  lda music_tempoHi
  adc tempoCounterHi
  sta tempoCounterHi
  bcs new_tick
music_not_playing:
  rts
new_tick:

  ldy tvSystem
  beq is_ntsc_1
  ldy #1
is_ntsc_1:
  ; Subtract tempo
  lda tempoCounterLo
  sbc fpmLo,y
  sta tempoCounterLo
  lda tempoCounterHi
  sbc fpmHi,y
  sta tempoCounterHi

  ;jmp skipConductor

  lda conductorWaitRows
  beq doConductor
  dec conductorWaitRows
  jmp skipConductor

doConductor:

  ldy #0
  lda (conductorPos),y
  inc conductorPos
  bne :+
    inc conductorPos+1
  :
  sta 0
  cmp #CON_SETTEMPO
  bcc @notTempoChange
    and #%00000011
    sta music_tempoHi
  
    lda (conductorPos),y
    inc conductorPos
    bne :+
      inc conductorPos+1
    :
    sta music_tempoLo
    jmp doConductor
  @notTempoChange:
  cmp #CON_WAITROWS
  bcc conductorPlayPattern
  beq conductorDoWaitRows

  cmp #CON_FINE
  bne @notFine
    lda #0
    sta music_playing
    sta music_tempoHi
    sta music_tempoLo
    rts
  @notFine:

  cmp #CON_SEGNO
  bne @notSegno
    lda conductorPos
    sta conductorSegno
    lda conductorPos+1
    sta conductorSegno+1
    jmp doConductor
  @notSegno:

  cmp #CON_DALSEGNO
  bne @notDalSegno
    lda conductorSegno
    sta conductorPos
    lda conductorSegno+1
    sta conductorPos+1
    jmp doConductor
  @notDalSegno:

  jmp skipConductor

conductorPlayPattern:
  and #$03
  asl a
  asl a
  tax
  lda #0
  sta noteRowsLeft,x
  lda (conductorPos),y
  sta musicPattern,x
  iny
  lda (conductorPos),y
  sta patternTranspose,x
  iny
  lda (conductorPos),y
  sta noteInstrument,x
  tya
  sec
  adc conductorPos
  sta conductorPos
  bcc :+
    inc conductorPos+1
  :
  jsr startPattern
  jmp doConductor

  ; this should be last so it can fall into skipConductor
conductorDoWaitRows:

  lda (conductorPos),y
  inc conductorPos
  bne :+
    inc conductorPos+1
  :
  sta conductorWaitRows

skipConductor:

  ldx #12
  channelLoop:
    lda noteRowsLeft,x
    bne skipNote
    lda (musicPatternPos,x)
    cmp #255
    bne notStartPatternOver
      jsr startPattern
      lda (musicPatternPos,x)
    notStartPatternOver:
    
    inc musicPatternPos,x
    bne patternNotNewPage
      inc musicPatternPos+1,x
    patternNotNewPage:

    ; set the note's duration
    pha
    and #$07
    tay
    lda durations,y
    sta noteRowsLeft,x
    pla
    lsr a
    lsr a
    lsr a
    cmp #25
    bcc isTransposedNote
    beq notKeyOff
      lda #0
      sta noteEnvVol,x
    notKeyOff:
    jmp skipNote
    
    isTransposedNote:
      cpx #12
      beq isDrumNote
      adc patternTranspose,x
      sta notePitch,x
      lda noteInstrument,x
      asl a
      asl a
      tay  
      lda instrumentTable,y
      asl a
      asl a
      asl a
      asl a
      ora #$0C
      sta noteEnvVol,x
    
    skipNote:
    dec noteRowsLeft,x
    dex
    dex
    dex
    dex
    bpl channelLoop

  rts

isDrumNote:
  stx 5
  tax
  lda drumSFX,x
  jsr start_sound
  ldx 5
  jmp skipNote

startPattern:
  lda musicPattern,x
  asl a
  bcc @notSilentPattern
    lda #<silentPattern
    sta musicPatternPos,x
    lda #>silentPattern
    sta musicPatternPos+1,x
    rts
  @notSilentPattern:
  tay
  lda musicPatternTable,y
  sta musicPatternPos,x
  lda musicPatternTable+1,y
  sta musicPatternPos+1,x
  rts
.endproc

.proc update_music_ch
  ch_number = 0
  out_volume = 2
  out_pitch = 3

  lda music_playing
  beq silenced
  lda noteEnvVol,x
  lsr a
  lsr a
  lsr a
  lsr a
  bne notSilenced
silenced:
  lda #0
  sta 2
  rts
notSilenced:
  sta 2
  lda noteInstrument,x
  asl a
  asl a
  tay  
  lda 2
  eor instrumentTable,y
  and #$0F
  eor instrumentTable,y
  sta 2
  lda noteEnvVol,x
  sec
  sbc instrumentTable+1,y
  bcc silenced  
  sta noteEnvVol,x
  lda notePitch,x
  sta 3

  ; bit 7 of attribute 2: cut note when half a row remains
  lda instrumentTable+2,y
  bpl notCutNote
  lda noteRowsLeft,x
  bne notCutNote

  clc
  lda tempoCounterLo
  adc #<(FRAMES_PER_MINUTE_NTSC/2)
  lda tempoCounterHi
  adc #>(FRAMES_PER_MINUTE_NTSC/2)
  bcc notCutNote
  lda #0
  sta noteEnvVol,x

notCutNote:
  rts
.endproc

