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


JOY1      = $4016
JOY2      = $4017


.export read_pads
.importzp cur_keys, new_keys
read_pads:

  ; store the current keypress state to detect key-down later
  lda cur_keys
  sta 4
  lda cur_keys+1
  sta 5

  ; read the joypads twice
  jsr read_pads_once
  lda 0
  sta 2
  lda 1
  sta 3
  jsr read_pads_once

  ldx #1
@fixupKeys:

  ; if the player's keys read out the same ways both times, update
  lda 0,x
  cmp 2,x
  bne @dontUpdateGlitch
  sta cur_keys,x
@dontUpdateGlitch:
  
  lda 4,x   ; A = keys that were down last frame
  eor #$FF  ; A = keys that were up last frame
  and cur_keys,x  ; A = keys down now and up last frame
  sta new_keys,x
  dex
  bpl @fixupKeys
  rts

read_pads_once:
  lda #1
  sta 0
  sta 1
  sta JOY1
  lda #0
  sta JOY1
  loop:
    lda JOY1
    and #$03
    cmp #1
    rol 0
    lda JOY2
    and #$03
    cmp #1
    rol 1
    bcc loop
  rts
