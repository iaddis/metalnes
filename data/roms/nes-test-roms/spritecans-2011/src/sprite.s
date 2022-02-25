;
; sprite.asm
; 64 Sprite Cans intro for NES
; Copyright 2000-2011 Damian Yerrick

;;; Copyright (C) 2000-2011 Damian Yerrick
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

.include "src/nes.h"
.p02
.import getTVSystem, init_music, init_sound, update_sound
.exportzp nmis, psg_sfx_state, tvSystem

NTSC_INCREASE_TIME =  98  ; 3606*3/110
PAL_INCREASE_TIME  =  82 ; 3000*3/110

; This program runs on NROM-128 (mapper 0), with only 4 KiB of PRG
; and 2.5 KiB of CHR actually used.
.segment "INESHDR"
  .byt "NES",$1A
  .byt $01  ; one PRG bank
  .byt $01  ; one CHR bank
  .byt $00  ; mapper bits 3-0; no battery
  .byt $00  ; mapper bits 7-4

.segment "ZEROPAGE"

; Work around the 8 sprites per scanline limitation by constantly
; shuffling priorities.  Konami games use this algorithm.
firstsproffset: .res 1  ; offset to start writing sprites to
                        ; each frame, firstsproffset += 60
cursproffset: .res 1    ; offset to write next sprite to
                        ; for each sprite written, cursproffset += 68
tvSystem: .res 1        ; 0: ntsc; 1: pal; 2: dendy
nmis: .res 2            ; 16-bit number of elapsed vblanks
psg_sfx_state: .res 32  ; used by music engine

last_active_can: .res 1  ; (this + 1) cans are drawn
till_increase: .res 1    ; increase cans once per measure


OAM = $200           ; sprite dma communication area

.segment "BSS"
NUM_CANS = 64
canXLo: .res NUM_CANS
canXHi: .res NUM_CANS
canYLo: .res NUM_CANS
canYHi: .res NUM_CANS
canDXLo: .res NUM_CANS
canDYLo: .res NUM_CANS
canTheta: .res NUM_CANS
canDTheta: .res NUM_CANS

.segment "CODE"

.proc resetpoint
  cld
  sei
  ldx #$FF
  txs
  inx  ; turn off nmis and rendering
  stx PPUCTRL
  stx PPUMASK
  bit PPUSTATUS

vwait1:
  bit PPUSTATUS
  bpl vwait1

  txa
ramclrloop:
  sta $00,x
  sta $100,x
  sta $600,x
  sta $700,x
  sta $300,x
  sta $400,x
  sta $500,x
  inx
  bne ramclrloop

;clear OAM
oamclrloop:
  lda #$FF  ; y offscreen
  sta OAM,x
  inx
  inx
  inx
  inx
  bne oamclrloop

vwait2:
  bit PPUSTATUS
  bpl vwait2

; initialize palette
  lda #$3F
  sta PPUADDR
  stx PPUADDR
copypalloop:
  lda titlepal,x
  sta PPUDATA
  inx
  cpx #32
  bne copypalloop

; copy nametable
  lda #<obeydata
  sta 0
  lda #>obeydata
  sta 1
  jsr copynametable

; initialize sprite cans
  ldx #NUM_CANS - 1
setupCanPos:
  lda #0
  sta canXLo,x
  sta canYLo,x
  
  ; can't have 128 as the velocity because the bounce code fails if
  ; x == -x.  The value 128 is in 0-63, so use 0-127 for positions
  ; and 128-255 for velocities.
  lda randnos+128,x
  sta canDXLo,x
  lda randnos+192,x
  sta canDYLo,x
  txa
  sta canTheta,x
  lda randnos+0,x
  cmp #224
  bcc @canNotPastBottom
  eor #%10000000
@canNotPastBottom:
  sta canYHi,x
  lda randnos+64,x
  cmp #248
  bcc @canNotPastRight
  eor #%10000000
@canNotPastRight:
  sta canXHi,x
  txa
  lsr a
  lsr a
  lsr a
  sec
  sbc #4
  sta canDTheta,x
  dex
  bpl setupCanPos
  jsr getTVSystem
  sta tvSystem

  lda #NUM_CANS-1
  sta last_active_can
  jsr sortCans
  lda #0
  sta last_active_can
  lda #NTSC_INCREASE_TIME
  ldy tvSystem
  beq @initialNotPAL
  lda #PAL_INCREASE_TIME
@initialNotPAL:
  sta till_increase

  jsr init_sound
  lda #0          ; start "Celestial Soda Pop"
  jsr init_music
  lda #VBLANK_NMI
  sta PPUCTRL

mainloop:
  jsr update_sound

  ; In the early warmup of the intro, increase the number of
  ; sprites until all 64 are on screen.
  dec till_increase
  bne no_increase_yet
  lda last_active_can
  cmp #NUM_CANS - 1
  bcs no_increase_yet
  sec
  rol last_active_can
  lda #NTSC_INCREASE_TIME
  ldy tvSystem
  beq @increaseNotPAL
  lda #PAL_INCREASE_TIME
@increaseNotPAL:
  sta till_increase
no_increase_yet:  

  ldy firstsproffset
  tya
  clc
  adc #60
  sta firstsproffset
  ldx last_active_can
moveCanLoop:

  ; move can horizontally
  lda canDXLo,x
  bpl :+
  dec canXHi,x
:
  clc
  adc canXLo,x
  sta canXLo,x
  bcc :+
  inc canXHi,x
:
  ; does it need to bounce off the left/right wall?
  lda canXHi,x
  cmp #248
  bcc :+
  lda #0
  sbc canDXLo,x
  sta canDXLo,x
:

  ; move can vertically
  lda canDYLo,x
  bpl :+
  dec canYHi,x
:
  clc
  adc canYLo,x
  sta canYLo,x
  bcc :+
  inc canYHi,x
:
  lda canYHi,x

  ; does it need to bounce off the bottom/top wall?
  cmp #224
  bcc :+
  lda #0
  sbc canDYLo,x
  sta canDYLo,x
:

  ; rotate the can
  lda canTheta,x
  clc
  adc canDTheta,x
  sta canTheta,x
  and #%11110000
  lsr a
  lsr a
  lsr a
  ora #%10000000
  
  ; now actually draw the can
  sta OAM+1,y
  lda #%00100001  ; behind bg, basecolor=$3F14
  sta OAM+2,y
  
  lda canXHi,x
  cmp #252
  bcc :+
  lda #0
:
  sta OAM+3,y
  lda canYHi,x
  cmp #248
  bcc :+
  lda #0
:
  sta OAM,y

  tya
  clc
  adc #68
  tay
  dex
  bpl moveCanLoop

  ; clear out sprite space used for inactive cans

  lda last_active_can
  eor #$3F
  beq allCansActive
  tax
eraseInactiveCanLoop:
  lda #$FF
  sta OAM,y
  tya
  clc
  adc #68
  tay
  dex
  bne eraseInactiveCanLoop
  lda last_active_can
  beq noSortNeeded  
allCansActive:
  jsr sortCans
noSortNeeded:

  jsr wait4vbl
  ; If the time since power on is correct,
  ; erase the boot message.
  lda nmis    ;erase
  bne @noerasemsg
  lda nmis+1
  cmp #2
  bne @noerasemsg

  lda #$21
  sta PPUADDR
  lda #$c0
  sta PPUADDR
  ldx #32
  lda #0
@eraseloop:
  .repeat 4
    sta PPUDATA
  .endrepeat
  dex
  bne @eraseloop
@noerasemsg:

  ; Copy sprite display list to the PPU
  lda #0
  sta PPUSCROLL
  sta PPUSCROLL
  sta OAMADDR
  lda #>OAM
  sta OAM_DMA

  lda #VBLANK_NMI|OBJ_8X16
  sta PPUCTRL
  lda #BG_ON|OBJ_ON
  sta PPUMASK

  jmp mainloop
.endproc



;;
; Does one pass of bubble sort on the sprites by their X coordinates.
.proc sortCans
  ldx #0
sortloop:
  lda canXHi,x    ; compare the sprites' X coordinates
  cmp canXHi+1,x
  bcs noSwap
  jsr swapCans
noSwap:
  inx
  cpx last_active_can      
  bcc sortloop
  rts
.endproc


;;
; Swaps a pair of sprites x and x+1.
.proc swapCans
  ldy canXHi,x
  lda canXHi+1,x
  sta canXHi,x
  tya
  sta canXHi+1,x

  ldy canXLo,x
  lda canXLo+1,x
  sta canXLo,x
  tya
  sta canXLo+1,x

  ldy canDXLo,x
  lda canDXLo+1,x
  sta canDXLo,x
  tya
  sta canDXLo+1,x

  ldy canYHi,x
  lda canYHi+1,x
  sta canYHi,x
  tya
  sta canYHi+1,x

  ldy canYLo,x
  lda canYLo+1,x
  sta canYLo,x
  tya
  sta canYLo+1,x

  ldy canDYLo,x
  lda canDYLo+1,x
  sta canDYLo,x
  tya
  sta canDYLo+1,x

  ldy canTheta,x
  lda canTheta+1,x
  sta canTheta,x
  tya
  sta canTheta+1,x

  ldy canDTheta,x
  lda canDTheta+1,x
  sta canDTheta,x
  tya
  sta canDTheta+1,x
  rts
.endproc


;;
; Copies a name table from address in 0 to CIRAM $2000.
.proc copynametable
src = 0

  ldy #VBLANK_NMI
  sty PPUCTRL
  lda #$20
  sta PPUADDR
  ldy #$00
  sty PPUADDR
  ldx #4
copyloop:
  .repeat 2
    lda (src),y
    sta PPUDATA
    iny
  .endrepeat
  bne copyloop
  inc src+1
  dex
  bne copyloop

  rts
.endproc

;;
; Waits for vertical blanking.
.proc wait4vbl
  lda nmis
notyet:
  cmp nmis
  beq notyet
  rts
.endproc

;;
; Increments retrace count for wait4vbl and other logic.
.proc nmipoint
  inc nmis
  bne nohi
  inc nmis+1
nohi:
  rti
.endproc

;;
; IRQ handler that does nothing because doesn't use
; mapper IRQs, APU frame IRQs, or DPCM IRQs.
.proc irqpoint
  rti
.endproc

;
; DATA TABLES
;

.segment "RODATA"

obeydata: .incbin "src/sprite.nam"  ; made with 8name II
randnos:  ; per http://en.wikipedia.org/wiki/Rijndael_S-box
  .byt  99,124,119,123,242,107,111,197, 48,  1,103, 43,254,215,171,118
  .byt 202,130,201,125,250, 89, 71,240,173,212,162,175,156,164,114,192
  .byt 183,253,147, 38, 54, 63,247,204, 52,165,229,241,113,216, 49, 21
  .byt   4,199, 35,195, 24,150,  5,154,  7, 18,128,226,235, 39,178,117
  .byt   9,131, 44, 26, 27,110, 90,160, 82, 59,214,179, 41,227, 47,132
  .byt  83,209,  0,237, 32,252,177, 91,106,203,190, 57, 74, 76, 88,207
  .byt 208,239,170,251, 67, 77, 51,133, 69,249,  2,127, 80, 60,159,168
  .byt  81,163, 64,143,146,157, 56,245,188,182,218, 33, 16,255,243,210
  .byt 205, 12, 19,236, 95,151, 68, 23,196,167,126, 61,100, 93, 25,115
  .byt  96,129, 79,220, 34, 42,144,136, 70,238,184, 20,222, 94, 11,219
  .byt 224, 50, 58, 10, 73,  6, 36, 92,194,211,172, 98,145,149,228,121
  .byt 231,200, 55,109,141,213, 78,169,108, 86,244,234,101,122,174,  8
  .byt 186,120, 37, 46, 28,166,180,198,232,221,116, 31, 75,189,139,138
  .byt 112, 62,181,102, 72,  3,246, 14, 97, 53, 87,185,134,193, 29,158
  .byt 225,248,152, 17,105,217,142,148,155, 30,135,233,206, 85, 40,223
  .byt 140,161,137, 13,191,230, 66,104, 65,153, 45, 15,176, 84,187, 22


; palette
titlepal:
  .byt $0f,$00,$10,$30,$0f,$12,$1a,$30,$0f,$1a,$2c,$30,$0f,$12,$14,$30
  .byt $0f,$00,$10,$30,$0f,$12,$1a,$30,$0f,$1a,$2c,$30,$0f,$12,$14,$30

.segment "VECTORS"
  .addr nmipoint, resetpoint, irqpoint
