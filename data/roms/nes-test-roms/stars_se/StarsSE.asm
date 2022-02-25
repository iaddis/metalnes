;Stars Demo *SE*
;-------------------
;Binary created using DAsm 2.12 running on an Amiga.

   PROCESSOR   6502

SPRITEMAP  EQU   #$0600    ;Region in Memory to copy sprites.
SPRITEHARD EQU   #$C000    ;Format: Y-pos,Tile#,Attr,X-Pos
SPRITEDIR  EQU   #$C100    ;Format: DY,D2Y,D2X,DX

NMIPASS    EQU   #$0001    ;NMI has passed flag.
NMIODD     EQU   #$0000    ;Odd NMIs

XSCROLL    EQU   #$0002    ;Scroll values.
YSCROLL    EQU   #$0003
TEXTLO     EQU   #$04      ;Zero-Page pointers for the text.
TEXTHI     EQU   #$05
SCRLO      EQU   #$0006    ;Place to put the text.
SCRHI      EQU   #$0007
NMICOUNT   EQU   #$0008
SPRITEHIT  EQU   #$0009
FREEZEROL  EQU   #$0A
FREEZEROH  EQU   #$0B      ;In other words, free, always empty zero-page space.
XSCROLLSPEED EQU #$000C    ;Duh.
YSCROLLSPEED EQU #$000D
CHECKFORSPR EQU  #$000E    ;Flag to check for sprites
RAINBOWPOS EQU   #$000F    ;Position in rainbow-cycle.
TEXTHARDLO EQU   #$10
TEXTHARDHI EQU   #$11      ;Hard Copy of text

;-----------------Music-Playing Code----------------------------

;MUSIC IS NOT INCLUDED IN THE SOURCE BECAUSE IT IS NOT MINE TO GIVE OUT!!

;int_en EQU #$0100
;sng_ctr EQU #$0101
;pv_btn EQU #$0102
;
;INIT_ADD EQU #$8000
;PLAY_ADD EQU #$800E
;START_SONG EQU #$00           ;Although I played around with the order.
;MAX_SONG EQU #$0C
;---------------------------
   ORG   $C200    ;16Kb PRG-ROM, 8Kb CHR-ROM

Reset_Routine  SUBROUTINE
   cld         ;Clear decimal flag
   sei         ;Disable interrupts
.WaitV   lda $2002
   bpl .WaitV     ;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx $2001      ;Screen display off, amongst other things
   dex
   txs         ;Top of stack at $1FF

;Clear (most of) the NES' WRAM. This routine is ripped from "Duck Hunt" - I should probably clear all
;$800 bytes.
   ldy #$06    ;To clear 7 x $100 bytes, from $000 to $6FF?
   sty $01        ;Store count value in $01
   ldy #$00
   sty $00
   lda #$00

.Clear   sta ($00),y    ;Clear $100 bytes
   dey
   bne .Clear

   dec $01        ;Decrement "banks" left counter
   bpl .Clear     ;Do next if >= 0


   lda   #$20
   sta   $2006
   lda   #$00
   sta   $2006

   ldx   #$00
   ldy   #$10
.ClearPPU sta $2007        ;Clear the PPU space.  REALLY IMPORTANT for a real NES!
   dex
   bne   .ClearPPU
   dey
   bne   .ClearPPU

;------------------------------------------------------
;********* Set up Name & Attributes ******************

   lda   #<.NESDeck
   sta   FREEZEROL
   lda   #>.NESDeck
   sta   FREEZEROH

   lda   #$20        ;Load up entire name & attribute table for screen 0.
   sta   $2006
   lda   #$00
   sta   $2006
   ldx   #$00
   ldy   #$04

.LoadDeck
   txa
   pha

   ldx   #$00
   lda   (FREEZEROL),X     ;Load up NES image
   sta   $2007

   pla
   tax

   inc   FREEZEROL
   bne   .NoDeck1
   inc   FREEZEROH

.NoDeck1
   dex
   bne   .LoadDeck
   dey
   bne   .LoadDeck

;--------------------------------------------------

;---------- Set up other bits ----------------

   lda   #$26                 ;Bars on screen 1.
   sta   $2006
   lda   #$C0
   sta   $2006

   jsr   DrawBits

   lda   #$27
   sta   $2006
   lda   #$60
   sta   $2006

   jsr   DrawBits

;----------------------------------------------

;********* Initialize Palette to colour table ********

   ldx   #$3F
   stx   $2006
   ldx   #$00
   stx   $2006

   ldx   #$00
   ldy   #$20     ;Save BG & Sprite palettes.
.InitPal lda .Palette,X
   sta $2007
   inx
   dey
   bne   .InitPal
;------------------------------------------------------

;-------------------------------

   ldx   #$00
.CopySpr lda SPRITEHARD,X
   sta   SPRITEMAP,X            ;Copy sprite map.
   inx
   bne   .CopySpr

;-------------------------------

   lda   #$00
   sta   NMIPASS                 ;Flag for NMI Passed
   sta   NMIODD                  ;Even/OddVBs
   sta   NMICOUNT
   sta   SPRITEHIT
   sta   CHECKFORSPR
   sta   RAINBOWPOS              ;Position in rainbow

   lda   #<.text                 ;Start of text pointer
   sta   TEXTLO
   sta   TEXTHARDLO
   lda   #>.text
   sta   TEXTHI
   sta   TEXTHARDHI

   lda   #$23                    ;Where to place text on-screen
   sta   SCRHI
   lda   #$30
   sta   SCRLO

   lda   #$79
   sta   XSCROLL                 ;X-Y scroll values
   lda   #$00
   sta   YSCROLL

   lda   #$02
   sta   XSCROLLSPEED
   lda   #$01
   sta   YSCROLLSPEED            ;X-Y scrollspeeds

;------- MUSIC CODE ----------------
;   lda #START_SONG         ;Start Song
;   sta sng_ctr
;   jsr INIT_ADD     ;init tune
;   LDA #$01
;   sta int_en
;-------------------------------

   lda   #$00
   sta   $2006
   sta   $2006

;Enable vblank interrupts, etc.
   lda   #%10001000
   sta   $2000
   lda   #%00011000  ;Screen on, sprites on, show leftmost 8 pixels, colour
   sta   $2001
;   cli            ;Enable interrupts(?)  NO!!!!!!!!!!!!!!

.Loop

   lda   NMIPASS
   beq   .Loop

   lda   #$00
   sta   NMIPASS

   lda   NMIODD
   bne   .CheckSpr1


   ldx   #$00
.SprMov lda SPRITEMAP,X       ;Grab sprite Y-Position
   clc
   adc   SPRITEDIR,X          ;Add DY
   bcc   .NextMov1

   pha                        ;If it goes off-screen...
   inx
   lda   SPRITEDIR,X          ;Get D2Y...
   inx
   inx
   clc
   adc   SPRITEMAP,X          ;..Add to X-Position
   sta   SPRITEMAP,X
   dex
   dex
   dex
   pla

.NextMov1   sta   SPRITEMAP,X
   inx
   inx
   inx
   lda   SPRITEMAP,X          ;Grab sprite X-position
   clc
   adc   SPRITEDIR,X          ;Add DX
   bcc   .NextMov2

   pha                        ;If it goes off-screen...
   dex
   lda   SPRITEDIR,X          ;Get D2X
   dex
   dex
   clc
   adc   SPRITEMAP,X          ;Add to Y-Position
   sta   SPRITEMAP,X
   inx
   inx
   inx
   pla

.NextMov2   sta   SPRITEMAP,X
   inx
   bne   .SprMov

.CheckSpr1
   lda   $2002
   and   #$40
   bne   .CheckSpr1

.CheckSpr2
   lda   $2002
   and   #$40
   beq   .CheckSpr2

   lda   XSCROLL
   sta   $2005
   lda   $2002

;------- MUSIC CODE ---------------
;   jsr r_btn
;   and #$10
;   beq .Loop
;
;   inc sng_ctr
;   LDA #MAX_SONG         ;Max Song.
;   cmp sng_ctr
;   bne .no_scr
;   lda #$0
;   sta sng_ctr
;
;.no_scr   lda #$0
;   sta int_en
;   lda sng_ctr
;   jsr INIT_ADD
;   lda #$01
;   sta int_en        ;check button, if pressed inc song # and re-init
;-------------------------------------------------------------------------

   jmp   .Loop

.Palette dc.b #$0D,#$16,#$27,#$38,#$0D,#$00,#$10,#$30,#$0D,#$16,#$28,#$39,#$0D,#$2B,#$21,#$24
         dc.b #$0D,#$00,#$10,#$30,#$0D,#$16,#$26,#$16,#$0D,#$07,#$16,#$28,#$0D,#$00,#$00,#$00

.NESDeck
   INCLUDE starsnam.asm


.text
   INCLUDE scrolltext.bin
   dc.b #$00
   dc.b "Hello, all you hackers!"

IncText SUBROUTINE
   inc   TEXTLO
   bne   .nocarry
   inc   TEXTHI
.nocarry rts

IncScr SUBROUTINE
   inc   SCRLO
   lda   SCRLO
   and   #$1F
   bne   .nocarry2
   lda   SCRLO
   sec
   sbc   #$20
   sta   SCRLO
   lda   SCRHI
   clc
   sta   SCRHI
.nocarry2 rts

DrawBits SUBROUTINE
   ldy   #$20
   lda   #$04
.Bits1A sta  $2007
   dey
   bne   .Bits1A
   ldy   #$20
   lda   #$05
.Bits1B sta $2007
   dey
   bne   .Bits1B
   rts

;************* MUSIC CODE *******************
;r_btn SUBROUTINE
;           ldy #$08      ;read keypad
;           ldx #$01
;           stx $4016
;           dex
;           stx $4016
;
;.r_bit     lda $4016
;           ROR
;           txa
;           ROL
;           tax
;           dey
;           bne .r_bit
;
;           cmp pv_btn
;           beq .no_chg
;           sta pv_btn
;           rts
;
;.no_chg    lda #$0
;           rts
;***********************************************

IncRainbow SUBROUTINE
   inc   RAINBOWPOS
   lda   RAINBOWPOS
   cmp   #$06
   bne   .RainEnd
   lda   #$00
   sta   RAINBOWPOS
.RainEnd
   rts

SaveRainbow SUBROUTINE
   ldx   RAINBOWPOS
   lda   .Rainbow,X
   sta   $2007
   jsr   IncRainbow
   rts

.Rainbow dc.b #$16,#$28,#$39,#$2B,#$21,#$24

NMI_Routine SUBROUTINE
   php
   pha
   txa
   pha
   tya
   pha

   lda   XSCROLL
   clc
   adc   XSCROLLSPEED
   sta   XSCROLL

   lda   YSCROLL
   clc
   adc   YSCROLLSPEED
   sta   YSCROLL

   lda   #$00
   sta   $2005
   sta   $2005


   inc   NMICOUNT

   lda   NMICOUNT
   cmp   #$04
   bne   .NotThere

   lda   #$00
   sta   NMICOUNT

   lda   SCRHI
   sta   $2006
   lda   SCRLO
   sta   $2006

   ldx   #$00
   lda   (TEXTLO),X

   sta   $2007

   lda   SCRHI
   eor   #$04
   sta   $2006
   lda   SCRLO
   sta   $2006

   lda   (TEXTLO),X
   sta   $2007
   cmp   #$00
   bne   .NoTextWrap

   lda   TEXTHARDLO                 ;Start of text pointer
   sta   TEXTLO
   lda   TEXTHARDHI
   sta   TEXTHI

.NoTextWrap jsr   IncText
   jsr   IncScr

;---------------------------------------------
;   increase rainbow colours here.
   lda   #$3F
   sta   $2006
   lda   #$09
   sta   $2006

   jsr   SaveRainbow
   jsr   SaveRainbow
   jsr   SaveRainbow
   lda   #$0D
   sta   $2007
   jsr   SaveRainbow
   jsr   SaveRainbow
   jsr   SaveRainbow
   jsr   IncRainbow
   jsr   IncRainbow
   jsr   IncRainbow
   jsr   IncRainbow
   jsr   IncRainbow
;-----------------------------------

.NotThere

   lda   #$01
   eor   NMIODD      ;Update Even/Odd NMIs
   sta   NMIODD

   lda   #$01
   sta   NMIPASS

   lda   #$00
   sta   $2006
   sta   $2006

   lda   #$00
   sta   $2005
   sta   $2005

   lda   #$01
   sta   CHECKFORSPR

   lda   #>SPRITEMAP        ;Point to SPRITEMAP
   sta   $4014       ;Xfer sprites over

;----- MUSIC CODE -----------------------------
;   lda int_en
;   beq .no_ints
;   jsr PLAY_ADD    ;play tune
;
;.no_ints
;-------------------------------------


   pla
   tay
   pla
   tax
   pla
   plp
   rti

IRQ_Routine       ;Dummy label
   rti

;That's all the code. Now we just need to set the vector table approriately.

   ORG   $FFFA,0
   dc.w  NMI_Routine
   dc.w  Reset_Routine
   dc.w  IRQ_Routine    ;Not used, just points to RTI


;The end.
