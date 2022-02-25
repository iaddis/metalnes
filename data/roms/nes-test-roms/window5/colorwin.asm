**** PRIOR DEFINITIONS ****

;.define PAL
.include "maping.asm"   ;This tells the ROM definition for the CNROM hardware

.asctable
MAP "0" TO "9" = $10
MAP "A" TO "Z" = $20
MAP "=" = $1c
MAP "?" = $1e
MAP " " = $1f
.enda

.ramsection "NMIVars" SLOT 0
		;Thoose variables are used in the NMI routine
		;Don't do calculations with them if a VBlank is pending
		;set them after the calculation
SpriteDMAFlag   db  ;This tells if sprite DMA is ready in a frame
PalFlag         db  ;Check if palette uploaded is needed
NMIFlag         db  ;Check if a NMI is pending or not
ScrollH         db
ScrollV         db
M2000           db
FrameCounter    db
NMITemp         db
NMITemp2        db
NMITemp3        db
NMITemp4        db
nmi_sync_count  db
.ends

.struct SpriteDMA   ;Structure for the Sprites
PosV    db
TileNmr db
Palette db
PosH    db
.endst
			;$200-$2ff is reserved for sprite DMA
.enum $200
SpriteBuffer INSTANCEOF SpriteDMA 64
.ende

.ramsection "RAM Code" SLOT 1

RAMTimedCode    dsb 39+5

.ends

; Delays Delay cycles, up to around 65536. Delay must be >= 45. 
; Preserved: X, Y 
.macro DELAY args Delay 
    lda #<((Delay) - 2 - 25 - 2 - 16) 
    jsr delay_a_25_cycles 
    lda #>((Delay) - 2 - 25 - 2 - 16) 
    jsr delay_256a_16_cycles 
.endm


****** ROM aera begins here *******

.bank 0 SLOT 2
.orga $c000

***********************
*** Wait for a VBlank ***
***********************

.section "WaitNMI" FREE
WaitNMI
	inc NMIFlag     ;Typical wait for next frame
-   lda NMIFlag
	beq +
	jmp -
+   rts
.ends

.section "NMIRoutine" FREE

NMI
	pha
	txa
	pha
	tya
	pha                 ;13
	lda #$00
	sta SpriteDMAFlag   ;17 ;Sprite buffer is read
	sta $2003.w         ;21
	jsr begin_nmi_sync
	lda #$02            ;23
	sta $4014.w         ;36 ;Do sprite DMA at $200
	lda ScrollH         ;39
	sta $2005.w         ;43
	lda ScrollV         ;46
	sta $2005.w         ;50
	lda M2000           ;53
	sta $2000.w         ;57
	lda #$00            ;59 ;Clears the flag to stop waiting the frame
	sta NMIFlag         ;62

    DELAY 1715 - 22 - 38 
    
.ifdef PAL 
    ; Just delay the extra amount PAL needs in comparison to NTSC 
    DELAY 6900 - 1715 
.endif
	
	jsr end_nmi_sync
	jsr Effect
	jsr FillBlankSprites
	
	pla                 ;Restore registers
	tay
	pla
	tax
	pla
IRQ rti
.ends

**************
* VRAM Stuff **
**************

.section "PPU" FREE
ClearVRAM
	jsr ClrPalette      ;This clears *everything* in the PPU
	jsr ClrNamTbl       ;This should be called only when rendering is off, of course
	jmp Clr2ndNamTbl

ClrPalette
	lda #$3f
	sta $2006
	ldy #$00
	sty $2006.w
-   sta $2007       ;Clear both buffer and the actual palette
	iny         ;Shall be called when rendering is off
	cpy #$20
	bne -
	rts

Clr2ndNamTbl
	lda #$28        ;Clears the name tables
	bne SetNamAdress
ClrNamTbl
	lda #$20
SetNamAdress
	sta $2006   ;Begin at $2000/$2400 (vertical mirroring)
	lda #$00
	sta $2006
	lda #$60
	ldx #$1e    ;Clears 30 rows
_screenloop
	ldy #$20
_rowloop
	sta $2007
	dey
	bne _rowloop
	dex
	bne _screenloop
	lda #$00
	ldx #$40    ;Clear attribute table
_attribloop
	sta $2007
	dex
	bne _attribloop
	rts

ClrSprRam       ;Clears the Sprite buffer at $200
	ldx #$00
	beq _ClearRemainingSprites

FillBlankSprites    ;This does just clears the unused sprites in $200-$2ff
	lda SpriteDMAFlag
	bne _endClrSprRam
_ClearRemainingSprites
	lda #$f0
-   sta $200,X
	inx
	bne -
_endClrSprRam
	inc SpriteDMAFlag
	rts
.ends

.section "RESET" FREE

RESET           ;The programm will start here
	sei
	ldx #$ff
	txs     ;Init stack pointer
	inx
	stx $2000.w
	stx $2001.w ;Turn off rendering and interrupts
	txa
_initRAMloop
	sta $0,X
	sta $100.w,X
	sta $200.w,X
	sta $300.w,X
	sta $400.w,X
	sta $500.w,X
	sta $600.w,X
	sta $700.w,X
	inx
	bne _initRAMloop
	lda #$40
	sta $4017.w                 ;Set sound clock
	lda #$00
	sta $4015.w
-   bit $2002.w
	bpl -
-   bit $2002.w             ;Wait for several VBlanks
	bpl -
	jsr ClearVRAM           ;Clear the whole PPU
	jsr ClrSprRam
	jsr LoadTextBox
	jsr LoadDefaultPal
	jsr init_nmi_sync       ;intitial sync
	lda #$1e
	sta $2001
	ldx #38+5
-   lda VeryTimedCode.w,X
	sta RAMTimedCode.w,X
	dex                     ;Copy timed code to RAM
	bpl -
-   jmp -                   ;endless loop

LoadDefaultPal
	bit $2002
	lda #$3f
	sta $2006
	lda #$00
	sta $2006
	ldx #$00
-   lda Pal.w,X
	sta $2007
	inx
	cpx #$20
	bne -
	rts

Pal
	.db $0f, $09, $20, $30
	.db $0f, $0f, $0f, $0f
	.db $0f, $0f, $0f, $0f
	.db $0f, $0f, $0f, $0f
	.db $0f, $0f, $0f, $0f
	.db $0f, $0f, $0f, $0f
	.db $0f, $0f, $0f, $0f
	.db $0f, $0f, $0f, $0f

LoadTextBox
	lda #$22
	sta $2006
	lda #$00
	sta $2006           ;VRAM Adress
	ldx #$00
-   lda TextData.w,X
	sta $2007
	inx
	cpx #$c0
	bne -
	rts

TextData
	.db $06, $00
.rept 28
	.db $01
.endr
	.db $02, $06
	.db $06, $03
	.asc "                            "
	.db $03, $06
	.db $06, $03
	.asc "  THIS IS A DUMMY TEXT BOX  "
	.db $03, $06
	.db $06, $03
	.asc "                            "
	.db $03, $06
	.db $06, $03
	.asc "  IS THAT BACKGROUND NICE?  "
	.db $03, $06

	.db $06, $04
.rept 28
	.db $01
.endr
	.db $05, $06
.ends

.include "win_timing.asm"

*** Dirty ***
; Delays A cycles + overhead 
; Preserved: X, Y 
; Time: A+25 cycles (including JSR and RTS) 

.section "Delay" ALIGN $100 FREE
-       sbc #7          ; carry set by CMP 
delay_a_25_cycles:
        cmp #7 
        bcs -           ; do multiples of 7 
        lsr a           ; bit 0 
        bcs + 
+                       ; A=clocks/2, either 0,1,2,3 
        beq +           ; 0: 5 
        lsr a 
        beq ++          ; 1: 7 
        bcc ++          ; 2: 9 
+       bne ++          ; 3: 11 
++      rts             ; (thanks to dclxvi for the algorithm) 


; Delays A*256 cycles + overhead 
; Preserved: X, Y 
; Time: A*256+16 cycles (including JSR and RTS) 
delay_256a_16_cycles
        cmp #0 
        bne + 
        rts 
+ 
-       pha 
        lda #256-19-22 
        jsr delay_a_25_cycles
        pla 
        sec 
        sbc #1 
        bne - 
        rts 

begin_nmi_sync
	lda nmi_sync_count
	and #$02
	beq +
+   rts

end_nmi_sync:
	lda nmi_sync_count
	inc nmi_sync_count
	and #$02
	bne +
+   lda $2002
	bmi +
+   bmi +
+   rts
.ends

.section "Init_Sync" ALIGN $100 FREE

.ifndef PAL
; Initializes synchronization and enables NMI
; Preserved: X, Y
; Time: 15 frames average, 28 frames max

init_nmi_sync
	; Disable interrupts and rendering
	sei
	lda #0
	sta $2000
	sta $2001
	
	; Coarse synchronize
	bit $2002
init_nmi_sync_1
	bit $2002
	bpl init_nmi_sync_1
	
	; Synchronize to odd CPU cycle
	sta $4014

	; Fine synchronize
	lda #3
init_nmi_sync_2
	sta nmi_sync_count
	bit $2002
	bit $2002
	php
	eor #$02
	nop
	nop
	plp
	bpl init_nmi_sync_2

	; Delay one frame
init_nmi_sync_3
	bit $2002
	bpl init_nmi_sync_3
	
	; Enable rendering long enough for frame to
	; be shortened if it's a short one, but not long
	; enough that background will get displayed.
	lda #$08
	sta $2001
	
	; Can reduce delay by up to 5 and this still works,
	; so there's a good margin.
	; delay 2377
	lda #216
init_nmi_sync_4
	nop
	nop
	sec
	sbc #1
	bne init_nmi_sync_4
	
	sta $2001
	
	lda nmi_sync_count
	
	; Wait for this and next frame to finish.
	; If this frame was short, loop ends. If it was
	; long, loop runs for a third frame.
init_nmi_sync_5
	bit $2002
	bit $2002
	php
	eor #$02
	sta nmi_sync_count
	nop
	nop
	plp
	bpl init_nmi_sync_5
	
	; Enable NMI
	lda #$80
	sta $2000
	sta M2000
	rts

.else

; Initializes synchronization and enables NMI on PAL NES
; Preserved: X, Y
; Time: about 20 frames
init_nmi_sync
	; NMI will first occur within frame 2 after
	; synchronization
	lda #2
	sta nmi_sync_count
	
	; Disable interrupts and rendering
	sei
	lda #0
	sta $2000
	sta $2001
	
	; Coarse synchronize
	bit $2002
init_nmi_sync_pal_1
	bit $2002
	bpl init_nmi_sync_pal_1
	
	; Synchronize to odd CPU cycle
	sta $4014
	bit <0
	
	; Fine synchronize
init_nmi_sync_pal_2
	bit <0
	nop
	bit $2002
	bit $2002
	bpl init_nmi_sync_pal_2
	
	; Enable NMI
	lda #$80
	sta $2000
	sta M2000
	
	rts
.endif
.ends

*************************
**** INTERUPTS VECTORS ****
*************************

.orga $fffa
.section "vectors" FORCE
.dw NMI
.dw RESET           ;Thoose are the actual interupts vectors
.dw IRQ
.ends

.bank 1 SLOT 3
.orga $0000
.section "graph"
.incbin "colorwin.chr"
.ends