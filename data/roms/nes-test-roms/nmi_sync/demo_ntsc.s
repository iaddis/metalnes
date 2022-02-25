; Uses nmi_sync to manually display line on screen
; using timed write. See readme.txt.
;
; NTSC NES only. Tested on hardware.
;
; ca65 -o rom.o demo_ntsc.s
; ld65 -C unrom.cfg rom.o -o demo_ntsc.nes
;
; Shay Green <gblargg@gmail.com>

.include "nmi_sync.s"

reset:
	; Initialize PPU and palette
	jsr init_graphics
	
	; Synchronize to PPU and enable NMI
	jsr init_nmi_sync
	
	; Loop endlessly
loop:   jsr wait_nmi
	
	; You could run normal code between NMIs here,
	; as long as it completes BEFORE NMI. If it
	; takes too long, synchronization may be off
	; by a few cycles for that frame.
	; ...
	
	jmp loop


.align 256 ; branches must not cross page
nmi:
	pha
	
	; Do this sometime before you DMA sprites
	jsr begin_nmi_sync
	
	; DMA then enable sprites. Instructions before
	; STA $4014 (excluding begin_nmi_sync) must take
	; an even number of cycles. The only required
	; instruction here is STA $4014.
	bit <0          ; to make cycle count even
	lda #0
	sta $2003
	lda #>sprites
	sta $4014
	lda #$10
	sta $2001
	
	; Our instructions up to this point MUST total
	; 1715 cycles, so we'll burn the rest in a loop.
	
	; delay 1715 - 30
	lda #29
	sec
nmi_1:  pha
	lda #9
nmi_2:  sbc #1
	bne nmi_2
	pla
	sbc #1
	bne nmi_1

	jsr end_nmi_sync
	
	; We're now synchronized exactly to 2286 cycles
	; after beginning of frame.
	
	; delay 16168 - 2286 - 5
	nop
	lda #24
	sec
nmi_3:  pha
	lda #113
nmi_4:  sbc #1
	bne nmi_4
	pla
	sbc #1
	bne nmi_3

	; Draw short line using monochrome mode bit
	lda #$11
	sta $2001       ; writes 16168 cycles into frame
	lda #$10
	sta $2001

	pla
	rti


.align 256
sprites:
	; Reference sprites around manually-drawn line
	.byte 118, 0, 0, 80
	.byte 118, 0, 0, 80+8
	.byte 118, 1, 0, 80+16
	
	.byte 122, 0, 0, 80
	.byte 122, 0, 0, 80+8
	
	.res 256 - 5*4, $FF


init_graphics:
	sei
	
	; Init PPU
	bit $2002
init_graphics_1:
	bit $2002
	bpl init_graphics_1
init_graphics_2:
	bit $2002
	bpl init_graphics_2
	lda #0
	sta $2000
	sta $2001
	
	; Load alternating black and white palette
	lda #$3F
	sta $2006
	ldy #$E0
	sty $2006
init_graphics_3:
	sta $2007
	eor #$0F
	iny
	bne init_graphics_3

	rts

; Freeze program if this somehow gets triggered, rather
; than silently messing up timing
irq:    jmp irq


.segment "HEADER"
	.byte "NES",26, 2,1, 0,0 ; 32K PRG, 8K CHR, UNROM
	.byte 0,0,0,0,0,0,0,0

.segment "VECTORS"
	.word 0,0,0, nmi, reset, irq

.segment "CHARS"
	; Characters for sprites
	.byte $FF,0,0,0,0,0,0,0
	.byte   0,0,0,0,0,0,0,0
	
	.byte $FF,$FF,$FF,$FF,$FF,0,0,0
	.byte 0,0,0,0,0,0,0,0
	
	.res $2000 - $20
