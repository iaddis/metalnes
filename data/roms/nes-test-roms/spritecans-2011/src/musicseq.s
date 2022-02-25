;
; Music sequence data for Sprite Cans Demo
; Copyright 2010 Damian Yerrick
; Copyright 1984 Ray Lynch
;
; To the extent permitted by law, copying and distribution of this
; file, with or without modification, are permitted in any medium
; without royalty provided the copyright notice and this notice are
; preserved in all copies of the source code.
; This file is offered as-is, without any warranty.
;

.include "src/musicseq.h"

.segment "RODATA"

musicPatternTable:
  .addr csp_pat_warmup
  .addr csp_pat_melody_warmup
  .addr csp_pat_backing_loop
  .addr csp_pat_melody_loop
  .addr csp_pat_bass_loop
  .addr csp_pat_bass_end

drumSFX:
  .byt 10, 9, 3
KICK  = 0*8
SNARE = 1*8
CLHAT = 2*8

instrumentTable:
  ; first byte: initial duty (0/4/8/c) and volume (1-F)
  ; second byte: volume decrease every 16 frames
  ; third byte:
  ; bit 7: cut note if half a row remains
  .byt $88, 8, $00, 0  ; bass
  .byt $48, 4, $00, 0  ; song start bass
  .byt $87, 3, $00, 0  ; bell between rounds
  .byt $87, 2, $00, 0  ; xylo

songTable:
  .addr csp_conductor

;____________________________________________________________________

csp_conductor:
  setTempo 440
  playPatSq2 0, 3, 1
  waitRows 12*6
  playPatSq1 1, 15, 2
  waitRows 12*18
  segno
  playPatSq2 2, 7, 1
  waitRows 12*2
  playPatSq1 3, 27, 2
  playPatTri 4, 14, 0
  waitRows 12*18
  playPatTri 5, 16, 0
  waitRows 12*2
  dalSegno

csp_pat_warmup:
  .byt N_CSH|D_D2
  .byt N_CSH|D_D2
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8

  ; melody cuts in
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_B|D_D8, N_B|D_D8, N_B|D_D8, N_B|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_GS|D_D8, N_GS|D_D8, N_GS|D_D8, N_GS|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_EH|D_D8, N_EH|D_D8, N_EH|D_D8, N_EH|D_D8
  .byt N_B|D_D8, N_B|D_D8, N_B|D_D8, N_B|D_D8
  .byt N_EH|D_D8, N_EH|D_D8, N_EH|D_D8, N_EH|D_D8
  .byt N_B|D_D8, N_B|D_D8, N_B|D_D8, N_B|D_D8
  .byt N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8, N_CSH|D_D8
  .byt N_GS|D_D8, N_GS|D_D8, N_GS|D_D8, N_GS|D_D8
  .byt N_A|D_D8, N_A|D_D8, N_A|D_D8, N_A|D_D8
  .byt N_A|D_D8, N_A|D_D8, N_A|D_D8, N_B|D_D8
  .byt 255

csp_pat_melody_warmup:
  .byt N_CSH|D_8, N_DSH|D_D8, N_EH|D_D8, N_FSH|D_D8, N_GSH|D_D8
  .byt N_FSH|D_D8, N_EH|D_D8, N_DSH, N_CSH|D_8, N_DSH|D_2
  .byt N_TIE, N_EH, N_DSH|D_8, N_CSH|D_2
  .byt N_TIE, N_CSH, N_B|D_8, N_CSH|D_D2
  .byt N_B
  .byt N_CSH|D_8, N_DSH|D_D8, N_EH|D_D8, N_FSH|D_D8, N_GSH|D_D8
  .byt N_FSH|D_D8, N_EH|D_D8, N_DSH, N_CSH|D_8, N_DSH|D_2
  .byt N_TIE, N_B, N_DSH|D_8, N_CSH|D_2
  .byt N_TIE, N_GS, N_B|D_8, N_CSH|D_2
  .byt N_TIE, N_EH, N_FSH|D_8, N_GSH|D_D8
  .byt N_GSH|D_D8, N_BH|D_4, N_EH|D_8, N_FSH|D_2
  .byt N_TIE, N_EH, N_FSH|D_8, N_GSH|D_D4
  .byt N_BH|D_4, N_GSH|D_8, N_FSH|D_2
  .byt N_TIE, N_EH, N_DSH|D_8, N_EH|D_D4
  .byt N_EH, N_DSH|D_8, N_CSH|D_4
  .byt N_DSH|D_4, N_TIE, N_DSH, N_CSH|D_D8, N_B|D_8, N_CSH|D_2
  .byt N_TIE, N_CSH|D_4
  .byt N_CSH|D_4, N_TIE, N_CSH, N_EH|D_8, N_DSH|D_4
  .byt N_CSH|D_D2
  .byt REST|D_D2

  .byt 255

csp_pat_backing_loop:
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  ; melody cuts in 
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_G|D_D8, N_GH|D_D8, N_G|D_D8, N_GH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_E|D_D8, N_EH|D_D8, N_E|D_D8, N_EH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_CH|D_D8, N_CHH|D_D8, N_CH|D_D8, N_CHH|D_D8
  .byt N_G|D_D8, N_GH|D_D8, N_G|D_D8, N_GH|D_D8
  .byt N_CH|D_D8, N_CHH|D_D8, N_CH|D_D8, N_CHH|D_D8
  .byt N_G|D_D8, N_GH|D_D8, N_G|D_D8, N_GH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_E|D_D8, N_EH|D_D8, N_E|D_D8, N_EH|D_D8
  .byt N_F|D_D8, N_FH|D_D8, N_F|D_D8, N_FH|D_D8
  .byt N_F|D_D8, N_FH|D_D8, N_G|D_D8, N_GH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt N_A|D_D8, N_AH|D_D8, N_A|D_D8, N_AH|D_D8
  .byt 255

csp_pat_melody_loop:
  .byt N_CSH|D_8, N_DSH|D_D8, N_EH|D_D8, N_FSH|D_D8, N_GSH|D_D8
  .byt N_FSH|D_D8, N_EH|D_D8, N_DSH, N_CSH|D_8, N_DSH|D_2
  .byt N_TIE, N_EH, N_DSH|D_8, N_CSH|D_2
  .byt N_TIE, N_B, N_GS|D_8, N_CSH|D_D2
  .byt N_B
  .byt N_CSH|D_8, N_DSH|D_D8, N_EH|D_D8, N_FSH|D_D8, N_GSH|D_4
  .byt N_FSH|D_D8, N_EH|D_8, N_DSH, N_CSH|D_8, N_DSH|D_D4
  .byt N_TIE, N_GS, N_B, N_CSH, N_DSH, N_EH, N_DSH
  .byt N_CSH|D_4, N_TIE, N_CSH|D_D8, N_B, N_GS|D_8, N_CSH|D_2
  .byt N_TIE, N_EH, N_FSH|D_8, N_GSH|D_D8
  .byt N_GSH|D_D8, N_BH|D_4, N_EH|D_8, N_FSH|D_2
  .byt N_TIE, N_EH, N_FSH|D_8, N_GSH|D_D4
  .byt N_BH|D_4, N_GSH|D_8, N_FSH|D_2
  .byt N_TIE, N_EH, N_DSH|D_8, N_EH|D_D4
  .byt N_EH, N_DSH|D_8, N_CSH|D_4
  .byt N_DSH|D_4, N_TIE, N_DSH, N_CSH|D_D8, N_B|D_8, N_CSH|D_D4
  .byt N_CSH|D_D4, N_CSH|D_D4
  .byt N_CSH, N_EH|D_8, N_DSH|D_4
  .byt N_CSH|D_D2
  .byt REST|D_D2
  .byt REST|D_D2
  .byt REST|D_D2

  .byt 255
csp_pat_bass_loop:
  .byt N_DH|D_2, N_A|D_4
  .byt N_D|D_2, N_D, N_A|D_D8
  .byt N_G|D_D4, N_C|D_D4
  .byt N_D|D_2, N_A|D_4
  .byt N_DH|D_D2
  .byt N_DH|D_2, N_A|D_4
  .byt N_D|D_2, N_D, N_A|D_D8
  .byt N_E|D_2, N_TIE, N_A|D_D8
  .byt N_D|D_2, N_TIE, N_A|D_D8
  .byt N_DH|D_D2
  .byt REST|D_4, REST, N_CHH|D_D8, N_FH, N_CH|D_8, N_F
  .byt N_C|D_D8, N_C|D_D8, N_C|D_D4
  .byt REST|D_4, REST, N_CHH|D_D8, N_FH, N_CH|D_8, N_F
  .byt N_C|D_D8, N_C|D_D8, N_C|D_D4
  .byt REST|D_4, REST, N_A, N_DH|D_8, N_AH|D_4
  .byt REST|D_4, REST, N_A, N_EH|D_8, N_AH|D_4
  .byt REST|D_2, N_AS, N_FH|D_8, N_ASH|D_D4
  .byt N_FH, N_BB|D_8, N_CH|D_4
  .byt 255
csp_pat_bass_end:
  .byt N_CH|D_2, N_G|D_4
  .byt N_C|D_2, N_G|D_4
  .byt N_CH|D_2, N_GH|D_4
  .byt N_CHH|D_2, N_CHH, N_GH|D_D8
  .byt 255
