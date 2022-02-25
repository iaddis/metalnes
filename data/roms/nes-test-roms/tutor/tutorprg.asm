; Program code for NES 101 Tutorial
; Code by Michael Martin, 2001-2

; Assign the sprite page to page 2.
sprite = $200

; Allocate memory in the zero page segment.  If we
; really wanted to, we could scatter these declarations
; through the code (P65 1.1 lets us do so) but not all
; assemblers allow this, and it doesn't help clarity
; any on this program.  So the heck with it.

; As a side note, P65 doesn't really grant any special
; status to any of the segments you use, and only has
; "text" and "data" built in.  This means that "zp"
; could be named whatever we wanted, and it also means
; that we have to tell it where to start from (it's the
; zero page, so we start it from zero, naturally).

enum $000	;asm6's way of declaring vars in ram

dx	.byte 0
a	.byte 0
scroll	.byte 0

ende

; If we had a normal data segment, it would have an .org $0300, so
; that it doesn't stomp on our sprite data.

; Actual program code.  We only have one PRG-ROM chip here, so the
; origin is $C000.
.org $C000

reset:  sei
	cld
	; Wait two VBLANKs.
-	lda $2002
	bpl -
-	lda $2002
	bpl -

	; Clear out RAM.
        lda #$00
        ldx #$00
-       sta $000,x
        sta $100,x
        sta $200,x
        sta $300,x
        sta $400,x
        sta $500,x
        sta $600,x
        sta $700,x
        inx
        bne -

	; Reset the stack pointer.
        ldx #$FF
        txs

	; Disable all graphics.
        lda #$00
        sta $2000
        sta $2001

	jsr init_graphics
	jsr init_input
	jsr init_sound

	; Set basic PPU registers.  Load background from $0000,
	; sprites from $1000, and the name table from $2000.
        lda #%10001000
        sta $2000
        lda #%00011110
        sta $2001

	cli

	; Transfer control to the VBLANK routines.
loop:   jmp loop

init_graphics:
        jsr init_sprites
        jsr load_palette
        jsr load_name_tables
        jsr init_scrolling
        rts

init_input:
        ; The A button starts out not-pressed.
        lda #$00
        sta a
        rts

init_sound:
        ; initialize sound hardware
        lda #$01
        sta $4015
        lda #$00
        sta $4001
	lda #$40
	sta $4017
        rts

init_sprites:
        ; Clear page #2, which we'll use to hold sprite data
        lda #$00
        ldx #$00
-       sta sprite, x
        inx
        bne -

        ; initialize Sprite 0
        lda #$70
        sta sprite                ; Y coordinate
        lda #$01
        sta sprite+1        ; Pattern number
        sta sprite+3        ; X coordinate
                        ; sprite+2, color, stays 0.

        ; Set initial value of dx
        lda #$01
        sta dx
        rts

; Load palette into $3F00
load_palette:
        lda #$3F
        ldx #$00
        sta $2006
        stx $2006
-       lda palette,x
        sta $2007
        inx
        cpx #$20
        bne -
        rts

load_name_tables:
; Jam some text into the first name table (at $2400, thanks to mirroring)
        ldy #$00
        ldx #$04
        lda #<bg
        sta $10
        lda #>bg
        sta $11
        lda #$24
        sta $2006
        lda #$00
        sta $2006
-       lda ($10),y
        sta $2007
        iny
        bne -
        inc $11
        dex
        bne -

; Clear out the Name Table at $2800 (where we already are.  Yay.)
        ldy #$00
        ldx #$04
        lda #$00
-       sta $2007
        iny
        bne -
        dex
        bne -
        rts

init_scrolling:
        lda #240
        sta scroll
        rts

update_sprite:
        lda #>sprite
        sta $4014                ; Jam page $200-$2FF into SPR-RAM

        lda sprite+3
        beq hit_left
        cmp #255-8
        bne edge_done
        ; Hit right
        ldx #$FF
        stx dx
        jsr high_c
        jmp edge_done
hit_left:
        ldx #$01
        stx dx
        jsr high_c

edge_done:                ; update X and store it.
        clc
        adc dx
        sta sprite+3
        rts

react_to_input:
        lda #$01        ; strobe joypad
        sta $4016
        lda #$00
        sta $4016

        lda $4016        ; Is the A button down?
        and #1
        beq not_a                
        ldx a
        bne a_done        ; Only react if the A button wasn't down last time.
        sta a                ; Store the 1 in local variable 'a' so that we this is
        jsr reverse_dx  ; only called once per press.
        jmp a_done
not_a:  sta a                ; A has been released, so put that zero into 'a'.
a_done: lda $4016        ; B does nothing
        lda $4016                ; Select does nothing
        lda $4016                ; Start does nothing
        lda $4016                ; Up
        and #1
        beq not_up
        ldx sprite                ; Load Y value
        cpx #7
        beq not_up                ; No going past the top of the screen
        dex                
        stx sprite
not_up: lda $4016                ; Down
        and #1
        beq not_dn
        ldx sprite
        cpx #223                ; No going past the bottom of the screen.
        beq not_dn
        inx
        stx sprite
not_dn: rts                                ; Ignore left and right, we don't use 'em

reverse_dx:
        lda #$FF                
        eor dx
        clc
        adc #$01
        sta dx
        jsr low_c
        rts

scroll_screen:
        ldx #$00                ; Reset VRAM
        stx $2006
        stx $2006

        ldx scroll                ; Do we need to scroll at all?
        beq no_scroll
        dex
        stx scroll
        lda #$00
        sta $2005                ; Write 0 for Horiz. Scroll value
        stx $2005                ; Write the value of 'scroll' for Vert. Scroll value
                
no_scroll:
        rts

low_c:
        pha
        lda #$84
        sta $4000
        lda #$AA
        sta $4002
        lda #$09
        sta $4003
        pla
        rts

high_c:
        pha
        lda #$86
        sta $4000
        lda #$69
        sta $4002
        lda #$08
        sta $4003
        pla
        rts

vblank: jsr scroll_screen
        jsr update_sprite
        jsr react_to_input
irq:    rti

; palette data
palette:
.byte $0E,$00,$0E,$19,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$21
.byte $0E,$20,$22,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; Background data
bg:
.byte "                                "
.byte "12345678901234567890123456789012"
.byte "                                "
.byte "                                "
.byte " PRESENTING NES 101:            "
.byte "    A GUIDE FOR OTHERWISE       "
.byte "    EXPERIENCED PROGRAMMERS     "
.byte "                                "
.byte "    TUTORIAL FILE BY            "
.byte "    MICHAEL MARTIN              "
.byte "                                "
.byte "                                "
.byte "                                "
.byte "    PRESS UP AND DOWN TO SHIFT  "
.byte "    THE SPRITE                  "
.byte "                                "
.byte "    PRESS A TO REVERSE DIRECTION"
.byte "                                "
.byte "                                "
.byte "                                "
.byte "                                "
.byte "                                "
.byte "                                "
.byte "CHARACTER SET HIJACKED FROM     "
.byte "COMMODORE BUSINESS MACHINES     "
.byte "           (C64'S CHARACTER ROM)"
.byte "                                "
.byte "READY.                          "
.byte "                                "
.byte "                                "
; Attribute table
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F

.pad $FFFA
.word vblank, reset, irq
