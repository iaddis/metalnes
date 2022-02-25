; nes sample timer abuse
;
; Copyright 2010 Damian Yerrick
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty
; provided the copyright notice and this notice are preserved.
; This file is offered as-is, without any warranty.

.p02
.include "src/nes.h"

WITH_CONTROLLERS = 1

; Possible playback rates are
; 428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106,  84,  72,  54


OAM = $200

.segment "INESHDR"
.byt 'N','E','S',$1A
.byt 1  ; 1 prg page
.byt 1  ; 1 chr page
.byt $01  ; mirror type 1 (vertical mirroring), mapper low nibble = 0
.byt $00  ; mapper high nibble = 0

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "ZEROPAGE"
irqs: .res 1
nmis: .res 1
camera_x: .res 1
camera_y: .res 1
lastPPUCTRL: .res 1
irq_lag: .res 1
val_4015: .res 1
.ifdef WITH_CONTROLLERS
  cur_keys: .res 2
.endif

.segment "CODE"
.proc irq_handler
  bit $4015
  inc irqs

  ; restart IRQ
  pha
  lda val_4015
  sta $4015
  lda irqs
  cmp #8
  beq irq_on
  cmp #16
  beq irq_slowdown
  cmp #19
  beq irq_off
irq_done:
  pla  
  rti

irq_on:
  txa
  pha
  jsr compensate
  jsr waste36dots
  jsr waste36dots
  jsr waste36dots
  bit $00
  nop

  ; Based on an example by tokumaru
  ; http://nesdev.parodius.com/bbs/viewtopic.php?p=64111#64111
  ; start setting the scroll before the horizontal blank
  lda lastPPUCTRL
  asl a
  asl a
  sta PPUADDR
  lda camera_y
  sta PPUSCROLL
  asl a
  asl a
  and #%11100000
  ldx camera_x
  sta camera_x
  txa
  lsr a
  lsr a
  lsr a
  ora camera_x

  ;finish setting the scroll during HBlank (11 cycles)
  stx PPUSCROLL
  sta PPUADDR
  stx camera_x

  lda #BG_ON|OBJ_ON
  sta PPUMASK
  pla
  tax
  jmp irq_done

irq_slowdown:
  lda #1
  sta DMCLEN
  jmp irq_done

irq_off:
  txa
  pha
  jsr compensate
  jsr waste36dots
  jsr waste36dots
  bit OAM
  bit OAM
  lda #OBJ_ON|LIGHTGRAY
  sta PPUMASK
  pla
  tax
  jmp irq_done

compensate:
  ldx irq_lag
:
  lda $00
  inx
  bne :-
waste36dots:
  rts
.endproc

.proc nmi_handler
  bit PPUSTATUS
  inc nmis
  pha
  txa
  pha

  ; Set sample channel to high frequency and turn off playback.
  ; This makes sure that 1. the sample buffer is empty, and 2. all
  ; CPU cycles are available for VRAM transfer.
  lda #$0F
  sta DMCFREQ  ; fastest pitch, no loop, no irq
  sta SNDCHN   ; tones on, sample off
  lda #$00
  sta irqs     ; init irq counter to distinguish single from double
  sta DMCLEN   ; sample length: 1 byte
  
  ; OMITTED: Write to VRAM and stuff here.

  ; After writing to VRAM, we need some sort of raster time
  ; reference.  If your VRAM update code executes in constant time,
  ; you can use that.  But instead, we're using sprite 0, so we 
  ; scroll the background to guarantee that a sprite 0 hit will
  ; trigger.

  sta PPUSCROLL
  sta PPUSCROLL
  sta OAMADDR
  lda #>OAM
  sta OAM_DMA
  lda #BG_ON|OBJ_ON|LIGHTGRAY
  sta PPUMASK
wait_s0_off:
  bit PPUSTATUS
  bvs wait_s0_off
wait_s0_on:
  bit PPUSTATUS
  bvc wait_s0_on
  lda #OBJ_ON|LIGHTGRAY
  sta PPUMASK

  ; *** Start of timer setup code ***

  ; There are two buffers in the sample playback chain.  One is an
  ; 8-bit buffer that holds bytes fetched from memory; for reasons
  ; related to audio hardware on another Nintendo platform, I call
  ; this buffer the "FIFO".  The other is an 8-bit shift register
  ; from which delta values are shifted.  Every 8 sample periods, the
  ; data in the FIFO gets moved to the shift register, and the FIFO
  ; becomes empty.  Whenever the FIFO is empty, and at least one
  ; byte remains in the wave data, one byte gets read into the FIFO.
  ; If this is the last byte of the wave, the APU pulls /IRQ low.
  ;
  ; This first playback starts with an empty FIFO and a sample of
  ; length 1.  It will finish instantly and cause an IRQ, which we
  ; ignore, but it
  ; will also fill the sample buffer.
  lda #SNDCHN_PSGS|SNDCHN_DMC
  sta val_4015
  sta $4015
  nop

  ; By that time, 'irqs' should
  ; have become 1.

  ; Now we start using IRQs on this one.
  ldx #$0F | DMC_IRQMODE
  stx DMCFREQ
  sta $4015
  cli
  ldx #0

  ; The IRQ handler has started a second playback, and we
  ; measure this one.
  lda irqs
:
  inx
  cmp irqs
  beq :-
  stx irq_lag

  ; irq_lag measurements should ordinarily be in the range of 1 to 54
  ; or thereabouts.  But occasionally, the second playback triggers
  ; *during* the IRQ handler after the first, and 'irqs' will be 2 at
  ; the start of the measurement loop.  So  at the end of the loop,
  ; if the value of 'irqs' was 2 at the start, we were measuring the
  ; *third* playback, so we have to compensate for time spent in the
  ; second playback's IRQ handler by adding a few eight-cycle units
  ; to the elapsed time.

  cmp #1
  bcc not_double_irq
  lda #6  ; Increase this or decrease this based on the length of
          ; the IRQ handler.
not_double_irq:

  ; Inside the IRQ handler, the compensate subroutine counts up from
  ; irq_lag to 256.  So we add about 180 or so to convert irq_lag to
  ; work as an up-counter.  (Other examples of up-counters include
  ; the frequency timers on the Game Boy tone generators and the
  ; Game Boy Advance PCM channels.)
  adc #188
  adc irq_lag
  
  ; For robustness: counting once is better than counting 250 times.
  bcc not_excessive_lag
  lda #255  
not_excessive_lag:
  sta irq_lag

  ; At this point, we're at a predictable position relative to the
  ; phase of the sample clock.
  lda #0
  sta irqs

  ; *** End of timer setup code ***
  ; At this point, we have about 400 cycles until the next sample
  ; fetch.  Take advantage of this time to read the controllers
  ; without any double clocking interference.
.if ::WITH_CONTROLLERS
  ldx #1
  stx cur_keys+1  ; when this is shifted left 8 times, carry will be set
  stx $4016
  dex
  stx $4016
padsloop:
  ; bit 0: famicom hardwired controller or nes controller
  ; bit 1: famicom expansion port controller
  ; if either is set, consider the button pressed
  lda $4016
  and #$03
  cmp #$01
  rol cur_keys
  lda $4017
  and #$03
  cmp #$01
  rol cur_keys+1
  bcc padsloop  
  
  ; Let player 1 control the camera position.  The position will
  ; actually get written to the PPU during the IRQ handler.
  
  lda cur_keys
  and #$08
  beq not_up
  lda camera_y
  beq not_up
  dec camera_y
not_up:

  lda cur_keys
  and #$04
  beq not_down
  lda camera_y
  cmp #80
  beq not_down
  inc camera_y
not_down:

  lda cur_keys
  and #$02
  beq not_left
  lda camera_x
  beq not_left
  dec camera_x
not_left:

  lda cur_keys
  and #$01
  beq not_right
  lda camera_x
  cmp #216
  beq not_right
  inc camera_x
not_right:
.else

  ; If we have the demo configured not to read the controllers,
  ; move the camera in a diamond pattern instead.
  lda #$80  ; nametable select bits go here
  sta lastPPUCTRL
  lda nmis
  cmp #128
  bcc :+
  eor #$FF
:
  lsr a
  sta camera_y

  lda nmis
  clc
  adc #64
  cmp #128
  bcc :+
  eor #$FF
:
  lsr a
  sta camera_x
.endif

  pla
  tax
  pla 
  rti
.endproc

.proc reset_handler
  sei  ; IRQs while initializing hardware: OFF!
  ldx #$00
  stx PPUCTRL  ; Vblank NMI: OFF!
  stx PPUMASK  ; Rendering: OFF!
  stx $4015    ; DPCM and tone generators: OFF!
  stx val_4015  ; ISR functionality: OFF!
  lda #$40
  sta $4017  ; APU IRQ: OFF!
  lda $4015  ; APU IRQ: ACK!
  cld  ; Decimal mode on famiclones: OFF!
  lda PPUSTATUS  ; Vblank NMI: ACK!
  dex
  txs  ; Stack: TOP!

vwait1:
  lda PPUSTATUS
  bpl vwait1
  
  ; Clear zero page and sprite page
  ; (the demo doesn't use anything else)
  ldx #0
  ldy #$00
  lda #$f0
  tay
clear_zeropage:
  sty $00,x
  sta OAM,x
  inx
  bne clear_zeropage
  
  ; Set up those variables that are actually used
  lda #0
  sta camera_x
  lda #40
  sta camera_y
  lda #<(sampledata >> 6)
  sta DMCADDR
vwait2:
  lda PPUSTATUS
  bpl vwait2

  ; Clear the nametables
  lda #$24
  sta PPUADDR
  stx PPUADDR
  txa
clear_vram:
  .repeat 8
    sta PPUDATA
  .endrepeat
  inx
  bne clear_vram
  
  lda #$20
  ldy #$00
  sty OAM
  sty OAM+2
  iny
  sta PPUADDR
  sty PPUADDR
  iny
  sty PPUDATA
  sty OAM+1
  lda #8
  sta OAM+3
  sta OAM+2
  
  ; Write a green-tinted palette to the PPU to show that the program
  ; counter has reached this point
  lda #$3F
  sta PPUADDR
  ldx #$00
  stx PPUADDR
set_initial_palette:
  lda initial_palette,x
  sta PPUDATA
  inx
  cpx #32
  bcc set_initial_palette

  jsr sayHello
  cli
:
  jmp :-

.endproc

.proc sayHello
  lineIdx = 2
  vramDstHi = 3
  vramDstLo = 4
  
  lda #0
  sta lineIdx
  lda #$20
  sta vramDstHi
  lda #$A2
  sta vramDstLo
  
lineloop:
  ldx lineIdx
  lda helloLines,x
  sta 0
  inx
  lda helloLines,x
  sta 1
  inx
  stx lineIdx
  ora #0  ; skip null pointers
  beq skipLine
  lda vramDstHi
  ldx vramDstLo
  jsr puts
skipLine:
  
  lda vramDstLo
  clc
  adc #64
  sta vramDstLo
  lda vramDstHi
  adc #0
  sta vramDstHi
  lda lineIdx
  cmp #20
  bcc lineloop
  
  lda PPUSTATUS
  lda #$80
  sta PPUCTRL
  lda nmis
:
  cmp nmis
  beq :-
  lda PPUSTATUS

  rts
.endproc

.proc puts
  sta PPUADDR
  stx PPUADDR
  pha
  txa
  pha
  ldy #0
copyloop1:
  lda (0),y
  beq after_copyloop1
  asl a
  sta PPUDATA
  iny
  bne copyloop1
after_copyloop1:
  
  pla
  clc
  adc #32
  tax
  pla
  adc #0
  sta PPUADDR
  stx PPUADDR
  ldy #0
copyloop2:
  lda (0),y
  beq after_copyloop2
  sec
  rol a
  sta PPUDATA
  iny
  bne copyloop2
after_copyloop2:
  rts
.endproc

.segment "RODATA"
initial_palette:
  .byt $0A,$1A,$2A,$3A,$0A,$1A,$2A,$3A,$0A,$1A,$2A,$3A,$0A,$1A,$2A,$3A
  .byt $0A,$16,$26,$36,$0A,$1A,$2A,$3A,$0A,$1A,$2A,$3A,$0A,$1A,$2A,$3A
helloLines:
  .addr hello1, hello2, 0, hello4, hello5, hello6, hello7
  .addr hello8, hello9, hello10

;             [                            ]
hello1:  .byt "DPCM Letterbox Demo v2",0
hello2:  .byt "Copr. 2010 Damian Yerrick",0
hello4:  .byt "This 16:9 window (scroll it",0
hello5:  .byt "with the Control Pad) uses",0
hello6:  .byt "no mapper IRQ.  Instead, it",0
hello7:  .byt "uses the DMC IRQ as a crude",0
hello8:  .byt "timer to hide the top and",0
hello9:  .byt "bottom of the background.",0
hello10: .byt "Too bad it can't do 720p :(",0


.segment "DMC"
.align 64
sampledata:
  .res 17,$00

