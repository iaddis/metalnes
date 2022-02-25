; Copyright 2010 Damian Yerrick
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty
; provided the copyright notice and this notice are preserved.
; This file is offered as-is, without any warranty.

PPUCTRL = $2000
  VBLANK_NMI = $80
PPUMASK = $2001
  TINT_B = $80
  TINT_G = $40
  TINT_R = $20
  OBJ_CLIP = $10
  OBJ_ON = $14
  BG_CLIP = $08
  BG_ON = $0A
  LIGHTGRAY = $01
PPUSTATUS = $2002
  ; N is NMI_occurred, used primarily for PPU warmup wait after reset
  ; V is sprite 0 hit status, cleared at end of vblank
OAMADDR = $2003
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007
DMCFREQ = $4010
  DMC_IRQMODE = $80
  DMC_LOOPMODE = $40
DMCADDR = $4012
DMCLEN = $4013
OAM_DMA = $4014
SNDCHN = $4015
  SNDCHN_PSGS = $0F
  SNDCHN_DMC = $10
P1 = $4016
P2 = $4017


