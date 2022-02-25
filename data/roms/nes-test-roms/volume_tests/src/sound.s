; Copyright (c) 2009 Damian Yerrick
;
; This work is provided 'as-is', without any express or implied
; warranty. In no event will the authors be held liable for any
; damages arising from the use of this work.
;
; Permission is granted to anyone to use this work for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
;  1. The origin of this work must not be misrepresented; you
;     must not claim that you wrote the original work. If you use
;     this work in a product, an acknowledgment in the product
;     documentation would be appreciated but is not required.
;  2. Altered source versions must be plainly marked as such,
;     and must not be misrepresented as being the original work.
;  3. This notice may not be removed or altered from any
;     source distribution.
;
; The term "source" refers to the preferred form of a work for making
; changes to it. 


.export init_sound, volume_test
.importzp retraces

SNDCHN = $4015

.segment "ZEROPAGE"
level4011: .res 1

.segment "CODE"

;;
; Initializes all sound channels.
;
.proc init_sound
  ldx #$00
  stx SNDCHN
  lda #$0F
  sta SNDCHN
  lda #$30
  sta $4000
  sta $4004
  sta $400C
  lda #8
  sta $4001
  sta $4005
  stx $4003
  stx $4007
  stx $400F
  stx $4011
  rts
.endproc

;;
.proc volume_test
  ; 1. square wave 1
  ; 2. square wave 1 + 2
  ; 3. triangle
  ; 4. noise
  ; 5. raw dac

  lda #0
  sta level4011
  sta $4011
  ldy #4
  jsr wait_frames

  loop4011:
    lda level4011
    sta $4011

    ldy #0
    jsr test_square_waves
    ldy #1
    jsr test_square_waves
    jsr test_triangle_wave
    ldy #2
    jsr test_square_waves
    jsr test_raw_4011

    lda level4011
    clc
    adc #$30
    bmi done
    tax
    jsr ramp_4011_to_x
    jmp loop4011
  done:    

  rts
.endproc

.proc ramp_4011_to_x
  cpx level4011
  beq done
  bcc done
  inc level4011
  lda level4011
  sta $4011
  ldy #200
  :
    dey
    bne :-
  jmp ramp_4011_to_x
done:
  rts
.endproc


;;
; y: nonzero if using $4004; zero if only using $4000
.proc test_square_waves

mask4000 = 0
mask4004 = 1
mask400C = 2
volumeCountdown = 3
duty = 4

  cpy #1
  beq mode1
  cpy #2
  beq mode2

  ; mode 0: one square wave, four duty cycles
  ldy #$FF
  sty mask4000
  iny
  sty mask4004
  sty mask400C
  jmp begin_test

mode1:
  ; two unison square waves, four duty cycles
  ldy #$FF
  sty mask4000
  sty mask4004
  iny
  sty mask400C
  jmp begin_test

mode2:
  ; one noise wave, two duty cycles
  ldy #$FF
  sty mask400C
  iny
  sty mask4000
  sty mask4004

begin_test:
  lda #$30
  sta duty
  doOneDuty:
    lda #15
    sta volumeCountdown
    lda #$30
    sta $4000
    sta $4004
    sta $400C
    lda #111
    sta $4002
    sta $4006
    lda duty
    ora #$02
    sta $400E
    lda #0
    sta $4003
    sta $4007
    sta $400F

    ldy #8
    jsr wait_frames

    doOneVolume:
      lda volumeCountdown
      ora duty
      and mask4000
      sta $4000
      lda volumeCountdown
      ora duty
      and mask4004
      sta $4004
      lda volumeCountdown
      ora #$30
      and mask400C
      sta $400C
      ldy #4
      jsr wait_frames
      dec volumeCountdown
      bpl doOneVolume

    ; go to next duty
    ; in mode 0, 1: $30, $70, $B0, $F0
    ; in mode 2: $30, $F0
    lda mask400C
    and #$80
    ora duty
    clc
    adc #$40
    sta duty
    bcc doOneDuty
  rts
.endproc

.proc test_triangle_wave
  lda #$00
  sta $4008
  ldy #8
  jsr wait_frames
  lda #$81
  sta $4008
  lda #55
  sta $400A
  lda #0
  sta $400B
  ldy #60
  jsr wait_frames
  lda #0
  sta $4008
  ldy #4
  jsr wait_frames
  rts
.endproc

.proc test_raw_4011
  lda #<(65536-997)
  sta 0
  lda #>(65536-997)
  sta 1
  lda level4011
  sta $4011

  clc
  adc #30
  sta 2
  ldy #8
  jsr wait_frames
  loop:

    ; The top and bottom halves of this wave are 896 cycles each.
    ; TOP HALF: 7 to move speaker, 889 to waste
    ldx 2
    stx $4011
    ldy #890/5
    :
      dey
      bne :-

    ; BOTTOM HALF: 7 to move speaker, 868 to waste, 21 to loop
    lda level4011
    sta $4011
    ldy #865/5
    :
      dey
      bne :-
    lsr a
    lsr a
    sec
    lda #0
    adc 0
    sta 0
    lda #0
    adc 1
    sta 1
    bcc loop

  ldy #20
  jsr wait_frames

waste12:
  rts
.endproc   


.proc wait_frames
  lda retraces
:
  cmp retraces
  beq :-
  dey
  bne wait_frames
  rts
.endproc
