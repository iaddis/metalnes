;
; NES TV system detection code
; Copyright 2011 Damian Yerrick
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty
; provided the copyright notice and this notice are preserved.
; This file is offered as-is, without any warranty.
;
.export getTVSystem
.importzp nmis

.align 32  ; ensure that branches do not cross a page boundary

;;
; Detects which of NTSC, PAL, or Dendy is in use by counting cycles
; between NMIs.
;
; NTSC NES produces 262 scanlines, with 341/3 CPU cycles per line.
; PAL NES produces 312 scanlines, with 341/3.2 CPU cycles per line.
; Its vblank is longer than NTSC, and its CPU is slower.
; Dendy is a Russian famiclone distributed by Steepler that uses the
; PAL signal with a CPU as fast as the NTSC CPU.  Its vblank is as
; long as PAL's, but its NMI occurs toward the end of vblank (line
; 291 instead of 241) so that cycle offsets from NMI remain the same
; as NTSC, keeping Balloon Fight and any game using a CPU cycle-
; counting mapper (e.g. FDS, Konami VRC) working.
;
; nmis is a variable that the NMI handler modifies every frame.
; Make sure your NMI handler finishes within 1500 or so cycles (not
; taking the whole NMI or waiting for sprite 0) while calling this,
; or the result in A will be wrong.
;
; @return A: TV system (0: NTSC, 1: PAL, 2: Dendy; 3: unknown
;         Y: high byte of iterations used (1 iteration = 11 cycles)
;         X: low byte of iterations used
.proc getTVSystem
  ldx #0
  ldy #0
  lda nmis
nmiwait1:
  cmp nmis
  beq nmiwait1
  lda nmis

nmiwait2:
  ; Each iteration takes 11 cycles.
  ; NTSC NES: 29780 cycles or 2707 = $A93 iterations
  ; PAL NES:  33247 cycles or 3022 = $BCE iterations
  ; Dendy:    35464 cycles or 3224 = $C98 iterations
  ; so we can divide by $100 (rounding down), subtract ten,
  ; and end up with 0=ntsc, 1=pal, 2=dendy, 3=unknown
  inx
  bne :+
  iny
:
  cmp nmis
  beq nmiwait2
  tya
  sec
  sbc #10
  cmp #3
  bcc notAbove3
  lda #3
notAbove3:
  rts
.endproc

