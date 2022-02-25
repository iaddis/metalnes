; Uses nmi_sync to manually display line on screen
; using timed write. See readme.txt.
;
; PAL NES only. Tested on hardware.
;
; ca65 -o rom.o demo_pal.s
; ld65 -C unrom.cfg rom.o -o demo_pal.nes
;
; Shay Green <gblargg@gmail.com>

.include "nmi_sync.s"

reset:
	; Initialize PPU and palette
	jsr init_graphics
	
	; Synchronize with PPU and enable NMI
	jsr init_nmi_sync_pal
	
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
	; 6900 cycles, so we'll burn the rest in a loop.
	
	; delay 6900 - 30
	lda #9
	sec
nmi_1:  pha
	lda #150
nmi_2:  sbc #1
	bne nmi_2
	pla
	sbc #1
	bne nmi_1
	
	jsr end_nmi_sync
	
	; We're now synchronized exactly to 7471 cycles
	; after beginning of frame.
	
	; delay 20486 - 7471 - 5
	nop
	lda #85
	sec
nmi_3:  pha
	lda #28
nmi_4:  sbc #1
	bne nmi_4
	pla
	sbc #1
	bne nmi_3

	; Draw short line using monochrome mode bit
	lda #$11
	sta $2001       ; writes 20486 cycles into frame
	lda #$10
	sta $2001

	pla
	rti


.align 256
sprites:
	; Reference sprites around manually-drawn line
	.byte 118, 0, 0, 82
	.byte 118, 0, 0, 82+8
	.byte 118, 1, 0, 82+16
	
	.byte 122, 0, 0, 84
	.byte 122, 0, 0, 84+8
	
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
