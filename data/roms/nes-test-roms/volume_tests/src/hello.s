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

.p02

PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
PPUADDR = $2006
PPUDATA = $2007
OAM_DMA = $4014
P1 = $4016
P2 = $4017

.exportzp cur_keys, new_keys, retraces
.import read_pads
.import init_sound, volume_test

.segment "INESHDR"
  .byt "NES", $1a
  .byt 1, 1, 0, 0
  .res 8

.segment "ZEROPAGE"

cur_keys: .res 2
new_keys: .res 2
retraces: .res 1
psg_sfx_state: .res 16


.segment "CODE"
nmi:
  inc retraces
irq:
  rti

reset:
  sei
  ldx #0
  stx PPUCTRL
  stx PPUMASK
  dex
  txs
  lda #$40
  sta P2
  bit PPUSTATUS
  cld  ; no effect on NES; helps in generic 6502 debuggers

  jsr init_sound
@waitvbl1:
  bit PPUSTATUS
  bpl @waitvbl1
  lda #0
  tax
@clrram:
  sta 0,x
  sta $100,x
  sta $300,x
  sta $400,x
  sta $500,x
  sta $600,x
  sta $700,x
  inx
  bne @clrram
@waitvbl2:
  bit PPUSTATUS
  bpl @waitvbl2

  ; write palette
  lda #$3F
  sta PPUADDR
  ldx #$00
  stx PPUADDR
  lda #$0D
  sta PPUDATA
  lda #$1A
  sta PPUDATA
  lda #$2A
  sta PPUDATA
  lda #$3A
  sta PPUDATA
  stx PPUADDR
  stx PPUADDR

  lda #%10000000
  sta PPUCTRL

forever:
  lda retraces
:
  cmp retraces
  beq :-
  jsr read_pads

  lda new_keys
  bpl @not_p1A
  jsr volume_test
@not_p1A:

  jmp forever




.segment "VECTORS"
  .addr nmi, reset, irq