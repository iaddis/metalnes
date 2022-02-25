;NEStress program
;-------------------
;Binary created using DAsm 2.12 running on WinUAE.

   PROCESSOR   6502
OVERFLOWF	EQU   #$0006		;To check the V-flag
TMPCOUNT	EQU   #$0007		;Temporary Counter
READY		EQU   #$000E		;Is the game ready for the player's input?
CONTROLLER1	EQU   #$0010		;Controller 1 data
CONTROLLER2	EQU   #$0011		;Controller 2 data
CONTROLLER3	EQU   #$0012		;Controller 3 data
CONTROLLER4	EQU   #$0013		;Controller 4 data
CONTROLER1X	EQU   #$0014		;Controller 1 Xdata
CONTROLER2X	EQU   #$0015		;Controller 2 Xdata
P1RANDBASE	EQU   #$0018		;Random number storage for player 1's position
P2RANDBASE	EQU   #$0019		;Random number storage for player 2's position
FADESTATUS	EQU   #$001B		;Controls fading
;-----------------------
PALETTEPTR	EQU   #$24			;Pointer to Current Palette.
SCORE		EQU   #$30			;Score on the test.
SCORE_T		EQU   #$32			;Temp reg for score.
;-----------------------
VBWAIT		EQU   #$0050		;Delays updating of game data
VBDELAY		EQU   #$0051		;Timing for fades...
VBPASS		EQU   #$0052		;Flag that VB has passed.
VBODD		EQU   #$0053		;Flag for even/odd VBs.
PPU2000		EQU   #$0058		;$2000 of PPU

;-------------------------------------------------------
GAMESCREEN  EQU   #$0059      ;ID for which game screen is running...
                              ;.. sometimes also for what CHR-ROM in use...
                              ;0 = Tanks Screen
                              ;1 = Planets Screen
                              ;2 = Title Screen
                              ;3 = /
                              ;4 = Controls Screen
                              ;5 = Credits Screen
                              ;6 = Victory Screen
;---------------------------------------
PLANETCHANGE EQU  #$005A      ;Flag to change planets on selection screen.

IOREADS     EQU   #$0500		;Storage of reads from $4016, 48 bytes.

TEMPPAL     EQU   #$0600		;Temporary storage for palette.
SOFTTERRAIN EQU   #$06BF		;$700-64-1

;----------------------
;Sprite-RAM
;----------------------
BALLCHR     EQU   #$0701		;Ball's Sprite
P1VHIY      EQU   #$0711		;Sprites for Y,X Initial Velocity
P1VLOY      EQU   #$0715
P1VHIX      EQU   #$0719
P1VLOX      EQU   #$071D
P2VHIY      EQU   #$0721		;Sprites for Y,X Initial Velocity
P2VLOY      EQU   #$0725
P2VHIX      EQU   #$0729
P2VLOX      EQU   #$072D
P1SCRSCORE  EQU   #$0731		;Score on-screen
P2SCRSCORE  EQU   #$0735
P1CHRPOSY   EQU   #$0750		;Sprites for tank's position
P1CHRPOSX   EQU   #$0753
P2CHRPOSY   EQU   #$0758
P2CHRPOSX   EQU   #$075B
EXPLSPR1    EQU   #$0741		;Sprites for explosions
EXPLSPR2    EQU   #$0745		;"       "
EXPLSPR3    EQU   #$0749		;"       "
EXPLSPR4    EQU   #$074D		;"       "


   ORG   $8000    ;32Kb PRG-ROM, 8Kb CHR-ROM

    dc.b  "FluBBa YaDa YaDa"


Reset_Routine  SUBROUTINE
   cld					;Clear decimal flag
   sei					;Disable interrupts
;----------------------------------------------------------
   lda   $2002
   sta   P1RANDBASE        ;Randomize Stuff???
   lda   $4016
   sta   P2RANDBASE


;----------------------------------------------------------

.WaitV01   lda $2002
   bpl .WaitV01     	;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx PPU2000
   stx $2001			;Screen display off, amongst other things
   dex
   txs					;Top of stack at $1FF

;Clear (most of) the NES' WRAM.
   ldy #$07				;To clear 8 x $100 bytes, from $0000 to $07FF.
   sty $01				;Store count value in $01
   ldy #$00
   sty $00
   lda #$00
.Clear
   sta ($00),y			;Clear $100 bytes
   dey
   bne .Clear

   dec $01				;Decrement "banks" left counter
   bpl .Clear			;Do next if >= 0

   jsr   WipePPU
   lda   #$00			; What is filled in the SPRRAM
   jsr   ClearSPRRAM

;-------------------------------------------------------------------
;*******************************************************************
;-------------------------------------------------------------------
;Title Screen
.TitleMain
   lda   #$02
   sta   GAMESCREEN        ;Set CHR-ROM for mapper 3??

TITLESCROLL   EQU   $0000
TITLESCROLL1  EQU   $0001
TITLESCROLL2  EQU   $0002
TITLESELECT   EQU   $0003
BUTTONDOWN    EQU   $0006

   lda   #$0D
   jsr   SetPalette

   lda   #<.TitleMap
   sta   $00
   lda   #>.TitleMap
   sta   $01
   lda   #$00              ;Screen 0
   jsr   PrintFullScreen

   lda   #$00
   sta   $2003
   lda   #$4E              ;Copy sprite to SPR-RAM?
   sta   $0700
   lda   #$01
   sta   $0701
   lda   #$00
   sta   $0702
   lda   #$66
   sta   $0703

   lda   .TitleCursorPos
   sta   $0704
   lda   #$02
   sta   $0705
   lda   #$01
   sta   $0706
   lda   #$40
   sta   $0707

   lda   #$00
   sta   $2005
   sta   $2005

   sta   TITLESCROLL
   sta   TITLESCROLL1
   sta   TITLESCROLL2
   sta   VBPASS
   sta   TITLESELECT
   sta   BUTTONDOWN

;************************************


;Enable vblank interrupts, etc.
   lda   #%10001000
   sta   $2000
   lda   #%00011110        ;Screen on, sprites on, show leftmost 8 pixels, colour
   sta   $2001

.TitleLoop
   lda   VBPASS
   beq   .TitleLoop        ;Wait for VBlank to pass...

.TitleLoop0
   lda   $2002
   bmi   .TitleLoop0       ;Yet again....

.TitleLoop0A
   lda   $2002
   and   #$40
   bne   .TitleLoop0A      ;Wait for sprite 0 clear...

   lda   #$00
   sta   VBPASS
   ldx   TITLESCROLL




.TitleLoop1
   lda   $2002
   and   #%00010000
   bne   .TitleLoop1

   lda   CONTROLLER1       ;Check for controller press
   and   #%00010000
   beq   .TitleLoop0Z
   jmp   .ExitTitle
.TitleLoop0Z

   inc   TITLESCROLL2
   lda   TITLESCROLL2
   cmp   #$02
   bne   .NoUpdateTitleScroll
   lda   #$00
   sta   TITLESCROLL2

   lda   .TitleSINTAB,X    ;Set up wavy scrolling.
   sta   $2005
   lda   #$00
   sta   $2005
   inx
   cpx   #$40
   bne   .NoUpdateTitleScroll
   ldx   #$00
.NoUpdateTitleScroll

.TitleLoop0B
   lda   $2002
   and   #$40
   beq   .TitleLoop1       ;Test for sprite 0 hit yet.

   lda   #$00
   sta   $2005
   sta   $2005

   lda   CONTROLLER1
   and   #%00100000
   beq   .NoTitleSelect
   lda   BUTTONDOWN
   bne   .NoTitleStart
   lda   #$01
   sta   BUTTONDOWN
   inc   TITLESELECT
   ldx   TITLESELECT
   lda   .TitleCursorPos,X
   sta   $0704
   lda   TITLESELECT
   cmp   #$05
   bne   .NoTitleSelectClear
   lda   #$00
   sta   TITLESELECT
   lda   .TitleCursorPos
   sta   $0704
.NoTitleSelectClear
   jmp   .NoTitleStart
.NoTitleSelect
   lda   #$00
   sta   BUTTONDOWN
   lda   CONTROLLER1
   and   #%11010000
   beq   .NoTitleStart
   jmp   .ExitTitle
.NoTitleStart
   jmp .TitleLoop

.TitleCursorPos   dc.b #$60,#$70,#$80,#$90,#$A0

.TitleSINTAB
	dc.b	1,3,7,13,20,30,40,50,60,70,80,90,95,100,101,102,103,103,104,103,100,90,85,80,74,67,59,49,36
   INCLUDE FireWave.asm

.TitleMap
	dc.b	"01234      First line      78901"
	dc.b	"0              I               1"
	dc.b	" AAAD      AAAD  AAAAAAAAAA    1"
	dc.b	" A  D      A  D  A        D    1"
	dc.b	" A  D AAAD A  D  A   DA   D    1"
	dc.b	" A  DA    DA  D  A        D    1"
	dc.b	" A  D      A  D  A  DDDD  D    1"
	dc.b	" A    DDDA    D  A  D  A  D    1"
	dc.b	" A   D    A   D  A  D  A  D    1"
	dc.b	" ADDD      AAAD  ADDD  ADDD    1"
	dc.b	"0          000000000000000000001"
	dc.b	"0                              1"
	dc.b	"0        PPU Test (Graphics)   1"
	dc.b	"0                              1"
	dc.b	"0        pAPU Test (Sound)     1"
	dc.b	"0                              1"
	dc.b	"0        CPU Test (Code)       1"
	dc.b	"0                              1"
	dc.b	"0        IO-Ports (Controllers)1"
	dc.b	"0                              1"
	dc.b	"0        Exit                  1"
	dc.b	"0                              1"
	dc.b	"0                              1"
	dc.b	"0 ---------------------------- 1"
	dc.b	"0                              1"
	dc.b	"0                              1"
	dc.b	"0                              1"
	dc.b	"0                              1"
	dc.b	"0                              1"
	dc.b	"01234       Last Line      78901"


   INCLUDE SolarTitleNAM.asm

.Mess000
	dc.b	"--------------------------------",$0A
	dc.b	" * PPU Test 1: $2005/6/7.     * ",$0A
	dc.b	"--------------------------------",$0A,$0A

	dc.b	" PPU Normal write/read:",$0A
	dc.b	" PPU Write, read, write:",$0A
	dc.b	" PPU First read then write:",$0A
	dc.b	" PPU First read correct:",$0A
	dc.b	" PPU Mixed adr/data write:",$0A
	dc.b	" PPU $3000 Mirroring:",$0A
	dc.b	" PPU $3FFF-$0000 boundary:",$0A
	dc.b	" Mix writes to $2005/6:",$0A
	dc.b	" PPU Palette write/read:",$0A,$0A

	dc.b	" Score:   /9",$0A,$0A

	dc.b	"          Press Start",$0


.Mess010
	dc.b	"--------------------------------",$0A
	dc.b	" * PPU Test 2: Sprites.       * ",$0A
	dc.b	"--------------------------------",$0A,$0A

	dc.b	" Sprite Collision:",$0A
	dc.b	" Sprite Limiter:",$0A
	dc.b	" CPU write CPU read:",$0A
	dc.b	" DMA write CPU read:",$0A
	dc.b	" Dif. DMA write CPU read:",$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A

	dc.b	" Score:   /13",$0A,$0A

	dc.b	"          Press Start",$0

.Mess020
	dc.b	"--------------------------------",$0A
	dc.b	" * PPU Test 3: VBl ($2002).   * ",$0A
	dc.b	"--------------------------------",$0A,$0A

	dc.b	" Bit 7 cleared after read:",$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A

	dc.b	" Score:   /14",$0A,$0A

	dc.b	"          Press Start",$0


.Mess040
	dc.b	"--------------------------------",$0A
	dc.b	" * pAPU Test 1: $4000-$4003.  * ",$0A
	dc.b	"--------------------------------",$0A,$0A
.Mess041
	dc.b	$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	dc.b	" Score:   /0",$0A,$0A
	dc.b	"          Press Start",0


.Mess080
	dc.b	"--------------------------------",$A
	dc.b	" * CPU Test 1: Aritmethic ops * ",$A
	dc.b	"--------------------------------",$A,$A
.Mess081
	dc.b	" CPU ADC:",$A
	dc.b	" CPU SBC:",$A
	dc.b	" CPU CMP:",$A
	dc.b	" CPU CPX:",$A
	dc.b	" CPU CPY:",$A
	dc.b	" CPU INC:",$A
	dc.b	" CPU DEC:",$A
	dc.b	" CPU INX:",$A
	dc.b	" CPU DEX:",$A
	dc.b	" CPU INY:",$A
	dc.b	" CPU DEY:",$A
	dc.b	" CPU ASL:",$A
	dc.b	" CPU LSR:",$A
	dc.b	" CPU ROL:",$A
	dc.b	" CPU ROR:",$A,$A,$A,$A,$A
	dc.b	" Score:   /15",$A,$A
	dc.b	"          Press Start",0

.Mess090
	dc.b	"--------------------------------",$A
	dc.b	" * CPU Test 2: Logic ops      * ",$A
	dc.b	"--------------------------------",$A,$A
.Mess091
	dc.b	" CPU LDA:",$A
	dc.b	" CPU LDX:",$A
	dc.b	" CPU LDY:",$A
	dc.b	" CPU TAX:",$A
	dc.b	" CPU TAY:",$A
	dc.b	" CPU TSX:",$A
	dc.b	" CPU TXA:",$A
	dc.b	" CPU TXS:",$A
	dc.b	" CPU TYA:",$A
	dc.b	" CPU PLA:",$A
	dc.b	" CPU AND:",$A
	dc.b	" CPU EOR:",$A
	dc.b	" CPU ORA:",$A
	dc.b	" CPU BIT:",$A,$A,$A,$A,$A,$A
	dc.b	" Score:   /29",$A,$A
	dc.b	"          Press Start",0

.Mess0A0
	dc.b	"--------------------------------",$0A
	dc.b	" * CPU Test 3: Addresses      * ",$0A
	dc.b	"--------------------------------",$0A,$0A
.Mess0A1
	dc.b	" Adr Immediate:",$0A
	dc.b	" Adr Zero Page:",$0A
	dc.b	" Adr Zero Page,X:",$0A
	dc.b	" Adr Absolute:",$0A
	dc.b	" Adr Absolute,X:",$0A
	dc.b	" Adr Absolute,Y:",$0A
	dc.b	" Adr (Indirect,X):",$0A
	dc.b	" Adr (Indirect),Y:",$0A
	dc.b	" JMP:",$0A
	dc.b	" JMP():",$0A
	dc.b	" JSR:",$0A
	dc.b	" RTS:",$0A
	dc.b	" RTI:",$0A,$0A,$0A,$0A,$0A,$0A,$0A
	dc.b	" Score:   /42",$0A,$0A
	dc.b	"          Press Start",0

.Mess0B0
	dc.b	"--------------------------------",$0A
	dc.b	" * CPU Test 4: Misc           * ",$0A
	dc.b	"--------------------------------",$0A,$0A
.Mess0B1
	dc.b	" Write / read SR:",$0A
	dc.b	" BRK flags:",$0A
	dc.b	" BRK return adr:",$0A
	dc.b	" Stack adr:",$0A
	dc.b	" CPU RAM:",$0A
	dc.b	" CPU RAM Mirror:",$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	dc.b	" Score:   /48",$0A,$0A
	dc.b	"          Press Start",0


.Mess0C0
	dc.b	"--------------------------------",$0A
	dc.b	" * IO Test 1: $4016, $4017.   * ",$0A
	dc.b	"--------------------------------",$0A,$0A,$0A
.Mess0C1
	dc.b	" $4016",$0A
	dc.b	" Read 1-8:",$0A
	dc.b	" Read 9-16:",$0A
	dc.b	" Read 17-24:",$0A,$0A
	dc.b	" $4017",$0A
	dc.b	" Read 1-8:",$0A
	dc.b	" Read 9-16:",$0A
	dc.b	" Read 17-24:",$0A,$0A
	dc.b	$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	dc.b	" Score:   /0",$0A,$0A
	dc.b	"      Press Select & Start",0

.Mess0D0
	dc.b	" -------------------",$0A
	dc.b	" |  ^              |",$0A
	dc.b	" | <o>             |",$0A
	dc.b	" |  v   Se St  B A |",$0A
	dc.b	" -------------------",$0A
	dc.b	" -------------------",$0A
	dc.b	" |  ^              |",$0A
	dc.b	" | <o>             |",$0A
	dc.b	" |  v   Se St  B A |",$0A
	dc.b	" -------------------",$0A
	dc.b	" -------------------",$0A
	dc.b	" |  ^              |",$0A
	dc.b	" | <o>             |",$0A
	dc.b	" |  v   Se St  B A |",$0A
	dc.b	" -------------------",$0A
	dc.b	" -------------------",$0A
	dc.b	" |  ^              |",$0A
	dc.b	" | <o>             |",$0A
	dc.b	" |  v   Se St  B A |",$0A
	dc.b	" -------------------",$0A
	dc.b	$0A,$0A,$0A
	dc.b	" Score:   /0",$0A,$0A
	dc.b	"      Press Select & Start",0



DrpcjrMess
	dc.b	"DrPC",0
FamiMess
	dc.b	"Fami",0
NesMess
	dc.b	"NES",0
YesMess
	dc.b	"Yes",0
NoMess
	dc.b	"No",0
OkMess
	dc.b	"Ok",0
ErrMess
	dc.b	"Error",0
ErrMessZ
	dc.b	"Error in Z-Flag",0
ErrMessN
	dc.b	"Error in N-Flag",0
ErrMessV
	dc.b	"Error in V-Flag",0
ErrMessC
	dc.b	"Error in C-Flag",0
ErrMessD
	dc.b	"Error in D-Flag",0
ErrMessI
	dc.b	"Error I-Flag",0
ErrMessB
	dc.b	"Error B-Flag",0
ErrMessR
	dc.b	"Error in result",0
ErrMessW
	dc.b	"Error in wrap",0
;----------------------------------------------------------------
.ExitTitle
   lda   TITLESELECT
   cmp   #$00
   beq   StartPPUTest
   cmp   #$01
   beq   StartpAPUTest
   cmp   #$02
   beq   StartCPUTest
   cmp   #$03
   beq   StartIOTest
   jmp   TestEnd

StartpAPUTest
   jmp   pAPUTest
StartPPUTest
   jmp   PPUTest
StartCPUTest
   jmp   CPUTest
StartIOTest
;----------------------------------------------------------------
IOTest				;Test IO-ports (controllers)

.WaitV10
   lda $2002
   bpl .WaitV10		;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx $2001		;Screen display off, amongst other things


   jsr   WipePPU

   lda   #<.Mess0C0
   sta   $00
   lda   #>.Mess0C0
   sta   $01
   lda   #$20
   sta   $02
   lda   #$40
   sta   $03
   jsr   NESWriter0
;-----------------------------
   lda   #%10001000
   sta   $2000
   lda   #%00011110        ;Screen on, sprites on, show leftmost 8 pixels, colour
   sta   $2001

   lda   #$00
   sta   TMPCOUNT

.IOTest00
   lda   VBPASS
   beq   .IOTest00			;Wait for VBlank to pass...

   clc
   lda   #$21				;Set PPU address for the first 24 values.
   sta   $2006
   lda   TMPCOUNT
   asl
   asl
   cmp   #$60
   bmi   .SkipRow
   adc   #$40
.SkipRow
   adc   #$0C
   sta   $2006

   lda   TMPCOUNT
   clc
   adc   #$08
   tax
   ldy   #8
.IOLoop1_0
   dex
   lda   $500,x
   lsr
   lsr
   lsr
   lsr
   clc
   adc   #$30
   sta   $2007
   lda   $500,x
   and   #$0F
   adc   #$30
   sta   $2007
   dey
   bne   .IOLoop1_0

   clc
   lda   TMPCOUNT
   adc   #$08
   cmp   #$30
   bne   .NoOverflow
   lda   #$00
.NoOverflow
   sta   TMPCOUNT
   jmp .IOSkipBig


.IOSkipBig
   lda   #$00
   sta   VBPASS
   sta   $2005
   sta   $2005

   lda   CONTROLLER1
   eor   #$30				; Check for both [Select] and [Start].
   bne   .IOTest00

;-----------------------------
IO1_End
   ldx   #$23
   ldy   #$28
   jsr   PrintScore
   jsr   ScrOnWaitKey

;-----------------------------
.WaitV11
   lda $2002
   bpl .WaitV11		;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx $2001		;Screen display off, amongst other things


   jsr   WipePPU

   lda   #<.Mess0D0
   sta   $00
   lda   #>.Mess0D0
   sta   $01
   lda   #$20
   sta   $02
   lda   #$40
   sta   $03
   jsr   NESWriter0
;-----------------------------
   lda   #%10001000
   sta   $2000
   lda   #%00011110        ;Screen on, sprites on, show leftmost 8 pixels, colour
   sta   $2001
.IOTest20
   lda   VBPASS
   beq   .IOTest20			;Wait for VBlank to pass...

.IOLoop2
   lda   #$20				;Set PPU address.
   sta   $2006
   lda   #$64
   sta   $2006
   ldx   #"^"
   lda   $503				;Check Cont1 Up
   and   #1
   beq   .NoCont1Up
   ldx   #1
.NoCont1Up
   stx   $2007

   lda   #$20				;Set PPU address.
   sta   $2006
   lda   #$83
   sta   $2006
   ldx   #"<"
   lda   $501				;Check Cont1 Left
   and   #1
   beq   .NoCont1Left
   ldx   #1
.NoCont1Left
   stx   $2007

   lda   #$20				;Set PPU address.
   sta   $2006
   lda   #$85
   sta   $2006
   ldx   #">"
   lda   $500				;Check Cont1 Right
   and   #1
   beq   .NoCont1Right
   ldx   #1
.NoCont1Right
   stx   $2007

   lda   #$20				;Set PPU address.
   sta   $2006
   lda   #$A4
   sta   $2006
   ldx   #"V"
   lda   $502				;Check Cont1 Down
   and   #1
   beq   .NoCont1Down
   ldx   #1
.NoCont1Down
   stx   $2007


   lda   #$00
   sta   VBPASS
   sta   $2005
   sta   $2005

   lda   CONTROLLER1
   eor   #$30				; Check for both [Select] and [Start].
   bne   .IOTest20


;-----------------------------
   jsr   ScrOnWaitKey

.TestNoKey1
   lda   CONTROLLER1
   and   #%11010000
   bne   .TestNoKey1
;-----------------------------

   jmp   Reset_Routine

;----------------------------------------------------------------
;****************************************************************
;----------------------------------------------------------------
CPUTest				;Test Aritmethic operations

.WaitV04
   lda $2002
   bpl .WaitV04     ;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx PPU2000
   stx $2001      ;Screen display off, amongst other things

   jsr   WipePPU

   lda   #<.Mess080
   sta   $00
   lda   #>.Mess080
   sta   $01
   lda   #$20
   sta   $02
   lda   #$40
   sta   $03
   jsr   NESWriter0

   lda   #%00011110        ;Background on, sprites on, show leftmost 8 pixels, colour
   sta   $2001
;-----------------------------
.CPUTest00			;CMP
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$09
   sta   $03

   lda   #$40		;Setup $6 for V-Flag detection
   sta   OVERFLOWF

.CPULoop00
   clv
   lda   #$82
   cmp   #4
   beq   .CPUError00Z
   bmi   .CPUError00N
   bvs   .CPUError00V
   bcc   .CPUError00C

   bit   OVERFLOWF			;Set V-Flag
   lda   #$7e
   cmp   #$7e
   bne   .CPUError00Z
   bmi   .CPUError00N
   bvc   .CPUError00V
   bcc   .CPUError00C

   cmp   #$7f
   beq   .CPUError00Z
   bpl   .CPUError00N
   bvc   .CPUError00V
   bcs   .CPUError00C

   clv
   lda   #$ff
   cmp   #4
   beq   .CPUError00Z
   bpl   .CPUError00N
   bvs   .CPUError00V
   bcc   .CPUError00C

.CPUOk00
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest01

.CPUError00Z
   jsr   WriteErrorZ
   jmp   .CPUTest01
.CPUError00N
   jsr   WriteErrorN
   jmp   .CPUTest01
.CPUError00V
   jsr   WriteErrorV
   jmp   .CPUTest01
.CPUError00C
   jsr   WriteErrorC
;-----------------------------
.CPUTest01			;CPX
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$29
   sta   $03
.CPULoop01
   clc
   clv
   lda   #$82
   ldx   #$82
   cpx   #4
   beq   .CPUError01Z
   bmi   .CPUError01N
   bvs   .CPUError01V
   bcc   .CPUError01C
   ldx   #$7e
   sbc   #4
   cpx   #$7e
   bne   .CPUError01Z
   bmi   .CPUError01N
   bvc   .CPUError01V
   bcc   .CPUError01C
   cpx   #$7f
   beq   .CPUError01Z
   bpl   .CPUError01N
   bvc   .CPUError01V
   bcs   .CPUError01C
   ldx   #$FF
   sbc   #$7E
   cpx   #4
   beq   .CPUError01Z
   bpl   .CPUError01N
   bvs   .CPUError01V
   bcc   .CPUError01C

.CPUOk01
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest02

.CPUError01Z
   jsr   WriteErrorZ
   jmp   .CPUTest02
.CPUError01N
   jsr   WriteErrorN
   jmp   .CPUTest02
.CPUError01V
   jsr   WriteErrorV
   jmp   .CPUTest02
.CPUError01C
   jsr   WriteErrorC
;-----------------------------
.CPUTest02			;CPY
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$49
   sta   $03
.CPULoop02
   clc
   clv
   lda   #$82
   ldy   #$82
   cpy   #4
   beq   .CPUError02Z
   bmi   .CPUError02N
   bvs   .CPUError02V
   bcc   .CPUError02C
   ldy   #$7e
   sbc   #4
   cpy   #$7e
   bne   .CPUError02Z
   bmi   .CPUError02N
   bvc   .CPUError02V
   bcc   .CPUError02C
   cpy   #$7f
   beq   .CPUError02Z
   bpl   .CPUError02N
   bvc   .CPUError02V
   bcs   .CPUError02C
   ldy   #$FF
   sbc   #$7E
   cpy   #4
   beq   .CPUError02Z
   bpl   .CPUError02N
   bvs   .CPUError02V
   bcc   .CPUError02C

.CPUOk02
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest1

.CPUError02Z
   jsr   WriteErrorZ
   jmp   .CPUTest1
.CPUError02N
   jsr   WriteErrorN
   jmp   .CPUTest1
.CPUError02V
   jsr   WriteErrorV
   jmp   .CPUTest1
.CPUError02C
   jsr   WriteErrorC
;-----------------------------
.CPUTest1			;ADC
   lda   #$20		;Where the msg prints.
   sta   $02
   lda   #$C9
   sta   $03
.CPULoop1
   clc
   lda   #$7a
   adc   #4
   beq   .CPUError1Z
   bmi   .CPUError1N
   bvs   .CPUError1V
   bcs   .CPUError1C
   adc   #4
   beq   .CPUError1Z
   bpl   .CPUError1N
   bvc   .CPUError1V
   bcs   .CPUError1C
   adc   #$70
   beq   .CPUError1Z
   bpl   .CPUError1N
   bvs   .CPUError1V
   bcs   .CPUError1C
   adc   #$e
   bne   .CPUError1Z
   bmi   .CPUError1N
   bvs   .CPUError1V
   bcc   .CPUError1C
   lda   #$94
   adc   #$7f
   beq   .CPUError1Z
   bmi   .CPUError1N
   bvs   .CPUError1V
   bcc   .CPUError1C
   adc   #$e
   cmp   #$23
   bne   .CPUError1R

   clc
   sed
   lda   #$08
   adc   #$08
   cmp   #$10
   cld
   bne   .CPUError1D

.CPUOk1
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest2

.CPUError1Z
   jsr   WriteErrorZ
   jmp   .CPUTest2
.CPUError1N
   jsr   WriteErrorN
   jmp   .CPUTest2
.CPUError1V
   jsr   WriteErrorV
   jmp   .CPUTest2
.CPUError1C
   jsr   WriteErrorC
   jmp   .CPUTest2
.CPUError1R
   jsr   WriteErrorR
   jmp   .CPUTest2
.CPUError1D
   jsr   WriteErrorD
;-----------------------------
.CPUTest2			;SBC
   lda   #$20		;Where the msg prints.
   sta   $02
   lda   #$E9
   sta   $03
.CPULoop2
   clc
   lda   #$82
   sbc   #$81
   bne   .CPUError2R
   sec
   lda   #$3A
   sbc   #$3A
   bne   .CPUError2R


   clc
   lda   #$82
   sbc   #4
   beq   .CPUError2Z
   bmi   .CPUError2N
   bvc   .CPUError2V
   bcc   .CPUError2C
   sbc   #$7d
   bne   .CPUError2Z
   bmi   .CPUError2N
   bvs   .CPUError2V
   bcc   .CPUError2C
   sbc   #$7
   beq   .CPUError2Z
   bpl   .CPUError2N
   bvs   .CPUError2V
   bcs   .CPUError2C
   sbc   #$79
   beq   .CPUError2Z
   bmi   .CPUError2N
   bvc   .CPUError2V
   bcc   .CPUError2C
   cmp   #$7F
   bne   .CPUError2R

   clc
   lda   #$7E
   sbc   #$7F
   beq   .CPUError2Z
   bpl   .CPUError2N
   bvs   .CPUError2V
   bcs   .CPUError2C

   sec
   sed
   lda   #$10
   sbc   #$08
   cmp   #$08
   cld
   bne   .CPUError2D

.CPUOk2
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest3

.CPUError2Z
   jsr   WriteErrorZ
   jmp   .CPUTest3
.CPUError2N
   jsr   WriteErrorN
   jmp   .CPUTest3
.CPUError2V
   jsr   WriteErrorV
   jmp   .CPUTest3
.CPUError2C
   jsr   WriteErrorC
   jmp   .CPUTest3
.CPUError2R
   jsr   WriteErrorR
   jmp   .CPUTest3
.CPUError2D
   jsr   WriteErrorD
;-----------------------------
.CPUTest3			;INC
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$69
   sta   $03

.CPULoop3
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$fe
   sta   $04
   lda   #0
   inc   $04
   beq   .CPUError3Z
   bpl   .CPUError3N
   bvc   .CPUError3V
   bcc   .CPUError3C

   clc
   lda   #1
   inc   $04
   bne   .CPUError3Z
   bmi   .CPUError3N
   bvc   .CPUError3V
   bcs   .CPUError3C

   sec
   clv
   lda   #$7f
   sta   $04
   lda   #0
   inc   $04
   beq   .CPUError3Z
   bpl   .CPUError3N
   bvs   .CPUError3V
   bcc   .CPUError3C

.CPUOk3
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest4

.CPUError3Z
   jsr   WriteErrorZ
   jmp   .CPUTest4
.CPUError3N
   jsr   WriteErrorN
   jmp   .CPUTest4
.CPUError3V
   jsr   WriteErrorV
   jmp   .CPUTest4
.CPUError3C
   jsr   WriteErrorC
;-----------------------------
.CPUTest4			;DEC
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$89
   sta   $03

.CPULoop4
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$01
   sta   $04
   lda   #$fe
   dec   $04
   bne   .CPUError4Z
   bmi   .CPUError4N
   bvc   .CPUError4V
   bcc   .CPUError4C

   clc
   dec   $04
   beq   .CPUError4Z
   bpl   .CPUError4N
   bvc   .CPUError4V
   bcs   .CPUError4C

   sec
   clv
   lda   #$80
   sta   $04
   lda   #0
   dec   $04
   beq   .CPUError4Z
   bmi   .CPUError4N
   bvs   .CPUError4V
   bcc   .CPUError4C

.CPUOk4
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest5

.CPUError4Z
   jsr   WriteErrorZ
   jmp   .CPUTest5
.CPUError4N
   jsr   WriteErrorN
   jmp   .CPUTest5
.CPUError4V
   jsr   WriteErrorV
   jmp   .CPUTest5
.CPUError4C
   jsr   WriteErrorC
;-----------------------------
.CPUTest5			;INX
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$A9
   sta   $03

.CPULoop5
   bit   OVERFLOWF			;Set V-Flag
   sec
   ldx   #$fe
   lda   #0
   inx
   beq   .CPUError5Z
   bpl   .CPUError5N
   bvc   .CPUError5V
   bcc   .CPUError5C

   clc
   lda   #1
   inx
   bne   .CPUError5Z
   bmi   .CPUError5N
   bvc   .CPUError5V
   bcs   .CPUError5C

   sec
   clv
   ldx   #$7f
   lda   #0
   inx
   beq   .CPUError5Z
   bpl   .CPUError5N
   bvs   .CPUError5V
   bcc   .CPUError5C

.CPUOk5
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest6

.CPUError5Z
   jsr   WriteErrorZ
   jmp   .CPUTest6
.CPUError5N
   jsr   WriteErrorN
   jmp   .CPUTest6
.CPUError5V
   jsr   WriteErrorV
   jmp   .CPUTest6
.CPUError5C
   jsr   WriteErrorC
;-----------------------------
.CPUTest6			;DEX
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$C9
   sta   $03

.CPULoop6
   bit   OVERFLOWF			;Set V-Flag.
   sec
   ldx   #$01
   lda   #$fe
   dex
   bne   .CPUError6Z
   bmi   .CPUError6N
   bvc   .CPUError6V
   bcc   .CPUError6C

   clc
   dex
   beq   .CPUError6Z
   bpl   .CPUError6N
   bvc   .CPUError6V
   bcs   .CPUError6C

   sec
   clv
   ldx   #$80
   lda   #0
   dex
   beq   .CPUError6Z
   bmi   .CPUError6N
   bvs   .CPUError6V
   bcc   .CPUError6C

.CPUOk6
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest7

.CPUError6Z
   jsr   WriteErrorZ
   jmp   .CPUTest7
.CPUError6N
   jsr   WriteErrorN
   jmp   .CPUTest7
.CPUError6V
   jsr   WriteErrorV
   jmp   .CPUTest7
.CPUError6C
   jsr   WriteErrorC
;-----------------------------
.CPUTest7			;INY
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$E9
   sta   $03

.CPULoop7
   bit   OVERFLOWF			;Set V-Flag.
   sec
   ldy   #$fe
   lda   #0
   iny
   beq   .CPUError7Z
   bpl   .CPUError7N
   bvc   .CPUError7V
   bcc   .CPUError7C

   clc
   lda   #1
   iny
   bne   .CPUError7Z
   bmi   .CPUError7N
   bvc   .CPUError7V
   bcs   .CPUError7C

   sec
   clv
   ldy   #$7f
   lda   #0
   iny
   beq   .CPUError7Z
   bpl   .CPUError7N
   bvs   .CPUError7V
   bcc   .CPUError7C

.CPUOk7
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest8

.CPUError7Z
   jsr   WriteErrorZ
   jmp   .CPUTest8
.CPUError7N
   jsr   WriteErrorN
   jmp   .CPUTest8
.CPUError7V
   jsr   WriteErrorV
   jmp   .CPUTest8
.CPUError7C
   jsr   WriteErrorC
;-----------------------------
.CPUTest8			;DEY
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$09
   sta   $03

.CPULoop8
   bit   OVERFLOWF			;Set V-Flag.
   sec
   ldy   #$01
   lda   #$fe
   dey
   bne   .CPUError8Z
   bmi   .CPUError8N
   bvc   .CPUError8V
   bcc   .CPUError8C

   clc
   dey
   beq   .CPUError8Z
   bpl   .CPUError8N
   bvc   .CPUError8V
   bcs   .CPUError8C

   sec
   clv
   ldy   #$80
   lda   #0
   dey
   beq   .CPUError8Z
   bmi   .CPUError8N
   bvs   .CPUError8V
   bcc   .CPUError8C

.CPUOk8
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest9

.CPUError8Z
   jsr   WriteErrorZ
   jmp   .CPUTest9
.CPUError8N
   jsr   WriteErrorN
   jmp   .CPUTest9
.CPUError8V
   jsr   WriteErrorV
   jmp   .CPUTest9
.CPUError8C
   jsr   WriteErrorC
;-----------------------------
.CPUTest9			;ASL
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$29
   sta   $03

.CPULoop9
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$40
   asl
   beq   .CPUError9Z
   bpl   .CPUError9N
   bvc   .CPUError9V
   bcs   .CPUError9C

   clv
   asl
   bne   .CPUError9Z
   bmi   .CPUError9N
   bvs   .CPUError9V
   bcc   .CPUError9C

.CPUOk9
   inc   SCORE
   jsr   WriteOk
   jmp  .CPUTest10

.CPUError9Z
   jsr   WriteErrorZ
   jmp   .CPUTest10
.CPUError9N
   jsr   WriteErrorN
   jmp   .CPUTest10
.CPUError9V
   jsr   WriteErrorV
   jmp   .CPUTest10
.CPUError9C
   jsr   WriteErrorC
;-----------------------------
.CPUTest10			;LSR
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$49
   sta   $03

.CPULoop10
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$02
   lsr
   beq   .CPUError10Z
   bmi   .CPUError10N
   bvc   .CPUError10V
   bcs   .CPUError10C

   clv
   lsr
   bne   .CPUError10Z
   bmi   .CPUError10N
   bvs   .CPUError10V
   bcc   .CPUError10C

   lda   #$C2
   lsr
   beq   .CPUError10Z
   bmi   .CPUError10N
   bvs   .CPUError10V
   bcs   .CPUError10C

.CPUOk10
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest11

.CPUError10Z
   jsr   WriteErrorZ
   jmp   .CPUTest11
.CPUError10N
   jsr   WriteErrorN
   jmp   .CPUTest11
.CPUError10V
   jsr   WriteErrorV
   jmp   .CPUTest11
.CPUError10C
   jsr   WriteErrorC
;-----------------------------
.CPUTest11			;ROL
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$69
   sta   $03

.CPULoop11
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #0
   rol
   beq   .CPUError11Z
   bmi   .CPUError11N
   bvc   .CPUError11V
   bcs   .CPUError11C

   lda   #$55
   rol
   beq   .CPUError11Z
   bpl   .CPUError11N
   bvc   .CPUError11V
   bcs   .CPUError11C

   clv
   lda   #$80
   rol
   bne   .CPUError11Z
   bmi   .CPUError11N
   bvs   .CPUError11V
   bcc   .CPUError11C

   lda   #$C2
   rol
   beq   .CPUError11Z
   bpl   .CPUError11N
   bvs   .CPUError11V
   bcc   .CPUError11C

.CPUOk11
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest12

.CPUError11Z
   jsr   WriteErrorZ
   jmp   .CPUTest12
.CPUError11N
   jsr   WriteErrorN
   jmp   .CPUTest12
.CPUError11V
   jsr   WriteErrorV
   jmp   .CPUTest12
.CPUError11C
   jsr   WriteErrorC
;-----------------------------
.CPUTest12			;ROR
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$89
   sta   $03

.CPULoop12
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$0e
   ror
   beq   .CPUError12Z
   bpl   .CPUError12N
   bvc   .CPUError12V
   bcs   .CPUError12C

   ror
   beq   .CPUError12Z
   bmi   .CPUError12N
   bvc   .CPUError12V
   bcc   .CPUError12C

   clc
   clv
   lda   #$01
   ror
   bne   .CPUError12Z
   bmi   .CPUError12N
   bvs   .CPUError12V
   bcc   .CPUError12C

   ror
   beq   .CPUError12Z
   bpl   .CPUError12N
   bvs   .CPUError12V
   bcs   .CPUError12C

.CPUOk12
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest13

.CPUError12Z
   jsr   WriteErrorZ
   jmp   .CPUTest13
.CPUError12N
   jsr   WriteErrorN
   jmp   .CPUTest13
.CPUError12V
   jsr   WriteErrorV
   jmp   .CPUTest13
.CPUError12C
   jsr   WriteErrorC
;-----------------------------
.CPUTest13
CPU1_End
   ldx   #$23
   ldy   #$28
   jsr   PrintScore
   jsr   ScrOnWaitKey
;----------------------------------------------------------------
CPUTest_2				;Test Logical operations

.WaitV05
   lda $2002
   bpl .WaitV05     ;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx $2001      ;Screen display off, amongst other things


   jsr   WipePPU

   lda   #<.Mess090
   sta   $00
   lda   #>.Mess090
   sta   $01
   lda   #$20
   sta   $02
   lda   #$40
   sta   $03
   jsr   NESWriter0

   lda   #%00011110        ;Background on, sprites on, show leftmost 8 pixels, colour
   sta   $2001
;-----------------------------
.CPUTest20			;LDA
   lda   #$20		;Where the msg prints.
   sta   $02
   lda   #$C9
   sta   $03

.CPULoop20
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$0e
   beq   .CPUError20Z
   bmi   .CPUError20N
   bvc   .CPUError20V
   bcc   .CPUError20C

   lda   #0
   bne   .CPUError20Z
   bmi   .CPUError20N
   bvc   .CPUError20V
   bcc   .CPUError20C

   clv
   clc
   lda   #$aa
   beq   .CPUError20Z
   bpl   .CPUError20N
   bvs   .CPUError20V
   bcs   .CPUError20C

   lda   #$c8
   beq   .CPUError20Z
   bpl   .CPUError20N
   bvs   .CPUError20V
   bcs   .CPUError20C

.CPUOk20
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest21

.CPUError20Z
   jsr   WriteErrorZ
   jmp   .CPUTest21
.CPUError20N
   jsr   WriteErrorN
   jmp   .CPUTest21
.CPUError20V
   jsr   WriteErrorV
   jmp   .CPUTest21
.CPUError20C
   jsr   WriteErrorC
;-----------------------------
.CPUTest21			;LDX
   lda   #$20		;Where the msg prints.
   sta   $02
   lda   #$E9
   sta   $03

.CPULoop21
   bit   OVERFLOWF			;Set V-Flag.
   sec
   ldx   #$99
   beq   .CPUError21Z
   bpl   .CPUError21N
   bvc   .CPUError21V
   bcc   .CPUError21C

   ldx   #0
   bne   .CPUError21Z
   bmi   .CPUError21N
   bvc   .CPUError21V
   bcc   .CPUError21C

   clv
   clc
   ldx   #$ea
   beq   .CPUError21Z
   bpl   .CPUError21N
   bvs   .CPUError21V
   bcs   .CPUError21C

   ldx   #$45
   beq   .CPUError21Z
   bmi   .CPUError21N
   bvs   .CPUError21V
   bcs   .CPUError21C

.CPUOk21
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest22

.CPUError21Z
   jsr   WriteErrorZ
   jmp   .CPUTest22
.CPUError21N
   jsr   WriteErrorN
   jmp   .CPUTest22
.CPUError21V
   jsr   WriteErrorV
   jmp   .CPUTest22
.CPUError21C
   jsr   WriteErrorC
;-----------------------------
.CPUTest22			;LDY
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$09
   sta   $03

.CPULoop22
   bit   OVERFLOWF			;Set V-Flag.
   sec
   ldy   #$b2
   beq   .CPUError22Z
   bpl   .CPUError22N
   bvc   .CPUError22V
   bcc   .CPUError22C

   ldy   #0
   bne   .CPUError22Z
   bmi   .CPUError22N
   bvc   .CPUError22V
   bcc   .CPUError22C

   clv
   clc
   ldy   #$aa
   beq   .CPUError22Z
   bpl   .CPUError22N
   bvs   .CPUError22V
   bcs   .CPUError22C

   ldy   #$38
   beq   .CPUError22Z
   bmi   .CPUError22N
   bvs   .CPUError22V
   bcs   .CPUError22C

.CPUOk22
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest23

.CPUError22Z
   jsr   WriteErrorZ
   jmp   .CPUTest23
.CPUError22N
   jsr   WriteErrorN
   jmp   .CPUTest23
.CPUError22V
   jsr   WriteErrorV
   jmp   .CPUTest23
.CPUError22C
   jsr   WriteErrorC
;-----------------------------
.CPUTest23			;TAX
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$29
   sta   $03

.CPULoop23
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$0e
   ldx   #$90
   tax
   beq   .CPUError23Z
   bmi   .CPUError23N
   bvc   .CPUError23V
   bcc   .CPUError23C

   lda   #0
   ldx   #$ff
   tax
   bne   .CPUError23Z
   bmi   .CPUError23N
   bvc   .CPUError23V
   bcc   .CPUError23C

   clv
   clc
   lda   #$aa
   ldx   #0
   tax
   beq   .CPUError23Z
   bpl   .CPUError23N
   bvs   .CPUError23V
   bcs   .CPUError23C

   lda   #$c8
   ldx   #$32
   tax
   beq   .CPUError23Z
   bpl   .CPUError23N
   bvs   .CPUError23V
   bcs   .CPUError23C

.CPUOk23
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest24

.CPUError23Z
   jsr   WriteErrorZ
   jmp   .CPUTest24
.CPUError23N
   jsr   WriteErrorN
   jmp   .CPUTest24
.CPUError23V
   jsr   WriteErrorV
   jmp   .CPUTest24
.CPUError23C
   jsr   WriteErrorC
;-----------------------------
.CPUTest24			;TAY
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$49
   sta   $03

.CPULoop24
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$0e
   ldy   #$90
   tay
   beq   .CPUError24Z
   bmi   .CPUError24N
   bvc   .CPUError24V
   bcc   .CPUError24C

   lda   #0
   ldy   #$ff
   tay
   bne   .CPUError24Z
   bmi   .CPUError24N
   bvc   .CPUError24V
   bcc   .CPUError24C

   clv
   clc
   lda   #$aa
   ldy   #0
   tay
   beq   .CPUError24Z
   bpl   .CPUError24N
   bvs   .CPUError24V
   bcs   .CPUError24C

   lda   #$c8
   ldy   #$32
   tay
   beq   .CPUError24Z
   bpl   .CPUError24N
   bvs   .CPUError24V
   bcs   .CPUError24C

.CPUOk24
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest25

.CPUError24Z
   jsr   WriteErrorZ
   jmp   .CPUTest25
.CPUError24N
   jsr   WriteErrorN
   jmp   .CPUTest25
.CPUError24V
   jsr   WriteErrorV
   jmp   .CPUTest25
.CPUError24C
   jsr   WriteErrorC
;-----------------------------
.CPUTest25			;TSX
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$69
   sta   $03

   tsx
   txa
   tay				; Save old S
.CPULoop25
   bit   OVERFLOWF			;Set V-Flag.
   sec
   ldx   #$25
   txs
   ldx   #$93
   tsx
   beq   .CPUError25Z
   bmi   .CPUError25N
   bvc   .CPUError25V
   bcc   .CPUError25C

   ldx   #0
   txs
   ldx   #$ff
   tsx
   bne   .CPUError25Z
   bmi   .CPUError25N
   bvc   .CPUError25V
   bcc   .CPUError25C

   clv
   clc
   ldx   #$fa
   txs
   ldx   #0
   tsx
   beq   .CPUError25Z
   bpl   .CPUError25N
   bvs   .CPUError25V
   bcs   .CPUError25C

   ldx   #$b9
   txs
   ldx   #$7f
   tsx
   beq   .CPUError25Z
   bpl   .CPUError25N
   bvs   .CPUError25V
   bcs   .CPUError25C

.CPUOk25
   tya
   tax
   txs				; Get old S
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest26

.CPUError25Z
   tya
   tax
   txs				; Get old S
   jsr   WriteErrorZ
   jmp   .CPUTest26
.CPUError25N
   tya
   tax
   txs				; Get old S
   jsr   WriteErrorN
   jmp   .CPUTest26
.CPUError25V
   tya
   tax
   txs				; Get old S
   jsr   WriteErrorV
   jmp   .CPUTest26
.CPUError25C
   tya
   tax
   txs				; Get old S
   jsr   WriteErrorC
;-----------------------------
.CPUTest26			;TXA
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$89
   sta   $03

.CPULoop26
   bit   OVERFLOWF			;Set V-Flag.
   sec
   ldx   #$0e
   lda   #$90
   txa
   beq   .CPUError26Z
   bmi   .CPUError26N
   bvc   .CPUError26V
   bcc   .CPUError26C

   ldx   #0
   lda   #$ff
   txa
   bne   .CPUError26Z
   bmi   .CPUError26N
   bvc   .CPUError26V
   bcc   .CPUError26C

   clv
   clc
   ldx   #$aa
   lda   #0
   txa
   beq   .CPUError26Z
   bpl   .CPUError26N
   bvs   .CPUError26V
   bcs   .CPUError26C

   ldx   #$c8
   lda   #$32
   txa
   beq   .CPUError26Z
   bpl   .CPUError26N
   bvs   .CPUError26V
   bcs   .CPUError26C

.CPUOk26
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest27

.CPUError26Z
   jsr   WriteErrorZ
   jmp   .CPUTest27
.CPUError26N
   jsr   WriteErrorN
   jmp   .CPUTest27
.CPUError26V
   jsr   WriteErrorV
   jmp   .CPUTest27
.CPUError26C
   jsr   WriteErrorC
;-----------------------------
.CPUTest27			;TXS
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$A9
   sta   $03

   tsx
   txa
   tay				; Save old S
.CPULoop27
   bit   OVERFLOWF			;Set V-Flag.
   sec
   ldx   #$90
   lda   #$0e
   txs
   beq   .CPUError27Z
   bmi   .CPUError27N
   bvc   .CPUError27V
   bcc   .CPUError27C

   ldx   #$ff
   lda   #0
   txs
   bne   .CPUError27Z
   bmi   .CPUError27N
   bvc   .CPUError27V
   bcc   .CPUError27C

   clv
   clc
   ldx   #0
   lda   #$aa
   txs
   beq   .CPUError27Z
   bpl   .CPUError27N
   bvs   .CPUError27V
   bcs   .CPUError27C

   ldx   #$32
   lda   #$c8
   txs
   beq   .CPUError27Z
   bpl   .CPUError27N
   bvs   .CPUError27V
   bcs   .CPUError27C

.CPUOk27
   tya
   tax
   txs				; Get old S
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest28

.CPUError27Z
   tya
   tax
   txs				; Get old S
   jsr   WriteErrorZ
   jmp   .CPUTest28
.CPUError27N
   tya
   tax
   txs				; Get old S
   jsr   WriteErrorN
   jmp   .CPUTest28
.CPUError27V
   tya
   tax
   txs				; Get old S
   jsr   WriteErrorV
   jmp   .CPUTest28
.CPUError27C
   tya
   tax
   txs				; Get old S
   jsr   WriteErrorC
;-----------------------------
.CPUTest28			;TYA
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$C9
   sta   $03

.CPULoop28
   bit   OVERFLOWF			;Set V-Flag.
   sec
   ldy   #$0e
   lda   #$90
   tya
   beq   .CPUError28Z
   bmi   .CPUError28N
   bvc   .CPUError28V
   bcc   .CPUError28C

   ldy   #0
   lda   #$ff
   tya
   bne   .CPUError28Z
   bmi   .CPUError28N
   bvc   .CPUError28V
   bcc   .CPUError28C

   clv
   clc
   ldy   #$aa
   lda   #0
   tya
   beq   .CPUError28Z
   bpl   .CPUError28N
   bvs   .CPUError28V
   bcs   .CPUError28C

   ldy   #$c8
   lda   #$32
   tya
   beq   .CPUError28Z
   bpl   .CPUError28N
   bvs   .CPUError28V
   bcs   .CPUError28C

.CPUOk28
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest29

.CPUError28Z
   jsr   WriteErrorZ
   jmp   .CPUTest29
.CPUError28N
   jsr   WriteErrorN
   jmp   .CPUTest29
.CPUError28V
   jsr   WriteErrorV
   jmp   .CPUTest29
.CPUError28C
   jsr   WriteErrorC
;-----------------------------
.CPUTest29			;PLA
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$E9
   sta   $03

.CPULoop29
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$0e
   pha
   ldx   #$90
   pla
   beq   .CPUError29Z
   bmi   .CPUError29N
   bvc   .CPUError29V
   bcc   .CPUError29C

   lda   #0
   pha
   ldx   #$ff
   pla
   bne   .CPUError29Z
   bmi   .CPUError29N
   bvc   .CPUError29V
   bcc   .CPUError29C

   clv
   clc
   lda   #$aa
   pha
   ldx   #0
   pla
   beq   .CPUError29Z
   bpl   .CPUError29N
   bvs   .CPUError29V
   bcs   .CPUError29C

   lda   #$c8
   pha
   ldx   #$32
   pla
   beq   .CPUError29Z
   bpl   .CPUError29N
   bvs   .CPUError29V
   bcs   .CPUError29C

.CPUOk29
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest30

.CPUError29Z
   jsr   WriteErrorZ
   jmp   .CPUTest30
.CPUError29N
   jsr   WriteErrorN
   jmp   .CPUTest30
.CPUError29V
   jsr   WriteErrorV
   jmp   .CPUTest30
.CPUError29C
   jsr   WriteErrorC
;-----------------------------
.CPUTest30			;AND
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$09
   sta   $03

.CPULoop30
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$C8
   ldx   #$59
   and   #$9F
   beq   .CPUError30Z
   bpl   .CPUError30N
   bvc   .CPUError30V
   bcc   .CPUError30C

   lda   #0
   ldx   #$FF
   and   #$C5
   bne   .CPUError30Z
   bmi   .CPUError30N
   bvc   .CPUError30V
   bcc   .CPUError30C

   clv
   clc
   lda   #$c8
   ldx   #$83
   and   #$37
   bne   .CPUError30Z
   bmi   .CPUError30N
   bvs   .CPUError30V
   bcs   .CPUError30C

   lda   #$AA
   ldx   #0
   and   #$8F
   beq   .CPUError30Z
   bpl   .CPUError30N
   bvs   .CPUError30V
   bcs   .CPUError30C

   cmp   #$8A
   bne   .CPUError30R

.CPUOk30
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest31

.CPUError30Z
   jsr   WriteErrorZ
   jmp   .CPUTest31
.CPUError30N
   jsr   WriteErrorN
   jmp   .CPUTest31
.CPUError30V
   jsr   WriteErrorV
   jmp   .CPUTest31
.CPUError30C
   jsr   WriteErrorC
   jmp   .CPUTest31
.CPUError30R
   jsr   WriteErrorR
;-----------------------------
.CPUTest31			;EOR
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$29
   sta   $03

.CPULoop31
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$9e
   ldx   #$90
   eor   #$81
   beq   .CPUError31Z
   bmi   .CPUError31N
   bvc   .CPUError31V
   bcc   .CPUError31C

   lda   #$01
   ldx   #$ff
   eor   #$01
   bne   .CPUError31Z
   bmi   .CPUError31N
   bvc   .CPUError31V
   bcc   .CPUError31C

   clv
   clc
   lda   #$aa
   ldx   #0
   eor   #$71
   beq   .CPUError31Z
   bpl   .CPUError31N
   bvs   .CPUError31V
   bcs   .CPUError31C

   lda   #$C8
   ldx   #$32
   eor   #$66
   beq   .CPUError31Z
   bpl   .CPUError31N
   bvs   .CPUError31V
   bcs   .CPUError31C

   cmp   #$AE
   bne   .CPUError31R

.CPUOk31
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest32

.CPUError31Z
   jsr   WriteErrorZ
   jmp   .CPUTest32
.CPUError31N
   jsr   WriteErrorN
   jmp   .CPUTest32
.CPUError31V
   jsr   WriteErrorV
   jmp   .CPUTest32
.CPUError31C
   jsr   WriteErrorC
   jmp   .CPUTest32
.CPUError31R
   jsr   WriteErrorR
;-----------------------------
.CPUTest32			;ORA
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$49
   sta   $03

.CPULoop32
   bit   OVERFLOWF			;Set V-Flag.
   sec
   lda   #$0e
   ldx   #$90
   ora   #$20
   beq   .CPUError32Z
   bmi   .CPUError32N
   bvc   .CPUError32V
   bcc   .CPUError32C

   lda   #$00
   ldx   #$ff
   ora   #$00
   bne   .CPUError32Z
   bmi   .CPUError32N
   bvc   .CPUError32V
   bcc   .CPUError32C

   clv
   clc
   lda   #$0a
   ldx   #0
   ora   #$a0
   beq   .CPUError32Z
   bpl   .CPUError32N
   bvs   .CPUError32V
   bcs   .CPUError32C

   lda   #$08
   ldx   #$32
   ora   #$c0
   beq   .CPUError32Z
   bpl   .CPUError32N
   bvs   .CPUError32V
   bcs   .CPUError32C

   cmp   #$C8
   bne   .CPUError32R

.CPUOk32
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest33

.CPUError32Z
   jsr   WriteErrorZ
   jmp   .CPUTest33
.CPUError32N
   jsr   WriteErrorN
   jmp   .CPUTest33
.CPUError32V
   jsr   WriteErrorV
   jmp   .CPUTest33
.CPUError32C
   jsr   WriteErrorC
   jmp   .CPUTest33
.CPUError32R
   jsr   WriteErrorR
;-----------------------------
.CPUTest33			;BIT
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$69
   sta   $03

.CPULoop33
   sec
   lda   #$5E
   sta   $05
   lda   #$97
   bit   $05
   beq   .CPUError33Z
   bmi   .CPUError33N
   bvc   .CPUError33V
   bcc   .CPUError33C

   lda   #$05
   sta   $05
   lda   #$F0
   bit   $05
   bne   .CPUError33Z
   bmi   .CPUError33N
   bvs   .CPUError33V
   bcc   .CPUError33C

   clc
   lda   #$C5
   sta   $05
   lda   #$3A
   bit   $05
   bne   .CPUError33Z
   bpl   .CPUError33N
   bvc   .CPUError33V
   bcs   .CPUError33C

   lda   #$99
   sta   $05
   lda   #$6D
   bit   $05
   beq   .CPUError33Z
   bpl   .CPUError33N
   bvs   .CPUError33V
   bcs   .CPUError33C

.CPUOk33
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest34

.CPUError33Z
   jsr   WriteErrorZ
   jmp   .CPUTest34
.CPUError33N
   jsr   WriteErrorN
   jmp   .CPUTest34
.CPUError33V
   jsr   WriteErrorV
   jmp   .CPUTest34
.CPUError33C
   jsr   WriteErrorC
;-----------------------------
.CPUTest34
CPU2_End
   ldx   #$23
   ldy   #$28
   jsr   PrintScore
   jsr   ScrOnWaitKey

;----------------------------------------------------------------
CPUTest4			;Test Address CPU operations

.WaitVBl
   lda $2002
   bpl .WaitVBl     ;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx $2001      ;Screen display off, amongst other things


   jsr   WipePPU

   lda   #<.Mess0A0
   sta   $00
   lda   #>.Mess0A0
   sta   $01
   lda   #$20
   sta   $02
   lda   #$40
   sta   $03
   jsr   NESWriter0

   lda   #%00011110        ;Background on, sprites on, show leftmost 8 pixels, colour
   sta   $2001
;-----------------------------
.CPUTest40			;Adr Imediate
   lda   #$20		;Where the msg prints.
   sta   $02
   lda   #$D2
   sta   $03



   lda   #$5E
   beq   .CPUError40	;Stupid isn't it?  ;-)
   bmi   .CPUError40
   cmp   #$23			;How do you do a test for the imediate addressing?
   beq   .CPUError40
   cmp   #$5E
   bne   .CPUError40
   lda   #$82
   beq   .CPUError40
   bpl   .CPUError40

.CPUOk40
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest41

.CPUError40
   jsr   WriteError
;-----------------------------
.CPUTest41			;Adr Zero page
   lda   #$20		;Where the msg prints.
   sta   $02
   lda   #$F2
   sta   $03



   lda   #0
   sta   $05
   lda   #$93
   sta   $06
   lda   #$45
   sta   $07
   lda   $05
   bne   .CPUError41	;Stupid isn't it?  ;-)
   bmi   .CPUError41
   lda   $06			;How do you do a test for the Zero page addressing?
   beq   .CPUError41
   bpl   .CPUError41
   lda   $07
   beq   .CPUError41
   bmi   .CPUError41

.CPUOk41
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest42

.CPUError41
   jsr   WriteError
;-----------------------------
.CPUTest42			;Adr Zero page,X
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$12
   sta   $03


   lda   #0
   sta   $0106
   sta   $05
   lda   #$93
   sta   $06
   lda   #$45
   sta   $07
   ldx   #$04

   lda   $01,x
   bne   .CPUError42
   bmi   .CPUError42
   lda   $02,x
   cmp   #$93
   bne   .CPUError42
   ldx   #$08
   lda   $FE,x
   cmp   #$93
   bne   .CPUError42W
   ldx   #$FE
   lda   $08,x
   beq   .CPUError42W
   bpl   .CPUError42W
   cmp   $06
   bne   .CPUError42W
   cmp   $0106
   beq   .CPUError42W
   ldx   #0
   lda   $07,x
   beq   .CPUError42
   bmi   .CPUError42
   cmp   #$45
   bne   .CPUError42


.CPUOk42
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest43

.CPUError42W
   jsr   WriteErrorW
   jmp   .CPUTest43
.CPUError42
   jsr   WriteError
;-----------------------------
.CPUTest43			;Adr Absolute
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$32
   sta   $03



   lda   #$5E
   sta   $0200
   lda   $FEFE
   cmp   #$AA
   bne   .CPUError43
   lda   $0200
   cmp   #$5E
   bne   .CPUError43
   lda   $FEFF
   cmp   #$55
   bne   .CPUError43
   lda   $FE00
   cmp   #$FF
   bne   .CPUError43


.CPUOk43
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest44

.CPUError43
   jsr   WriteError
;-----------------------------
.CPUTest44			;Adr Absolute,X
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$52
   sta   $03



   lda   #$11
   sta   $05
   lda   #$5E
   sta   $0219
   ldx   #$19
   lda   $0200,x
   cmp   #$5E
   bne   .CPUError44
   lda   $FEE6,x
   cmp   #$55
   bne   .CPUError44
   lda   $FEE7,x
   cmp   #$22
   bne   .CPUError44W
   ldx   #$25
   lda   $FFe0,x
   cmp   #$11
   bne   .CPUError44W
   ldx   #$D9
   lda   $FE25,x
   cmp   #$AA
   bne   .CPUError44


.CPUOk44
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest45
.CPUError44W
   jsr   WriteErrorW
   jmp   .CPUTest45
.CPUError44
   jsr   WriteError
;-----------------------------
.CPUTest45			;Adr Absolute,Y
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$72
   sta   $03



   lda   #$11
   sta   $05
   lda   #$5E
   sta   $0219
   ldy   #$19
   lda   $0200,y
   cmp   #$5E
   bne   .CPUError45
   lda   $FEE6,y
   cmp   #$55
   bne   .CPUError45
   lda   $FEE7,y
   cmp   #$22
   bne   .CPUError45W
   ldy   #$26
   lda   $FFDF,y
   cmp   #$11
   bne   .CPUError45W
   ldy   #$DA
   lda   $FE24,y
   cmp   #$AA
   bne   .CPUError45

.CPUOk45
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest46
.CPUError45W
   jsr   WriteErrorW
   jmp   .CPUTest46
.CPUError45
   jsr   WriteError
;-----------------------------
.CPUTest46			;Adr (Indirect,X)
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$92
   sta   $03



   lda   #<Ind_Values1
   sta   $06
   lda   #>Ind_Values1
   sta   $07
   lda   #<Ind_Values2
   sta   $08
   lda   #>Ind_Values2
   sta   $09
   ldx   #0
   lda   ($06,x)
   cmp   #$FF
   bne   .CPUError46
   ldx   #1
   cmp   ($05,x)
   bne   .CPUError46
   ldx   #4
   lda   ($04,x)
   cmp   #$AA
   bne   .CPUError46
   ldx   #$27
   lda   ($e1,x)
   cmp   #$AA
   bne   .CPUError46W


.CPUOk46
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest47
.CPUError46W
   jsr   WriteErrorW
   jmp   .CPUTest47
.CPUError46
   jsr   WriteError
;-----------------------------
.CPUTest47			;Adr (Indirect),Y
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$B2
   sta   $03



   lda   #<Ind_Values1
   sta   $06
   lda   #>Ind_Values1
   sta   $07
   lda   #<Ind_Values2
   sta   $08
   lda   #>Ind_Values2
   sta   $09
   ldy   #0
   lda   ($06),y
   cmp   #$FF
   bne   .CPUError47
   ldy   #3
   lda   ($06),y
   cmp   #$BB
   bne   .CPUError47
   ldy   #$FE
   lda   ($06),y
   cmp   #$AA
   bne   .CPUError47
   ldy   #2
   lda   ($08),y
   cmp   #$22
   bne   .CPUError47
   ldy   #1
   lda   ($08),y
   cmp   #$55
   bne   .CPUError47W


.CPUOk47
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest48
.CPUError47W
   jsr   WriteErrorW
   jmp   .CPUTest48
.CPUError47
   jsr   WriteError
;-----------------------------
.CPUTest48			;JMP
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$D2
   sta   $03

   jmp   .CPUOk48		;What!?!
   lda   #0
   beq   .CPUError48


.CPUOk48
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest49

.CPUError48
   jsr   WriteError
;-----------------------------
.CPUTest49			;JMP()
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$F2
   sta   $03

   lda   #<JmpStep2
   sta   $200
   lda   #>JmpStep2
   sta   $201
   jmp   ($200)
   lda   #0
   beq   .CPUError49
JmpStep2
   lda   #>JmpTstOk
   sta   $200
   lda   #<JmpTstOk
   sta   $2FF
   lda   #>JmpTstFail
   sta   $300
   jmp   ($2FF)


CPUOk49
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest50
CPUError49W
   jsr   WriteErrorW
   jmp   .CPUTest50
.CPUError49
   jsr   WriteError
;-----------------------------
.CPUTest50			;JSR
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$12
   sta   $03
   clv

   jsr   .JsrTst1
.JsrDummy
   bvc   .CPUError51
   nop
.JsrTst1
   pla
   tay
   pla
   cmp   #>.JsrDummy
   bne   .CPUError51
   tya
   cmp   #<.JsrDummy-1
   bne   .CPUError51

.CPUOk50
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest51
.CPUError50
   jsr   WriteError
;-----------------------------
.CPUTest51			;RTS
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$32
   sta   $03

   lda   #>RtsTst1
   pha
   lda   #<RtsTst1
   pha
   lda   #1
   rts
   nop
   nop
;-------------------
RtsTst1
   dc.b   $AD		;LDA $XXXX
   bne   .CPUOk51
   jmp   .CPUError51


.CPUOk51
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest52

.CPUError51
   jsr   WriteError
;-----------------------------
.CPUTest52			;RTI
   jmp   .CPUTest53						;To skip the RTI test all together.
   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$52
   sta   $03

   lda   #>RtiTst1
   pha
   lda   #<RtiTst1
   pha
   lda   #1
   pha
   rti
   nop
   nop
;-------------------
RtiTst1
   dc.b   $AD		;LDA $XXXX
   bne   .CPUError52


.CPUOk52
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest53

.CPUError52
   jsr   WriteError
;-----------------------------
.CPUTest53

;-----------------------------
CPU4End
   ldx   #$23
   ldy   #$28
   jsr   PrintScore
   jsr   ScrOnWaitKey

;----------------------------------------------------------------
CPUTest6			;Test Misc CPU operations

.WaitVBl1
   lda $2002
   bpl .WaitVBl1     ;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx $2001      ;Screen display off, amongst other things


   jsr   WipePPU

   lda   #<.Mess0B0
   sta   $00
   lda   #>.Mess0B0
   sta   $01
   lda   #$20
   sta   $02
   lda   #$40
   sta   $03
   jsr   NESWriter0

   lda   #%00011110        ;Background on, sprites on, show leftmost 8 pixels, colour
   sta   $2001
;-----------------------------
.CPUTest60			;Test SR
   lda   #$20		;Where the msg prints.
   sta   $02
   lda   #$D1
   sta   $03

   lda   #$FF
   pha
   plp
   php
   pla
   cmp   #$FF
   bne   .CPUError60

   lda   #$00
   pha
   plp
   php				; This actually sets the B flag.
   sei
   pla
;   tay
   cmp   #$30
;   and   #$10
   bne   .CPUError60
;   tya
;   cmp   #$20
;   bne   .CPUError60

.CPUOk60
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest61
.CPUError60B
   jsr   WriteErrorB
   jmp   .CPUTest61
.CPUError60
   jsr   WriteError
;-----------------------------------------------------------
.CPUTest61			;BRK flags
   lda   #$20		;Where the msg prints.
   sta   $02
   lda   #$F1
   sta   $03

   lda   #$00
   sta   $07
   pha				;Push A
   plp				;Pull SR - Clear SVDIZC.
   brk				;The BRK!
;--------------
   nop				;The BRK's return address is +1.
   php				;Push SR - B should be set, I should be clear.
   sei
   pla				;Pull A
   tay
   and   #$04
   bne   .CPUError61I
   tya
   and   #$10
   beq   .CPUError61B
   lda   $07		; Load SR from inside Interrupt
   and   #$10
   beq   .CPUError61B
   lda   $07		; Load SR from inside Interrupt
   and   #$04
   beq   .CPUError61I



   lda   #$00
   sta   $07
   lda   #$04
   pha				;Push A
   plp				;Pull SR - Clear SVBDZC, set I.
   brk				;The BRK!
;--------------
   nop				;The BRK's return address is +1.
   php				;Push SR - B & I should be set.
   pla				;Pull A
   tay
   and   #$04
   beq   .CPUError61I
   tya
   and   #$10
   beq   .CPUError61B
   lda   $07		; Load SR from inside Interrupt
   and   #$10
   beq   .CPUError61B
   lda   $07		; Load SR from inside Interrupt
   and   #$04
   beq   .CPUError61I


.CPUOk61
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest62

.CPUError61I
   jsr   WriteErrorI
   jmp   .CPUTest62
.CPUError61B
   jsr   WriteErrorB
   jmp   .CPUTest62
.CPUError61
   jsr   WriteError
;-----------------------------------------------------------
.CPUTest62			;BRK return address.
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$11
   sta   $03

   brk				;The BRK!
;--------------
   dc.b   $AD		;LDA $XXXX
   bne   .CPUOk62
   jmp   .CPUError62


.CPUOk62
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest63

.CPUError62
   jsr   WriteError
;-----------------------------------------------------------
.CPUTest63			;Stack pointer test
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$31
   sta   $03

   lda   #$55
   tsx
   pha
   cmp   $100,x
   bne   .CPUError63
   pla
   lda   #$AA
   tsx
   pha
   cmp   $100,x
   bne   .CPUError63
   lda   #$AA
   sta   $0100
   lda   #$55
   sta   $0200
   ldx   #$FE
   txs
   pla
   pla
   cmp   #$AA
   bne   .CPUError63W


.CPUOk63
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest64
.CPUError63W
   jsr   WriteErrorW
   jmp   .CPUTest64
.CPUError63
   jsr   WriteError
;-----------------------------------------------------------
.CPUTest64			;RAM test
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$51
   sta   $03

   ldx   #$06			;To write 7 x $100 bytes, from $0100 to $07FF.
   ldy   #$07			;To write 7 x $100 bytes, from $0100 to $07FF.
   sty   $05			;Store count value in $05
   ldy   #$00
   sty   $04
   lda   #$55
.Clear2
   sta   ($04),y		;Clear $100 bytes
   dey
   bne   .Clear2
   dec   $05			;Decrement "banks" left counter
   dex
   bne   .Clear2		;Do next if > 0

   ldx   #$06			;To test 7 x $100 bytes, from $0100 to $07FF.
   ldy   #$07			;To test 7 x $100 bytes, from $0100 to $07FF.
   sty   $05			;Store count value in $05
   ldy   #$00
   sty   $04
   lda   #$55
.Clear3
   cmp   ($04),y		;Clear $100 bytes
   bne   .CPUError64
   dey
   bne   .Clear3
   dec   $05			;Decrement "banks" left counter
   dex
   bne   .Clear3		;Do next if > 0


   ldx   #$06			;To write 7 x $100 bytes, from $0100 to $07FF.
   ldy   #$07			;To write 7 x $100 bytes, from $0100 to $07FF.
   sty   $05			;Store count value in $05
   ldy   #$00
   sty   $04
   lda   #$AA
.Clear4
   sta   ($04),y		;Clear $100 bytes
   dey
   bne   .Clear4
   dec   $05			;Decrement "banks" left counter
   dex
   bne   .Clear4		;Do next if > 0

   ldx   #$06			;To test 7 x $100 bytes, from $0100 to $07FF.
   ldy   #$07			;To test 7 x $100 bytes, from $0100 to $07FF.
   sty   $05			;Store count value in $05
   ldy   #$00
   sty   $04
   lda   #$AA
.Clear5
   cmp   ($04),y		;Clear $100 bytes
   bne   .CPUError64
   dey
   bne   .Clear5
   dec   $05			;Decrement "banks" left counter
   dex
   bne   .Clear5		;Do next if > 0


.CPUOk64
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest65

.CPUError64
   jsr   WriteError
;-----------------------------------------------------------
.CPUTest65			;RAM mirroring test
   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$71
   sta   $03

   lda   #$55
   sta   $0200
   lda   #$AA
   sta   $0201
   lda   #$00
   sta   $0202
   lda   #$FF
   sta   $0203

   lda   $0200
   cmp   #$55
   bne   .CPUError65
   lda   $0A00
   cmp   #$55
   bne   .CPUError65
   lda   $0A03
   cmp   #$FF
   bne   .CPUError65
   lda   $1201
   cmp   #$AA
   bne   .CPUError65
   lda   $1A02
   cmp   #$00
   bne   .CPUError65
   lda   $1A03
   cmp   #$FF
   bne   .CPUError65

   lda   #$00
   sta   $1200
   lda   $0200
   bne   .CPUError65

.CPUOk65
   jsr   WriteOk
   inc   SCORE
   jmp   .CPUTest66

.CPUError65
   jsr   WriteError
;-----------------------------------------------------------
.CPUTest66

CPU6End
   ldx   #$23
   ldy   #$28
   jsr   PrintScore
   jsr   ScrOnWaitKey


.TestNoKey2
   lda   CONTROLLER1
   and   #%11010000
   bne   .TestNoKey2

   jmp   Reset_Routine
;----------------------------------------------------------------
;****************************************************************
;----------------------------------------------------------------
pAPUTest

.WaitV03
   lda $2002
   bpl .WaitV03     ;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx PPU2000
   stx $2001      ;Screen display off, amongst other things


   jsr   WipePPU

   lda   #<.Mess040
   sta   $00
   lda   #>.Mess040
   sta   $01
   lda   #$20
   sta   $02
   lda   #$40
   sta   $03
   jsr   NESWriter0

;-----------------------------
APUEnd
   ldx   #$23
   ldy   #$28
   jsr   PrintScore
   jsr   ScrOnWaitKey

.TestNoKey3
   lda   CONTROLLER1
   and   #%11010000
   bne   .TestNoKey3

   jmp   Reset_Routine

;----------------------------------------------------------------
;****************************************************************
;----------------------------------------------------------------
PPUTest

.WaitV02
   lda $2002
   bpl .WaitV02     ;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx PPU2000
   stx $2001      ;Screen display off, amongst other things


   jsr   WipePPU

   lda   #<.Mess000
   sta   $00
   lda   #>.Mess000
   sta   $01
   lda   #$21
   sta   $02
   lda   #$60
   sta   $03
   jsr   NESWriter0

   lda   #$00
   sta   SCORE		;Clear score.
;----------------------------------
.PPUTest0
   lda   #$20
   sta   $2006
   lda   #$21
   sta   $2006

   ldx   #$30
.PPUWriteLoop0
   stx   $2007
   inx
   cpx   #$3a
   bne   .PPUWriteLoop0


   lda   #$20
   sta   $2006
   lda   #$21
   sta   $2006

   ldx   #$30
   stx   $04
   ldy   #10
   lda   $2007

   lda   #$21		;Where the msg prints.
   sta   $02
   lda   #$FB
   sta   $03
.PPUReadLoop0
   lda   $2007
   cmp   $04
   bne   .PPUError0
   inc   $04
   dey
   bne   .PPUReadLoop0


.PPUOk0
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest1

.PPUError0
   jsr   WriteError
;-----------------------------
.PPUTest1
   lda   #$20
   sta   $2006
   lda   #$41
   sta   $2006

   ldx   #$30
.PPUWriteLoop1
   stx   $2007
   inx
   cpx   #$35
   bne   .PPUWriteLoop1
   lda   $2007
   inx
.PPUWriteLoop1_1
   stx   $2007
   inx
   cpx   #$3a
   bne   .PPUWriteLoop1_1



   lda   #$20
   sta   $2006
   lda   #$46
   sta   $2006

   lda   #$22		; Where the msg prints.
   sta   $02
   lda   #$1B
   sta   $03

   ldx   #$36
   stx   $04
   ldy   #04
   lda   $2007
   lda   $2007
   cmp   #0
   bne   .PPUError1
.PPUReadLoop1
   lda   $2007
   cmp   $04
   bne   .PPUError1
   inc   $04
   dey
   bne   .PPUReadLoop1



.PPUOk1
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest2

.PPUError1
   jsr   WriteError

;-----------------------------
.PPUTest2
   lda   #$20
   sta   $2006
   lda   #$60
   sta   $2006
   lda   $2007

   ldx   #$30
.PPUWriteLoop2
   stx   $2007
   inx
   cpx   #$3a
   bne   .PPUWriteLoop2


   lda   #$20
   sta   $2006
   lda   #$61
   sta   $2006

   ldx   #$30
   stx   $04
   ldy   #9
   lda   $2007

   lda   #$22		; Where the msg prints.
   sta   $02
   lda   #$3b
   sta   $03
.PPUReadLoop2
   lda   $2007
   cmp   $04
   bne   .PPUError2
   inc   $04
   dey
   bne   .PPUReadLoop2


.PPUOk2
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest3

.PPUError2
   jsr   WriteError
;-----------------------------
.PPUTest3
   lda   #$20
   sta   $2006
   lda   #$81
   sta   $2006

   ldx   #$30
.PPUWriteLoop3
   stx   $2007
   inx
   cpx   #$39
   bne   .PPUWriteLoop3

   ldx   $2007
   lda   #$20
   sta   $2006
   lda   #$8a
   sta   $2006
   stx   $2007

   lda   #$20
   sta   $2006
   lda   #$81
   sta   $2006

   ldx   #$30
   stx   $04
   ldy   #10
   lda   $2007

   lda   #$22		; Where the msg prints.
   sta   $02
   lda   #$5B
   sta   $03
.PPUReadLoop3
   lda   $2007
   cmp   $04
   bne   .PPUError3
   inc   $04
   dey
   bne   .PPUReadLoop3


.PPUOk3
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest4

.PPUError3
   jsr   WriteError
;-----------------------------
.PPUTest4
   lda   #$20
   sta   $2006
   lda   #$A1
   sta   $2006

   ldx   #$30
.PPUWriteLoop4
   stx   $2007
   inx
   cpx   #$35
   bne   .Not5
   lda   #$26		; 1st Adr byte.
   sta   $2006
.Not5
   cpx   #$3A
   bne   .PPUWriteLoop4

   lda   #$01		; 2nd adr byte.
   sta   $2006

   lda   #$20
   sta   $2006
   lda   #$A1
   sta   $2006

   ldx   #$30
   stx   $04
   ldy   #10
   lda   $2007

   lda   #$22		; Where the msg prints.
   sta   $02
   lda   #$7B
   sta   $03
.PPUReadLoop4
   lda   $2007
   cmp   $04
   bne   .PPUError4
   inc   $04
   dey
   bne   .PPUReadLoop4


.PPUOk4
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest5

.PPUError4
   jsr   WriteError
;----------------------------------
.PPUTest5
   lda   #$30
   sta   $2006
   lda   #$C1
   sta   $2006

   ldx   #$30
.PPUWriteLoop5
   stx   $2007
   inx
   cpx   #$3a
   bne   .PPUWriteLoop5


   lda   #$20
   sta   $2006
   lda   #$C1
   sta   $2006

   ldx   #$30
   stx   $04
   ldy   #10
   lda   $2007

   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$9B
   sta   $03
.PPUReadLoop5
   lda   $2007
   cmp   $04
   bne   .PPUError5
   inc   $04
   dey
   bne   .PPUReadLoop5


.PPUOk5
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest6

.PPUError5
   jsr   WriteError
;----------------------------------
.PPUTest6
   lda   #$3E		;Where to print test pattern.
   sta   $2006
   lda   #$E1
   sta   $2006

   lda   #$04		;Set 32 byte increment for PPU.
   sta   $2000

   ldx   #$88
.PPUIncLoop6
   lda   $2007
   lda   $2007
   dex
   bne   .PPUIncLoop6

   lda   #$00		;Set 1 byte increment for PPU.
   sta   $2000


   ldx   #$30
.PPUWriteLoop6
   stx   $2007
   inx
   cpx   #$3a
   bne   .PPUWriteLoop6

   lda   #$20		;Where to read pattern.
   sta   $2006
   lda   #$E1
   sta   $2006

   ldx   #$30
   stx   $04
   ldy   #10
   lda   $2007

   lda   #$22		;Where the msg prints.
   sta   $02
   lda   #$BB
   sta   $03
.PPUReadLoop6
   lda   $2007
   cmp   $04
   bne   .PPUError6
   inc   $04
   dey
   bne   .PPUReadLoop6


.PPUOk6
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest7

.PPUError6
   jsr   WriteError
;-----------------------------
.PPUTest7
   lda   #$24
   sta   $2006
   lda   #$05
   sta   $2006

   ldx   #$33
.PPUWriteLoop7
   stx   $2007
   inx
   cpx   #$43
   bne   .PPUWriteLoop7

   lda   #$25
   sta   $2006
   lda   #$1D
   sta   $2006

   ldx   #$01
.PPUWriteLoop7b
   stx   $2007
   inx
   cpx   #$11
   bne   .PPUWriteLoop7b

   lda   #$24
   sta   $2005
   lda   #$05
   sta   $2006

   ldx   #$33
   stx   $04
   ldy   #7

   lda   #$22		; Where the msg prints.
   sta   $02
   lda   #$DB
   sta   $03

   lda   $2007
.PPUReadLoop7
   lda   $2007
   cmp   $04
   bne   .PPU2Latches7
   inc   $04
   dey
   bne   .PPUReadLoop7

.PPUDrpcjr7
   lda   #<DrpcjrMess
   sta   $00
   lda   #>DrpcjrMess
   sta   $01
   jsr   NESWriter0
   inc   SCORE
   jmp   PPU1_End

.PPU2Latches7
   lda   #$00
   sta   $2005
   lda   #$00
   sta   $2006
   lda   #$24
   sta   $2006
   lda   #$05
   sta   $2006
   lda   $2007

.PPUReadLoop7b
   lda   $2007
   cmp   $04
   bne   .PPUError7
   inc   $04
   dey
   bne   .PPUReadLoop7b
.PPUNES7
   lda   #<NesMess
   sta   $00
   lda   #>NesMess
   sta   $01
   jsr   NESWriter0
   inc   SCORE
   jmp   .PPUTest8

.PPUError7
   jsr   WriteError
;-----------------------------
.PPUTest8
   lda   #$3F
   sta   $2006
   lda   #$05
   sta   $2006

   ldx   #$33
.PPUWriteLoop8
   stx   $2007
   inx
   cpx   #$3A
   bne   .PPUWriteLoop8

   lda   #$3F
   sta   $2006
   lda   #$25
   sta   $2006

   ldx   #$33
   stx   $04
   ldy   #7

   lda   #$22		; Where the msg prints.
   sta   $02
   lda   #$FB
   sta   $03
.PPUReadLoop8
   lda   $2007
   cmp   $04
   bne   .PPUPalNES8
   inc   $04
   dey
   bne   .PPUReadLoop8


.PPUDrpcjr8
   lda   #<DrpcjrMess
   sta   $00
   lda   #>DrpcjrMess
   sta   $01
   jsr   NESWriter0
   inc   SCORE
   jmp   PPU1_End

.PPUPalNES8
   lda   $2007
   cmp   $04
   bne   .PPUError8
   inc   $04
   dey
   bne   .PPUPalNES8
.PPUNES8
   lda   #<NesMess
   sta   $00
   lda   #>NesMess
   sta   $01
   jsr   NESWriter0
   inc   SCORE
   jmp   PPU1_End

.PPUError8
   jsr   WriteError
;----------------------------------------------------------------
PPU1_End
   ldx   #$23
   ldy   #$28
   jsr   PrintScore
   jsr   ScrOnWaitKey
;----------------------------------------------------------------
PPUTest_2			; ! Test Sprites !

.WaitV06
   lda $2002
   bpl .WaitV06     ;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx $2001      ;Screen display off, amongst other things


   jsr   WipePPU

   lda   #<.Mess010
   sta   $00
   lda   #>.Mess010
   sta   $01
   lda   #$20
   sta   $02
   lda   #$40
   sta   $03
   jsr   NESWriter0
;-----------------------------
.PPUTest20			; ! Test Sprite 0 collision detection !
   lda   #$FF			; What is filled in the SPRRAM
   jsr   ClearSPRRAM

   lda   #$20		; Where the msg prints.
   sta   $02
   lda   #$D4
   sta   $03

   lda   #200			;New y pos for spr0
   sta   $700
   lda   #$07
   sta   $4014			;Copy $700 to Spr-RAM

   lda   #$18
   sta   $2001		; Sprite & Display On

   ldx   #0
.WaitV08
   lda $2002
   bpl .WaitV08     ;Wait for vertical blanking interval
   stx   $2005
   stx   $2005
   stx   $2006
   stx   $2006
.WaitV09
   lda $2002
   bmi .WaitV09     ; Stupid fix for bad emus.

.PPUTestLoop20
   lda   $2002
   asl
   bmi   .PPUError20
   bcc   .PPUTestLoop20     ; Loop for one whole frame

   lda   #80			;New y pos for spr0
   sta   $700
   lda   #$07
   sta   $4014			;Copy $700 to Spr-RAM

   stx   $2005
   stx   $2005
   stx   $2006
   stx   $2006
.WaitV0A
   lda $2002
   bmi .WaitV0A     ; Stupid fix for bad emus.

.PPUTestLoop20_1
   lda   $2002
   asl
   bmi   .PPUOk20
   bcc   .PPUTestLoop20_1     ; Loop for one whole frame
   jmp   .PPUError20

   lda   #$08
   sta   $2001		; Sprite Off, Display On
   stx   $2005
   stx   $2005
   stx   $2006
   stx   $2006
.WaitV0B
   lda $2002
   bmi .WaitV0B     ; Stupid fix for bad emus.

.PPUTestLoop20_2
   lda   $2002
   asl
   bmi   .PPUError20
   bcc   .PPUTestLoop20_2     ; Loop for one whole frame


.PPUOk20
   stx   $2001		; Sprite & Display Off
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest21

.PPUError20
   stx   $2001		; Sprite & Display Off
   jsr   WriteError
;-----------------------------
.PPUTest21			; Test Sprite Overflow ;-)
   lda   #$20		; Where the msg prints.
   sta   $02
   lda   #$F4
   sta   $03

   ldx   #$00
   lda   #$18
   sta   $2001		; Sprite & Display On

.WaitV0C
   lda $2002
   bpl .WaitV0C     ;Wait for vertical blanking interval

.WaitV0D
   lda $2002
   bmi .WaitV0D     ; Stupid fix for bad emus.

.PPUTestLoop21
   lda   $2002
   tay
   and   #$20
   bne   .PPUError21
   tya
   bpl   .PPUTestLoop21     ; Loop for one whole frame

   lda   #80			;New y pos for spr0
   sta   $704
   sta   $708
   sta   $70C
   sta   $710
   sta   $714
   sta   $718
   sta   $71C
   sta   $720

   lda   #$07
   sta   $4014			;Copy $700 to Spr-RAM

.WaitV0E
   lda $2002
   bpl .WaitV0E     ;Wait for vertical blanking interval

.WaitV0F
   lda $2002
   bmi .WaitV0F     ; Stupid fix for bad emus.

.PPUTestLoop21_1
   lda   $2002
   tay
   and   #$20
   bne   .PPUOk21
   tya
   bpl   .PPUTestLoop21_1     ; Loop for one whole frame
   jmp   .PPUError21

.PPUOk21
   stx   $2001		; Sprite & Display Off
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest22

.PPUError21
   stx   $2001		; Sprite & Display Off
   jsr   WriteError
;-----------------------------
.PPUTest22
   lda   #$21		; Where the msg prints.
   sta   $02
   lda   #$14
   sta   $03

   ldx   #$00
   stx   $2003
.PPUWriteLoop22
   stx   $2004
   inx
   bne   .PPUWriteLoop22

   stx   $04
   stx   $2003
.PPUReadLoop22
   lda   $2004
   cmp   $04
   bne   .PPUError22
   inc   $04
   inx
   bne   .PPUReadLoop22


.PPUOk22
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest23

.PPUError22
   jsr   WriteError
;-----------------------------
.PPUTest23
   lda   #$21		; Where the msg prints.
   sta   $02
   lda   #$34
   sta   $03

   ldx   #$00
   stx   $2003
   txa
   clc
.PPUWriteLoop23
   sta   $0500,X
   adc   #$01
   inx
   bne   .PPUWriteLoop23
   lda   #$05
   sta   $4014

   stx   $04
   stx   $2003
.PPUReadLoop23
   lda   $2004
   cmp   $04
   bne   .PPUError23
   inc   $04
   inx
   bne   .PPUReadLoop23


.PPUOk23
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest24

.PPUError23
   jsr   WriteError
;-----------------------------
.PPUTest24
   lda   #$21		; Where the msg prints.
   sta   $02
   lda   #$54
   sta   $03

   lda   #$24
   sta   $2003
   ldx   #$00
   txa
   clc
.PPUWriteLoop24
   sta   $0500,X
   adc   #$01
   inx
   bne   .PPUWriteLoop24
   lda   #$05
   sta   $4014

   stx   $04
   lda   #$24
   sta   $2003
.PPUReadLoop24
   lda   $2004
   cmp   $04
   bne   .PPUError24
   inc   $04
   inx
   bne   .PPUReadLoop24


.PPUOk24
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest25

.PPUError24
   jsr   WriteError
;-----------------------------
.PPUTest25
;----------------------------------------------------------------
PPU2_End
   ldx   #$23
   ldy   #$28
   jsr   PrintScore
   jsr   ScrOnWaitKey
;----------------------------------------------------------------
PPUTest_3			; VBl clear after read.
;-----------------------------
.WaitV07
   lda $2002
   bpl .WaitV07     ;Wait for vertical blanking interval
   ldx #$00
   stx $2000
   stx $2001      ;Screen display off, amongst other things


   jsr   WipePPU

   lda   #<.Mess020
   sta   $00
   lda   #>.Mess020
   sta   $01
   lda   #$20
   sta   $02
   lda   #$40
   sta   $03
   jsr   NESWriter0
;-----------------------------
.PPUTest14
   lda   #$08
   sta   $2001		; Display On

   lda   #$20		; Where the msg prints.
   sta   $02
   lda   #$DA
   sta   $03

.PPUTestLoop14
   lda   $2002
   bpl   .PPUTestLoop14

   lda   #$00
   sta   $2001		; Display Off
   lda   $2002
   bmi   .PPUError14


.PPUOk14
   jsr   WriteOk
   inc   SCORE
   jmp   .PPUTest15

.PPUError14
   jsr   WriteError
;-----------------------------
.PPUTest15

PPU3_End
   ldx   #$23
   ldy   #$28
   jsr   PrintScore
   jsr   ScrOnWaitKey

.TestNoKey5
   lda   CONTROLLER1
   and   #%11010000
   bne   .TestNoKey5

;----------------------------------------------------------------
   jmp   Reset_Routine
;----------------------------------------------------------------









;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; !!! Subroutines !!!
;----------------------------------------------------------------
PrintScore SUBROUTINE	; need X & Y for pos.
   stx   $02	; Where the msg prints.
   sty   $03
   lda   #$20
   sta   SCORE_T
   lda   SCORE
   cmp   #10
   bmi   .singleScore
   lda   #$30
   sta   SCORE_T
   lda   SCORE
.countMore
   inc   SCORE_T
   sec
   sbc   #10
   cmp   #10
   bpl   .countMore

.singleScore
   clc
   adc   #$30
   sta   SCORE_T+1
   lda   #<SCORE_T
   sta   $00
   lda   #>SCORE_T
   sta   $01
   jmp   NESWriterS

;----------------------------------------------------------------

TestEnd
;Enable vblank interrupts, etc.
   lda   #%10001000
   sta   $2000
   lda   #%00011110        ;Screen on, sprites on, show leftmost 8 pixels, colour
   sta   $2001



.Title2Loop
   lda   VBPASS
   beq   .Title2Loop        ;Wait for VBlank to pass...


.alltid
   jmp   .alltid


;*****************************************************
;-----------------------------------------------------
;*****************************************************

ScrOnWaitKey SUBROUTINE
;Enable vblank interrupts, etc.
   lda   #%10001000
   sta   $2000
   lda   #%00011110        ;Screen on, sprites on, show leftmost 8 pixels, colour
   sta   $2001

.TestNoKey
   lda   CONTROLLER1
   and   #%11010000
   bne   .TestNoKey
.WaitKey0
   lda   CONTROLLER1
   and   #%11010000
   beq   .WaitKey0
   rts

;*****************************************************
;-----------------------------------------------------
;*****************************************************

WipePPU SUBROUTINE
   lda   #$20
   sta   $2006
   lda   #$00
   sta   $2006

   ldx   #$00
   ldy   #$10
.ClearPPU sta $2007
   dex
   bne   .ClearPPU
   dey
   bne   .ClearPPU

   lda   #$00
   sta   $2003
   tay
.ClearSpr sta   $2004
   dey
   bne   .ClearSpr
   rts

;--------------------------------
ClearSPRRAM SUBROUTINE		; Needs fill value in A

   ldx   #$08
   stx   $2003
.ClearSPRRAM   sta   $0700,X        ;$700 FOR NOW!!!!
   sta   $2004
   inx
   bne   .ClearSPRRAM

   rts
;--------------------------------------------------



PrintFullScreen SUBROUTINE
;--------------------------------------------------
; Needs $00 & $01 for address of picture.
; Needs A for screen number (0-3).
;--------------------------------------------------
   asl
   asl
   adc   #$20        ;Load Name and Attribute Table
   sta   $2006
   lda   #$00
   sta   $2006

   ldy   #$00
   ldx   #$04

.LoadTitle
   lda   ($00),Y  ;Load Title Image
   sta   $2007
   iny
   bne   .LoadTitle
   inc   $01
   dex
   bne   .LoadTitle

   rts

;--------------------------------------------------
WriteOk SUBROUTINE
;--------------------------------------------------
   lda   #<OkMess
   sta   $00
   lda   #>OkMess
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
WriteError SUBROUTINE
;--------------------------------------------------
   lda   #<ErrMess
   sta   $00
   lda   #>ErrMess
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
WriteErrorZ SUBROUTINE
;--------------------------------------------------
   lda   #<ErrMessZ
   sta   $00
   lda   #>ErrMessZ
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
WriteErrorN SUBROUTINE
;--------------------------------------------------
   lda   #<ErrMessN
   sta   $00
   lda   #>ErrMessN
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
WriteErrorV SUBROUTINE
;--------------------------------------------------
   lda   #<ErrMessV
   sta   $00
   lda   #>ErrMessV
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
WriteErrorC SUBROUTINE
;--------------------------------------------------
   lda   #<ErrMessC
   sta   $00
   lda   #>ErrMessC
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
WriteErrorD SUBROUTINE
;--------------------------------------------------
   lda   #<ErrMessD
   sta   $00
   lda   #>ErrMessD
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
WriteErrorI SUBROUTINE
;--------------------------------------------------
   lda   #<ErrMessI
   sta   $00
   lda   #>ErrMessI
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
WriteErrorB SUBROUTINE
;--------------------------------------------------
   lda   #<ErrMessB
   sta   $00
   lda   #>ErrMessB
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
WriteErrorR SUBROUTINE
;--------------------------------------------------
   lda   #<ErrMessR
   sta   $00
   lda   #>ErrMessR
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
WriteErrorW SUBROUTINE
;--------------------------------------------------
   lda   #<ErrMessW
   sta   $00
   lda   #>ErrMessW
   sta   $01
   jmp   NESWriterS

;--------------------------------------------------
NESWriterS SUBROUTINE	;S as in Safe
.WriteLoopS
   lda $2002
   bpl .WriteLoopS		;Wait for vertical blanking interval
   jsr NESWriter0
   lda   #$00
   sta   $2005
   sta   $2005
   rts
;--------------------------------------------------
NESWriter0 SUBROUTINE
;--------------------------------------------------------------------------
; Needs $00 & $01 as address to text, $02 & $03 as PPU destination address.
;--------------------------------------------------------------------------
   lda   $02
   sta   $2006
   lda   $03
   sta   $2006

   ldy   #$00
.WriteChr
   lda   ($00),Y		;Load Title Image
   beq   .WriteEnd
   cmp   #$0A
   beq   .NewRow
   sta   $2007
.WriteLoop
   iny
   bne   .WriteChr
   inc   $01
   bne   .WriteChr
.WriteEnd
   rts

.NewRow
   clc
   lda   $03
   adc   #$20			;One whole row.
   bcc   .NewRow2
   inc   $02
.NewRow2
   and   #$e0
   ldx   $02
   stx   $2006
   sta   $03
   sta   $2006
   jmp   .WriteLoop
;--------------------------------------------------



SetPalette SUBROUTINE
;----------------------------------
; INPUT: A: PALETTE NUMBER
;----------------------------------
   tax
   lda   #<.Palette
   sta   PALETTEPTR
   lda   #>.Palette
   sta   PALETTEPTR+1          ;Point to Palette

   cpx   #$00
   beq   .NoAddPalette
.AddPalette
   lda   PALETTEPTR
   clc
   adc   #$20                 ;Multiply Palette Index by 32
   sta   PALETTEPTR
   lda   PALETTEPTR+1
   adc   #$00
   sta   PALETTEPTR+1
   dex
   bne   .AddPalette

.NoAddPalette
   ldx   #$3F
   stx   $2006
   ldx   #$00
   stx   $2006

   ldy   #$00
   ldx   #$20     ;Set BG & Sprite palettes.
.InitPal lda   (PALETTEPTR),Y
   sta   $2007
   sta   TEMPPAL,Y               ;Store to palette copy
   iny
   dex
   bne   .InitPal
   rts

;*********************************************************
.Palette
   INCLUDE  TanksPal.ASM
;*********************************************************



ToDecimal SUBROUTINE
;--------------------------------------------
; INPUT: A: Number to convert from Hex to Dec
;--------------------------------------------
   sta   $0100
   tya
   pha

   lda   $0100
   ldy   #$FF
   sec
.ToDecLoop1
   iny
   sbc   #$0A
   bcs   .ToDecLoop1
   adc   #$0A
   sta   $0100
   tya
   asl
   asl
   asl
   asl
   ora   $0100
   sta   $0100

   pla
   tay
   lda   $0100
   rts
;--------------------------------------------------



;--------------------------------------------------
Fadeout SUBROUTINE
   lda   #$3F
   sta   $2006
   lda   #$00
   sta   $2006

   ldx   #$00
   stx   $0100
   ldy   #$20
.FadePal
   ldx   $0100
   lda   TEMPPAL,X
   tax
   lda   .FadeIndex,X   ;Get Fade info.
   sta   $2007
   ldx   $0100
   sta   TEMPPAL,X
   inc   $0100
   dey
   bne   .FadePal

   dec   FADESTATUS
   lda   #$00
   sta   $2005
   sta   $2005
   lda   #%10001000
   ora   PPU2000
   sta   PPU2000
   sta   $2000
;   lda   #%00011110
;   sta   $2001

   rts
;--------------------------------------------------
.FadeIndex
   INCLUDE TanksFadePal.ASM
;--------------------------------------------------



;----------------------------------------------------------------------
;              ! This is run every VBlank !
;----------------------------------------------------------------------
NMI_Routine SUBROUTINE
   php
   pha
   txa
   pha
   tya
   pha

   lda   #$01
   sta   VBPASS
   lda   VBODD
   eor   #$01
   sta   VBODD

;---------- READ JOYPAD -----------------------

   ldx   #$01
   stx   $4016
   dex
   stx   $4016
   stx   CONTROLLER1
   stx   CONTROLLER2
   stx   CONTROLLER3
   stx   CONTROLLER4
   stx   CONTROLER1X
   stx   CONTROLER2X
   ldy   #$05				; Write to $0500.
   sty   $05
   ldy   #$00
   sty   $04

.ReadCont1_0
   ldy   #8-1				; Read 3 x 8 bits from $4016
.ReadCont1
   lda   $4016				; Read controller port.
   sta   ($04),y
   ror
   lda   CONTROLLER1,x
   rol
   sta   CONTROLLER1,x
   dey
   bpl   .ReadCont1
   lda   $04
   adc   #8
   sta   $04
   inx
   inx
   cpx   #6
   bne   .ReadCont1_0


;---------------------------------------------
;--- TEST FOR FADEOUT ------------------------
   lda   FADESTATUS
   beq   .NoFade
   lda   VBDELAY
   bne   .DelayFade
   jsr   Fadeout
   lda   #$04
   sta   VBDELAY
   jmp   .NoFade
.DelayFade
   dec   VBDELAY
;---------------------------------------------
.NoFade


   lda   GAMESCREEN
   cmp   #$01
   bne   .NotGameScreenPlanets
   lda   VBWAIT
   beq   .NoPlanetChangeWait
   dec   VBWAIT
.NoPlanetChangeWait
   lda   PLANETCHANGE
   beq   .PlanetChangeEnd
   lda   #$00
   sta   PLANETCHANGE

;   jsr   DisplayPlanetName

.PlanetChangeEnd
   lda   #$00
   sta   $2005
   sta   $2005

   jmp   .VBEnd

.NotGameScreenPlanets
   cmp   #$02
   bne   .NotGameScreenTitle
   lda   #$00
   sta   TITLESCROLL2
   sta   $2005
   sta   $2005
   inc   TITLESCROLL1
   lda   TITLESCROLL1
   cmp   #$02
   bne   .NotTooWavyTitle
   lda   #$00
   sta   TITLESCROLL1

   inc   TITLESCROLL
   lda   TITLESCROLL
   cmp   #$40
   bne   .NotTooWavyTitle
   lda   #$00
   sta   TITLESCROLL
.NotTooWavyTitle
   jmp   .VBEnd
.NotGameScreenTitle


;   lda   #$07
;   sta   $4014             ;Copy $700 to Spr-RAM

;--- SET SCROLLING ----------
   lda   #$40
   lda   #%10001001
.SaveScrolling
   sta   $2000
   sta   PPU2000
   lda   #$00
   sta   $2005
   sta   $2005

.VBEnd

   lda   #$07
   sta   $4014
   pla
   tay
   pla
   tax
   pla
   plp
   rti
;--------------------------------------------------------
;                ! Here ends the VBlank routines !
;--------------------------------------------------------
IRQ_Routine
   pha				;Push A
   php				;Push SR
   pla				;Pull SR to A
   sta   $07		;Save SR in $7
   pla				;Pull A
   rti


   ORG   $FC00,0
JmpTstFail
   jmp   CPUError49W

   ORG   $FD00,0
JmpTstOk
   jmp   CPUOk49
   ORG   $FDFC,0
   jmp   CPUError49W


   ORG   $FE00,0
Ind_Values1
   dc.b  $FF
   dc.b  $88
   dc.b  $44
   dc.b  $BB

   ORG   $FEFE,0
Ind_Values2
   dc.b  $AA
   dc.b  $55
   dc.b  $22
   dc.b  $33

;That's all the code. Now we just need to set the vector table approriately.

   ORG   $FFFA,0
   dc.w  NMI_Routine
   dc.w  Reset_Routine
   dc.w  IRQ_Routine    ;Used to test the BRK instruction.


;The end.
