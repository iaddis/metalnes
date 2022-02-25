;
; NES controller reading code (for Arkanoid controller)
; Copyright 2013 Damian Yerrick
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies.  This file is offered as-is, without any warranty.
;

.exportzp cur_keys_d0, cur_keys_d1, cur_keys_d3, cur_keys_d4
.export read_all_pads
.segment "ZEROPAGE"
cur_keys_d0: .res 2
cur_keys_d1: .res 2
cur_keys_d3: .res 2
cur_keys_d4: .res 2

.segment "CODE"
.proc read_all_pads
  ; $4016 output pulse: copy sample to shift register and
  ; start taking new sample from potentiometer
  lda #1
  sta $4016
  sta cur_keys_d4
  lsr a
  sta $4016
bitloop:
  ldx #1
portloop:
  lda $4016,x
  lsr a
  rol cur_keys_d0,x
  lsr a
  rol cur_keys_d1,x
  lsr a
  lsr a
  rol cur_keys_d3,x
  lsr a
  rol cur_keys_d4,x
  dex
  bpl portloop
  bcc bitloop
  rts
.endproc

; Famicom, no expansion controllers
; NES, standard controllers in 7-pin ports
; cur_keys_d0+0 = controller 1
; cur_keys_d0+1 = controller 2

; Famicom, standard controllers in 15-pin port
; cur_keys_d1+0 = controller 3
; cur_keys_d1+1 = controller 4

; Famicom, Arkanoid controller in 15-pin port
; cur_keys_d1+0 = $FF if pressed, $00 if not
; cur_keys_d1+1 = Position (increases counterclockwise)

; NES, Arkanoid controller in 7-pin port (usually port 2)
; cur_keys_d3+x = $FF if pressed, $00 if not
; cur_keys_d4+x = Position (increases counterclockwise)

; Famicom, Zapper in 15-pin port (always port 2)
; NES, Zapper in 7-pin port (usually port 2)
; cur_keys_d3+x = $FF if dark, $00 if light or unplugged
; cur_keys_d4+x = $FF if pressed, $00 if not

