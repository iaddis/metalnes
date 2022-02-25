PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007

P1 = $4016
P2 = $4017


.segment "ZEROPAGE"
retraces: .res 3
isPAL: .res 1
palstate: .res 1
joy1: .res 1
last_joy1: .res 1
joy1new: .res 1

.segment "VECTORS"
  .addr nmi, reset, irq

.segment "INESHDR"

  .byt "NES", 26
  .byt 1  ; number of 16 KB program segments
  .byt 1  ; number of 8 KB chr segments
  .byt 0  ; mapper, mirroring, etc
  .byt 0  ; extended mapper info
  .byt 0,0,0,0,0,0,0,0  ; f you DiskDude

.segment "CODE"
nmi:
  inc retraces
irq:
  rti

reset:
  sei
  lda #0
  sta PPUCTRL
  sta PPUMASK
  cld
  ldy #$40
  sty P2

  ldx #$FF
  txs

@warmup1:
  bit PPUSTATUS
  bpl @warmup1

; we have nearly 29000 cycles to init other parts of the NES
; so do it while waiting for the PPU to signal that it's warming up

@clearZP:
  sta $00,x
  dex
  bne @clearZP

; done with tasks; wait for warmup

@warmup2:
  bit PPUSTATUS
  bpl @warmup2

  jsr detectPAL


; Display television test

; Set palette
  ldx #0
  stx PPUMASK
  jsr setGrayPalette

.segment "RODATA"
healthScreen:
  .incbin "health.nam"
.segment "CODE"
  ldx #<healthScreen
  ldy #>healthScreen
  lda #$20
  jsr copyNT
  jsr displayLoop





tvTest:

  ; Skip this test on PAL
  lda isPAL
  beq :+
  jmp aspectRatioTest
:

; Set up initial palette
  ldx #0
  stx PPUMASK
  ldy #$3F
  sty PPUADDR
  stx PPUADDR
  sty PPUDATA
  sty PPUDATA
  sty PPUDATA
  sty PPUDATA
  sty PPUDATA
  stx PPUDATA
  lda #$10
  sta PPUDATA
  lda #$30
  sta PPUDATA


; Set up test screen
.segment "RODATA"
tvScreen:
  .incbin "tv.nam"
.segment "CODE"
  ldx #<tvScreen
  ldy #>tvScreen
  lda #$20
  jsr copyNT

tvLoop:
  ; wait for vertical blanking NMI
  lda PPUSTATUS
  lda #$80
  sta PPUCTRL
  lda retraces
:
  cmp retraces
  beq :-
  lda PPUSTATUS  ; acknowledge NMI

; Rewrite palette
  lda #0
  sta PPUMASK
  inc palstate
  lda palstate
  cmp #192
  bcc :+
  lda #0
  sta palstate
:
  lsr a
  lsr a
  lsr a
  lsr a
  clc
  adc #$21

  ldy #$3F
  sty PPUADDR
  ldy #1
  sty PPUADDR

  sta PPUDATA
  clc
  adc #4
  cmp #$2D
  bcc :+
  sbc #$0C
:
  sta PPUDATA
  clc
  adc #4
  cmp #$2D
  bcc :+
  sbc #$0C
:
  sta PPUDATA

; Turn on screen
  lda #$00
  sta PPUSCROLL
  sta PPUSCROLL
  lda #$80
  sta PPUCTRL
  lda #%00001010
  sta PPUMASK

; Read controller
  jsr readPad
  lda joy1new
  and #$90
  beq tvLoop


aspectRatioTest:
; Set palette
  ldx #0
  stx PPUMASK
  jsr setGrayPalette

.segment "RODATA"
ntscAspectScreen:
  .incbin "square.nam"
palAspectScreen:
  .incbin "palsquare.nam"
.segment "CODE"

  lda isPAL
  beq @copyNTSC
  ldx #<palAspectScreen
  ldy #>palAspectScreen
  bne @gotoCopy
@copyNTSC:
  ldx #<ntscAspectScreen
  ldy #>ntscAspectScreen
@gotoCopy:
  lda #$20
  jsr copyNT

aspectLoop:
  jsr displayLoop
  jmp tvTest








.proc setGrayPalette
  ldy #$3F
  ldx #0
  sty PPUADDR
  stx PPUADDR
  sty PPUDATA
  stx PPUDATA
  lda #$10
  sta PPUDATA
  lda #$30
  sta PPUDATA
  rts
.endproc


;;;
; Runs the game loop for one display,
; waiting for the player to press A.
.proc displayLoop
  ; wait for vertical blanking NMI
  lda PPUSTATUS
  lda #$80
  sta PPUCTRL
  lda retraces

waitForNMI:
  cmp retraces
  beq waitForNMI
  lda PPUSTATUS  ; acknowledge NMI

; Turn on screen
  lda #$00
  sta PPUSCROLL
  sta PPUSCROLL
  lda #$80
  sta PPUCTRL
  lda #%00001010
  sta PPUMASK

; Read controller
  jsr readPad
  lda joy1new
  and #$90
  beq displayLoop

  rts
.endproc

;;;
; Copies a nametable data from PRG ROM to VRAM.
; @param X bits 7-0 of source address
; @param Y bits 15-8 of source address
; @param A bits 15-8 of destination address
copyNT:
  stx 0
  sty 1
  sta PPUADDR
  ldy #0
  sty PPUADDR
  ldx #4
  ldx #4
@loop:
  lda (0),y
  sta PPUDATA
  iny
  bne @loop
  inc 1
  dex
  bne @loop
  rts

readPad:
; Strobe the joypad and set up the last frame joy state.
  lda #1
  sta P1
  lda joy1
  sta last_joy1
  ldx #8
  lda #0
  sta P1

; Read the joypad out serially.
@loop:
  lda P1
  lsr a
  rol joy1
  dex
  bne @loop

; Compute which buttons were newly pressed.
  lda last_joy1
  eor #$FF
  and joy1
  sta joy1new
  rts

;;;
; Sets isPAL to nonzero if the machine is on 50 Hz timing.
.proc detectPAL

  lda PPUSTATUS  ; acknowledge any pending NMI

  ; wait for vblank with the screen turned off
  lda #$80
  sta PPUCTRL
  asl a
  sta PPUMASK
  lda retraces
:
  cmp retraces
  beq :-
  lda retraces

  ; wait 24 * 1285 cycles, longer than the NTSC
  ; frame period but shorter than that of PAL
  ldx #24
  ldy #0
:
  dey
  bne :-
  dex
  bne :-

  ; compare to retrace count before waiting
  ; if we've had a vblank, then we're NTSC
  ; otherwise we're PAL
  cmp retraces
  bne notPAL
  lda #1
  sta isPAL
notPAL:
  rts
.endproc
