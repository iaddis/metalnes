**** PRIOR DEFINITIONS ****

.include "maping.asm"	;This tells the ROM definition for the hardware
;.define PAL

.asctable
MAP "1" TO "9" = $10
MAP "A" TO "Z" = $20
MAP "=" = $1c
MAP "?" = $1e
MAP " " = $1f
MAP "/" = $3b
.enda

.ramsection "NMIVars" SLOT 0
		;Thoose variables are used in the NMI routine
		;Don't do calculations with them if a VBlank is pending
		;set them after the calculation
SpriteDMAFlag		db	;This tells if sprite DMA is ready in a frame
PalFlag			db	;Check if palette uploaded is needed
NMIFlag			db	;Check if a NMI is pending or not
FrameCounter		db
NMITemp			db
NMITemp2		db
NMITemp3		db
NMITemp4		db
ScrollV			db
ScrollH			db
M2001			db
M2000			db

.ends

.ramsection "Palette" SLOT 1
PaletteBuffer	dsb $20
.ends

.ramsection "Main Vars" SLOT 0
Pointer		.dw
PointerL  	db
PointerH  	db
Temp		db
Temp2		db
Temp3		db
Temp4		db
EffectCtr	db
DataCtr		db
VRAMPointerH	db
VRAMPointerL	db
.ends

.ramsection "JoypadVar" SLOT 0
Pad1		db
Pad2		db
Pad1Locked	db
Pad2Locked	db
.ends

.ramsection "PlayerVars" SLOT 0
Delay		db
.ends
.define DelayMax = $50

.struct SpriteDMA	;Structure for the Sprites
PosV		db
TileNmr		db
Palette		db
PosH		db
.endst
			;$200-$2ff is reserved for sprite DMA
.enum $200
SpriteBuffer INSTANCEOF SpriteDMA 64
.ende

.ramsection "MMC1" SLOT 0
BankLatch1	db
BankLatch2	db
.ends

****** ROM aera begins here *******

.bank 0 SLOT 2
.orga $8000
.bank 1 SLOT 2
.orga $8000
.bank 3 SLOT 2
.orga $8000
.bank 4 SLOT 2
.orga $8000
.bank 5 SLOT 2
.orga $8000
.bank 6 SLOT 2
.orga $8000

.bank 7 SLOT 3
.orga $c000

***********************
*** Wait for a VBlank ***
***********************

.section "WaitNMI" FREE
WaitNMI
	lda #$01
	sta NMIFlag
-	lda NMIFlag
	bne -
	rts

;Wait multiple NMIs in function of the value in X
WaitNMIs
-	jsr WaitNMI
	dex
	bne -
	rts
.ends

.section "NMIRoutine" FREE

NMI
	pha
	txa
	pha
	tya
	pha
	bit $2002
	lda M2001
	sta $2001
	lda SpriteDMAFlag
	beq _skipSpriteDMA	;Is the sprite buffer ready ?
	lda #$00
	sta SpriteDMAFlag	;Sprite buffer is read
	sta $2003.w
	lda #$02
	sta $4014.w		;Do sprite DMA at $200
_skipSpriteDMA
	lda PalFlag
	beq +			;Do we need to update tiles ?
	lda #$00
	sta PalFlag
	jsr WritePalette

+	lda #$22
	sta $2006.w
	lda #$1d
	sta $2006.w

	ldx #$00
	lda Delay
-	cmp #$0a		;Display units and tens of delay to NT
	bcc +
	sbc #$0a
	inx
	jmp -
+	tay
	txa
	clc
	bne +
	lda #$3f
	bne ++
+	adc #$0f
++	sta $2007.w
	tya
	bne +
	lda #$2e
	bne ++
+	adc #$0f
++	sta $2007.w

	lda ScrollH
	sta $2005.w
	lda ScrollV
	sta $2005.w		;Upload scrolling regs
	lda M2000
	sta $2000.w
	lda FrameCounter
	eor #$01
	sta FrameCounter
	lda #$00		;Clears the flag to stop waiting the frame
	sta NMIFlag
	pla				;Restore registers
	tay
	pla
	tax
	pla
IRQ	rti
.ends

******************
* Graphics Stuff **
******************

;then clear all nametables and attribute tables with spaces ($60)
.section "ClearVRAM" FREE
ClearVRAM
	lda M2000		;Enable NMIs
	ora #$80
	sta M2000
	sta $2000
	jsr PaletteFadeOut	;Fade out palette (trick to save a routine to clear it)
	lda #$00
	sta $2000
	lda #$06
	sta M2001
	sta $2001		;Rendering off (so that nametables can be cleared)
	jsr Clr2ndNamTbl	;Clear 2 active name tables
	jmp ClrNamTbl
.ends

.section "PaletteFadeOut" FREE
PaletteFadeOut			;Fade out the palette
	lda #$04
	sta EffectCtr
_palfadeLoop
	ldy #$1f
-	lda PaletteBuffer.w,Y
	sec
	sbc #$10		;Remove $10 from the color
	bpl +
	lda #$0f		;"Negative" colors forced to black
+	sta PaletteBuffer.w,Y
	dey
	bpl -
	jsr WritePalette	;Palette will be uploaded at next NMI
	ldx #$05
	jsr WaitNMIs		;Wait 5 NMIs
	dec EffectCtr
	bne _palfadeLoop
	rts
.ends

.section "ClrNamTbl" FREE
Clr2ndNamTbl
	lda #$24		;Clears the name tables
	.db $cd
ClrNamTbl
	lda #$20
SetNamAdress
	sta $2006		;Begin at $2000/$2400 (vertical mirroring)
	lda #$00
	sta $2006
	lda #$0f
	ldx #$1e		;Clears 30 rows with spaces ($60)
_screenloop
	ldy #$20
_rowloop
	sta $2007
	dey
	bne _rowloop
	dex
	bne _screenloop
	lda #$00
	ldx #$40		;Clear attribute table with color $0
_attribloop
	sta $2007
	dex
	bne _attribloop
	rts
.ends

.section "ClrSprRam" FREE
ClrSprRam			;Clears the whole OAM buffer at $200
	ldx #$00
	beq _ClearRemainingSprites

FillBlankSprites		;This does just clears the unused sprites in $200-$2ff
	lda SpriteDMAFlag	;For proper filling before sprite DMA
	bne _endClrSprRam
_ClearRemainingSprites
	lda #$f0
-	sta SpriteBuffer.w,X
	inx
	inx
	inx
	inx
	bne -
_endClrSprRam
	inc SpriteDMAFlag
	rts
.ends

;Turn the screen back on without scrolling glitches
;Set nametable 0 and scrolling to 0,0
;To be used only when the screen is disabled
.section "ResetScreen" FREE
ResetScreen
-	bit $2002
	bpl -			;Wait for VBlank and acknownledge it (no NMI)
	lda #$88
	sta M2000
	sta $2000
	lda #$00
	sta ScrollV		;Enable NMI, enable endering, reset scrolling
	sta ScrollH
	lda M2001
	ora #$1e
	sta M2001		;Enable rendering
	sta $2001
	rts
.ends

*****************
* Main programm *
*****************

.section "RESET" FREE
RESET				;The programm will start here
	sei
	ldx #$ff
	txs				;Init stack pointer
	inx
	stx $2000.w
	stx $2001.w		;Turn off rendering and interrupts
	lda #$40
	sta $4017.w		;Set sound clock, IRQ off
	txa
	sta PointerL
	tay
	ldx #$07
_initRAMloop
	stx PointerH
-	dey
	sta [Pointer],Y		;Clear RAM
	bne -
	dex
	bpl _initRAMloop

-	bit $2002.w
	bpl -
-	bit $2002.w			;Wait for several VBlanks
	bpl -
_MMC1
	inc _MMC1.w
	jsr ClearVRAM		;Clear the whole PPU
	jsr LoadAlphabet	;Load character set
	lda #$1e
	jsr WriteR0			;Initialise mapper
	lda #$00
	jsr WriteR1
	lda #$00
	jsr WriteR2			;WRAM always enabled (for now)	
	lda #$06
	jsr WriteR3
	
	lda #$00
	sta $2000.w
	sta $2001.w
	jsr PaletteInit
	jsr PrintMsg
	jsr ResetScreen		;This will make sprites use right pattern table (important !)
	lda #$10
	sta Delay				;Initial delay of $10

Loop
	jsr ClrSprRam
	lda #$85
	sta $200
	lda #$0f
	sta $201
	lda #$0f
	sta $202
	lda #$de
	sta $203				;Setup sprite zero hit
	inc SpriteDMAFlag
	jsr WaitNMI				;Wait a frame

	jsr ReadLockJoypad
	lda Pad1
	lsr A					;Increase delay if right is pressed
	bcc _noRight
	lda Delay
	cmp #DelayMax
	bcs _noRight
	inc Delay

_noRight
	lda #$02
	and Pad1
	beq _noLeft
	lda Delay				;Decrease delay if left is pressed
	cmp #$01
	beq _noLeft
	dec Delay

_noLeft
	lda #$04
	and Pad1
	beq _noDown
	lda Delay				;Substract 10 to delay if down is pressed
	sec
	sbc #$0a
	bcc +
	bne ++
+	lda #$01
++	sta Delay

_noDown
	lda #$08
	and Pad1
	beq _noUp				;Add 10 to delay if up is pressed
	lda Delay
	clc
	adc #$0a
	cmp #DelayMax
	bcc +
	lda #DelayMax
+	sta Delay
_noUp
	jsr DisplayTestBar		;Display the grayscale test area
	jmp Loop
.ends


.section "PaletteInit" FREE
PaletteInit
	ldx #$00
-	lda PalData.w,X
	sta PaletteBuffer.w,X
	inx
	cpx #$20
	bne -
	inc PalFlag
	rts

PalData
	.db $01, $06, $26, $36
	.db $01, $06, $27, $36
	.db $01, $06, $0a, $0a
	.db $01, $06, $0a, $0a
	.db $01, $06, $0a, $0a
	.db $01, $06, $0a, $0a
	.db $01, $06, $0a, $0a
	.db $01, $06, $0a, $0a
.ends

.section "WritePalette" FREE
WritePalette
	lda #$3f
	sta $2006.w
	lda #$00
	sta $2006.w
	tay
_palLoop
	lda PaletteBuffer.w,Y
	sta $2007.w
	iny
	cpy #$20
	bne _palLoop
	rts
.ends

.section "LoadAlphabet" FREE

LoadAlphabet
	ldy #$00
	jsr +				;Load tileset into first pattern table
	ldy #$10			;Load identical tileset into second pattern table
+	sty $2006.w
	ldy #$00
	sty $2006.w
	sty PointerL
	ldx #$04
	lda #>Alphabet
	sta PointerH
-	lda [Pointer],Y
	sta $2007
	iny
	bne -
	inc PointerH
	dex
	bne -
	rts
.ends

.section "Alphabet" ALIGN $100

Alphabet
.incbin "alphabet.chr"

.ends

.section "PrintMsg" FREE
PrintMsg
	lda #$21
	sta $2006
	lda #$a0
	sta $2006
	ldy #$00
-	lda Msg.w,Y
	sta $2007
	iny
	bpl -
	rts

Msg
.asc "   MMC1 WRAM DISABLE SCANLINE   "
.asc "         COUNTER TEST           "
.asc "        C 2O1O BREGALAD         "
.asc " USE U/D L/R TO ADJUST DELAY=   "

.ends

.section "DisplayTestBar" FREE
.define TestConst = $60~$ff		;Use the value oposite as the open bus value.

DisplayTestBar
	lda #TestConst
	sta $6000				;Write a test constant in PRG RAM

	lda #$10
	jsr WriteR2				;WRAM disabled when fecthing sprites, but enabled when fetchin BG (!)
						;Now we can read $6000 as if we were reading PPU A12 directly...
						;We can detect
-	bit $2002
	bvs -
-	bit $2002				;Wait for sprite zero hit
	bvc -

	lda #$1f
	sta $2001				;Turn on grayscale mode
	ldx Delay
_delayLoop
-	lda $6000
	cmp #TestConst				;Wait until PRG RAM is disabled (emulators will freeze here)
	beq -

	ldy #$05
-	dey					;Delay while sprites are being fetched
	bne -

	dex
	bne _delayLoop				;Loop until the delay is expired


	lda #$1e
	sta $2001
	lda #$00
	jsr WriteR2				;WRAM always enabled
	sta $6000
	rts
.ends

*************************
**** INTERUPTS VECTORS ****
*************************

.orga $fffa
.section "vectors" FORCE
.dw NMI
.dw RESET			;Thoose are the actual interupts vectors
.dw IRQ
.ends
