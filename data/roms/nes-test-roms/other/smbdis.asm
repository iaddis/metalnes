;SMBDIS.ASM - A COMPREHENSIVE SUPER MARIO BROS. DISASSEMBLY
;by doppelganger (doppelheathen@gmail.com)

;This file is provided for your own use as-is.  It will require the character rom data
;and an iNES file header to get it to work.

;There are so many people I have to thank for this, that taking all the credit for
;myself would be an unforgivable act of arrogance. Without their help this would
;probably not be possible.  So I thank all the peeps in the nesdev scene whose insight into
;the 6502 and the NES helped me learn how it works (you guys know who you are, there's no
;way I could have done this without your help), as well as the authors of x816 and SMB
;Utility, and the reverse-engineers who did the original Super Mario Bros. Hacking Project,
;which I compared notes with but did not copy from.  Last but certainly not least, I thank
;Nintendo for creating this game and the NES, without which this disassembly would
;only be theory.

;Assembles with x816.

;-------------------------------------------------------------------------------------
;DEFINES

;NES specific hardware defines

PPU_CTRL_REG1         = $2000
PPU_CTRL_REG2         = $2001
PPU_STATUS            = $2002
PPU_SPR_ADDR          = $2003
PPU_SPR_DATA          = $2004
PPU_SCROLL_REG        = $2005
PPU_ADDRESS           = $2006
PPU_DATA              = $2007

SND_REGISTER          = $4000
SND_SQUARE1_REG       = $4000
SND_SQUARE2_REG       = $4004
SND_TRIANGLE_REG      = $4008
SND_NOISE_REG         = $400c
SND_DELTA_REG         = $4010
SND_MASTERCTRL_REG    = $4015

SPR_DMA               = $4014
JOYPAD_PORT           = $4016
JOYPAD_PORT1          = $4016
JOYPAD_PORT2          = $4017

; GAME SPECIFIC DEFINES

ObjectOffset          = $08

FrameCounter          = $09

SavedJoypadBits       = $06fc
SavedJoypad1Bits      = $06fc
SavedJoypad2Bits      = $06fd
JoypadBitMask         = $074a
JoypadOverride        = $0758

A_B_Buttons           = $0a
PreviousA_B_Buttons   = $0d
Up_Down_Buttons       = $0b
Left_Right_Buttons    = $0c

GameEngineSubroutine  = $0e

Mirror_PPU_CTRL_REG1  = $0778
Mirror_PPU_CTRL_REG2  = $0779

OperMode              = $0770
OperMode_Task         = $0772
ScreenRoutineTask     = $073c

GamePauseStatus       = $0776
GamePauseTimer        = $0777

DemoAction            = $0717
DemoActionTimer       = $0718

TimerControl          = $0747
IntervalTimerControl  = $077f

Timers                = $0780
SelectTimer           = $0780
PlayerAnimTimer       = $0781
JumpSwimTimer         = $0782
RunningTimer          = $0783
BlockBounceTimer      = $0784
SideCollisionTimer    = $0785
JumpspringTimer       = $0786
GameTimerCtrlTimer    = $0787
ClimbSideTimer        = $0789
EnemyFrameTimer       = $078a
FrenzyEnemyTimer      = $078f
BowserFireBreathTimer = $0790
StompTimer            = $0791
AirBubbleTimer        = $0792
ScrollIntervalTimer   = $0795
EnemyIntervalTimer    = $0796
BrickCoinTimer        = $079d
InjuryTimer           = $079e
StarInvincibleTimer   = $079f
ScreenTimer           = $07a0
WorldEndTimer         = $07a1
DemoTimer             = $07a2

Sprite_Data           = $0200

Sprite_Y_Position     = $0200
Sprite_Tilenumber     = $0201
Sprite_Attributes     = $0202
Sprite_X_Position     = $0203

ScreenEdge_PageLoc    = $071a
ScreenEdge_X_Pos      = $071c
ScreenLeft_PageLoc    = $071a
ScreenRight_PageLoc   = $071b
ScreenLeft_X_Pos      = $071c
ScreenRight_X_Pos     = $071d

PlayerFacingDir       = $33
DestinationPageLoc    = $34
VictoryWalkControl    = $35
ScrollFractional      = $0768
PrimaryMsgCounter     = $0719
SecondaryMsgCounter   = $0749

HorizontalScroll      = $073f
VerticalScroll        = $0740
ScrollLock            = $0723
ScrollThirtyTwo       = $073d
Player_X_Scroll       = $06ff
Player_Pos_ForScroll  = $0755
ScrollAmount          = $0775

AreaData              = $e7
AreaDataLow           = $e7
AreaDataHigh          = $e8
EnemyData             = $e9
EnemyDataLow          = $e9
EnemyDataHigh         = $ea

AreaParserTaskNum     = $071f
ColumnSets            = $071e
CurrentPageLoc        = $0725
CurrentColumnPos      = $0726
BackloadingFlag       = $0728
BehindAreaParserFlag  = $0729
AreaObjectPageLoc     = $072a
AreaObjectPageSel     = $072b
AreaDataOffset        = $072c
AreaObjOffsetBuffer   = $072d
AreaObjectLength      = $0730
StaircaseControl      = $0734
AreaObjectHeight      = $0735
MushroomLedgeHalfLen  = $0736
EnemyDataOffset       = $0739
EnemyObjectPageLoc    = $073a
EnemyObjectPageSel    = $073b
MetatileBuffer        = $06a1
BlockBufferColumnPos  = $06a0
CurrentNTAddr_Low     = $0721
CurrentNTAddr_High    = $0720
AttributeBuffer       = $03f9

LoopCommand           = $0745

DisplayDigits         = $07d7
TopScoreDisplay       = $07d7
ScoreAndCoinDisplay   = $07dd
PlayerScoreDisplay    = $07dd
GameTimerDisplay      = $07f8
DigitModifier         = $0134

VerticalFlipFlag      = $0109
FloateyNum_Control    = $0110
ShellChainCounter     = $0125
FloateyNum_Timer      = $012c
FloateyNum_X_Pos      = $0117
FloateyNum_Y_Pos      = $011e
FlagpoleFNum_Y_Pos    = $010d
FlagpoleFNum_YMFDummy = $010e
FlagpoleScore         = $010f
FlagpoleCollisionYPos = $070f
StompChainCounter     = $0484

VRAM_Buffer1_Offset   = $0300
VRAM_Buffer1          = $0301
VRAM_Buffer2_Offset   = $0340
VRAM_Buffer2          = $0341
VRAM_Buffer_AddrCtrl  = $0773
Sprite0HitDetectFlag  = $0722
DisableScreenFlag     = $0774
DisableIntermediate   = $0769
ColorRotateOffset     = $06d4

TerrainControl        = $0727
AreaStyle             = $0733
ForegroundScenery     = $0741
BackgroundScenery     = $0742
CloudTypeOverride     = $0743
BackgroundColorCtrl   = $0744
AreaType              = $074e
AreaAddrsLOffset      = $074f
AreaPointer           = $0750

PlayerEntranceCtrl    = $0710
GameTimerSetting      = $0715
AltEntranceControl    = $0752
EntrancePage          = $0751
NumberOfPlayers       = $077a
WarpZoneControl       = $06d6
ChangeAreaTimer       = $06de

MultiLoopCorrectCntr  = $06d9
MultiLoopPassCntr     = $06da

FetchNewGameTimerFlag = $0757
GameTimerExpiredFlag  = $0759

PrimaryHardMode       = $076a
SecondaryHardMode     = $06cc
WorldSelectNumber     = $076b
WorldSelectEnableFlag = $07fc
ContinueWorld         = $07fd

CurrentPlayer         = $0753
PlayerSize            = $0754
PlayerStatus          = $0756

OnscreenPlayerInfo    = $075a
NumberofLives         = $075a ;used by current player
HalfwayPage           = $075b
LevelNumber           = $075c ;the actual dash number
Hidden1UpFlag         = $075d
CoinTally             = $075e
WorldNumber           = $075f
AreaNumber            = $0760 ;internal number used to find areas

CoinTallyFor1Ups      = $0748

OffscreenPlayerInfo   = $0761
OffScr_NumberofLives  = $0761 ;used by offscreen player
OffScr_HalfwayPage    = $0762
OffScr_LevelNumber    = $0763
OffScr_Hidden1UpFlag  = $0764
OffScr_CoinTally      = $0765
OffScr_WorldNumber    = $0766
OffScr_AreaNumber     = $0767

BalPlatformAlignment  = $03a0
Platform_X_Scroll     = $03a1
PlatformCollisionFlag = $03a2
YPlatformTopYPos      = $0401
YPlatformCenterYPos   = $58

BrickCoinTimerFlag    = $06bc
StarFlagTaskControl   = $0746

PseudoRandomBitReg    = $07a7
WarmBootValidation    = $07ff

SprShuffleAmtOffset   = $06e0
SprShuffleAmt         = $06e1
SprDataOffset         = $06e4
Player_SprDataOffset  = $06e4
Enemy_SprDataOffset   = $06e5
Block_SprDataOffset   = $06ec
Alt_SprDataOffset     = $06ec
Bubble_SprDataOffset  = $06ee
FBall_SprDataOffset   = $06f1
Misc_SprDataOffset    = $06f3
SprDataOffset_Ctrl    = $03ee

Player_State          = $1d
Enemy_State           = $1e
Fireball_State        = $24
Block_State           = $26
Misc_State            = $2a

Player_MovingDir      = $45
Enemy_MovingDir       = $46

SprObject_X_Speed     = $57
Player_X_Speed        = $57
Enemy_X_Speed         = $58
Fireball_X_Speed      = $5e
Block_X_Speed         = $60
Misc_X_Speed          = $64

Jumpspring_FixedYPos  = $58
JumpspringAnimCtrl    = $070e
JumpspringForce       = $06db

SprObject_PageLoc     = $6d
Player_PageLoc        = $6d
Enemy_PageLoc         = $6e
Fireball_PageLoc      = $74
Block_PageLoc         = $76
Misc_PageLoc          = $7a
Bubble_PageLoc        = $83

SprObject_X_Position  = $86
Player_X_Position     = $86
Enemy_X_Position      = $87
Fireball_X_Position   = $8d
Block_X_Position      = $8f
Misc_X_Position       = $93
Bubble_X_Position     = $9c

SprObject_Y_Speed     = $9f
Player_Y_Speed        = $9f
Enemy_Y_Speed         = $a0
Fireball_Y_Speed      = $a6
Block_Y_Speed         = $a8
Misc_Y_Speed          = $ac

SprObject_Y_HighPos   = $b5
Player_Y_HighPos      = $b5
Enemy_Y_HighPos       = $b6
Fireball_Y_HighPos    = $bc
Block_Y_HighPos       = $be
Misc_Y_HighPos        = $c2
Bubble_Y_HighPos      = $cb

SprObject_Y_Position  = $ce
Player_Y_Position     = $ce
Enemy_Y_Position      = $cf
Fireball_Y_Position   = $d5
Block_Y_Position      = $d7
Misc_Y_Position       = $db
Bubble_Y_Position     = $e4

SprObject_Rel_XPos    = $03ad
Player_Rel_XPos       = $03ad
Enemy_Rel_XPos        = $03ae
Fireball_Rel_XPos     = $03af
Bubble_Rel_XPos       = $03b0
Block_Rel_XPos        = $03b1
Misc_Rel_XPos         = $03b3

SprObject_Rel_YPos    = $03b8
Player_Rel_YPos       = $03b8
Enemy_Rel_YPos        = $03b9
Fireball_Rel_YPos     = $03ba
Bubble_Rel_YPos       = $03bb
Block_Rel_YPos        = $03bc
Misc_Rel_YPos         = $03be

SprObject_SprAttrib   = $03c4
Player_SprAttrib      = $03c4
Enemy_SprAttrib       = $03c5

SprObject_X_MoveForce = $0400
Enemy_X_MoveForce     = $0401

SprObject_YMF_Dummy   = $0416
Player_YMF_Dummy      = $0416
Enemy_YMF_Dummy       = $0417
Bubble_YMF_Dummy      = $042c

SprObject_Y_MoveForce = $0433
Player_Y_MoveForce    = $0433
Enemy_Y_MoveForce     = $0434
Block_Y_MoveForce     = $043c

DisableCollisionDet   = $0716
Player_CollisionBits  = $0490
Enemy_CollisionBits   = $0491

SprObj_BoundBoxCtrl   = $0499
Player_BoundBoxCtrl   = $0499
Enemy_BoundBoxCtrl    = $049a
Fireball_BoundBoxCtrl = $04a0
Misc_BoundBoxCtrl     = $04a2

EnemyFrenzyBuffer     = $06cb
EnemyFrenzyQueue      = $06cd
Enemy_Flag            = $0f
Enemy_ID              = $16

PlayerGfxOffset       = $06d5
Player_XSpeedAbsolute = $0700
FrictionAdderHigh     = $0701
FrictionAdderLow      = $0702
RunningSpeed          = $0703
SwimmingFlag          = $0704
Player_X_MoveForce    = $0705
DiffToHaltJump        = $0706
JumpOrigin_Y_HighPos  = $0707
JumpOrigin_Y_Position = $0708
VerticalForce         = $0709
VerticalForceDown     = $070a
PlayerChangeSizeFlag  = $070b
PlayerAnimTimerSet    = $070c
PlayerAnimCtrl        = $070d
DeathMusicLoaded      = $0712
FlagpoleSoundQueue    = $0713
CrouchingFlag         = $0714
MaximumLeftSpeed      = $0450
MaximumRightSpeed     = $0456

SprObject_OffscrBits  = $03d0
Player_OffscreenBits  = $03d0
Enemy_OffscreenBits   = $03d1
FBall_OffscreenBits   = $03d2
Bubble_OffscreenBits  = $03d3
Block_OffscreenBits   = $03d4
Misc_OffscreenBits    = $03d6
EnemyOffscrBitsMasked = $03d8

Cannon_Offset         = $046a
Cannon_PageLoc        = $046b
Cannon_X_Position     = $0471
Cannon_Y_Position     = $0477
Cannon_Timer          = $047d

Whirlpool_Offset      = $046a
Whirlpool_PageLoc     = $046b
Whirlpool_LeftExtent  = $0471
Whirlpool_Length      = $0477
Whirlpool_Flag        = $047d

VineFlagOffset        = $0398
VineHeight            = $0399
VineObjOffset         = $039a
VineStart_Y_Position  = $039d

Block_Orig_YPos       = $03e4
Block_BBuf_Low        = $03e6
Block_Metatile        = $03e8
Block_PageLoc2        = $03ea
Block_RepFlag         = $03ec
Block_ResidualCounter = $03f0
Block_Orig_XPos       = $03f1

BoundingBox_UL_XPos   = $04ac
BoundingBox_UL_YPos   = $04ad
BoundingBox_DR_XPos   = $04ae
BoundingBox_DR_YPos   = $04af
BoundingBox_UL_Corner = $04ac
BoundingBox_LR_Corner = $04ae
EnemyBoundingBoxCoord = $04b0

PowerUpType           = $39

FireballBouncingFlag  = $3a
FireballCounter       = $06ce
FireballThrowingTimer = $0711

HammerEnemyOffset     = $06ae
JumpCoinMiscOffset    = $06b7

Block_Buffer_1        = $0500
Block_Buffer_2        = $05d0

HammerThrowingTimer   = $03a2
HammerBroJumpTimer    = $3c
Misc_Collision_Flag   = $06be

RedPTroopaOrigXPos    = $0401
RedPTroopaCenterYPos  = $58

XMovePrimaryCounter   = $a0
XMoveSecondaryCounter = $58

CheepCheepMoveMFlag   = $58
CheepCheepOrigYPos    = $0434
BitMFilter            = $06dd

LakituReappearTimer   = $06d1
LakituMoveSpeed       = $58
LakituMoveDirection   = $a0

FirebarSpinState_Low  = $58
FirebarSpinState_High = $a0
FirebarSpinSpeed      = $0388
FirebarSpinDirection  = $34

DuplicateObj_Offset   = $06cf
NumberofGroupEnemies  = $06d3

BlooperMoveCounter    = $a0
BlooperMoveSpeed      = $58

BowserBodyControls    = $0363
BowserFeetCounter     = $0364
BowserMovementSpeed   = $0365
BowserOrigXPos        = $0366
BowserFlameTimerCtrl  = $0367
BowserFront_Offset    = $0368
BridgeCollapseOffset  = $0369
BowserGfxFlag         = $036a
BowserHitPoints       = $0483
MaxRangeFromOrigin    = $06dc

BowserFlamePRandomOfs = $0417

PiranhaPlantUpYPos    = $0417
PiranhaPlantDownYPos  = $0434
PiranhaPlant_Y_Speed  = $58
PiranhaPlant_MoveFlag = $a0

FireworksCounter      = $06d7
ExplosionGfxCounter   = $58
ExplosionTimerCounter = $a0

;sound related defines
Squ2_NoteLenBuffer    = $07b3
Squ2_NoteLenCounter   = $07b4
Squ2_EnvelopeDataCtrl = $07b5
Squ1_NoteLenCounter   = $07b6
Squ1_EnvelopeDataCtrl = $07b7
Tri_NoteLenBuffer     = $07b8
Tri_NoteLenCounter    = $07b9
Noise_BeatLenCounter  = $07ba
Squ1_SfxLenCounter    = $07bb
Squ2_SfxLenCounter    = $07bd
Sfx_SecondaryCounter  = $07be
Noise_SfxLenCounter   = $07bf

PauseSoundQueue       = $fa
Square1SoundQueue     = $ff
Square2SoundQueue     = $fe
NoiseSoundQueue       = $fd
AreaMusicQueue        = $fb
EventMusicQueue       = $fc

Square1SoundBuffer    = $f1
Square2SoundBuffer    = $f2
NoiseSoundBuffer      = $f3
AreaMusicBuffer       = $f4
EventMusicBuffer      = $07b1
PauseSoundBuffer      = $07b2

MusicData             = $f5
MusicDataLow          = $f5
MusicDataHigh         = $f6
MusicOffset_Square2   = $f7
MusicOffset_Square1   = $f8
MusicOffset_Triangle  = $f9
MusicOffset_Noise     = $07b0

NoteLenLookupTblOfs   = $f0
DAC_Counter           = $07c0
NoiseDataLoopbackOfs  = $07c1
NoteLengthTblAdder    = $07c4
AreaMusicBuffer_Alt   = $07c5
PauseModeFlag         = $07c6
GroundMusicHeaderOfs  = $07c7
AltRegContentFlag     = $07ca

;-------------------------------------------------------------------------------------
;CONSTANTS

;sound effects constants
Sfx_SmallJump         = %10000000
Sfx_Flagpole          = %01000000
Sfx_Fireball          = %00100000
Sfx_PipeDown_Injury   = %00010000
Sfx_EnemySmack        = %00001000
Sfx_EnemyStomp        = %00000100
Sfx_Bump              = %00000010
Sfx_BigJump           = %00000001

Sfx_BowserFall        = %10000000
Sfx_ExtraLife         = %01000000
Sfx_PowerUpGrab       = %00100000
Sfx_TimerTick         = %00010000
Sfx_Blast             = %00001000
Sfx_GrowVine          = %00000100
Sfx_GrowPowerUp       = %00000010
Sfx_CoinGrab          = %00000001

Sfx_BowserFlame       = %00000010
Sfx_BrickShatter      = %00000001

;music constants
Silence               = %10000000

StarPowerMusic        = %01000000
PipeIntroMusic        = %00100000
CloudMusic            = %00010000
CastleMusic           = %00001000
UndergroundMusic      = %00000100
WaterMusic            = %00000010
GroundMusic           = %00000001

TimeRunningOutMusic   = %01000000
EndOfLevelMusic       = %00100000
AltGameOverMusic      = %00010000
EndOfCastleMusic      = %00001000
VictoryMusic          = %00000100
GameOverMusic         = %00000010
DeathMusic            = %00000001

;enemy object constants
GreenKoopa            = $00
BuzzyBeetle           = $02
RedKoopa              = $03
HammerBro             = $05
Goomba                = $06
Bloober               = $07
BulletBill_FrenzyVar  = $08
GreyCheepCheep        = $0a
RedCheepCheep         = $0b
Podoboo               = $0c
PiranhaPlant          = $0d
GreenParatroopaJump   = $0e
RedParatroopa         = $0f
GreenParatroopaFly    = $10
Lakitu                = $11
Spiny                 = $12
FlyCheepCheepFrenzy   = $14
FlyingCheepCheep      = $14
BowserFlame           = $15
Fireworks             = $16
BBill_CCheep_Frenzy   = $17
Stop_Frenzy           = $18
Bowser                = $2d
PowerUpObject         = $2e
VineObject            = $2f
FlagpoleFlagObject    = $30
StarFlagObject        = $31
JumpspringObject      = $32
BulletBill_CannonVar  = $33
RetainerObject        = $35
TallEnemy             = $09

;other constants
World1 = 0
World2 = 1
World3 = 2
World4 = 3
World5 = 4
World6 = 5
World7 = 6
World8 = 7
Level1 = 0
Level2 = 1
Level3 = 2
Level4 = 3

WarmBootOffset        = <$07d6
ColdBootOffset        = <$07fe
TitleScreenDataOffset = $1ec0
SoundMemory           = $07b0
SwimTileRepOffset     = PlayerGraphicsTable + $9e
MusicHeaderOffsetData = MusicHeaderData - 1
MHD                   = MusicHeaderData

A_Button              = %10000000
B_Button              = %01000000
Select_Button         = %00100000
Start_Button          = %00010000
Up_Dir                = %00001000
Down_Dir              = %00000100
Left_Dir              = %00000010
Right_Dir             = %00000001

TitleScreenModeValue  = 0
GameModeValue         = 1
VictoryModeValue      = 2
GameOverModeValue     = 3

;-------------------------------------------------------------------------------------
;DIRECTIVES

;       .index 8
;       .mem 8

       .org $8000

;-------------------------------------------------------------------------------------

Start:
             sei                          ;pretty standard 6502 type init here
             cld
             lda #%00010000               ;init PPU control register 1
             sta PPU_CTRL_REG1
             ldx #$ff                     ;reset stack pointer
             txs
VBlank1:     lda PPU_STATUS               ;wait two frames
             bpl VBlank1
VBlank2:     lda PPU_STATUS
             bpl VBlank2
             ldy #ColdBootOffset          ;load default cold boot pointer
             ldx #$05                     ;this is where we check for a warm boot
WBootCheck:  lda TopScoreDisplay,x        ;check each score digit in the top score
             cmp #10                      ;to see if we have a valid digit
             bcs ColdBoot                 ;if not, give up and proceed with cold boot
             dex
             bpl WBootCheck
             lda WarmBootValidation       ;second checkpoint, check to see if
             cmp #$a5                     ;another location has a specific value
             bne ColdBoot
             ldy #WarmBootOffset          ;if passed both, load warm boot pointer
ColdBoot:    jsr InitializeMemory         ;clear memory using pointer in Y
             sta SND_DELTA_REG+1          ;reset delta counter load register
             sta OperMode                 ;reset primary mode of operation
             lda #$a5                     ;set warm boot flag
             sta WarmBootValidation
             sta PseudoRandomBitReg       ;set seed for pseudorandom register
             lda #%00001111
             sta SND_MASTERCTRL_REG       ;enable all sound channels except dmc
             lda #%00000110
             sta PPU_CTRL_REG2            ;turn off clipping for OAM and background
             jsr MoveAllSpritesOffscreen
             jsr InitializeNameTables     ;initialize both name tables
             inc DisableScreenFlag        ;set flag to disable screen output
             lda Mirror_PPU_CTRL_REG1
             ora #%10000000               ;enable NMIs
             jsr WritePPUReg1
EndlessLoop: jmp EndlessLoop              ;endless loop, need I say more?

;-------------------------------------------------------------------------------------
;$00 - vram buffer address table low, also used for pseudorandom bit
;$01 - vram buffer address table high

VRAM_AddrTable_Low:
      .db <VRAM_Buffer1, <WaterPaletteData, <GroundPaletteData
      .db <UndergroundPaletteData, <CastlePaletteData, <VRAM_Buffer1_Offset
      .db <VRAM_Buffer2, <VRAM_Buffer2, <BowserPaletteData
      .db <DaySnowPaletteData, <NightSnowPaletteData, <MushroomPaletteData
      .db <MarioThanksMessage, <LuigiThanksMessage, <MushroomRetainerSaved
      .db <PrincessSaved1, <PrincessSaved2, <WorldSelectMessage1
      .db <WorldSelectMessage2

VRAM_AddrTable_High:
      .db >VRAM_Buffer1, >WaterPaletteData, >GroundPaletteData
      .db >UndergroundPaletteData, >CastlePaletteData, >VRAM_Buffer1_Offset
      .db >VRAM_Buffer2, >VRAM_Buffer2, >BowserPaletteData
      .db >DaySnowPaletteData, >NightSnowPaletteData, >MushroomPaletteData
      .db >MarioThanksMessage, >LuigiThanksMessage, >MushroomRetainerSaved
      .db >PrincessSaved1, >PrincessSaved2, >WorldSelectMessage1
      .db >WorldSelectMessage2

VRAM_Buffer_Offset:
      .db <VRAM_Buffer1_Offset, <VRAM_Buffer2_Offset

NonMaskableInterrupt:
               lda Mirror_PPU_CTRL_REG1  ;disable NMIs in mirror reg
               and #%01111111            ;save all other bits
               sta Mirror_PPU_CTRL_REG1
               and #%01111110            ;alter name table address to be $2800
               sta PPU_CTRL_REG1         ;(essentially $2000) but save other bits
               lda Mirror_PPU_CTRL_REG2  ;disable OAM and background display by default
               and #%11100110
               ldy DisableScreenFlag     ;get screen disable flag
               bne ScreenOff             ;if set, used bits as-is
               lda Mirror_PPU_CTRL_REG2  ;otherwise reenable bits and save them
               ora #%00011110
ScreenOff:     sta Mirror_PPU_CTRL_REG2  ;save bits for later but not in register at the moment
               and #%11100111            ;disable screen for now
               sta PPU_CTRL_REG2
               ldx PPU_STATUS            ;reset flip-flop and reset scroll registers to zero
               lda #$00
               jsr InitScroll
               sta PPU_SPR_ADDR          ;reset spr-ram address register
               lda #$02                  ;perform spr-ram DMA access on $0200-$02ff
               sta SPR_DMA
               ldx VRAM_Buffer_AddrCtrl  ;load control for pointer to buffer contents
               lda VRAM_AddrTable_Low,x  ;set indirect at $00 to pointer
               sta $00
               lda VRAM_AddrTable_High,x
               sta $01
               jsr UpdateScreen          ;update screen with buffer contents
               ldy #$00
               ldx VRAM_Buffer_AddrCtrl  ;check for usage of $0341
               cpx #$06
               bne InitBuffer
               iny                       ;get offset based on usage
InitBuffer:    ldx VRAM_Buffer_Offset,y
               lda #$00                  ;clear buffer header at last location
               sta VRAM_Buffer1_Offset,x
               sta VRAM_Buffer1,x
               sta VRAM_Buffer_AddrCtrl  ;reinit address control to $0301
               lda Mirror_PPU_CTRL_REG2  ;copy mirror of $2001 to register
               sta PPU_CTRL_REG2
               jsr SoundEngine           ;play sound
               jsr ReadJoypads           ;read joypads
               jsr PauseRoutine          ;handle pause
               jsr UpdateTopScore
               lda GamePauseStatus       ;check for pause status
               lsr
               bcs PauseSkip
               lda TimerControl          ;if master timer control not set, decrement
               beq DecTimers             ;all frame and interval timers
               dec TimerControl
               bne NoDecTimers
DecTimers:     ldx #$14                  ;load end offset for end of frame timers
               dec IntervalTimerControl  ;decrement interval timer control,
               bpl DecTimersLoop         ;if not expired, only frame timers will decrement
               lda #$14
               sta IntervalTimerControl  ;if control for interval timers expired,
               ldx #$23                  ;interval timers will decrement along with frame timers
DecTimersLoop: lda Timers,x              ;check current timer
               beq SkipExpTimer          ;if current timer expired, branch to skip,
               dec Timers,x              ;otherwise decrement the current timer
SkipExpTimer:  dex                       ;move onto next timer
               bpl DecTimersLoop         ;do this until all timers are dealt with
NoDecTimers:   inc FrameCounter          ;increment frame counter
PauseSkip:     ldx #$00
               ldy #$07
               lda PseudoRandomBitReg    ;get first memory location of LSFR bytes
               and #%00000010            ;mask out all but d1
               sta $00                   ;save here
               lda PseudoRandomBitReg+1  ;get second memory location
               and #%00000010            ;mask out all but d1
               eor $00                   ;perform exclusive-OR on d1 from first and second bytes
               clc                       ;if neither or both are set, carry will be clear
               beq RotPRandomBit
               sec                       ;if one or the other is set, carry will be set
RotPRandomBit: ror PseudoRandomBitReg,x  ;rotate carry into d7, and rotate last bit into carry
               inx                       ;increment to next byte
               dey                       ;decrement for loop
               bne RotPRandomBit
               lda Sprite0HitDetectFlag  ;check for flag here
               beq SkipSprite0
Sprite0Clr:    lda PPU_STATUS            ;wait for sprite 0 flag to clear, which will
               and #%01000000            ;not happen until vblank has ended
               bne Sprite0Clr
               lda GamePauseStatus       ;if in pause mode, do not bother with sprites at all
               lsr
               bcs Sprite0Hit
               jsr MoveSpritesOffscreen
               jsr SpriteShuffler
Sprite0Hit:    lda PPU_STATUS            ;do sprite #0 hit detection
               and #%01000000
               beq Sprite0Hit
               ldy #$14                  ;small delay, to wait until we hit horizontal blank time
HBlankDelay:   dey
               bne HBlankDelay
SkipSprite0:   lda HorizontalScroll      ;set scroll registers from variables
               sta PPU_SCROLL_REG
               lda VerticalScroll
               sta PPU_SCROLL_REG
               lda Mirror_PPU_CTRL_REG1  ;load saved mirror of $2000
               pha
               sta PPU_CTRL_REG1
               lda GamePauseStatus       ;if in pause mode, do not perform operation mode stuff
               lsr
               bcs SkipMainOper
               jsr OperModeExecutionTree ;otherwise do one of many, many possible subroutines
SkipMainOper:  lda PPU_STATUS            ;reset flip-flop
               pla
               ora #%10000000            ;reactivate NMIs
               sta PPU_CTRL_REG1
               rti                       ;we are done until the next frame!

;-------------------------------------------------------------------------------------

PauseRoutine:
               lda OperMode           ;are we in victory mode?
               cmp #VictoryModeValue  ;if so, go ahead
               beq ChkPauseTimer
               cmp #GameModeValue     ;are we in game mode?
               bne ExitPause          ;if not, leave
               lda OperMode_Task      ;if we are in game mode, are we running game engine?
               cmp #$03
               bne ExitPause          ;if not, leave
ChkPauseTimer: lda GamePauseTimer     ;check if pause timer is still counting down
               beq ChkStart
               dec GamePauseTimer     ;if so, decrement and leave
               rts
ChkStart:      lda SavedJoypad1Bits   ;check to see if start is pressed
               and #Start_Button      ;on controller 1
               beq ClrPauseTimer
               lda GamePauseStatus    ;check to see if timer flag is set
               and #%10000000         ;and if so, do not reset timer (residual,
               bne ExitPause          ;joypad reading routine makes this unnecessary)
               lda #$2b               ;set pause timer
               sta GamePauseTimer
               lda GamePauseStatus
               tay
               iny                    ;set pause sfx queue for next pause mode
               sty PauseSoundQueue
               eor #%00000001         ;invert d0 and set d7
               ora #%10000000
               bne SetPause           ;unconditional branch
ClrPauseTimer: lda GamePauseStatus    ;clear timer flag if timer is at zero and start button
               and #%01111111         ;is not pressed
SetPause:      sta GamePauseStatus
ExitPause:     rts

;-------------------------------------------------------------------------------------
;$00 - used for preset value

SpriteShuffler:
               ldy AreaType                ;load level type, likely residual code
               lda #$28                    ;load preset value which will put it at
               sta $00                     ;sprite #10
               ldx #$0e                    ;start at the end of OAM data offsets
ShuffleLoop:   lda SprDataOffset,x         ;check for offset value against
               cmp $00                     ;the preset value
               bcc NextSprOffset           ;if less, skip this part
               ldy SprShuffleAmtOffset     ;get current offset to preset value we want to add
               clc
               adc SprShuffleAmt,y         ;get shuffle amount, add to current sprite offset
               bcc StrSprOffset            ;if not exceeded $ff, skip second add
               clc
               adc $00                     ;otherwise add preset value $28 to offset
StrSprOffset:  sta SprDataOffset,x         ;store new offset here or old one if branched to here
NextSprOffset: dex                         ;move backwards to next one
               bpl ShuffleLoop
               ldx SprShuffleAmtOffset     ;load offset
               inx
               cpx #$03                    ;check if offset + 1 goes to 3
               bne SetAmtOffset            ;if offset + 1 not 3, store
               ldx #$00                    ;otherwise, init to 0
SetAmtOffset:  stx SprShuffleAmtOffset
               ldx #$08                    ;load offsets for values and storage
               ldy #$02
SetMiscOffset: lda SprDataOffset+5,y       ;load one of three OAM data offsets
               sta Misc_SprDataOffset-2,x  ;store first one unmodified, but
               clc                         ;add eight to the second and eight
               adc #$08                    ;more to the third one
               sta Misc_SprDataOffset-1,x  ;note that due to the way X is set up,
               clc                         ;this code loads into the misc sprite offsets
               adc #$08
               sta Misc_SprDataOffset,x
               dex
               dex
               dex
               dey
               bpl SetMiscOffset           ;do this until all misc spr offsets are loaded
               rts

;-------------------------------------------------------------------------------------

OperModeExecutionTree:
      lda OperMode     ;this is the heart of the entire program,
      jsr JumpEngine   ;most of what goes on starts here

      .dw TitleScreenMode
      .dw GameMode
      .dw VictoryMode
      .dw GameOverMode

;-------------------------------------------------------------------------------------

MoveAllSpritesOffscreen:
              ldy #$00                ;this routine moves all sprites off the screen
              .db $2c                 ;BIT instruction opcode

MoveSpritesOffscreen:
              ldy #$04                ;this routine moves all but sprite 0
              lda #$f8                ;off the screen
SprInitLoop:  sta Sprite_Y_Position,y ;write 248 into OAM data's Y coordinate
              iny                     ;which will move it off the screen
              iny
              iny
              iny
              bne SprInitLoop
              rts

;-------------------------------------------------------------------------------------

TitleScreenMode:
      lda OperMode_Task
      jsr JumpEngine

      .dw InitializeGame
      .dw ScreenRoutines
      .dw PrimaryGameSetup
      .dw GameMenuRoutine

;-------------------------------------------------------------------------------------

WSelectBufferTemplate:
      .db $04, $20, $73, $01, $00, $00

GameMenuRoutine:
              ldy #$00
              lda SavedJoypad1Bits        ;check to see if either player pressed
              ora SavedJoypad2Bits        ;only the start button (either joypad)
              cmp #Start_Button
              beq StartGame
              cmp #A_Button+Start_Button  ;check to see if A + start was pressed
              bne ChkSelect               ;if not, branch to check select button
StartGame:    jmp ChkContinue             ;if either start or A + start, execute here
ChkSelect:    cmp #Select_Button          ;check to see if the select button was pressed
              beq SelectBLogic            ;if so, branch reset demo timer
              ldx DemoTimer               ;otherwise check demo timer
              bne ChkWorldSel             ;if demo timer not expired, branch to check world selection
              sta SelectTimer             ;set controller bits here if running demo
              jsr DemoEngine              ;run through the demo actions
              bcs ResetTitle              ;if carry flag set, demo over, thus branch
              jmp RunDemo                 ;otherwise, run game engine for demo
ChkWorldSel:  ldx WorldSelectEnableFlag   ;check to see if world selection has been enabled
              beq NullJoypad
              cmp #B_Button               ;if so, check to see if the B button was pressed
              bne NullJoypad
              iny                         ;if so, increment Y and execute same code as select
SelectBLogic: lda DemoTimer               ;if select or B pressed, check demo timer one last time
              beq ResetTitle              ;if demo timer expired, branch to reset title screen mode
              lda #$18                    ;otherwise reset demo timer
              sta DemoTimer
              lda SelectTimer             ;check select/B button timer
              bne NullJoypad              ;if not expired, branch
              lda #$10                    ;otherwise reset select button timer
              sta SelectTimer
              cpy #$01                    ;was the B button pressed earlier?  if so, branch
              beq IncWorldSel             ;note this will not be run if world selection is disabled
              lda NumberOfPlayers         ;if no, must have been the select button, therefore
              eor #%00000001              ;change number of players and draw icon accordingly
              sta NumberOfPlayers
              jsr DrawMushroomIcon
              jmp NullJoypad
IncWorldSel:  ldx WorldSelectNumber       ;increment world select number
              inx
              txa
              and #%00000111              ;mask out higher bits
              sta WorldSelectNumber       ;store as current world select number
              jsr GoContinue
UpdateShroom: lda WSelectBufferTemplate,x ;write template for world select in vram buffer
              sta VRAM_Buffer1-1,x        ;do this until all bytes are written
              inx
              cpx #$06
              bmi UpdateShroom
              ldy WorldNumber             ;get world number from variable and increment for
              iny                         ;proper display, and put in blank byte before
              sty VRAM_Buffer1+3          ;null terminator
NullJoypad:   lda #$00                    ;clear joypad bits for player 1
              sta SavedJoypad1Bits
RunDemo:      jsr GameCoreRoutine         ;run game engine
              lda GameEngineSubroutine    ;check to see if we're running lose life routine
              cmp #$06
              bne ExitMenu                ;if not, do not do all the resetting below
ResetTitle:   lda #$00                    ;reset game modes, disable
              sta OperMode                ;sprite 0 check and disable
              sta OperMode_Task           ;screen output
              sta Sprite0HitDetectFlag
              inc DisableScreenFlag
              rts
ChkContinue:  ldy DemoTimer               ;if timer for demo has expired, reset modes
              beq ResetTitle
              asl                         ;check to see if A button was also pushed
              bcc StartWorld1             ;if not, don't load continue function's world number
              lda ContinueWorld           ;load previously saved world number for secret
              jsr GoContinue              ;continue function when pressing A + start
StartWorld1:  jsr LoadAreaPointer
              inc Hidden1UpFlag           ;set 1-up box flag for both players
              inc OffScr_Hidden1UpFlag
              inc FetchNewGameTimerFlag   ;set fetch new game timer flag
              inc OperMode                ;set next game mode
              lda WorldSelectEnableFlag   ;if world select flag is on, then primary
              sta PrimaryHardMode         ;hard mode must be on as well
              lda #$00
              sta OperMode_Task           ;set game mode here, and clear demo timer
              sta DemoTimer
              ldx #$17
              lda #$00
InitScores:   sta ScoreAndCoinDisplay,x   ;clear player scores and coin displays
              dex
              bpl InitScores
ExitMenu:     rts
GoContinue:   sta WorldNumber             ;start both players at the first area
              sta OffScr_WorldNumber      ;of the previously saved world number
              ldx #$00                    ;note that on power-up using this function
              stx AreaNumber              ;will make no difference
              stx OffScr_AreaNumber
              rts

;-------------------------------------------------------------------------------------

MushroomIconData:
      .db $07, $22, $49, $83, $ce, $24, $24, $00

DrawMushroomIcon:
              ldy #$07                ;read eight bytes to be read by transfer routine
IconDataRead: lda MushroomIconData,y  ;note that the default position is set for a
              sta VRAM_Buffer1-1,y    ;1-player game
              dey
              bpl IconDataRead
              lda NumberOfPlayers     ;check number of players
              beq ExitIcon            ;if set to 1-player game, we're done
              lda #$24                ;otherwise, load blank tile in 1-player position
              sta VRAM_Buffer1+3
              lda #$ce                ;then load shroom icon tile in 2-player position
              sta VRAM_Buffer1+5
ExitIcon:     rts

;-------------------------------------------------------------------------------------

DemoActionData:
      .db $01, $80, $02, $81, $41, $80, $01
      .db $42, $c2, $02, $80, $41, $c1, $41, $c1
      .db $01, $c1, $01, $02, $80, $00

DemoTimingData:
      .db $9b, $10, $18, $05, $2c, $20, $24
      .db $15, $5a, $10, $20, $28, $30, $20, $10
      .db $80, $20, $30, $30, $01, $ff, $00

DemoEngine:
          ldx DemoAction         ;load current demo action
          lda DemoActionTimer    ;load current action timer
          bne DoAction           ;if timer still counting down, skip
          inx
          inc DemoAction         ;if expired, increment action, X, and
          sec                    ;set carry by default for demo over
          lda DemoTimingData-1,x ;get next timer
          sta DemoActionTimer    ;store as current timer
          beq DemoOver           ;if timer already at zero, skip
DoAction: lda DemoActionData-1,x ;get and perform action (current or next)
          sta SavedJoypad1Bits
          dec DemoActionTimer    ;decrement action timer
          clc                    ;clear carry if demo still going
DemoOver: rts

;-------------------------------------------------------------------------------------

VictoryMode:
            jsr VictoryModeSubroutines  ;run victory mode subroutines
            lda OperMode_Task           ;get current task of victory mode
            beq AutoPlayer              ;if on bridge collapse, skip enemy processing
            ldx #$00
            stx ObjectOffset            ;otherwise reset enemy object offset
            jsr EnemiesAndLoopsCore     ;and run enemy code
AutoPlayer: jsr RelativePlayerPosition  ;get player's relative coordinates
            jmp PlayerGfxHandler        ;draw the player, then leave

VictoryModeSubroutines:
      lda OperMode_Task
      jsr JumpEngine

      .dw BridgeCollapse
      .dw SetupVictoryMode
      .dw PlayerVictoryWalk
      .dw PrintVictoryMessages
      .dw PlayerEndWorld

;-------------------------------------------------------------------------------------

SetupVictoryMode:
      ldx ScreenRight_PageLoc  ;get page location of right side of screen
      inx                      ;increment to next page
      stx DestinationPageLoc   ;store here
      lda #EndOfCastleMusic
      sta EventMusicQueue      ;play win castle music
      jmp IncModeTask_B        ;jump to set next major task in victory mode

;-------------------------------------------------------------------------------------

PlayerVictoryWalk:
             ldy #$00                ;set value here to not walk player by default
             sty VictoryWalkControl
             lda Player_PageLoc      ;get player's page location
             cmp DestinationPageLoc  ;compare with destination page location
             bne PerformWalk         ;if page locations don't match, branch
             lda Player_X_Position   ;otherwise get player's horizontal position
             cmp #$60                ;compare with preset horizontal position
             bcs DontWalk            ;if still on other page, branch ahead
PerformWalk: inc VictoryWalkControl  ;otherwise increment value and Y
             iny                     ;note Y will be used to walk the player
DontWalk:    tya                     ;put contents of Y in A and
             jsr AutoControlPlayer   ;use A to move player to the right or not
             lda ScreenLeft_PageLoc  ;check page location of left side of screen
             cmp DestinationPageLoc  ;against set value here
             beq ExitVWalk           ;branch if equal to change modes if necessary
             lda ScrollFractional
             clc                     ;do fixed point math on fractional part of scroll
             adc #$80
             sta ScrollFractional    ;save fractional movement amount
             lda #$01                ;set 1 pixel per frame
             adc #$00                ;add carry from previous addition
             tay                     ;use as scroll amount
             jsr ScrollScreen        ;do sub to scroll the screen
             jsr UpdScrollVar        ;do another sub to update screen and scroll variables
             inc VictoryWalkControl  ;increment value to stay in this routine
ExitVWalk:   lda VictoryWalkControl  ;load value set here
             beq IncModeTask_A       ;if zero, branch to change modes
             rts                     ;otherwise leave

;-------------------------------------------------------------------------------------

PrintVictoryMessages:
               lda SecondaryMsgCounter   ;load secondary message counter
               bne IncMsgCounter         ;if set, branch to increment message counters
               lda PrimaryMsgCounter     ;otherwise load primary message counter
               beq ThankPlayer           ;if set to zero, branch to print first message
               cmp #$09                  ;if at 9 or above, branch elsewhere (this comparison
               bcs IncMsgCounter         ;is residual code, counter never reaches 9)
               ldy WorldNumber           ;check world number
               cpy #World8
               bne MRetainerMsg          ;if not at world 8, skip to next part
               cmp #$03                  ;check primary message counter again
               bcc IncMsgCounter         ;if not at 3 yet (world 8 only), branch to increment
               sbc #$01                  ;otherwise subtract one
               jmp ThankPlayer           ;and skip to next part
MRetainerMsg:  cmp #$02                  ;check primary message counter
               bcc IncMsgCounter         ;if not at 2 yet (world 1-7 only), branch
ThankPlayer:   tay                       ;put primary message counter into Y
               bne SecondPartMsg         ;if counter nonzero, skip this part, do not print first message
               lda CurrentPlayer         ;otherwise get player currently on the screen
               beq EvalForMusic          ;if mario, branch
               iny                       ;otherwise increment Y once for luigi and
               bne EvalForMusic          ;do an unconditional branch to the same place
SecondPartMsg: iny                       ;increment Y to do world 8's message
               lda WorldNumber
               cmp #World8               ;check world number
               beq EvalForMusic          ;if at world 8, branch to next part
               dey                       ;otherwise decrement Y for world 1-7's message
               cpy #$04                  ;if counter at 4 (world 1-7 only)
               bcs SetEndTimer           ;branch to set victory end timer
               cpy #$03                  ;if counter at 3 (world 1-7 only)
               bcs IncMsgCounter         ;branch to keep counting
EvalForMusic:  cpy #$03                  ;if counter not yet at 3 (world 8 only), branch
               bne PrintMsg              ;to print message only (note world 1-7 will only
               lda #VictoryMusic         ;reach this code if counter = 0, and will always branch)
               sta EventMusicQueue       ;otherwise load victory music first (world 8 only)
PrintMsg:      tya                       ;put primary message counter in A
               clc                       ;add $0c or 12 to counter thus giving an appropriate value,
               adc #$0c                  ;($0c-$0d = first), ($0e = world 1-7's), ($0f-$12 = world 8's)
               sta VRAM_Buffer_AddrCtrl  ;write message counter to vram address controller
IncMsgCounter: lda SecondaryMsgCounter
               clc
               adc #$04                      ;add four to secondary message counter
               sta SecondaryMsgCounter
               lda PrimaryMsgCounter
               adc #$00                      ;add carry to primary message counter
               sta PrimaryMsgCounter
               cmp #$07                      ;check primary counter one more time
SetEndTimer:   bcc ExitMsgs                  ;if not reached value yet, branch to leave
               lda #$06
               sta WorldEndTimer             ;otherwise set world end timer
IncModeTask_A: inc OperMode_Task             ;move onto next task in mode
ExitMsgs:      rts                           ;leave

;-------------------------------------------------------------------------------------

PlayerEndWorld:
               lda WorldEndTimer          ;check to see if world end timer expired
               bne EndExitOne             ;branch to leave if not
               ldy WorldNumber            ;check world number
               cpy #World8                ;if on world 8, player is done with game,
               bcs EndChkBButton          ;thus branch to read controller
               lda #$00
               sta AreaNumber             ;otherwise initialize area number used as offset
               sta LevelNumber            ;and level number control to start at area 1
               sta OperMode_Task          ;initialize secondary mode of operation
               inc WorldNumber            ;increment world number to move onto the next world
               jsr LoadAreaPointer        ;get area address offset for the next area
               inc FetchNewGameTimerFlag  ;set flag to load game timer from header
               lda #GameModeValue
               sta OperMode               ;set mode of operation to game mode
EndExitOne:    rts                        ;and leave
EndChkBButton: lda SavedJoypad1Bits
               ora SavedJoypad2Bits       ;check to see if B button was pressed on
               and #B_Button              ;either controller
               beq EndExitTwo             ;branch to leave if not
               lda #$01                   ;otherwise set world selection flag
               sta WorldSelectEnableFlag
               lda #$ff                   ;remove onscreen player's lives
               sta NumberofLives
               jsr TerminateGame          ;do sub to continue other player or end game
EndExitTwo:    rts                        ;leave

;-------------------------------------------------------------------------------------

;data is used as tiles for numbers
;that appear when you defeat enemies
FloateyNumTileData:
      .db $ff, $ff ;dummy
      .db $f6, $fb ; "100"
      .db $f7, $fb ; "200"
      .db $f8, $fb ; "400"
      .db $f9, $fb ; "500"
      .db $fa, $fb ; "800"
      .db $f6, $50 ; "1000"
      .db $f7, $50 ; "2000"
      .db $f8, $50 ; "4000"
      .db $f9, $50 ; "5000"
      .db $fa, $50 ; "8000"
      .db $fd, $fe ; "1-UP"

;high nybble is digit number, low nybble is number to
;add to the digit of the player's score
ScoreUpdateData:
      .db $ff ;dummy
      .db $41, $42, $44, $45, $48
      .db $31, $32, $34, $35, $38, $00

FloateyNumbersRoutine:
              lda FloateyNum_Control,x     ;load control for floatey number
              beq EndExitOne               ;if zero, branch to leave
              cmp #$0b                     ;if less than $0b, branch
              bcc ChkNumTimer
              lda #$0b                     ;otherwise set to $0b, thus keeping
              sta FloateyNum_Control,x     ;it in range
ChkNumTimer:  tay                          ;use as Y
              lda FloateyNum_Timer,x       ;check value here
              bne DecNumTimer              ;if nonzero, branch ahead
              sta FloateyNum_Control,x     ;initialize floatey number control and leave
              rts
DecNumTimer:  dec FloateyNum_Timer,x       ;decrement value here
              cmp #$2b                     ;if not reached a certain point, branch
              bne ChkTallEnemy
              cpy #$0b                     ;check offset for $0b
              bne LoadNumTiles             ;branch ahead if not found
              inc NumberofLives            ;give player one extra life (1-up)
              lda #Sfx_ExtraLife
              sta Square2SoundQueue        ;and play the 1-up sound
LoadNumTiles: lda ScoreUpdateData,y        ;load point value here
              lsr                          ;move high nybble to low
              lsr
              lsr
              lsr
              tax                          ;use as X offset, essentially the digit
              lda ScoreUpdateData,y        ;load again and this time
              and #%00001111               ;mask out the high nybble
              sta DigitModifier,x          ;store as amount to add to the digit
              jsr AddToScore               ;update the score accordingly
ChkTallEnemy: ldy Enemy_SprDataOffset,x    ;get OAM data offset for enemy object
              lda Enemy_ID,x               ;get enemy object identifier
              cmp #Spiny
              beq FloateyPart              ;branch if spiny
              cmp #PiranhaPlant
              beq FloateyPart              ;branch if piranha plant
              cmp #HammerBro
              beq GetAltOffset             ;branch elsewhere if hammer bro
              cmp #GreyCheepCheep
              beq FloateyPart              ;branch if cheep-cheep of either color
              cmp #RedCheepCheep
              beq FloateyPart
              cmp #TallEnemy
              bcs GetAltOffset             ;branch elsewhere if enemy object => $09
              lda Enemy_State,x
              cmp #$02                     ;if enemy state defeated or otherwise
              bcs FloateyPart              ;$02 or greater, branch beyond this part
GetAltOffset: ldx SprDataOffset_Ctrl       ;load some kind of control bit
              ldy Alt_SprDataOffset,x      ;get alternate OAM data offset
              ldx ObjectOffset             ;get enemy object offset again
FloateyPart:  lda FloateyNum_Y_Pos,x       ;get vertical coordinate for
              cmp #$18                     ;floatey number, if coordinate in the
              bcc SetupNumSpr              ;status bar, branch
              sbc #$01
              sta FloateyNum_Y_Pos,x       ;otherwise subtract one and store as new
SetupNumSpr:  lda FloateyNum_Y_Pos,x       ;get vertical coordinate
              sbc #$08                     ;subtract eight and dump into the
              jsr DumpTwoSpr               ;left and right sprite's Y coordinates
              lda FloateyNum_X_Pos,x       ;get horizontal coordinate
              sta Sprite_X_Position,y      ;store into X coordinate of left sprite
              clc
              adc #$08                     ;add eight pixels and store into X
              sta Sprite_X_Position+4,y    ;coordinate of right sprite
              lda #$02
              sta Sprite_Attributes,y      ;set palette control in attribute bytes
              sta Sprite_Attributes+4,y    ;of left and right sprites
              lda FloateyNum_Control,x
              asl                          ;multiply our floatey number control by 2
              tax                          ;and use as offset for look-up table
              lda FloateyNumTileData,x
              sta Sprite_Tilenumber,y      ;display first half of number of points
              lda FloateyNumTileData+1,x
              sta Sprite_Tilenumber+4,y    ;display the second half
              ldx ObjectOffset             ;get enemy object offset and leave
              rts

;-------------------------------------------------------------------------------------

ScreenRoutines:
      lda ScreenRoutineTask        ;run one of the following subroutines
      jsr JumpEngine

      .dw InitScreen
      .dw SetupIntermediate
      .dw WriteTopStatusLine
      .dw WriteBottomStatusLine
      .dw DisplayTimeUp
      .dw ResetSpritesAndScreenTimer
      .dw DisplayIntermediate
      .dw ResetSpritesAndScreenTimer
      .dw AreaParserTaskControl
      .dw GetAreaPalette
      .dw GetBackgroundColor
      .dw GetAlternatePalette1
      .dw DrawTitleScreen
      .dw ClearBuffersDrawIcon
      .dw WriteTopScore

;-------------------------------------------------------------------------------------

InitScreen:
      jsr MoveAllSpritesOffscreen ;initialize all sprites including sprite #0
      jsr InitializeNameTables    ;and erase both name and attribute tables
      lda OperMode
      beq NextSubtask             ;if mode still 0, do not load
      ldx #$03                    ;into buffer pointer
      jmp SetVRAMAddr_A

;-------------------------------------------------------------------------------------

SetupIntermediate:
      lda BackgroundColorCtrl  ;save current background color control
      pha                      ;and player status to stack
      lda PlayerStatus
      pha
      lda #$00                 ;set background color to black
      sta PlayerStatus         ;and player status to not fiery
      lda #$02                 ;this is the ONLY time background color control
      sta BackgroundColorCtrl  ;is set to less than 4
      jsr GetPlayerColors
      pla                      ;we only execute this routine for
      sta PlayerStatus         ;the intermediate lives display
      pla                      ;and once we're done, we return bg
      sta BackgroundColorCtrl  ;color ctrl and player status from stack
      jmp IncSubtask           ;then move onto the next task

;-------------------------------------------------------------------------------------

AreaPalette:
      .db $01, $02, $03, $04

GetAreaPalette:
               ldy AreaType             ;select appropriate palette to load
               ldx AreaPalette,y        ;based on area type
SetVRAMAddr_A: stx VRAM_Buffer_AddrCtrl ;store offset into buffer control
NextSubtask:   jmp IncSubtask           ;move onto next task

;-------------------------------------------------------------------------------------
;$00 - used as temp counter in GetPlayerColors

BGColorCtrl_Addr:
      .db $00, $09, $0a, $04

BackgroundColors:
      .db $22, $22, $0f, $0f ;used by area type if bg color ctrl not set
      .db $0f, $22, $0f, $0f ;used by background color control if set

PlayerColors:
      .db $22, $16, $27, $18 ;mario's colors
      .db $22, $30, $27, $19 ;luigi's colors
      .db $22, $37, $27, $16 ;fiery (used by both)

GetBackgroundColor:
           ldy BackgroundColorCtrl   ;check background color control
           beq NoBGColor             ;if not set, increment task and fetch palette
           lda BGColorCtrl_Addr-4,y  ;put appropriate palette into vram
           sta VRAM_Buffer_AddrCtrl  ;note that if set to 5-7, $0301 will not be read
NoBGColor: inc ScreenRoutineTask     ;increment to next subtask and plod on through

GetPlayerColors:
               ldx VRAM_Buffer1_Offset  ;get current buffer offset
               ldy #$00
               lda CurrentPlayer        ;check which player is on the screen
               beq ChkFiery
               ldy #$04                 ;load offset for luigi
ChkFiery:      lda PlayerStatus         ;check player status
               cmp #$02
               bne StartClrGet          ;if fiery, load alternate offset for fiery player
               ldy #$08
StartClrGet:   lda #$03                 ;do four colors
               sta $00
ClrGetLoop:    lda PlayerColors,y       ;fetch player colors and store them
               sta VRAM_Buffer1+3,x     ;in the buffer
               iny
               inx
               dec $00
               bpl ClrGetLoop
               ldx VRAM_Buffer1_Offset  ;load original offset from before
               ldy BackgroundColorCtrl  ;if this value is four or greater, it will be set
               bne SetBGColor           ;therefore use it as offset to background color
               ldy AreaType             ;otherwise use area type bits from area offset as offset
SetBGColor:    lda BackgroundColors,y   ;to background color instead
               sta VRAM_Buffer1+3,x
               lda #$3f                 ;set for sprite palette address
               sta VRAM_Buffer1,x       ;save to buffer
               lda #$10
               sta VRAM_Buffer1+1,x
               lda #$04                 ;write length byte to buffer
               sta VRAM_Buffer1+2,x
               lda #$00                 ;now the null terminator
               sta VRAM_Buffer1+7,x
               txa                      ;move the buffer pointer ahead 7 bytes
               clc                      ;in case we want to write anything else later
               adc #$07
SetVRAMOffset: sta VRAM_Buffer1_Offset  ;store as new vram buffer offset
               rts

;-------------------------------------------------------------------------------------

GetAlternatePalette1:
               lda AreaStyle            ;check for mushroom level style
               cmp #$01
               bne NoAltPal
               lda #$0b                 ;if found, load appropriate palette
SetVRAMAddr_B: sta VRAM_Buffer_AddrCtrl
NoAltPal:      jmp IncSubtask           ;now onto the next task

;-------------------------------------------------------------------------------------

WriteTopStatusLine:
      lda #$00          ;select main status bar
      jsr WriteGameText ;output it
      jmp IncSubtask    ;onto the next task

;-------------------------------------------------------------------------------------

WriteBottomStatusLine:
      jsr GetSBNybbles        ;write player's score and coin tally to screen
      ldx VRAM_Buffer1_Offset
      lda #$20                ;write address for world-area number on screen
      sta VRAM_Buffer1,x
      lda #$73
      sta VRAM_Buffer1+1,x
      lda #$03                ;write length for it
      sta VRAM_Buffer1+2,x
      ldy WorldNumber         ;first the world number
      iny
      tya
      sta VRAM_Buffer1+3,x
      lda #$28                ;next the dash
      sta VRAM_Buffer1+4,x
      ldy LevelNumber         ;next the level number
      iny                     ;increment for proper number display
      tya
      sta VRAM_Buffer1+5,x
      lda #$00                ;put null terminator on
      sta VRAM_Buffer1+6,x
      txa                     ;move the buffer offset up by 6 bytes
      clc
      adc #$06
      sta VRAM_Buffer1_Offset
      jmp IncSubtask

;-------------------------------------------------------------------------------------

DisplayTimeUp:
          lda GameTimerExpiredFlag  ;if game timer not expired, increment task
          beq NoTimeUp              ;control 2 tasks forward, otherwise, stay here
          lda #$00
          sta GameTimerExpiredFlag  ;reset timer expiration flag
          lda #$02                  ;output time-up screen to buffer
          jmp OutputInter
NoTimeUp: inc ScreenRoutineTask     ;increment control task 2 tasks forward
          jmp IncSubtask

;-------------------------------------------------------------------------------------

DisplayIntermediate:
               lda OperMode                 ;check primary mode of operation
               beq NoInter                  ;if in title screen mode, skip this
               cmp #GameOverModeValue       ;are we in game over mode?
               beq GameOverInter            ;if so, proceed to display game over screen
               lda AltEntranceControl       ;otherwise check for mode of alternate entry
               bne NoInter                  ;and branch if found
               ldy AreaType                 ;check if we are on castle level
               cpy #$03                     ;and if so, branch (possibly residual)
               beq PlayerInter
               lda DisableIntermediate      ;if this flag is set, skip intermediate lives display
               bne NoInter                  ;and jump to specific task, otherwise
PlayerInter:   jsr DrawPlayer_Intermediate  ;put player in appropriate place for
               lda #$01                     ;lives display, then output lives display to buffer
OutputInter:   jsr WriteGameText
               jsr ResetScreenTimer
               lda #$00
               sta DisableScreenFlag        ;reenable screen output
               rts
GameOverInter: lda #$12                     ;set screen timer
               sta ScreenTimer
               lda #$03                     ;output game over screen to buffer
               jsr WriteGameText
               jmp IncModeTask_B
NoInter:       lda #$08                     ;set for specific task and leave
               sta ScreenRoutineTask
               rts

;-------------------------------------------------------------------------------------

AreaParserTaskControl:
           inc DisableScreenFlag     ;turn off screen
TaskLoop:  jsr AreaParserTaskHandler ;render column set of current area
           lda AreaParserTaskNum     ;check number of tasks
           bne TaskLoop              ;if tasks still not all done, do another one
           dec ColumnSets            ;do we need to render more column sets?
           bpl OutputCol
           inc ScreenRoutineTask     ;if not, move on to the next task
OutputCol: lda #$06                  ;set vram buffer to output rendered column set
           sta VRAM_Buffer_AddrCtrl  ;on next NMI
           rts

;-------------------------------------------------------------------------------------

;$00 - vram buffer address table low
;$01 - vram buffer address table high

DrawTitleScreen:
            lda OperMode                 ;are we in title screen mode?
            bne IncModeTask_B            ;if not, exit
            lda #>TitleScreenDataOffset  ;load address $1ec0 into
            sta PPU_ADDRESS              ;the vram address register
            lda #<TitleScreenDataOffset
            sta PPU_ADDRESS
            lda #$03                     ;put address $0300 into
            sta $01                      ;the indirect at $00
            ldy #$00
            sty $00
            lda PPU_DATA                 ;do one garbage read
OutputTScr: lda PPU_DATA                 ;get title screen from chr-rom
            sta ($00),y                  ;store 256 bytes into buffer
            iny
            bne ChkHiByte                ;if not past 256 bytes, do not increment
            inc $01                      ;otherwise increment high byte of indirect
ChkHiByte:  lda $01                      ;check high byte?
            cmp #$04                     ;at $0400?
            bne OutputTScr               ;if not, loop back and do another
            cpy #$3a                     ;check if offset points past end of data
            bcc OutputTScr               ;if not, loop back and do another
            lda #$05                     ;set buffer transfer control to $0300,
            jmp SetVRAMAddr_B            ;increment task and exit

;-------------------------------------------------------------------------------------

ClearBuffersDrawIcon:
             lda OperMode               ;check game mode
             bne IncModeTask_B          ;if not title screen mode, leave
             ldx #$00                   ;otherwise, clear buffer space
TScrClear:   sta VRAM_Buffer1-1,x
             sta VRAM_Buffer1-1+$100,x
             dex
             bne TScrClear
             jsr DrawMushroomIcon       ;draw player select icon
IncSubtask:  inc ScreenRoutineTask      ;move onto next task
             rts

;-------------------------------------------------------------------------------------

WriteTopScore:
               lda #$fa           ;run display routine to display top score on title
               jsr UpdateNumber
IncModeTask_B: inc OperMode_Task  ;move onto next mode
               rts

;-------------------------------------------------------------------------------------

GameText:
TopStatusBarLine:
  .db $20, $43, $05, $16, $0a, $1b, $12, $18 ; "MARIO"
  .db $20, $52, $0b, $20, $18, $1b, $15, $0d ; "WORLD  TIME"
  .db $24, $24, $1d, $12, $16, $0e
  .db $20, $68, $05, $00, $24, $24, $2e, $29 ; score trailing digit and coin display
  .db $23, $c0, $7f, $aa ; attribute table data, clears name table 0 to palette 2
  .db $23, $c2, $01, $ea ; attribute table data, used for coin icon in status bar
  .db $ff ; end of data block

WorldLivesDisplay:
  .db $21, $cd, $07, $24, $24 ; cross with spaces used on
  .db $29, $24, $24, $24, $24 ; lives display
  .db $21, $4b, $09, $20, $18 ; "WORLD  - " used on lives display
  .db $1b, $15, $0d, $24, $24, $28, $24
  .db $22, $0c, $47, $24 ; possibly used to clear time up
  .db $23, $dc, $01, $ba ; attribute table data for crown if more than 9 lives
  .db $ff

TwoPlayerTimeUp:
  .db $21, $cd, $05, $16, $0a, $1b, $12, $18 ; "MARIO"
OnePlayerTimeUp:
  .db $22, $0c, $07, $1d, $12, $16, $0e, $24, $1e, $19 ; "TIME UP"
  .db $ff

TwoPlayerGameOver:
  .db $21, $cd, $05, $16, $0a, $1b, $12, $18 ; "MARIO"
OnePlayerGameOver:
  .db $22, $0b, $09, $10, $0a, $16, $0e, $24 ; "GAME OVER"
  .db $18, $1f, $0e, $1b
  .db $ff

WarpZoneWelcome:
  .db $25, $84, $15, $20, $0e, $15, $0c, $18, $16 ; "WELCOME TO WARP ZONE!"
  .db $0e, $24, $1d, $18, $24, $20, $0a, $1b, $19
  .db $24, $23, $18, $17, $0e, $2b
  .db $26, $25, $01, $24         ; placeholder for left pipe
  .db $26, $2d, $01, $24         ; placeholder for middle pipe
  .db $26, $35, $01, $24         ; placeholder for right pipe
  .db $27, $d9, $46, $aa         ; attribute data
  .db $27, $e1, $45, $aa
  .db $ff

LuigiName:
  .db $15, $1e, $12, $10, $12    ; "LUIGI", no address or length

WarpZoneNumbers:
  .db $04, $03, $02, $00         ; warp zone numbers, note spaces on middle
  .db $24, $05, $24, $00         ; zone, partly responsible for
  .db $08, $07, $06, $00         ; the minus world

GameTextOffsets:
  .db TopStatusBarLine-GameText, TopStatusBarLine-GameText
  .db WorldLivesDisplay-GameText, WorldLivesDisplay-GameText
  .db TwoPlayerTimeUp-GameText, OnePlayerTimeUp-GameText
  .db TwoPlayerGameOver-GameText, OnePlayerGameOver-GameText
  .db WarpZoneWelcome-GameText, WarpZoneWelcome-GameText

WriteGameText:
               pha                      ;save text number to stack
               asl
               tay                      ;multiply by 2 and use as offset
               cpy #$04                 ;if set to do top status bar or world/lives display,
               bcc LdGameText           ;branch to use current offset as-is
               cpy #$08                 ;if set to do time-up or game over,
               bcc Chk2Players          ;branch to check players
               ldy #$08                 ;otherwise warp zone, therefore set offset
Chk2Players:   lda NumberOfPlayers      ;check for number of players
               bne LdGameText           ;if there are two, use current offset to also print name
               iny                      ;otherwise increment offset by one to not print name
LdGameText:    ldx GameTextOffsets,y    ;get offset to message we want to print
               ldy #$00
GameTextLoop:  lda GameText,x           ;load message data
               cmp #$ff                 ;check for terminator
               beq EndGameText          ;branch to end text if found
               sta VRAM_Buffer1,y       ;otherwise write data to buffer
               inx                      ;and increment increment
               iny
               bne GameTextLoop         ;do this for 256 bytes if no terminator found
EndGameText:   lda #$00                 ;put null terminator at end
               sta VRAM_Buffer1,y
               pla                      ;pull original text number from stack
               tax
               cmp #$04                 ;are we printing warp zone?
               bcs PrintWarpZoneNumbers
               dex                      ;are we printing the world/lives display?
               bne CheckPlayerName      ;if not, branch to check player's name
               lda NumberofLives        ;otherwise, check number of lives
               clc                      ;and increment by one for display
               adc #$01
               cmp #10                  ;more than 9 lives?
               bcc PutLives
               sbc #10                  ;if so, subtract 10 and put a crown tile
               ldy #$9f                 ;next to the difference...strange things happen if
               sty VRAM_Buffer1+7       ;the number of lives exceeds 19
PutLives:      sta VRAM_Buffer1+8
               ldy WorldNumber          ;write world and level numbers (incremented for display)
               iny                      ;to the buffer in the spaces surrounding the dash
               sty VRAM_Buffer1+19
               ldy LevelNumber
               iny
               sty VRAM_Buffer1+21      ;we're done here
               rts

CheckPlayerName:
             lda NumberOfPlayers    ;check number of players
             beq ExitChkName        ;if only 1 player, leave
             lda CurrentPlayer      ;load current player
             dex                    ;check to see if current message number is for time up
             bne ChkLuigi
             ldy OperMode           ;check for game over mode
             cpy #GameOverModeValue
             beq ChkLuigi
             eor #%00000001         ;if not, must be time up, invert d0 to do other player
ChkLuigi:    lsr
             bcc ExitChkName        ;if mario is current player, do not change the name
             ldy #$04
NameLoop:    lda LuigiName,y        ;otherwise, replace "MARIO" with "LUIGI"
             sta VRAM_Buffer1+3,y
             dey
             bpl NameLoop           ;do this until each letter is replaced
ExitChkName: rts

PrintWarpZoneNumbers:
             sbc #$04               ;subtract 4 and then shift to the left
             asl                    ;twice to get proper warp zone number
             asl                    ;offset
             tax
             ldy #$00
WarpNumLoop: lda WarpZoneNumbers,x  ;print warp zone numbers into the
             sta VRAM_Buffer1+27,y  ;placeholders from earlier
             inx
             iny                    ;put a number in every fourth space
             iny
             iny
             iny
             cpy #$0c
             bcc WarpNumLoop
             lda #$2c               ;load new buffer pointer at end of message
             jmp SetVRAMOffset

;-------------------------------------------------------------------------------------

ResetSpritesAndScreenTimer:
         lda ScreenTimer             ;check if screen timer has expired
         bne NoReset                 ;if not, branch to leave
         jsr MoveAllSpritesOffscreen ;otherwise reset sprites now

ResetScreenTimer:
         lda #$07                    ;reset timer again
         sta ScreenTimer
         inc ScreenRoutineTask       ;move onto next task
NoReset: rts

;-------------------------------------------------------------------------------------
;$00 - temp vram buffer offset
;$01 - temp metatile buffer offset
;$02 - temp metatile graphics table offset
;$03 - used to store attribute bits
;$04 - used to determine attribute table row
;$05 - used to determine attribute table column
;$06 - metatile graphics table address low
;$07 - metatile graphics table address high

RenderAreaGraphics:
            lda CurrentColumnPos         ;store LSB of where we're at
            and #$01
            sta $05
            ldy VRAM_Buffer2_Offset      ;store vram buffer offset
            sty $00
            lda CurrentNTAddr_Low        ;get current name table address we're supposed to render
            sta VRAM_Buffer2+1,y
            lda CurrentNTAddr_High
            sta VRAM_Buffer2,y
            lda #$9a                     ;store length byte of 26 here with d7 set
            sta VRAM_Buffer2+2,y         ;to increment by 32 (in columns)
            lda #$00                     ;init attribute row
            sta $04
            tax
DrawMTLoop: stx $01                      ;store init value of 0 or incremented offset for buffer
            lda MetatileBuffer,x         ;get first metatile number, and mask out all but 2 MSB
            and #%11000000
            sta $03                      ;store attribute table bits here
            asl                          ;note that metatile format is:
            rol                          ;%xx000000 - attribute table bits,
            rol                          ;%00xxxxxx - metatile number
            tay                          ;rotate bits to d1-d0 and use as offset here
            lda MetatileGraphics_Low,y   ;get address to graphics table from here
            sta $06
            lda MetatileGraphics_High,y
            sta $07
            lda MetatileBuffer,x         ;get metatile number again
            asl                          ;multiply by 4 and use as tile offset
            asl
            sta $02
            lda AreaParserTaskNum        ;get current task number for level processing and
            and #%00000001               ;mask out all but LSB, then invert LSB, multiply by 2
            eor #%00000001               ;to get the correct column position in the metatile,
            asl                          ;then add to the tile offset so we can draw either side
            adc $02                      ;of the metatiles
            tay
            ldx $00                      ;use vram buffer offset from before as X
            lda ($06),y
            sta VRAM_Buffer2+3,x         ;get first tile number (top left or top right) and store
            iny
            lda ($06),y                  ;now get the second (bottom left or bottom right) and store
            sta VRAM_Buffer2+4,x
            ldy $04                      ;get current attribute row
            lda $05                      ;get LSB of current column where we're at, and
            bne RightCheck               ;branch if set (clear = left attrib, set = right)
            lda $01                      ;get current row we're rendering
            lsr                          ;branch if LSB set (clear = top left, set = bottom left)
            bcs LLeft
            rol $03                      ;rotate attribute bits 3 to the left
            rol $03                      ;thus in d1-d0, for upper left square
            rol $03
            jmp SetAttrib
RightCheck: lda $01                      ;get LSB of current row we're rendering
            lsr                          ;branch if set (clear = top right, set = bottom right)
            bcs NextMTRow
            lsr $03                      ;shift attribute bits 4 to the right
            lsr $03                      ;thus in d3-d2, for upper right square
            lsr $03
            lsr $03
            jmp SetAttrib
LLeft:      lsr $03                      ;shift attribute bits 2 to the right
            lsr $03                      ;thus in d5-d4 for lower left square
NextMTRow:  inc $04                      ;move onto next attribute row
SetAttrib:  lda AttributeBuffer,y        ;get previously saved bits from before
            ora $03                      ;if any, and put new bits, if any, onto
            sta AttributeBuffer,y        ;the old, and store
            inc $00                      ;increment vram buffer offset by 2
            inc $00
            ldx $01                      ;get current gfx buffer row, and check for
            inx                          ;the bottom of the screen
            cpx #$0d
            bcc DrawMTLoop               ;if not there yet, loop back
            ldy $00                      ;get current vram buffer offset, increment by 3
            iny                          ;(for name table address and length bytes)
            iny
            iny
            lda #$00
            sta VRAM_Buffer2,y           ;put null terminator at end of data for name table
            sty VRAM_Buffer2_Offset      ;store new buffer offset
            inc CurrentNTAddr_Low        ;increment name table address low
            lda CurrentNTAddr_Low        ;check current low byte
            and #%00011111               ;if no wraparound, just skip this part
            bne ExitDrawM
            lda #$80                     ;if wraparound occurs, make sure low byte stays
            sta CurrentNTAddr_Low        ;just under the status bar
            lda CurrentNTAddr_High       ;and then invert d2 of the name table address high
            eor #%00000100               ;to move onto the next appropriate name table
            sta CurrentNTAddr_High
ExitDrawM:  jmp SetVRAMCtrl              ;jump to set buffer to $0341 and leave

;-------------------------------------------------------------------------------------
;$00 - temp attribute table address high (big endian order this time!)
;$01 - temp attribute table address low

RenderAttributeTables:
             lda CurrentNTAddr_Low    ;get low byte of next name table address
             and #%00011111           ;to be written to, mask out all but 5 LSB,
             sec                      ;subtract four
             sbc #$04
             and #%00011111           ;mask out bits again and store
             sta $01
             lda CurrentNTAddr_High   ;get high byte and branch if borrow not set
             bcs SetATHigh
             eor #%00000100           ;otherwise invert d2
SetATHigh:   and #%00000100           ;mask out all other bits
             ora #$23                 ;add $2300 to the high byte and store
             sta $00
             lda $01                  ;get low byte - 4, divide by 4, add offset for
             lsr                      ;attribute table and store
             lsr
             adc #$c0                 ;we should now have the appropriate block of
             sta $01                  ;attribute table in our temp address
             ldx #$00
             ldy VRAM_Buffer2_Offset  ;get buffer offset
AttribLoop:  lda $00
             sta VRAM_Buffer2,y       ;store high byte of attribute table address
             lda $01
             clc                      ;get low byte, add 8 because we want to start
             adc #$08                 ;below the status bar, and store
             sta VRAM_Buffer2+1,y
             sta $01                  ;also store in temp again
             lda AttributeBuffer,x    ;fetch current attribute table byte and store
             sta VRAM_Buffer2+3,y     ;in the buffer
             lda #$01
             sta VRAM_Buffer2+2,y     ;store length of 1 in buffer
             lsr
             sta AttributeBuffer,x    ;clear current byte in attribute buffer
             iny                      ;increment buffer offset by 4 bytes
             iny
             iny
             iny
             inx                      ;increment attribute offset and check to see
             cpx #$07                 ;if we're at the end yet
             bcc AttribLoop
             sta VRAM_Buffer2,y       ;put null terminator at the end
             sty VRAM_Buffer2_Offset  ;store offset in case we want to do any more
SetVRAMCtrl: lda #$06
             sta VRAM_Buffer_AddrCtrl ;set buffer to $0341 and leave
             rts

;-------------------------------------------------------------------------------------

;$00 - used as temporary counter in ColorRotation

ColorRotatePalette:
       .db $27, $27, $27, $17, $07, $17

BlankPalette:
       .db $3f, $0c, $04, $ff, $ff, $ff, $ff, $00

;used based on area type
Palette3Data:
       .db $0f, $07, $12, $0f
       .db $0f, $07, $17, $0f
       .db $0f, $07, $17, $1c
       .db $0f, $07, $17, $00

ColorRotation:
              lda FrameCounter         ;get frame counter
              and #$07                 ;mask out all but three LSB
              bne ExitColorRot         ;branch if not set to zero to do this every eighth frame
              ldx VRAM_Buffer1_Offset  ;check vram buffer offset
              cpx #$31
              bcs ExitColorRot         ;if offset over 48 bytes, branch to leave
              tay                      ;otherwise use frame counter's 3 LSB as offset here
GetBlankPal:  lda BlankPalette,y       ;get blank palette for palette 3
              sta VRAM_Buffer1,x       ;store it in the vram buffer
              inx                      ;increment offsets
              iny
              cpy #$08
              bcc GetBlankPal          ;do this until all bytes are copied
              ldx VRAM_Buffer1_Offset  ;get current vram buffer offset
              lda #$03
              sta $00                  ;set counter here
              lda AreaType             ;get area type
              asl                      ;multiply by 4 to get proper offset
              asl
              tay                      ;save as offset here
GetAreaPal:   lda Palette3Data,y       ;fetch palette to be written based on area type
              sta VRAM_Buffer1+3,x     ;store it to overwrite blank palette in vram buffer
              iny
              inx
              dec $00                  ;decrement counter
              bpl GetAreaPal           ;do this until the palette is all copied
              ldx VRAM_Buffer1_Offset  ;get current vram buffer offset
              ldy ColorRotateOffset    ;get color cycling offset
              lda ColorRotatePalette,y
              sta VRAM_Buffer1+4,x     ;get and store current color in second slot of palette
              lda VRAM_Buffer1_Offset
              clc                      ;add seven bytes to vram buffer offset
              adc #$07
              sta VRAM_Buffer1_Offset
              inc ColorRotateOffset    ;increment color cycling offset
              lda ColorRotateOffset
              cmp #$06                 ;check to see if it's still in range
              bcc ExitColorRot         ;if so, branch to leave
              lda #$00
              sta ColorRotateOffset    ;otherwise, init to keep it in range
ExitColorRot: rts                      ;leave

;-------------------------------------------------------------------------------------
;$00 - temp store for offset control bit
;$01 - temp vram buffer offset
;$02 - temp store for vertical high nybble in block buffer routine
;$03 - temp adder for high byte of name table address
;$04, $05 - name table address low/high
;$06, $07 - block buffer address low/high

BlockGfxData:
       .db $45, $45, $47, $47
       .db $47, $47, $47, $47
       .db $57, $58, $59, $5a
       .db $24, $24, $24, $24
       .db $26, $26, $26, $26

RemoveCoin_Axe:
              ldy #$41                 ;set low byte so offset points to $0341
              lda #$03                 ;load offset for default blank metatile
              ldx AreaType             ;check area type
              bne WriteBlankMT         ;if not water type, use offset
              lda #$04                 ;otherwise load offset for blank metatile used in water
WriteBlankMT: jsr PutBlockMetatile     ;do a sub to write blank metatile to vram buffer
              lda #$06
              sta VRAM_Buffer_AddrCtrl ;set vram address controller to $0341 and leave
              rts

ReplaceBlockMetatile:
       jsr WriteBlockMetatile    ;write metatile to vram buffer to replace block object
       inc Block_ResidualCounter ;increment unused counter (residual code)
       dec Block_RepFlag,x       ;decrement flag (residual code)
       rts                       ;leave

DestroyBlockMetatile:
       lda #$00       ;force blank metatile if branched/jumped to this point

WriteBlockMetatile:
             ldy #$03                ;load offset for blank metatile
             cmp #$00                ;check contents of A for blank metatile
             beq UseBOffset          ;branch if found (unconditional if branched from 8a6b)
             ldy #$00                ;load offset for brick metatile w/ line
             cmp #$58
             beq UseBOffset          ;use offset if metatile is brick with coins (w/ line)
             cmp #$51
             beq UseBOffset          ;use offset if metatile is breakable brick w/ line
             iny                     ;increment offset for brick metatile w/o line
             cmp #$5d
             beq UseBOffset          ;use offset if metatile is brick with coins (w/o line)
             cmp #$52
             beq UseBOffset          ;use offset if metatile is breakable brick w/o line
             iny                     ;if any other metatile, increment offset for empty block
UseBOffset:  tya                     ;put Y in A
             ldy VRAM_Buffer1_Offset ;get vram buffer offset
             iny                     ;move onto next byte
             jsr PutBlockMetatile    ;get appropriate block data and write to vram buffer
MoveVOffset: dey                     ;decrement vram buffer offset
             tya                     ;add 10 bytes to it
             clc
             adc #10
             jmp SetVRAMOffset       ;branch to store as new vram buffer offset

PutBlockMetatile:
            stx $00               ;store control bit from SprDataOffset_Ctrl
            sty $01               ;store vram buffer offset for next byte
            asl
            asl                   ;multiply A by four and use as X
            tax
            ldy #$20              ;load high byte for name table 0
            lda $06               ;get low byte of block buffer pointer
            cmp #$d0              ;check to see if we're on odd-page block buffer
            bcc SaveHAdder        ;if not, use current high byte
            ldy #$24              ;otherwise load high byte for name table 1
SaveHAdder: sty $03               ;save high byte here
            and #$0f              ;mask out high nybble of block buffer pointer
            asl                   ;multiply by 2 to get appropriate name table low byte
            sta $04               ;and then store it here
            lda #$00
            sta $05               ;initialize temp high byte
            lda $02               ;get vertical high nybble offset used in block buffer routine
            clc
            adc #$20              ;add 32 pixels for the status bar
            asl
            rol $05               ;shift and rotate d7 onto d0 and d6 into carry
            asl
            rol $05               ;shift and rotate d6 onto d0 and d5 into carry
            adc $04               ;add low byte of name table and carry to vertical high nybble
            sta $04               ;and store here
            lda $05               ;get whatever was in d7 and d6 of vertical high nybble
            adc #$00              ;add carry
            clc
            adc $03               ;then add high byte of name table
            sta $05               ;store here
            ldy $01               ;get vram buffer offset to be used
RemBridge:  lda BlockGfxData,x    ;write top left and top right
            sta VRAM_Buffer1+2,y  ;tile numbers into first spot
            lda BlockGfxData+1,x
            sta VRAM_Buffer1+3,y
            lda BlockGfxData+2,x  ;write bottom left and bottom
            sta VRAM_Buffer1+7,y  ;right tiles numbers into
            lda BlockGfxData+3,x  ;second spot
            sta VRAM_Buffer1+8,y
            lda $04
            sta VRAM_Buffer1,y    ;write low byte of name table
            clc                   ;into first slot as read
            adc #$20              ;add 32 bytes to value
            sta VRAM_Buffer1+5,y  ;write low byte of name table
            lda $05               ;plus 32 bytes into second slot
            sta VRAM_Buffer1-1,y  ;write high byte of name
            sta VRAM_Buffer1+4,y  ;table address to both slots
            lda #$02
            sta VRAM_Buffer1+1,y  ;put length of 2 in
            sta VRAM_Buffer1+6,y  ;both slots
            lda #$00
            sta VRAM_Buffer1+9,y  ;put null terminator at end
            ldx $00               ;get offset control bit here
            rts                   ;and leave

;-------------------------------------------------------------------------------------
;METATILE GRAPHICS TABLE

MetatileGraphics_Low:
  .db <Palette0_MTiles, <Palette1_MTiles, <Palette2_MTiles, <Palette3_MTiles

MetatileGraphics_High:
  .db >Palette0_MTiles, >Palette1_MTiles, >Palette2_MTiles, >Palette3_MTiles

Palette0_MTiles:
  .db $24, $24, $24, $24 ;blank
  .db $27, $27, $27, $27 ;black metatile
  .db $24, $24, $24, $35 ;bush left
  .db $36, $25, $37, $25 ;bush middle
  .db $24, $38, $24, $24 ;bush right
  .db $24, $30, $30, $26 ;mountain left
  .db $26, $26, $34, $26 ;mountain left bottom/middle center
  .db $24, $31, $24, $32 ;mountain middle top
  .db $33, $26, $24, $33 ;mountain right
  .db $34, $26, $26, $26 ;mountain right bottom
  .db $26, $26, $26, $26 ;mountain middle bottom
  .db $24, $c0, $24, $c0 ;bridge guardrail
  .db $24, $7f, $7f, $24 ;chain
  .db $b8, $ba, $b9, $bb ;tall tree top, top half
  .db $b8, $bc, $b9, $bd ;short tree top
  .db $ba, $bc, $bb, $bd ;tall tree top, bottom half
  .db $60, $64, $61, $65 ;warp pipe end left, points up
  .db $62, $66, $63, $67 ;warp pipe end right, points up
  .db $60, $64, $61, $65 ;decoration pipe end left, points up
  .db $62, $66, $63, $67 ;decoration pipe end right, points up
  .db $68, $68, $69, $69 ;pipe shaft left
  .db $26, $26, $6a, $6a ;pipe shaft right
  .db $4b, $4c, $4d, $4e ;tree ledge left edge
  .db $4d, $4f, $4d, $4f ;tree ledge middle
  .db $4d, $4e, $50, $51 ;tree ledge right edge
  .db $6b, $70, $2c, $2d ;mushroom left edge
  .db $6c, $71, $6d, $72 ;mushroom middle
  .db $6e, $73, $6f, $74 ;mushroom right edge
  .db $86, $8a, $87, $8b ;sideways pipe end top
  .db $88, $8c, $88, $8c ;sideways pipe shaft top
  .db $89, $8d, $69, $69 ;sideways pipe joint top
  .db $8e, $91, $8f, $92 ;sideways pipe end bottom
  .db $26, $93, $26, $93 ;sideways pipe shaft bottom
  .db $90, $94, $69, $69 ;sideways pipe joint bottom
  .db $a4, $e9, $ea, $eb ;seaplant
  .db $24, $24, $24, $24 ;blank, used on bricks or blocks that are hit
  .db $24, $2f, $24, $3d ;flagpole ball
  .db $a2, $a2, $a3, $a3 ;flagpole shaft
  .db $24, $24, $24, $24 ;blank, used in conjunction with vines

Palette1_MTiles:
  .db $a2, $a2, $a3, $a3 ;vertical rope
  .db $99, $24, $99, $24 ;horizontal rope
  .db $24, $a2, $3e, $3f ;left pulley
  .db $5b, $5c, $24, $a3 ;right pulley
  .db $24, $24, $24, $24 ;blank used for balance rope
  .db $9d, $47, $9e, $47 ;castle top
  .db $47, $47, $27, $27 ;castle window left
  .db $47, $47, $47, $47 ;castle brick wall
  .db $27, $27, $47, $47 ;castle window right
  .db $a9, $47, $aa, $47 ;castle top w/ brick
  .db $9b, $27, $9c, $27 ;entrance top
  .db $27, $27, $27, $27 ;entrance bottom
  .db $52, $52, $52, $52 ;green ledge stump
  .db $80, $a0, $81, $a1 ;fence
  .db $be, $be, $bf, $bf ;tree trunk
  .db $75, $ba, $76, $bb ;mushroom stump top
  .db $ba, $ba, $bb, $bb ;mushroom stump bottom
  .db $45, $47, $45, $47 ;breakable brick w/ line
  .db $47, $47, $47, $47 ;breakable brick
  .db $45, $47, $45, $47 ;breakable brick (not used)
  .db $b4, $b6, $b5, $b7 ;cracked rock terrain
  .db $45, $47, $45, $47 ;brick with line (power-up)
  .db $45, $47, $45, $47 ;brick with line (vine)
  .db $45, $47, $45, $47 ;brick with line (star)
  .db $45, $47, $45, $47 ;brick with line (coins)
  .db $45, $47, $45, $47 ;brick with line (1-up)
  .db $47, $47, $47, $47 ;brick (power-up)
  .db $47, $47, $47, $47 ;brick (vine)
  .db $47, $47, $47, $47 ;brick (star)
  .db $47, $47, $47, $47 ;brick (coins)
  .db $47, $47, $47, $47 ;brick (1-up)
  .db $24, $24, $24, $24 ;hidden block (1 coin)
  .db $24, $24, $24, $24 ;hidden block (1-up)
  .db $ab, $ac, $ad, $ae ;solid block (3-d block)
  .db $5d, $5e, $5d, $5e ;solid block (white wall)
  .db $c1, $24, $c1, $24 ;bridge
  .db $c6, $c8, $c7, $c9 ;bullet bill cannon barrel
  .db $ca, $cc, $cb, $cd ;bullet bill cannon top
  .db $2a, $2a, $40, $40 ;bullet bill cannon bottom
  .db $24, $24, $24, $24 ;blank used for jumpspring
  .db $24, $47, $24, $47 ;half brick used for jumpspring
  .db $82, $83, $84, $85 ;solid block (water level, green rock)
  .db $24, $47, $24, $47 ;half brick (???)
  .db $86, $8a, $87, $8b ;water pipe top
  .db $8e, $91, $8f, $92 ;water pipe bottom
  .db $24, $2f, $24, $3d ;flag ball (residual object)

Palette2_MTiles:
  .db $24, $24, $24, $35 ;cloud left
  .db $36, $25, $37, $25 ;cloud middle
  .db $24, $38, $24, $24 ;cloud right
  .db $24, $24, $39, $24 ;cloud bottom left
  .db $3a, $24, $3b, $24 ;cloud bottom middle
  .db $3c, $24, $24, $24 ;cloud bottom right
  .db $41, $26, $41, $26 ;water/lava top
  .db $26, $26, $26, $26 ;water/lava
  .db $b0, $b1, $b2, $b3 ;cloud level terrain
  .db $77, $79, $77, $79 ;bowser's bridge

Palette3_MTiles:
  .db $53, $55, $54, $56 ;question block (coin)
  .db $53, $55, $54, $56 ;question block (power-up)
  .db $a5, $a7, $a6, $a8 ;coin
  .db $c2, $c4, $c3, $c5 ;underwater coin
  .db $57, $59, $58, $5a ;empty block
  .db $7b, $7d, $7c, $7e ;axe

;-------------------------------------------------------------------------------------
;VRAM BUFFER DATA FOR LOCATIONS IN PRG-ROM

WaterPaletteData:
  .db $3f, $00, $20
  .db $0f, $15, $12, $25
  .db $0f, $3a, $1a, $0f
  .db $0f, $30, $12, $0f
  .db $0f, $27, $12, $0f
  .db $22, $16, $27, $18
  .db $0f, $10, $30, $27
  .db $0f, $16, $30, $27
  .db $0f, $0f, $30, $10
  .db $00

GroundPaletteData:
  .db $3f, $00, $20
  .db $0f, $29, $1a, $0f
  .db $0f, $36, $17, $0f
  .db $0f, $30, $21, $0f
  .db $0f, $27, $17, $0f
  .db $0f, $16, $27, $18
  .db $0f, $1a, $30, $27
  .db $0f, $16, $30, $27
  .db $0f, $0f, $36, $17
  .db $00

UndergroundPaletteData:
  .db $3f, $00, $20
  .db $0f, $29, $1a, $09
  .db $0f, $3c, $1c, $0f
  .db $0f, $30, $21, $1c
  .db $0f, $27, $17, $1c
  .db $0f, $16, $27, $18
  .db $0f, $1c, $36, $17
  .db $0f, $16, $30, $27
  .db $0f, $0c, $3c, $1c
  .db $00

CastlePaletteData:
  .db $3f, $00, $20
  .db $0f, $30, $10, $00
  .db $0f, $30, $10, $00
  .db $0f, $30, $16, $00
  .db $0f, $27, $17, $00
  .db $0f, $16, $27, $18
  .db $0f, $1c, $36, $17
  .db $0f, $16, $30, $27
  .db $0f, $00, $30, $10
  .db $00

DaySnowPaletteData:
  .db $3f, $00, $04
  .db $22, $30, $00, $10
  .db $00

NightSnowPaletteData:
  .db $3f, $00, $04
  .db $0f, $30, $00, $10
  .db $00

MushroomPaletteData:
  .db $3f, $00, $04
  .db $22, $27, $16, $0f
  .db $00

BowserPaletteData:
  .db $3f, $14, $04
  .db $0f, $1a, $30, $27
  .db $00

MarioThanksMessage:
;"THANK YOU MARIO!"
  .db $25, $48, $10
  .db $1d, $11, $0a, $17, $14, $24
  .db $22, $18, $1e, $24
  .db $16, $0a, $1b, $12, $18, $2b
  .db $00

LuigiThanksMessage:
;"THANK YOU LUIGI!"
  .db $25, $48, $10
  .db $1d, $11, $0a, $17, $14, $24
  .db $22, $18, $1e, $24
  .db $15, $1e, $12, $10, $12, $2b
  .db $00

MushroomRetainerSaved:
;"BUT OUR PRINCESS IS IN"
  .db $25, $c5, $16
  .db $0b, $1e, $1d, $24, $18, $1e, $1b, $24
  .db $19, $1b, $12, $17, $0c, $0e, $1c, $1c, $24
  .db $12, $1c, $24, $12, $17
;"ANOTHER CASTLE!"
  .db $26, $05, $0f
  .db $0a, $17, $18, $1d, $11, $0e, $1b, $24
  .db $0c, $0a, $1c, $1d, $15, $0e, $2b, $00

PrincessSaved1:
;"YOUR QUEST IS OVER."
  .db $25, $a7, $13
  .db $22, $18, $1e, $1b, $24
  .db $1a, $1e, $0e, $1c, $1d, $24
  .db $12, $1c, $24, $18, $1f, $0e, $1b, $af
  .db $00

PrincessSaved2:
;"WE PRESENT YOU A NEW QUEST."
  .db $25, $e3, $1b
  .db $20, $0e, $24
  .db $19, $1b, $0e, $1c, $0e, $17, $1d, $24
  .db $22, $18, $1e, $24, $0a, $24, $17, $0e, $20, $24
  .db $1a, $1e, $0e, $1c, $1d, $af
  .db $00

WorldSelectMessage1:
;"PUSH BUTTON B"
  .db $26, $4a, $0d
  .db $19, $1e, $1c, $11, $24
  .db $0b, $1e, $1d, $1d, $18, $17, $24, $0b
  .db $00

WorldSelectMessage2:
;"TO SELECT A WORLD"
  .db $26, $88, $11
  .db $1d, $18, $24, $1c, $0e, $15, $0e, $0c, $1d, $24
  .db $0a, $24, $20, $18, $1b, $15, $0d
  .db $00

;-------------------------------------------------------------------------------------
;$04 - address low to jump address
;$05 - address high to jump address
;$06 - jump address low
;$07 - jump address high

JumpEngine:
       asl          ;shift bit from contents of A
       tay
       pla          ;pull saved return address from stack
       sta $04      ;save to indirect
       pla
       sta $05
       iny
       lda ($04),y  ;load pointer from indirect
       sta $06      ;note that if an RTS is performed in next routine
       iny          ;it will return to the execution before the sub
       lda ($04),y  ;that called this routine
       sta $07
       jmp ($06)    ;jump to the address we loaded

;-------------------------------------------------------------------------------------

InitializeNameTables:
              lda PPU_STATUS            ;reset flip-flop
              lda Mirror_PPU_CTRL_REG1  ;load mirror of ppu reg $2000
              ora #%00010000            ;set sprites for first 4k and background for second 4k
              and #%11110000            ;clear rest of lower nybble, leave higher alone
              jsr WritePPUReg1
              lda #$24                  ;set vram address to start of name table 1
              jsr WriteNTAddr
              lda #$20                  ;and then set it to name table 0
WriteNTAddr:  sta PPU_ADDRESS
              lda #$00
              sta PPU_ADDRESS
              ldx #$04                  ;clear name table with blank tile #24
              ldy #$c0
              lda #$24
InitNTLoop:   sta PPU_DATA              ;count out exactly 768 tiles
              dey
              bne InitNTLoop
              dex
              bne InitNTLoop
              ldy #64                   ;now to clear the attribute table (with zero this time)
              txa
              sta VRAM_Buffer1_Offset   ;init vram buffer 1 offset
              sta VRAM_Buffer1          ;init vram buffer 1
InitATLoop:   sta PPU_DATA
              dey
              bne InitATLoop
              sta HorizontalScroll      ;reset scroll variables
              sta VerticalScroll
              jmp InitScroll            ;initialize scroll registers to zero

;-------------------------------------------------------------------------------------
;$00 - temp joypad bit

ReadJoypads:
              lda #$01               ;reset and clear strobe of joypad ports
              sta JOYPAD_PORT
              lsr
              tax                    ;start with joypad 1's port
              sta JOYPAD_PORT
              jsr ReadPortBits
              inx                    ;increment for joypad 2's port
ReadPortBits: ldy #$08
PortLoop:     pha                    ;push previous bit onto stack
              lda JOYPAD_PORT,x      ;read current bit on joypad port
              sta $00                ;check d1 and d0 of port output
              lsr                    ;this is necessary on the old
              ora $00                ;famicom systems in japan
              lsr
              pla                    ;read bits from stack
              rol                    ;rotate bit from carry flag
              dey
              bne PortLoop           ;count down bits left
              sta SavedJoypadBits,x  ;save controller status here always
              pha
              and #%00110000         ;check for select or start
              and JoypadBitMask,x    ;if neither saved state nor current state
              beq Save8Bits          ;have any of these two set, branch
              pla
              and #%11001111         ;otherwise store without select
              sta SavedJoypadBits,x  ;or start bits and leave
              rts
Save8Bits:    pla
              sta JoypadBitMask,x    ;save with all bits in another place and leave
              rts

;-------------------------------------------------------------------------------------
;$00 - vram buffer address table low
;$01 - vram buffer address table high

WriteBufferToScreen:
               sta PPU_ADDRESS           ;store high byte of vram address
               iny
               lda ($00),y               ;load next byte (second)
               sta PPU_ADDRESS           ;store low byte of vram address
               iny
               lda ($00),y               ;load next byte (third)
               asl                       ;shift to left and save in stack
               pha
               lda Mirror_PPU_CTRL_REG1  ;load mirror of $2000,
               ora #%00000100            ;set ppu to increment by 32 by default
               bcs SetupWrites           ;if d7 of third byte was clear, ppu will
               and #%11111011            ;only increment by 1
SetupWrites:   jsr WritePPUReg1          ;write to register
               pla                       ;pull from stack and shift to left again
               asl
               bcc GetLength             ;if d6 of third byte was clear, do not repeat byte
               ora #%00000010            ;otherwise set d1 and increment Y
               iny
GetLength:     lsr                       ;shift back to the right to get proper length
               lsr                       ;note that d1 will now be in carry
               tax
OutputToVRAM:  bcs RepeatByte            ;if carry set, repeat loading the same byte
               iny                       ;otherwise increment Y to load next byte
RepeatByte:    lda ($00),y               ;load more data from buffer and write to vram
               sta PPU_DATA
               dex                       ;done writing?
               bne OutputToVRAM
               sec
               tya
               adc $00                   ;add end length plus one to the indirect at $00
               sta $00                   ;to allow this routine to read another set of updates
               lda #$00
               adc $01
               sta $01
               lda #$3f                  ;sets vram address to $3f00
               sta PPU_ADDRESS
               lda #$00
               sta PPU_ADDRESS
               sta PPU_ADDRESS           ;then reinitializes it for some reason
               sta PPU_ADDRESS
UpdateScreen:  ldx PPU_STATUS            ;reset flip-flop
               ldy #$00                  ;load first byte from indirect as a pointer
               lda ($00),y
               bne WriteBufferToScreen   ;if byte is zero we have no further updates to make here
InitScroll:    sta PPU_SCROLL_REG        ;store contents of A into scroll registers
               sta PPU_SCROLL_REG        ;and end whatever subroutine led us here
               rts

;-------------------------------------------------------------------------------------

WritePPUReg1:
               sta PPU_CTRL_REG1         ;write contents of A to PPU register 1
               sta Mirror_PPU_CTRL_REG1  ;and its mirror
               rts

;-------------------------------------------------------------------------------------
;$00 - used to store status bar nybbles
;$02 - used as temp vram offset
;$03 - used to store length of status bar number

;status bar name table offset and length data
StatusBarData:
      .db $f0, $06 ; top score display on title screen
      .db $62, $06 ; player score
      .db $62, $06
      .db $6d, $02 ; coin tally
      .db $6d, $02
      .db $7a, $03 ; game timer

StatusBarOffset:
      .db $06, $0c, $12, $18, $1e, $24

PrintStatusBarNumbers:
      sta $00            ;store player-specific offset
      jsr OutputNumbers  ;use first nybble to print the coin display
      lda $00            ;move high nybble to low
      lsr                ;and print to score display
      lsr
      lsr
      lsr

OutputNumbers:
             clc                      ;add 1 to low nybble
             adc #$01
             and #%00001111           ;mask out high nybble
             cmp #$06
             bcs ExitOutputN
             pha                      ;save incremented value to stack for now and
             asl                      ;shift to left and use as offset
             tay
             ldx VRAM_Buffer1_Offset  ;get current buffer pointer
             lda #$20                 ;put at top of screen by default
             cpy #$00                 ;are we writing top score on title screen?
             bne SetupNums
             lda #$22                 ;if so, put further down on the screen
SetupNums:   sta VRAM_Buffer1,x
             lda StatusBarData,y      ;write low vram address and length of thing
             sta VRAM_Buffer1+1,x     ;we're printing to the buffer
             lda StatusBarData+1,y
             sta VRAM_Buffer1+2,x
             sta $03                  ;save length byte in counter
             stx $02                  ;and buffer pointer elsewhere for now
             pla                      ;pull original incremented value from stack
             tax
             lda StatusBarOffset,x    ;load offset to value we want to write
             sec
             sbc StatusBarData+1,y    ;subtract from length byte we read before
             tay                      ;use value as offset to display digits
             ldx $02
DigitPLoop:  lda DisplayDigits,y      ;write digits to the buffer
             sta VRAM_Buffer1+3,x
             inx
             iny
             dec $03                  ;do this until all the digits are written
             bne DigitPLoop
             lda #$00                 ;put null terminator at end
             sta VRAM_Buffer1+3,x
             inx                      ;increment buffer pointer by 3
             inx
             inx
             stx VRAM_Buffer1_Offset  ;store it in case we want to use it again
ExitOutputN: rts

;-------------------------------------------------------------------------------------

DigitsMathRoutine:
            lda OperMode              ;check mode of operation
            cmp #TitleScreenModeValue
            beq EraseDMods            ;if in title screen mode, branch to lock score
            ldx #$05
AddModLoop: lda DigitModifier,x       ;load digit amount to increment
            clc
            adc DisplayDigits,y       ;add to current digit
            bmi BorrowOne             ;if result is a negative number, branch to subtract
            cmp #10
            bcs CarryOne              ;if digit greater than $09, branch to add
StoreNewD:  sta DisplayDigits,y       ;store as new score or game timer digit
            dey                       ;move onto next digits in score or game timer
            dex                       ;and digit amounts to increment
            bpl AddModLoop            ;loop back if we're not done yet
EraseDMods: lda #$00                  ;store zero here
            ldx #$06                  ;start with the last digit
EraseMLoop: sta DigitModifier-1,x     ;initialize the digit amounts to increment
            dex
            bpl EraseMLoop            ;do this until they're all reset, then leave
            rts
BorrowOne:  dec DigitModifier-1,x     ;decrement the previous digit, then put $09 in
            lda #$09                  ;the game timer digit we're currently on to "borrow
            bne StoreNewD             ;the one", then do an unconditional branch back
CarryOne:   sec                       ;subtract ten from our digit to make it a
            sbc #10                   ;proper BCD number, then increment the digit
            inc DigitModifier-1,x     ;preceding current digit to "carry the one" properly
            jmp StoreNewD             ;go back to just after we branched here

;-------------------------------------------------------------------------------------

UpdateTopScore:
      ldx #$05          ;start with mario's score
      jsr TopScoreCheck
      ldx #$0b          ;now do luigi's score

TopScoreCheck:
              ldy #$05                 ;start with the lowest digit
              sec
GetScoreDiff: lda PlayerScoreDisplay,x ;subtract each player digit from each high score digit
              sbc TopScoreDisplay,y    ;from lowest to highest, if any top score digit exceeds
              dex                      ;any player digit, borrow will be set until a subsequent
              dey                      ;subtraction clears it (player digit is higher than top)
              bpl GetScoreDiff
              bcc NoTopSc              ;check to see if borrow is still set, if so, no new high score
              inx                      ;increment X and Y once to the start of the score
              iny
CopyScore:    lda PlayerScoreDisplay,x ;store player's score digits into high score memory area
              sta TopScoreDisplay,y
              inx
              iny
              cpy #$06                 ;do this until we have stored them all
              bcc CopyScore
NoTopSc:      rts

;-------------------------------------------------------------------------------------

DefaultSprOffsets:
      .db $04, $30, $48, $60, $78, $90, $a8, $c0
      .db $d8, $e8, $24, $f8, $fc, $28, $2c

Sprite0Data:
      .db $18, $ff, $23, $58

;-------------------------------------------------------------------------------------

InitializeGame:
             ldy #$6f              ;clear all memory as in initialization procedure,
             jsr InitializeMemory  ;but this time, clear only as far as $076f
             ldy #$1f
ClrSndLoop:  sta SoundMemory,y     ;clear out memory used
             dey                   ;by the sound engines
             bpl ClrSndLoop
             lda #$18              ;set demo timer
             sta DemoTimer
             jsr LoadAreaPointer

InitializeArea:
               ldy #$4b                 ;clear all memory again, only as far as $074b
               jsr InitializeMemory     ;this is only necessary if branching from
               ldx #$21
               lda #$00
ClrTimersLoop: sta Timers,x             ;clear out memory between
               dex                      ;$0780 and $07a1
               bpl ClrTimersLoop
               lda HalfwayPage
               ldy AltEntranceControl   ;if AltEntranceControl not set, use halfway page, if any found
               beq StartPage
               lda EntrancePage         ;otherwise use saved entry page number here
StartPage:     sta ScreenLeft_PageLoc   ;set as value here
               sta CurrentPageLoc       ;also set as current page
               sta BackloadingFlag      ;set flag here if halfway page or saved entry page number found
               jsr GetScreenPosition    ;get pixel coordinates for screen borders
               ldy #$20                 ;if on odd numbered page, use $2480 as start of rendering
               and #%00000001           ;otherwise use $2080, this address used later as name table
               beq SetInitNTHigh        ;address for rendering of game area
               ldy #$24
SetInitNTHigh: sty CurrentNTAddr_High   ;store name table address
               ldy #$80
               sty CurrentNTAddr_Low
               asl                      ;store LSB of page number in high nybble
               asl                      ;of block buffer column position
               asl
               asl
               sta BlockBufferColumnPos
               dec AreaObjectLength     ;set area object lengths for all empty
               dec AreaObjectLength+1
               dec AreaObjectLength+2
               lda #$0b                 ;set value for renderer to update 12 column sets
               sta ColumnSets           ;12 column sets = 24 metatile columns = 1 1/2 screens
               jsr GetAreaDataAddrs     ;get enemy and level addresses and load header
               lda PrimaryHardMode      ;check to see if primary hard mode has been activated
               bne SetSecHard           ;if so, activate the secondary no matter where we're at
               lda WorldNumber          ;otherwise check world number
               cmp #World5              ;if less than 5, do not activate secondary
               bcc CheckHalfway
               bne SetSecHard           ;if not equal to, then world > 5, thus activate
               lda LevelNumber          ;otherwise, world 5, so check level number
               cmp #Level3              ;if 1 or 2, do not set secondary hard mode flag
               bcc CheckHalfway
SetSecHard:    inc SecondaryHardMode    ;set secondary hard mode flag for areas 5-3 and beyond
CheckHalfway:  lda HalfwayPage
               beq DoneInitArea
               lda #$02                 ;if halfway page set, overwrite start position from header
               sta PlayerEntranceCtrl
DoneInitArea:  lda #Silence             ;silence music
               sta AreaMusicQueue
               lda #$01                 ;disable screen output
               sta DisableScreenFlag
               inc OperMode_Task        ;increment one of the modes
               rts

;-------------------------------------------------------------------------------------

PrimaryGameSetup:
      lda #$01
      sta FetchNewGameTimerFlag   ;set flag to load game timer from header
      sta PlayerSize              ;set player's size to small
      lda #$02
      sta NumberofLives           ;give each player three lives
      sta OffScr_NumberofLives

SecondaryGameSetup:
             lda #$00
             sta DisableScreenFlag     ;enable screen output
             tay
ClearVRLoop: sta VRAM_Buffer1-1,y      ;clear buffer at $0300-$03ff
             iny
             bne ClearVRLoop
             sta GameTimerExpiredFlag  ;clear game timer exp flag
             sta DisableIntermediate   ;clear skip lives display flag
             sta BackloadingFlag       ;clear value here
             lda #$ff
             sta BalPlatformAlignment  ;initialize balance platform assignment flag
             lda ScreenLeft_PageLoc    ;get left side page location
             lsr Mirror_PPU_CTRL_REG1  ;shift LSB of ppu register #1 mirror out
             and #$01                  ;mask out all but LSB of page location
             ror                       ;rotate LSB of page location into carry then onto mirror
             rol Mirror_PPU_CTRL_REG1  ;this is to set the proper PPU name table
             jsr GetAreaMusic          ;load proper music into queue
             lda #$38                  ;load sprite shuffle amounts to be used later
             sta SprShuffleAmt+2
             lda #$48
             sta SprShuffleAmt+1
             lda #$58
             sta SprShuffleAmt
             ldx #$0e                  ;load default OAM offsets into $06e4-$06f2
ShufAmtLoop: lda DefaultSprOffsets,x
             sta SprDataOffset,x
             dex                       ;do this until they're all set
             bpl ShufAmtLoop
             ldy #$03                  ;set up sprite #0
ISpr0Loop:   lda Sprite0Data,y
             sta Sprite_Data,y
             dey
             bpl ISpr0Loop
             jsr DoNothing2            ;these jsrs doesn't do anything useful
             jsr DoNothing1
             inc Sprite0HitDetectFlag  ;set sprite #0 check flag
             inc OperMode_Task         ;increment to next task
             rts

;-------------------------------------------------------------------------------------

;$06 - RAM address low
;$07 - RAM address high

InitializeMemory:
              ldx #$07          ;set initial high byte to $0700-$07ff
              lda #$00          ;set initial low byte to start of page (at $00 of page)
              sta $06
InitPageLoop: stx $07
InitByteLoop: cpx #$01          ;check to see if we're on the stack ($0100-$01ff)
              bne InitByte      ;if not, go ahead anyway
              cpy #$60          ;otherwise, check to see if we're at $0160-$01ff
              bcs SkipByte      ;if so, skip write
InitByte:     sta ($06),y       ;otherwise, initialize byte with current low byte in Y
SkipByte:     dey
              cpy #$ff          ;do this until all bytes in page have been erased
              bne InitByteLoop
              dex               ;go onto the next page
              bpl InitPageLoop  ;do this until all pages of memory have been erased
              rts

;-------------------------------------------------------------------------------------

MusicSelectData:
      .db WaterMusic, GroundMusic, UndergroundMusic, CastleMusic
      .db CloudMusic, PipeIntroMusic

GetAreaMusic:
             lda OperMode           ;if in title screen mode, leave
             beq ExitGetM
             lda AltEntranceControl ;check for specific alternate mode of entry
             cmp #$02               ;if found, branch without checking starting position
             beq ChkAreaType        ;from area object data header
             ldy #$05               ;select music for pipe intro scene by default
             lda PlayerEntranceCtrl ;check value from level header for certain values
             cmp #$06
             beq StoreMusic         ;load music for pipe intro scene if header
             cmp #$07               ;start position either value $06 or $07
             beq StoreMusic
ChkAreaType: ldy AreaType           ;load area type as offset for music bit
             lda CloudTypeOverride
             beq StoreMusic         ;check for cloud type override
             ldy #$04               ;select music for cloud type level if found
StoreMusic:  lda MusicSelectData,y  ;otherwise select appropriate music for level type
             sta AreaMusicQueue     ;store in queue and leave
ExitGetM:    rts

;-------------------------------------------------------------------------------------

PlayerStarting_X_Pos:
      .db $28, $18
      .db $38, $28

AltYPosOffset:
      .db $08, $00

PlayerStarting_Y_Pos:
      .db $00, $20, $b0, $50, $00, $00, $b0, $b0
      .db $f0

PlayerBGPriorityData:
      .db $00, $20, $00, $00, $00, $00, $00, $00

GameTimerData:
      .db $20 ;dummy byte, used as part of bg priority data
      .db $04, $03, $02

Entrance_GameTimerSetup:
          lda ScreenLeft_PageLoc      ;set current page for area objects
          sta Player_PageLoc          ;as page location for player
          lda #$28                    ;store value here
          sta VerticalForceDown       ;for fractional movement downwards if necessary
          lda #$01                    ;set high byte of player position and
          sta PlayerFacingDir         ;set facing direction so that player faces right
          sta Player_Y_HighPos
          lda #$00                    ;set player state to on the ground by default
          sta Player_State
          dec Player_CollisionBits    ;initialize player's collision bits
          ldy #$00                    ;initialize halfway page
          sty HalfwayPage
          lda AreaType                ;check area type
          bne ChkStPos                ;if water type, set swimming flag, otherwise do not set
          iny
ChkStPos: sty SwimmingFlag
          ldx PlayerEntranceCtrl      ;get starting position loaded from header
          ldy AltEntranceControl      ;check alternate mode of entry flag for 0 or 1
          beq SetStPos
          cpy #$01
          beq SetStPos
          ldx AltYPosOffset-2,y       ;if not 0 or 1, override $0710 with new offset in X
SetStPos: lda PlayerStarting_X_Pos,y  ;load appropriate horizontal position
          sta Player_X_Position       ;and vertical positions for the player, using
          lda PlayerStarting_Y_Pos,x  ;AltEntranceControl as offset for horizontal and either $0710
          sta Player_Y_Position       ;or value that overwrote $0710 as offset for vertical
          lda PlayerBGPriorityData,x
          sta Player_SprAttrib        ;set player sprite attributes using offset in X
          jsr GetPlayerColors         ;get appropriate player palette
          ldy GameTimerSetting        ;get timer control value from header
          beq ChkOverR                ;if set to zero, branch (do not use dummy byte for this)
          lda FetchNewGameTimerFlag   ;do we need to set the game timer? if not, use
          beq ChkOverR                ;old game timer setting
          lda GameTimerData,y         ;if game timer is set and game timer flag is also set,
          sta GameTimerDisplay        ;use value of game timer control for first digit of game timer
          lda #$01
          sta GameTimerDisplay+2      ;set last digit of game timer to 1
          lsr
          sta GameTimerDisplay+1      ;set second digit of game timer
          sta FetchNewGameTimerFlag   ;clear flag for game timer reset
          sta StarInvincibleTimer     ;clear star mario timer
ChkOverR: ldy JoypadOverride          ;if controller bits not set, branch to skip this part
          beq ChkSwimE
          lda #$03                    ;set player state to climbing
          sta Player_State
          ldx #$00                    ;set offset for first slot, for block object
          jsr InitBlock_XY_Pos
          lda #$f0                    ;set vertical coordinate for block object
          sta Block_Y_Position
          ldx #$05                    ;set offset in X for last enemy object buffer slot
          ldy #$00                    ;set offset in Y for object coordinates used earlier
          jsr Setup_Vine              ;do a sub to grow vine
ChkSwimE: ldy AreaType                ;if level not water-type,
          bne SetPESub                ;skip this subroutine
          jsr SetupBubble             ;otherwise, execute sub to set up air bubbles
SetPESub: lda #$07                    ;set to run player entrance subroutine
          sta GameEngineSubroutine    ;on the next frame of game engine
          rts

;-------------------------------------------------------------------------------------

;page numbers are in order from -1 to -4
HalfwayPageNybbles:
      .db $56, $40
      .db $65, $70
      .db $66, $40
      .db $66, $40
      .db $66, $40
      .db $66, $60
      .db $65, $70
      .db $00, $00

PlayerLoseLife:
             inc DisableScreenFlag    ;disable screen and sprite 0 check
             lda #$00
             sta Sprite0HitDetectFlag
             lda #Silence             ;silence music
             sta EventMusicQueue
             dec NumberofLives        ;take one life from player
             bpl StillInGame          ;if player still has lives, branch
             lda #$00
             sta OperMode_Task        ;initialize mode task,
             lda #GameOverModeValue   ;switch to game over mode
             sta OperMode             ;and leave
             rts
StillInGame: lda WorldNumber          ;multiply world number by 2 and use
             asl                      ;as offset
             tax
             lda LevelNumber          ;if in area -3 or -4, increment
             and #$02                 ;offset by one byte, otherwise
             beq GetHalfway           ;leave offset alone
             inx
GetHalfway:  ldy HalfwayPageNybbles,x ;get halfway page number with offset
             lda LevelNumber          ;check area number's LSB
             lsr
             tya                      ;if in area -2 or -4, use lower nybble
             bcs MaskHPNyb
             lsr                      ;move higher nybble to lower if area
             lsr                      ;number is -1 or -3
             lsr
             lsr
MaskHPNyb:   and #%00001111           ;mask out all but lower nybble
             cmp ScreenLeft_PageLoc
             beq SetHalfway           ;left side of screen must be at the halfway page,
             bcc SetHalfway           ;otherwise player must start at the
             lda #$00                 ;beginning of the level
SetHalfway:  sta HalfwayPage          ;store as halfway page for player
             jsr TransposePlayers     ;switch players around if 2-player game
             jmp ContinueGame         ;continue the game

;-------------------------------------------------------------------------------------

GameOverMode:
      lda OperMode_Task
      jsr JumpEngine

      .dw SetupGameOver
      .dw ScreenRoutines
      .dw RunGameOver

;-------------------------------------------------------------------------------------

SetupGameOver:
      lda #$00                  ;reset screen routine task control for title screen, game,
      sta ScreenRoutineTask     ;and game over modes
      sta Sprite0HitDetectFlag  ;disable sprite 0 check
      lda #GameOverMusic
      sta EventMusicQueue       ;put game over music in secondary queue
      inc DisableScreenFlag     ;disable screen output
      inc OperMode_Task         ;set secondary mode to 1
      rts

;-------------------------------------------------------------------------------------

RunGameOver:
      lda #$00              ;reenable screen
      sta DisableScreenFlag
      lda SavedJoypad1Bits  ;check controller for start pressed
      and #Start_Button
      bne TerminateGame
      lda ScreenTimer       ;if not pressed, wait for
      bne GameIsOn          ;screen timer to expire
TerminateGame:
      lda #Silence          ;silence music
      sta EventMusicQueue
      jsr TransposePlayers  ;check if other player can keep
      bcc ContinueGame      ;going, and do so if possible
      lda WorldNumber       ;otherwise put world number of current
      sta ContinueWorld     ;player into secret continue function variable
      lda #$00
      asl                   ;residual ASL instruction
      sta OperMode_Task     ;reset all modes to title screen and
      sta ScreenTimer       ;leave
      sta OperMode
      rts

ContinueGame:
           jsr LoadAreaPointer       ;update level pointer with
           lda #$01                  ;actual world and area numbers, then
           sta PlayerSize            ;reset player's size, status, and
           inc FetchNewGameTimerFlag ;set game timer flag to reload
           lda #$00                  ;game timer from header
           sta TimerControl          ;also set flag for timers to count again
           sta PlayerStatus
           sta GameEngineSubroutine  ;reset task for game core
           sta OperMode_Task         ;set modes and leave
           lda #$01                  ;if in game over mode, switch back to
           sta OperMode              ;game mode, because game is still on
GameIsOn:  rts

TransposePlayers:
           sec                       ;set carry flag by default to end game
           lda NumberOfPlayers       ;if only a 1 player game, leave
           beq ExTrans
           lda OffScr_NumberofLives  ;does offscreen player have any lives left?
           bmi ExTrans               ;branch if not
           lda CurrentPlayer         ;invert bit to update
           eor #%00000001            ;which player is on the screen
           sta CurrentPlayer
           ldx #$06
TransLoop: lda OnscreenPlayerInfo,x    ;transpose the information
           pha                         ;of the onscreen player
           lda OffscreenPlayerInfo,x   ;with that of the offscreen player
           sta OnscreenPlayerInfo,x
           pla
           sta OffscreenPlayerInfo,x
           dex
           bpl TransLoop
           clc            ;clear carry flag to get game going
ExTrans:   rts

;-------------------------------------------------------------------------------------

DoNothing1:
      lda #$ff       ;this is residual code, this value is
      sta $06c9      ;not used anywhere in the program
DoNothing2:
      rts

;-------------------------------------------------------------------------------------

AreaParserTaskHandler:
              ldy AreaParserTaskNum     ;check number of tasks here
              bne DoAPTasks             ;if already set, go ahead
              ldy #$08
              sty AreaParserTaskNum     ;otherwise, set eight by default
DoAPTasks:    dey
              tya
              jsr AreaParserTasks
              dec AreaParserTaskNum     ;if all tasks not complete do not
              bne SkipATRender          ;render attribute table yet
              jsr RenderAttributeTables
SkipATRender: rts

AreaParserTasks:
      jsr JumpEngine

      .dw IncrementColumnPos
      .dw RenderAreaGraphics
      .dw RenderAreaGraphics
      .dw AreaParserCore
      .dw IncrementColumnPos
      .dw RenderAreaGraphics
      .dw RenderAreaGraphics
      .dw AreaParserCore

;-------------------------------------------------------------------------------------

IncrementColumnPos:
           inc CurrentColumnPos     ;increment column where we're at
           lda CurrentColumnPos
           and #%00001111           ;mask out higher nybble
           bne NoColWrap
           sta CurrentColumnPos     ;if no bits left set, wrap back to zero (0-f)
           inc CurrentPageLoc       ;and increment page number where we're at
NoColWrap: inc BlockBufferColumnPos ;increment column offset where we're at
           lda BlockBufferColumnPos
           and #%00011111           ;mask out all but 5 LSB (0-1f)
           sta BlockBufferColumnPos ;and save
           rts

;-------------------------------------------------------------------------------------
;$00 - used as counter, store for low nybble for background, ceiling byte for terrain
;$01 - used to store floor byte for terrain
;$07 - used to store terrain metatile
;$06-$07 - used to store block buffer address

BSceneDataOffsets:
      .db $00, $30, $60

BackSceneryData:
   .db $93, $00, $00, $11, $12, $12, $13, $00 ;clouds
   .db $00, $51, $52, $53, $00, $00, $00, $00
   .db $00, $00, $01, $02, $02, $03, $00, $00
   .db $00, $00, $00, $00, $91, $92, $93, $00
   .db $00, $00, $00, $51, $52, $53, $41, $42
   .db $43, $00, $00, $00, $00, $00, $91, $92

   .db $97, $87, $88, $89, $99, $00, $00, $00 ;mountains and bushes
   .db $11, $12, $13, $a4, $a5, $a5, $a5, $a6
   .db $97, $98, $99, $01, $02, $03, $00, $a4
   .db $a5, $a6, $00, $11, $12, $12, $12, $13
   .db $00, $00, $00, $00, $01, $02, $02, $03
   .db $00, $a4, $a5, $a5, $a6, $00, $00, $00

   .db $11, $12, $12, $13, $00, $00, $00, $00 ;trees and fences
   .db $00, $00, $00, $9c, $00, $8b, $aa, $aa
   .db $aa, $aa, $11, $12, $13, $8b, $00, $9c
   .db $9c, $00, $00, $01, $02, $03, $11, $12
   .db $12, $13, $00, $00, $00, $00, $aa, $aa
   .db $9c, $aa, $00, $8b, $00, $01, $02, $03

BackSceneryMetatiles:
   .db $80, $83, $00 ;cloud left
   .db $81, $84, $00 ;cloud middle
   .db $82, $85, $00 ;cloud right
   .db $02, $00, $00 ;bush left
   .db $03, $00, $00 ;bush middle
   .db $04, $00, $00 ;bush right
   .db $00, $05, $06 ;mountain left
   .db $07, $06, $0a ;mountain middle
   .db $00, $08, $09 ;mountain right
   .db $4d, $00, $00 ;fence
   .db $0d, $0f, $4e ;tall tree
   .db $0e, $4e, $4e ;short tree

FSceneDataOffsets:
      .db $00, $0d, $1a

ForeSceneryData:
   .db $86, $87, $87, $87, $87, $87, $87   ;in water
   .db $87, $87, $87, $87, $69, $69

   .db $00, $00, $00, $00, $00, $45, $47   ;wall
   .db $47, $47, $47, $47, $00, $00

   .db $00, $00, $00, $00, $00, $00, $00   ;over water
   .db $00, $00, $00, $00, $86, $87

TerrainMetatiles:
      .db $69, $54, $52, $62

TerrainRenderBits:
      .db %00000000, %00000000 ;no ceiling or floor
      .db %00000000, %00011000 ;no ceiling, floor 2
      .db %00000001, %00011000 ;ceiling 1, floor 2
      .db %00000111, %00011000 ;ceiling 3, floor 2
      .db %00001111, %00011000 ;ceiling 4, floor 2
      .db %11111111, %00011000 ;ceiling 8, floor 2
      .db %00000001, %00011111 ;ceiling 1, floor 5
      .db %00000111, %00011111 ;ceiling 3, floor 5
      .db %00001111, %00011111 ;ceiling 4, floor 5
      .db %10000001, %00011111 ;ceiling 1, floor 6
      .db %00000001, %00000000 ;ceiling 1, no floor
      .db %10001111, %00011111 ;ceiling 4, floor 6
      .db %11110001, %00011111 ;ceiling 1, floor 9
      .db %11111001, %00011000 ;ceiling 1, middle 5, floor 2
      .db %11110001, %00011000 ;ceiling 1, middle 4, floor 2
      .db %11111111, %00011111 ;completely solid top to bottom

AreaParserCore:
      lda BackloadingFlag       ;check to see if we are starting right of start
      beq RenderSceneryTerrain  ;if not, go ahead and render background, foreground and terrain
      jsr ProcessAreaData       ;otherwise skip ahead and load level data

RenderSceneryTerrain:
          ldx #$0c
          lda #$00
ClrMTBuf: sta MetatileBuffer,x       ;clear out metatile buffer
          dex
          bpl ClrMTBuf
          ldy BackgroundScenery      ;do we need to render the background scenery?
          beq RendFore               ;if not, skip to check the foreground
          lda CurrentPageLoc         ;otherwise check for every third page
ThirdP:   cmp #$03
          bmi RendBack               ;if less than three we're there
          sec
          sbc #$03                   ;if 3 or more, subtract 3 and
          bpl ThirdP                 ;do an unconditional branch
RendBack: asl                        ;move results to higher nybble
          asl
          asl
          asl
          adc BSceneDataOffsets-1,y  ;add to it offset loaded from here
          adc CurrentColumnPos       ;add to the result our current column position
          tax
          lda BackSceneryData,x      ;load data from sum of offsets
          beq RendFore               ;if zero, no scenery for that part
          pha
          and #$0f                   ;save to stack and clear high nybble
          sec
          sbc #$01                   ;subtract one (because low nybble is $01-$0c)
          sta $00                    ;save low nybble
          asl                        ;multiply by three (shift to left and add result to old one)
          adc $00                    ;note that since d7 was nulled, the carry flag is always clear
          tax                        ;save as offset for background scenery metatile data
          pla                        ;get high nybble from stack, move low
          lsr
          lsr
          lsr
          lsr
          tay                        ;use as second offset (used to determine height)
          lda #$03                   ;use previously saved memory location for counter
          sta $00
SceLoop1: lda BackSceneryMetatiles,x ;load metatile data from offset of (lsb - 1) * 3
          sta MetatileBuffer,y       ;store into buffer from offset of (msb / 16)
          inx
          iny
          cpy #$0b                   ;if at this location, leave loop
          beq RendFore
          dec $00                    ;decrement until counter expires, barring exception
          bne SceLoop1
RendFore: ldx ForegroundScenery      ;check for foreground data needed or not
          beq RendTerr               ;if not, skip this part
          ldy FSceneDataOffsets-1,x  ;load offset from location offset by header value, then
          ldx #$00                   ;reinit X
SceLoop2: lda ForeSceneryData,y      ;load data until counter expires
          beq NoFore                 ;do not store if zero found
          sta MetatileBuffer,x
NoFore:   iny
          inx
          cpx #$0d                   ;store up to end of metatile buffer
          bne SceLoop2
RendTerr: ldy AreaType               ;check world type for water level
          bne TerMTile               ;if not water level, skip this part
          lda WorldNumber            ;check world number, if not world number eight
          cmp #World8                ;then skip this part
          bne TerMTile
          lda #$62                   ;if set as water level and world number eight,
          jmp StoreMT                ;use castle wall metatile as terrain type
TerMTile: lda TerrainMetatiles,y     ;otherwise get appropriate metatile for area type
          ldy CloudTypeOverride      ;check for cloud type override
          beq StoreMT                ;if not set, keep value otherwise
          lda #$88                   ;use cloud block terrain
StoreMT:  sta $07                    ;store value here
          ldx #$00                   ;initialize X, use as metatile buffer offset
          lda TerrainControl         ;use yet another value from the header
          asl                        ;multiply by 2 and use as yet another offset
          tay
TerrLoop: lda TerrainRenderBits,y    ;get one of the terrain rendering bit data
          sta $00
          iny                        ;increment Y and use as offset next time around
          sty $01
          lda CloudTypeOverride      ;skip if value here is zero
          beq NoCloud2
          cpx #$00                   ;otherwise, check if we're doing the ceiling byte
          beq NoCloud2
          lda $00                    ;if not, mask out all but d3
          and #%00001000
          sta $00
NoCloud2: ldy #$00                   ;start at beginning of bitmasks
TerrBChk: lda Bitmasks,y             ;load bitmask, then perform AND on contents of first byte
          bit $00
          beq NextTBit               ;if not set, skip this part (do not write terrain to buffer)
          lda $07
          sta MetatileBuffer,x       ;load terrain type metatile number and store into buffer here
NextTBit: inx                        ;continue until end of buffer
          cpx #$0d
          beq RendBBuf               ;if we're at the end, break out of this loop
          lda AreaType               ;check world type for underground area
          cmp #$02
          bne EndUChk                ;if not underground, skip this part
          cpx #$0b
          bne EndUChk                ;if we're at the bottom of the screen, override
          lda #$54                   ;old terrain type with ground level terrain type
          sta $07
EndUChk:  iny                        ;increment bitmasks offset in Y
          cpy #$08
          bne TerrBChk               ;if not all bits checked, loop back
          ldy $01
          bne TerrLoop               ;unconditional branch, use Y to load next byte
RendBBuf: jsr ProcessAreaData        ;do the area data loading routine now
          lda BlockBufferColumnPos
          jsr GetBlockBufferAddr     ;get block buffer address from where we're at
          ldx #$00
          ldy #$00                   ;init index regs and start at beginning of smaller buffer
ChkMTLow: sty $00
          lda MetatileBuffer,x       ;load stored metatile number
          and #%11000000             ;mask out all but 2 MSB
          asl
          rol                        ;make %xx000000 into %000000xx
          rol
          tay                        ;use as offset in Y
          lda MetatileBuffer,x       ;reload original unmasked value here
          cmp BlockBuffLowBounds,y   ;check for certain values depending on bits set
          bcs StrBlock               ;if equal or greater, branch
          lda #$00                   ;if less, init value before storing
StrBlock: ldy $00                    ;get offset for block buffer
          sta ($06),y                ;store value into block buffer
          tya
          clc                        ;add 16 (move down one row) to offset
          adc #$10
          tay
          inx                        ;increment column value
          cpx #$0d
          bcc ChkMTLow               ;continue until we pass last row, then leave
          rts

;numbers lower than these with the same attribute bits
;will not be stored in the block buffer
BlockBuffLowBounds:
      .db $10, $51, $88, $c0

;-------------------------------------------------------------------------------------
;$00 - used to store area object identifier
;$07 - used as adder to find proper area object code

ProcessAreaData:
            ldx #$02                 ;start at the end of area object buffer
ProcADLoop: stx ObjectOffset
            lda #$00                 ;reset flag
            sta BehindAreaParserFlag
            ldy AreaDataOffset       ;get offset of area data pointer
            lda (AreaData),y         ;get first byte of area object
            cmp #$fd                 ;if end-of-area, skip all this crap
            beq RdyDecode
            lda AreaObjectLength,x   ;check area object buffer flag
            bpl RdyDecode            ;if buffer not negative, branch, otherwise
            iny
            lda (AreaData),y         ;get second byte of area object
            asl                      ;check for page select bit (d7), branch if not set
            bcc Chk1Row13
            lda AreaObjectPageSel    ;check page select
            bne Chk1Row13
            inc AreaObjectPageSel    ;if not already set, set it now
            inc AreaObjectPageLoc    ;and increment page location
Chk1Row13:  dey
            lda (AreaData),y         ;reread first byte of level object
            and #$0f                 ;mask out high nybble
            cmp #$0d                 ;row 13?
            bne Chk1Row14
            iny                      ;if so, reread second byte of level object
            lda (AreaData),y
            dey                      ;decrement to get ready to read first byte
            and #%01000000           ;check for d6 set (if not, object is page control)
            bne CheckRear
            lda AreaObjectPageSel    ;if page select is set, do not reread
            bne CheckRear
            iny                      ;if d6 not set, reread second byte
            lda (AreaData),y
            and #%00011111           ;mask out all but 5 LSB and store in page control
            sta AreaObjectPageLoc
            inc AreaObjectPageSel    ;increment page select
            jmp NextAObj
Chk1Row14:  cmp #$0e                 ;row 14?
            bne CheckRear
            lda BackloadingFlag      ;check flag for saved page number and branch if set
            bne RdyDecode            ;to render the object (otherwise bg might not look right)
CheckRear:  lda AreaObjectPageLoc    ;check to see if current page of level object is
            cmp CurrentPageLoc       ;behind current page of renderer
            bcc SetBehind            ;if so branch
RdyDecode:  jsr DecodeAreaData       ;do sub and do not turn on flag
            jmp ChkLength
SetBehind:  inc BehindAreaParserFlag ;turn on flag if object is behind renderer
NextAObj:   jsr IncAreaObjOffset     ;increment buffer offset and move on
ChkLength:  ldx ObjectOffset         ;get buffer offset
            lda AreaObjectLength,x   ;check object length for anything stored here
            bmi ProcLoopb            ;if not, branch to handle loopback
            dec AreaObjectLength,x   ;otherwise decrement length or get rid of it
ProcLoopb:  dex                      ;decrement buffer offset
            bpl ProcADLoop           ;and loopback unless exceeded buffer
            lda BehindAreaParserFlag ;check for flag set if objects were behind renderer
            bne ProcessAreaData      ;branch if true to load more level data, otherwise
            lda BackloadingFlag      ;check for flag set if starting right of page $00
            bne ProcessAreaData      ;branch if true to load more level data, otherwise leave
EndAParse:  rts

IncAreaObjOffset:
      inc AreaDataOffset    ;increment offset of level pointer
      inc AreaDataOffset
      lda #$00              ;reset page select
      sta AreaObjectPageSel
      rts

DecodeAreaData:
          lda AreaObjectLength,x     ;check current buffer flag
          bmi Chk1stB
          ldy AreaObjOffsetBuffer,x  ;if not, get offset from buffer
Chk1stB:  ldx #$10                   ;load offset of 16 for special row 15
          lda (AreaData),y           ;get first byte of level object again
          cmp #$fd
          beq EndAParse              ;if end of level, leave this routine
          and #$0f                   ;otherwise, mask out low nybble
          cmp #$0f                   ;row 15?
          beq ChkRow14               ;if so, keep the offset of 16
          ldx #$08                   ;otherwise load offset of 8 for special row 12
          cmp #$0c                   ;row 12?
          beq ChkRow14               ;if so, keep the offset value of 8
          ldx #$00                   ;otherwise nullify value by default
ChkRow14: stx $07                    ;store whatever value we just loaded here
          ldx ObjectOffset           ;get object offset again
          cmp #$0e                   ;row 14?
          bne ChkRow13
          lda #$00                   ;if so, load offset with $00
          sta $07
          lda #$2e                   ;and load A with another value
          bne NormObj                ;unconditional branch
ChkRow13: cmp #$0d                   ;row 13?
          bne ChkSRows
          lda #$22                   ;if so, load offset with 34
          sta $07
          iny                        ;get next byte
          lda (AreaData),y
          and #%01000000             ;mask out all but d6 (page control obj bit)
          beq LeavePar               ;if d6 clear, branch to leave (we handled this earlier)
          lda (AreaData),y           ;otherwise, get byte again
          and #%01111111             ;mask out d7
          cmp #$4b                   ;check for loop command in low nybble
          bne Mask2MSB               ;(plus d6 set for object other than page control)
          inc LoopCommand            ;if loop command, set loop command flag
Mask2MSB: and #%00111111             ;mask out d7 and d6
          jmp NormObj                ;and jump
ChkSRows: cmp #$0c                   ;row 12-15?
          bcs SpecObj
          iny                        ;if not, get second byte of level object
          lda (AreaData),y
          and #%01110000             ;mask out all but d6-d4
          bne LrgObj                 ;if any bits set, branch to handle large object
          lda #$16
          sta $07                    ;otherwise set offset of 24 for small object
          lda (AreaData),y           ;reload second byte of level object
          and #%00001111             ;mask out higher nybble and jump
          jmp NormObj
LrgObj:   sta $00                    ;store value here (branch for large objects)
          cmp #$70                   ;check for vertical pipe object
          bne NotWPipe
          lda (AreaData),y           ;if not, reload second byte
          and #%00001000             ;mask out all but d3 (usage control bit)
          beq NotWPipe               ;if d3 clear, branch to get original value
          lda #$00                   ;otherwise, nullify value for warp pipe
          sta $00
NotWPipe: lda $00                    ;get value and jump ahead
          jmp MoveAOId
SpecObj:  iny                        ;branch here for rows 12-15
          lda (AreaData),y
          and #%01110000             ;get next byte and mask out all but d6-d4
MoveAOId: lsr                        ;move d6-d4 to lower nybble
          lsr
          lsr
          lsr
NormObj:  sta $00                    ;store value here (branch for small objects and rows 13 and 14)
          lda AreaObjectLength,x     ;is there something stored here already?
          bpl RunAObj                ;if so, branch to do its particular sub
          lda AreaObjectPageLoc      ;otherwise check to see if the object we've loaded is on the
          cmp CurrentPageLoc         ;same page as the renderer, and if so, branch
          beq InitRear
          ldy AreaDataOffset         ;if not, get old offset of level pointer
          lda (AreaData),y           ;and reload first byte
          and #%00001111
          cmp #$0e                   ;row 14?
          bne LeavePar
          lda BackloadingFlag        ;if so, check backloading flag
          bne StrAObj                ;if set, branch to render object, else leave
LeavePar: rts
InitRear: lda BackloadingFlag        ;check backloading flag to see if it's been initialized
          beq BackColC               ;branch to column-wise check
          lda #$00                   ;if not, initialize both backloading and
          sta BackloadingFlag        ;behind-renderer flags and leave
          sta BehindAreaParserFlag
          sta ObjectOffset
LoopCmdE: rts
BackColC: ldy AreaDataOffset         ;get first byte again
          lda (AreaData),y
          and #%11110000             ;mask out low nybble and move high to low
          lsr
          lsr
          lsr
          lsr
          cmp CurrentColumnPos       ;is this where we're at?
          bne LeavePar               ;if not, branch to leave
StrAObj:  lda AreaDataOffset         ;if so, load area obj offset and store in buffer
          sta AreaObjOffsetBuffer,x
          jsr IncAreaObjOffset       ;do sub to increment to next object data
RunAObj:  lda $00                    ;get stored value and add offset to it
          clc                        ;then use the jump engine with current contents of A
          adc $07
          jsr JumpEngine

;large objects (rows $00-$0b or 00-11, d6-d4 set)
      .dw VerticalPipe         ;used by warp pipes
      .dw AreaStyleObject
      .dw RowOfBricks
      .dw RowOfSolidBlocks
      .dw RowOfCoins
      .dw ColumnOfBricks
      .dw ColumnOfSolidBlocks
      .dw VerticalPipe         ;used by decoration pipes

;objects for special row $0c or 12
      .dw Hole_Empty
      .dw PulleyRopeObject
      .dw Bridge_High
      .dw Bridge_Middle
      .dw Bridge_Low
      .dw Hole_Water
      .dw QuestionBlockRow_High
      .dw QuestionBlockRow_Low

;objects for special row $0f or 15
      .dw EndlessRope
      .dw BalancePlatRope
      .dw CastleObject
      .dw StaircaseObject
      .dw ExitPipe
      .dw FlagBalls_Residual

;small objects (rows $00-$0b or 00-11, d6-d4 all clear)
      .dw QuestionBlock     ;power-up
      .dw QuestionBlock     ;coin
      .dw QuestionBlock     ;hidden, coin
      .dw Hidden1UpBlock    ;hidden, 1-up
      .dw BrickWithItem     ;brick, power-up
      .dw BrickWithItem     ;brick, vine
      .dw BrickWithItem     ;brick, star
      .dw BrickWithCoins    ;brick, coins
      .dw BrickWithItem     ;brick, 1-up
      .dw WaterPipe
      .dw EmptyBlock
      .dw Jumpspring

;objects for special row $0d or 13 (d6 set)
      .dw IntroPipe
      .dw FlagpoleObject
      .dw AxeObj
      .dw ChainObj
      .dw CastleBridgeObj
      .dw ScrollLockObject_Warp
      .dw ScrollLockObject
      .dw ScrollLockObject
      .dw AreaFrenzy            ;flying cheep-cheeps
      .dw AreaFrenzy            ;bullet bills or swimming cheep-cheeps
      .dw AreaFrenzy            ;stop frenzy
      .dw LoopCmdE

;object for special row $0e or 14
      .dw AlterAreaAttributes

;-------------------------------------------------------------------------------------
;(these apply to all area object subroutines in this section unless otherwise stated)
;$00 - used to store offset used to find object code
;$07 - starts with adder from area parser, used to store row offset

AlterAreaAttributes:
         ldy AreaObjOffsetBuffer,x ;load offset for level object data saved in buffer
         iny                       ;load second byte
         lda (AreaData),y
         pha                       ;save in stack for now
         and #%01000000
         bne Alter2                ;branch if d6 is set
         pla
         pha                       ;pull and push offset to copy to A
         and #%00001111            ;mask out high nybble and store as
         sta TerrainControl        ;new terrain height type bits
         pla
         and #%00110000            ;pull and mask out all but d5 and d4
         lsr                       ;move bits to lower nybble and store
         lsr                       ;as new background scenery bits
         lsr
         lsr
         sta BackgroundScenery     ;then leave
         rts
Alter2:  pla
         and #%00000111            ;mask out all but 3 LSB
         cmp #$04                  ;if four or greater, set color control bits
         bcc SetFore               ;and nullify foreground scenery bits
         sta BackgroundColorCtrl
         lda #$00
SetFore: sta ForegroundScenery     ;otherwise set new foreground scenery bits
         rts

;--------------------------------

ScrollLockObject_Warp:
         ldx #$04            ;load value of 4 for game text routine as default
         lda WorldNumber     ;warp zone (4-3-2), then check world number
         beq WarpNum
         inx                 ;if world number > 1, increment for next warp zone (5)
         ldy AreaType        ;check area type
         dey
         bne WarpNum         ;if ground area type, increment for last warp zone
         inx                 ;(8-7-6) and move on
WarpNum: txa
         sta WarpZoneControl ;store number here to be used by warp zone routine
         jsr WriteGameText   ;print text and warp zone numbers
         lda #PiranhaPlant
         jsr KillEnemies     ;load identifier for piranha plants and do sub

ScrollLockObject:
      lda ScrollLock      ;invert scroll lock to turn it on
      eor #%00000001
      sta ScrollLock
      rts

;--------------------------------
;$00 - used to store enemy identifier in KillEnemies

KillEnemies:
           sta $00           ;store identifier here
           lda #$00
           ldx #$04          ;check for identifier in enemy object buffer
KillELoop: ldy Enemy_ID,x
           cpy $00           ;if not found, branch
           bne NoKillE
           sta Enemy_Flag,x  ;if found, deactivate enemy object flag
NoKillE:   dex               ;do this until all slots are checked
           bpl KillELoop
           rts

;--------------------------------

FrenzyIDData:
      .db FlyCheepCheepFrenzy, BBill_CCheep_Frenzy, Stop_Frenzy

AreaFrenzy:  ldx $00               ;use area object identifier bit as offset
             lda FrenzyIDData-8,x  ;note that it starts at 8, thus weird address here
             ldy #$05
FreCompLoop: dey                   ;check regular slots of enemy object buffer
             bmi ExitAFrenzy       ;if all slots checked and enemy object not found, branch to store
             cmp Enemy_ID,y    ;check for enemy object in buffer versus frenzy object
             bne FreCompLoop
             lda #$00              ;if enemy object already present, nullify queue and leave
ExitAFrenzy: sta EnemyFrenzyQueue  ;store enemy into frenzy queue
             rts

;--------------------------------
;$06 - used by MushroomLedge to store length

AreaStyleObject:
      lda AreaStyle        ;load level object style and jump to the right sub
      jsr JumpEngine
      .dw TreeLedge        ;also used for cloud type levels
      .dw MushroomLedge
      .dw BulletBillCannon

TreeLedge:
          jsr GetLrgObjAttrib     ;get row and length of green ledge
          lda AreaObjectLength,x  ;check length counter for expiration
          beq EndTreeL
          bpl MidTreeL
          tya
          sta AreaObjectLength,x  ;store lower nybble into buffer flag as length of ledge
          lda CurrentPageLoc
          ora CurrentColumnPos    ;are we at the start of the level?
          beq MidTreeL
          lda #$16                ;render start of tree ledge
          jmp NoUnder
MidTreeL: ldx $07
          lda #$17                ;render middle of tree ledge
          sta MetatileBuffer,x    ;note that this is also used if ledge position is
          lda #$4c                ;at the start of level for continuous effect
          jmp AllUnder            ;now render the part underneath
EndTreeL: lda #$18                ;render end of tree ledge
          jmp NoUnder

MushroomLedge:
          jsr ChkLrgObjLength        ;get shroom dimensions
          sty $06                    ;store length here for now
          bcc EndMushL
          lda AreaObjectLength,x     ;divide length by 2 and store elsewhere
          lsr
          sta MushroomLedgeHalfLen,x
          lda #$19                   ;render start of mushroom
          jmp NoUnder
EndMushL: lda #$1b                   ;if at the end, render end of mushroom
          ldy AreaObjectLength,x
          beq NoUnder
          lda MushroomLedgeHalfLen,x ;get divided length and store where length
          sta $06                    ;was stored originally
          ldx $07
          lda #$1a
          sta MetatileBuffer,x       ;render middle of mushroom
          cpy $06                    ;are we smack dab in the center?
          bne MushLExit              ;if not, branch to leave
          inx
          lda #$4f
          sta MetatileBuffer,x       ;render stem top of mushroom underneath the middle
          lda #$50
AllUnder: inx
          ldy #$0f                   ;set $0f to render all way down
          jmp RenderUnderPart       ;now render the stem of mushroom
NoUnder:  ldx $07                    ;load row of ledge
          ldy #$00                   ;set 0 for no bottom on this part
          jmp RenderUnderPart

;--------------------------------

;tiles used by pulleys and rope object
PulleyRopeMetatiles:
      .db $42, $41, $43

PulleyRopeObject:
           jsr ChkLrgObjLength       ;get length of pulley/rope object
           ldy #$00                  ;initialize metatile offset
           bcs RenderPul             ;if starting, render left pulley
           iny
           lda AreaObjectLength,x    ;if not at the end, render rope
           bne RenderPul
           iny                       ;otherwise render right pulley
RenderPul: lda PulleyRopeMetatiles,y
           sta MetatileBuffer        ;render at the top of the screen
MushLExit: rts                       ;and leave

;--------------------------------
;$06 - used to store upper limit of rows for CastleObject

CastleMetatiles:
      .db $00, $45, $45, $45, $00
      .db $00, $48, $47, $46, $00
      .db $45, $49, $49, $49, $45
      .db $47, $47, $4a, $47, $47
      .db $47, $47, $4b, $47, $47
      .db $49, $49, $49, $49, $49
      .db $47, $4a, $47, $4a, $47
      .db $47, $4b, $47, $4b, $47
      .db $47, $47, $47, $47, $47
      .db $4a, $47, $4a, $47, $4a
      .db $4b, $47, $4b, $47, $4b

CastleObject:
            jsr GetLrgObjAttrib      ;save lower nybble as starting row
            sty $07                  ;if starting row is above $0a, game will crash!!!
            ldy #$04
            jsr ChkLrgObjFixedLength ;load length of castle if not already loaded
            txa
            pha                      ;save obj buffer offset to stack
            ldy AreaObjectLength,x   ;use current length as offset for castle data
            ldx $07                  ;begin at starting row
            lda #$0b
            sta $06                  ;load upper limit of number of rows to print
CRendLoop:  lda CastleMetatiles,y    ;load current byte using offset
            sta MetatileBuffer,x
            inx                      ;store in buffer and increment buffer offset
            lda $06
            beq ChkCFloor            ;have we reached upper limit yet?
            iny                      ;if not, increment column-wise
            iny                      ;to byte in next row
            iny
            iny
            iny
            dec $06                  ;move closer to upper limit
ChkCFloor:  cpx #$0b                 ;have we reached the row just before floor?
            bne CRendLoop            ;if not, go back and do another row
            pla
            tax                      ;get obj buffer offset from before
            lda CurrentPageLoc
            beq ExitCastle           ;if we're at page 0, we do not need to do anything else
            lda AreaObjectLength,x   ;check length
            cmp #$01                 ;if length almost about to expire, put brick at floor
            beq PlayerStop
            ldy $07                  ;check starting row for tall castle ($00)
            bne NotTall
            cmp #$03                 ;if found, then check to see if we're at the second column
            beq PlayerStop
NotTall:    cmp #$02                 ;if not tall castle, check to see if we're at the third column
            bne ExitCastle           ;if we aren't and the castle is tall, don't create flag yet
            jsr GetAreaObjXPosition  ;otherwise, obtain and save horizontal pixel coordinate
            pha
            jsr FindEmptyEnemySlot   ;find an empty place on the enemy object buffer
            pla
            sta Enemy_X_Position,x   ;then write horizontal coordinate for star flag
            lda CurrentPageLoc
            sta Enemy_PageLoc,x      ;set page location for star flag
            lda #$01
            sta Enemy_Y_HighPos,x    ;set vertical high byte
            sta Enemy_Flag,x         ;set flag for buffer
            lda #$90
            sta Enemy_Y_Position,x   ;set vertical coordinate
            lda #StarFlagObject      ;set star flag value in buffer itself
            sta Enemy_ID,x
            rts
PlayerStop: ldy #$52                 ;put brick at floor to stop player at end of level
            sty MetatileBuffer+10    ;this is only done if we're on the second column
ExitCastle: rts

;--------------------------------

WaterPipe:
      jsr GetLrgObjAttrib     ;get row and lower nybble
      ldy AreaObjectLength,x  ;get length (residual code, water pipe is 1 col thick)
      ldx $07                 ;get row
      lda #$6b
      sta MetatileBuffer,x    ;draw something here and below it
      lda #$6c
      sta MetatileBuffer+1,x
      rts

;--------------------------------
;$05 - used to store length of vertical shaft in RenderSidewaysPipe
;$06 - used to store leftover horizontal length in RenderSidewaysPipe
; and vertical length in VerticalPipe and GetPipeHeight

IntroPipe:
               ldy #$03                 ;check if length set, if not set, set it
               jsr ChkLrgObjFixedLength
               ldy #$0a                 ;set fixed value and render the sideways part
               jsr RenderSidewaysPipe
               bcs NoBlankP             ;if carry flag set, not time to draw vertical pipe part
               ldx #$06                 ;blank everything above the vertical pipe part
VPipeSectLoop: lda #$00                 ;all the way to the top of the screen
               sta MetatileBuffer,x     ;because otherwise it will look like exit pipe
               dex
               bpl VPipeSectLoop
               lda VerticalPipeData,y   ;draw the end of the vertical pipe part
               sta MetatileBuffer+7
NoBlankP:      rts

SidePipeShaftData:
      .db $15, $14  ;used to control whether or not vertical pipe shaft
      .db $00, $00  ;is drawn, and if so, controls the metatile number
SidePipeTopPart:
      .db $15, $1e  ;top part of sideways part of pipe
      .db $1d, $1c
SidePipeBottomPart:
      .db $15, $21  ;bottom part of sideways part of pipe
      .db $20, $1f

ExitPipe:
      ldy #$03                 ;check if length set, if not set, set it
      jsr ChkLrgObjFixedLength
      jsr GetLrgObjAttrib      ;get vertical length, then plow on through RenderSidewaysPipe

RenderSidewaysPipe:
              dey                       ;decrement twice to make room for shaft at bottom
              dey                       ;and store here for now as vertical length
              sty $05
              ldy AreaObjectLength,x    ;get length left over and store here
              sty $06
              ldx $05                   ;get vertical length plus one, use as buffer offset
              inx
              lda SidePipeShaftData,y   ;check for value $00 based on horizontal offset
              cmp #$00
              beq DrawSidePart          ;if found, do not draw the vertical pipe shaft
              ldx #$00
              ldy $05                   ;init buffer offset and get vertical length
              jsr RenderUnderPart       ;and render vertical shaft using tile number in A
              clc                       ;clear carry flag to be used by IntroPipe
DrawSidePart: ldy $06                   ;render side pipe part at the bottom
              lda SidePipeTopPart,y
              sta MetatileBuffer,x      ;note that the pipe parts are stored
              lda SidePipeBottomPart,y  ;backwards horizontally
              sta MetatileBuffer+1,x
              rts

VerticalPipeData:
      .db $11, $10 ;used by pipes that lead somewhere
      .db $15, $14
      .db $13, $12 ;used by decoration pipes
      .db $15, $14

VerticalPipe:
          jsr GetPipeHeight
          lda $00                  ;check to see if value was nullified earlier
          beq WarpPipe             ;(if d3, the usage control bit of second byte, was set)
          iny
          iny
          iny
          iny                      ;add four if usage control bit was not set
WarpPipe: tya                      ;save value in stack
          pha
          lda AreaNumber
          ora WorldNumber          ;if at world 1-1, do not add piranha plant ever
          beq DrawPipe
          ldy AreaObjectLength,x   ;if on second column of pipe, branch
          beq DrawPipe             ;(because we only need to do this once)
          jsr FindEmptyEnemySlot   ;check for an empty moving data buffer space
          bcs DrawPipe             ;if not found, too many enemies, thus skip
          jsr GetAreaObjXPosition  ;get horizontal pixel coordinate
          clc
          adc #$08                 ;add eight to put the piranha plant in the center
          sta Enemy_X_Position,x   ;store as enemy's horizontal coordinate
          lda CurrentPageLoc       ;add carry to current page number
          adc #$00
          sta Enemy_PageLoc,x      ;store as enemy's page coordinate
          lda #$01
          sta Enemy_Y_HighPos,x
          sta Enemy_Flag,x         ;activate enemy flag
          jsr GetAreaObjYPosition  ;get piranha plant's vertical coordinate and store here
          sta Enemy_Y_Position,x
          lda #PiranhaPlant        ;write piranha plant's value into buffer
          sta Enemy_ID,x
          jsr InitPiranhaPlant
DrawPipe: pla                      ;get value saved earlier and use as Y
          tay
          ldx $07                  ;get buffer offset
          lda VerticalPipeData,y   ;draw the appropriate pipe with the Y we loaded earlier
          sta MetatileBuffer,x     ;render the top of the pipe
          inx
          lda VerticalPipeData+2,y ;render the rest of the pipe
          ldy $06                  ;subtract one from length and render the part underneath
          dey
          jmp RenderUnderPart

GetPipeHeight:
      ldy #$01       ;check for length loaded, if not, load
      jsr ChkLrgObjFixedLength ;pipe length of 2 (horizontal)
      jsr GetLrgObjAttrib
      tya            ;get saved lower nybble as height
      and #$07       ;save only the three lower bits as
      sta $06        ;vertical length, then load Y with
      ldy AreaObjectLength,x    ;length left over
      rts

FindEmptyEnemySlot:
              ldx #$00          ;start at first enemy slot
EmptyChkLoop: clc               ;clear carry flag by default
              lda Enemy_Flag,x  ;check enemy buffer for nonzero
              beq ExitEmptyChk  ;if zero, leave
              inx
              cpx #$05          ;if nonzero, check next value
              bne EmptyChkLoop
ExitEmptyChk: rts               ;if all values nonzero, carry flag is set

;--------------------------------

Hole_Water:
      jsr ChkLrgObjLength   ;get low nybble and save as length
      lda #$86              ;render waves
      sta MetatileBuffer+10
      ldx #$0b
      ldy #$01              ;now render the water underneath
      lda #$87
      jmp RenderUnderPart

;--------------------------------

QuestionBlockRow_High:
      lda #$03    ;start on the fourth row
      .db $2c     ;BIT instruction opcode

QuestionBlockRow_Low:
      lda #$07             ;start on the eighth row
      pha                  ;save whatever row to the stack for now
      jsr ChkLrgObjLength  ;get low nybble and save as length
      pla
      tax                  ;render question boxes with coins
      lda #$c0
      sta MetatileBuffer,x
      rts

;--------------------------------

Bridge_High:
      lda #$06  ;start on the seventh row from top of screen
      .db $2c   ;BIT instruction opcode

Bridge_Middle:
      lda #$07  ;start on the eighth row
      .db $2c   ;BIT instruction opcode

Bridge_Low:
      lda #$09             ;start on the tenth row
      pha                  ;save whatever row to the stack for now
      jsr ChkLrgObjLength  ;get low nybble and save as length
      pla
      tax                  ;render bridge railing
      lda #$0b
      sta MetatileBuffer,x
      inx
      ldy #$00             ;now render the bridge itself
      lda #$63
      jmp RenderUnderPart

;--------------------------------

FlagBalls_Residual:
      jsr GetLrgObjAttrib  ;get low nybble from object byte
      ldx #$02             ;render flag balls on third row from top
      lda #$6d             ;of screen downwards based on low nybble
      jmp RenderUnderPart

;--------------------------------

FlagpoleObject:
      lda #$24                 ;render flagpole ball on top
      sta MetatileBuffer
      ldx #$01                 ;now render the flagpole shaft
      ldy #$08
      lda #$25
      jsr RenderUnderPart
      lda #$61                 ;render solid block at the bottom
      sta MetatileBuffer+10
      jsr GetAreaObjXPosition
      sec                      ;get pixel coordinate of where the flagpole is,
      sbc #$08                 ;subtract eight pixels and use as horizontal
      sta Enemy_X_Position+5   ;coordinate for the flag
      lda CurrentPageLoc
      sbc #$00                 ;subtract borrow from page location and use as
      sta Enemy_PageLoc+5      ;page location for the flag
      lda #$30
      sta Enemy_Y_Position+5   ;set vertical coordinate for flag
      lda #$b0
      sta FlagpoleFNum_Y_Pos   ;set initial vertical coordinate for flagpole's floatey number
      lda #FlagpoleFlagObject
      sta Enemy_ID+5           ;set flag identifier, note that identifier and coordinates
      inc Enemy_Flag+5         ;use last space in enemy object buffer
      rts

;--------------------------------

EndlessRope:
      ldx #$00       ;render rope from the top to the bottom of screen
      ldy #$0f
      jmp DrawRope

BalancePlatRope:
          txa                 ;save object buffer offset for now
          pha
          ldx #$01            ;blank out all from second row to the bottom
          ldy #$0f            ;with blank used for balance platform rope
          lda #$44
          jsr RenderUnderPart
          pla                 ;get back object buffer offset
          tax
          jsr GetLrgObjAttrib ;get vertical length from lower nybble
          ldx #$01
DrawRope: lda #$40            ;render the actual rope
          jmp RenderUnderPart

;--------------------------------

CoinMetatileData:
      .db $c3, $c2, $c2, $c2

RowOfCoins:
      ldy AreaType            ;get area type
      lda CoinMetatileData,y  ;load appropriate coin metatile
      jmp GetRow

;--------------------------------

C_ObjectRow:
      .db $06, $07, $08

C_ObjectMetatile:
      .db $c5, $0c, $89

CastleBridgeObj:
      ldy #$0c                  ;load length of 13 columns
      jsr ChkLrgObjFixedLength
      jmp ChainObj

AxeObj:
      lda #$08                  ;load bowser's palette into sprite portion of palette
      sta VRAM_Buffer_AddrCtrl

ChainObj:
      ldy $00                   ;get value loaded earlier from decoder
      ldx C_ObjectRow-2,y       ;get appropriate row and metatile for object
      lda C_ObjectMetatile-2,y
      jmp ColObj

EmptyBlock:
        jsr GetLrgObjAttrib  ;get row location
        ldx $07
        lda #$c4
ColObj: ldy #$00             ;column length of 1
        jmp RenderUnderPart

;--------------------------------

SolidBlockMetatiles:
      .db $69, $61, $61, $62

BrickMetatiles:
      .db $22, $51, $52, $52
      .db $88 ;used only by row of bricks object

RowOfBricks:
            ldy AreaType           ;load area type obtained from area offset pointer
            lda CloudTypeOverride  ;check for cloud type override
            beq DrawBricks
            ldy #$04               ;if cloud type, override area type
DrawBricks: lda BrickMetatiles,y   ;get appropriate metatile
            jmp GetRow             ;and go render it

RowOfSolidBlocks:
         ldy AreaType               ;load area type obtained from area offset pointer
         lda SolidBlockMetatiles,y  ;get metatile
GetRow:  pha                        ;store metatile here
         jsr ChkLrgObjLength        ;get row number, load length
DrawRow: ldx $07
         ldy #$00                   ;set vertical height of 1
         pla
         jmp RenderUnderPart        ;render object

ColumnOfBricks:
      ldy AreaType          ;load area type obtained from area offset
      lda BrickMetatiles,y  ;get metatile (no cloud override as for row)
      jmp GetRow2

ColumnOfSolidBlocks:
         ldy AreaType               ;load area type obtained from area offset
         lda SolidBlockMetatiles,y  ;get metatile
GetRow2: pha                        ;save metatile to stack for now
         jsr GetLrgObjAttrib        ;get length and row
         pla                        ;restore metatile
         ldx $07                    ;get starting row
         jmp RenderUnderPart        ;now render the column

;--------------------------------

BulletBillCannon:
             jsr GetLrgObjAttrib      ;get row and length of bullet bill cannon
             ldx $07                  ;start at first row
             lda #$64                 ;render bullet bill cannon
             sta MetatileBuffer,x
             inx
             dey                      ;done yet?
             bmi SetupCannon
             lda #$65                 ;if not, render middle part
             sta MetatileBuffer,x
             inx
             dey                      ;done yet?
             bmi SetupCannon
             lda #$66                 ;if not, render bottom until length expires
             jsr RenderUnderPart
SetupCannon: ldx Cannon_Offset        ;get offset for data used by cannons and whirlpools
             jsr GetAreaObjYPosition  ;get proper vertical coordinate for cannon
             sta Cannon_Y_Position,x  ;and store it here
             lda CurrentPageLoc
             sta Cannon_PageLoc,x     ;store page number for cannon here
             jsr GetAreaObjXPosition  ;get proper horizontal coordinate for cannon
             sta Cannon_X_Position,x  ;and store it here
             inx
             cpx #$06                 ;increment and check offset
             bcc StrCOffset           ;if not yet reached sixth cannon, branch to save offset
             ldx #$00                 ;otherwise initialize it
StrCOffset:  stx Cannon_Offset        ;save new offset and leave
             rts

;--------------------------------

StaircaseHeightData:
      .db $07, $07, $06, $05, $04, $03, $02, $01, $00

StaircaseRowData:
      .db $03, $03, $04, $05, $06, $07, $08, $09, $0a

StaircaseObject:
           jsr ChkLrgObjLength       ;check and load length
           bcc NextStair             ;if length already loaded, skip init part
           lda #$09                  ;start past the end for the bottom
           sta StaircaseControl      ;of the staircase
NextStair: dec StaircaseControl      ;move onto next step (or first if starting)
           ldy StaircaseControl
           ldx StaircaseRowData,y    ;get starting row and height to render
           lda StaircaseHeightData,y
           tay
           lda #$61                  ;now render solid block staircase
           jmp RenderUnderPart

;--------------------------------

Jumpspring:
      jsr GetLrgObjAttrib
      jsr FindEmptyEnemySlot      ;find empty space in enemy object buffer
      jsr GetAreaObjXPosition     ;get horizontal coordinate for jumpspring
      sta Enemy_X_Position,x      ;and store
      lda CurrentPageLoc          ;store page location of jumpspring
      sta Enemy_PageLoc,x
      jsr GetAreaObjYPosition     ;get vertical coordinate for jumpspring
      sta Enemy_Y_Position,x      ;and store
      sta Jumpspring_FixedYPos,x  ;store as permanent coordinate here
      lda #JumpspringObject
      sta Enemy_ID,x              ;write jumpspring object to enemy object buffer
      ldy #$01
      sty Enemy_Y_HighPos,x       ;store vertical high byte
      inc Enemy_Flag,x            ;set flag for enemy object buffer
      ldx $07
      lda #$67                    ;draw metatiles in two rows where jumpspring is
      sta MetatileBuffer,x
      lda #$68
      sta MetatileBuffer+1,x
      rts

;--------------------------------
;$07 - used to save ID of brick object

Hidden1UpBlock:
      lda Hidden1UpFlag  ;if flag not set, do not render object
      beq ExitDecBlock
      lda #$00           ;if set, init for the next one
      sta Hidden1UpFlag
      jmp BrickWithItem  ;jump to code shared with unbreakable bricks

QuestionBlock:
      jsr GetAreaObjectID ;get value from level decoder routine
      jmp DrawQBlk        ;go to render it

BrickWithCoins:
      lda #$00                 ;initialize multi-coin timer flag
      sta BrickCoinTimerFlag

BrickWithItem:
          jsr GetAreaObjectID         ;save area object ID
          sty $07
          lda #$00                    ;load default adder for bricks with lines
          ldy AreaType                ;check level type for ground level
          dey
          beq BWithL                  ;if ground type, do not start with 5
          lda #$05                    ;otherwise use adder for bricks without lines
BWithL:   clc                         ;add object ID to adder
          adc $07
          tay                         ;use as offset for metatile
DrawQBlk: lda BrickQBlockMetatiles,y  ;get appropriate metatile for brick (question block
          pha                         ;if branched to here from question block routine)
          jsr GetLrgObjAttrib         ;get row from location byte
          jmp DrawRow                 ;now render the object

GetAreaObjectID:
              lda $00    ;get value saved from area parser routine
              sec
              sbc #$00   ;possibly residual code
              tay        ;save to Y
ExitDecBlock: rts

;--------------------------------

HoleMetatiles:
      .db $87, $00, $00, $00

Hole_Empty:
            jsr ChkLrgObjLength          ;get lower nybble and save as length
            bcc NoWhirlP                 ;skip this part if length already loaded
            lda AreaType                 ;check for water type level
            bne NoWhirlP                 ;if not water type, skip this part
            ldx Whirlpool_Offset         ;get offset for data used by cannons and whirlpools
            jsr GetAreaObjXPosition      ;get proper vertical coordinate of where we're at
            sec
            sbc #$10                     ;subtract 16 pixels
            sta Whirlpool_LeftExtent,x   ;store as left extent of whirlpool
            lda CurrentPageLoc           ;get page location of where we're at
            sbc #$00                     ;subtract borrow
            sta Whirlpool_PageLoc,x      ;save as page location of whirlpool
            iny
            iny                          ;increment length by 2
            tya
            asl                          ;multiply by 16 to get size of whirlpool
            asl                          ;note that whirlpool will always be
            asl                          ;two blocks bigger than actual size of hole
            asl                          ;and extend one block beyond each edge
            sta Whirlpool_Length,x       ;save size of whirlpool here
            inx
            cpx #$05                     ;increment and check offset
            bcc StrWOffset               ;if not yet reached fifth whirlpool, branch to save offset
            ldx #$00                     ;otherwise initialize it
StrWOffset: stx Whirlpool_Offset         ;save new offset here
NoWhirlP:   ldx AreaType                 ;get appropriate metatile, then
            lda HoleMetatiles,x          ;render the hole proper
            ldx #$08
            ldy #$0f                     ;start at ninth row and go to bottom, run RenderUnderPart

;--------------------------------

RenderUnderPart:
             sty AreaObjectHeight  ;store vertical length to render
             ldy MetatileBuffer,x  ;check current spot to see if there's something
             beq DrawThisRow       ;we need to keep, if nothing, go ahead
             cpy #$17
             beq WaitOneRow        ;if middle part (tree ledge), wait until next row
             cpy #$1a
             beq WaitOneRow        ;if middle part (mushroom ledge), wait until next row
             cpy #$c0
             beq DrawThisRow       ;if question block w/ coin, overwrite
             cpy #$c0
             bcs WaitOneRow        ;if any other metatile with palette 3, wait until next row
             cpy #$54
             bne DrawThisRow       ;if cracked rock terrain, overwrite
             cmp #$50
             beq WaitOneRow        ;if stem top of mushroom, wait until next row
DrawThisRow: sta MetatileBuffer,x  ;render contents of A from routine that called this
WaitOneRow:  inx
             cpx #$0d              ;stop rendering if we're at the bottom of the screen
             bcs ExitUPartR
             ldy AreaObjectHeight  ;decrement, and stop rendering if there is no more length
             dey
             bpl RenderUnderPart
ExitUPartR:  rts

;--------------------------------

ChkLrgObjLength:
        jsr GetLrgObjAttrib     ;get row location and size (length if branched to from here)

ChkLrgObjFixedLength:
        lda AreaObjectLength,x  ;check for set length counter
        clc                     ;clear carry flag for not just starting
        bpl LenSet              ;if counter not set, load it, otherwise leave alone
        tya                     ;save length into length counter
        sta AreaObjectLength,x
        sec                     ;set carry flag if just starting
LenSet: rts


GetLrgObjAttrib:
      ldy AreaObjOffsetBuffer,x ;get offset saved from area obj decoding routine
      lda (AreaData),y          ;get first byte of level object
      and #%00001111
      sta $07                   ;save row location
      iny
      lda (AreaData),y          ;get next byte, save lower nybble (length or height)
      and #%00001111            ;as Y, then leave
      tay
      rts

;--------------------------------

GetAreaObjXPosition:
      lda CurrentColumnPos    ;multiply current offset where we're at by 16
      asl                     ;to obtain horizontal pixel coordinate
      asl
      asl
      asl
      rts

;--------------------------------

GetAreaObjYPosition:
      lda $07  ;multiply value by 16
      asl
      asl      ;this will give us the proper vertical pixel coordinate
      asl
      asl
      clc
      adc #32  ;add 32 pixels for the status bar
      rts

;-------------------------------------------------------------------------------------
;$06-$07 - used to store block buffer address used as indirect

BlockBufferAddr:
      .db <Block_Buffer_1, <Block_Buffer_2
      .db >Block_Buffer_1, >Block_Buffer_2

GetBlockBufferAddr:
      pha                      ;take value of A, save
      lsr                      ;move high nybble to low
      lsr
      lsr
      lsr
      tay                      ;use nybble as pointer to high byte
      lda BlockBufferAddr+2,y  ;of indirect here
      sta $07
      pla
      and #%00001111           ;pull from stack, mask out high nybble
      clc
      adc BlockBufferAddr,y    ;add to low byte
      sta $06                  ;store here and leave
      rts

;-------------------------------------------------------------------------------------

;unused space
      .db $ff, $ff

;-------------------------------------------------------------------------------------

AreaDataOfsLoopback:
      .db $12, $36, $0e, $0e, $0e, $32, $32, $32, $0a, $26, $40

;-------------------------------------------------------------------------------------

LoadAreaPointer:
             jsr FindAreaPointer  ;find it and store it here
             sta AreaPointer
GetAreaType: and #%01100000       ;mask out all but d6 and d5
             asl
             rol
             rol
             rol                  ;make %0xx00000 into %000000xx
             sta AreaType         ;save 2 MSB as area type
             rts

FindAreaPointer:
      ldy WorldNumber        ;load offset from world variable
      lda WorldAddrOffsets,y
      clc                    ;add area number used to find data
      adc AreaNumber
      tay
      lda AreaAddrOffsets,y  ;from there we have our area pointer
      rts


GetAreaDataAddrs:
            lda AreaPointer          ;use 2 MSB for Y
            jsr GetAreaType
            tay
            lda AreaPointer          ;mask out all but 5 LSB
            and #%00011111
            sta AreaAddrsLOffset     ;save as low offset
            lda EnemyAddrHOffsets,y  ;load base value with 2 altered MSB,
            clc                      ;then add base value to 5 LSB, result
            adc AreaAddrsLOffset     ;becomes offset for level data
            tay
            lda EnemyDataAddrLow,y   ;use offset to load pointer
            sta EnemyDataLow
            lda EnemyDataAddrHigh,y
            sta EnemyDataHigh
            ldy AreaType             ;use area type as offset
            lda AreaDataHOffsets,y   ;do the same thing but with different base value
            clc
            adc AreaAddrsLOffset
            tay
            lda AreaDataAddrLow,y    ;use this offset to load another pointer
            sta AreaDataLow
            lda AreaDataAddrHigh,y
            sta AreaDataHigh
            ldy #$00                 ;load first byte of header
            lda (AreaData),y
            pha                      ;save it to the stack for now
            and #%00000111           ;save 3 LSB for foreground scenery or bg color control
            cmp #$04
            bcc StoreFore
            sta BackgroundColorCtrl  ;if 4 or greater, save value here as bg color control
            lda #$00
StoreFore:  sta ForegroundScenery    ;if less, save value here as foreground scenery
            pla                      ;pull byte from stack and push it back
            pha
            and #%00111000           ;save player entrance control bits
            lsr                      ;shift bits over to LSBs
            lsr
            lsr
            sta PlayerEntranceCtrl       ;save value here as player entrance control
            pla                      ;pull byte again but do not push it back
            and #%11000000           ;save 2 MSB for game timer setting
            clc
            rol                      ;rotate bits over to LSBs
            rol
            rol
            sta GameTimerSetting     ;save value here as game timer setting
            iny
            lda (AreaData),y         ;load second byte of header
            pha                      ;save to stack
            and #%00001111           ;mask out all but lower nybble
            sta TerrainControl
            pla                      ;pull and push byte to copy it to A
            pha
            and #%00110000           ;save 2 MSB for background scenery type
            lsr
            lsr                      ;shift bits to LSBs
            lsr
            lsr
            sta BackgroundScenery    ;save as background scenery
            pla
            and #%11000000
            clc
            rol                      ;rotate bits over to LSBs
            rol
            rol
            cmp #%00000011           ;if set to 3, store here
            bne StoreStyle           ;and nullify other value
            sta CloudTypeOverride    ;otherwise store value in other place
            lda #$00
StoreStyle: sta AreaStyle
            lda AreaDataLow          ;increment area data address by 2 bytes
            clc
            adc #$02
            sta AreaDataLow
            lda AreaDataHigh
            adc #$00
            sta AreaDataHigh
            rts

;-------------------------------------------------------------------------------------
;GAME LEVELS DATA

WorldAddrOffsets:
      .db World1Areas-AreaAddrOffsets, World2Areas-AreaAddrOffsets
      .db World3Areas-AreaAddrOffsets, World4Areas-AreaAddrOffsets
      .db World5Areas-AreaAddrOffsets, World6Areas-AreaAddrOffsets
      .db World7Areas-AreaAddrOffsets, World8Areas-AreaAddrOffsets

AreaAddrOffsets:
World1Areas: .db $25, $29, $c0, $26, $60
World2Areas: .db $28, $29, $01, $27, $62
World3Areas: .db $24, $35, $20, $63
World4Areas: .db $22, $29, $41, $2c, $61
World5Areas: .db $2a, $31, $26, $62
World6Areas: .db $2e, $23, $2d, $60
World7Areas: .db $33, $29, $01, $27, $64
World8Areas: .db $30, $32, $21, $65

;bonus area data offsets, included here for comparison purposes
;underground bonus area  - c2
;cloud area 1 (day)      - 2b
;cloud area 2 (night)    - 34
;water area (5-2/6-2)    - 00
;water area (8-4)        - 02
;warp zone area (4-2)    - 2f

EnemyAddrHOffsets:
      .db $1f, $06, $1c, $00

EnemyDataAddrLow:
      .db <E_CastleArea1, <E_CastleArea2, <E_CastleArea3, <E_CastleArea4, <E_CastleArea5, <E_CastleArea6
      .db <E_GroundArea1, <E_GroundArea2, <E_GroundArea3, <E_GroundArea4, <E_GroundArea5, <E_GroundArea6
      .db <E_GroundArea7, <E_GroundArea8, <E_GroundArea9, <E_GroundArea10, <E_GroundArea11, <E_GroundArea12
      .db <E_GroundArea13, <E_GroundArea14, <E_GroundArea15, <E_GroundArea16, <E_GroundArea17, <E_GroundArea18
      .db <E_GroundArea19, <E_GroundArea20, <E_GroundArea21, <E_GroundArea22, <E_UndergroundArea1
      .db <E_UndergroundArea2, <E_UndergroundArea3, <E_WaterArea1, <E_WaterArea2, <E_WaterArea3

EnemyDataAddrHigh:
      .db >E_CastleArea1, >E_CastleArea2, >E_CastleArea3, >E_CastleArea4, >E_CastleArea5, >E_CastleArea6
      .db >E_GroundArea1, >E_GroundArea2, >E_GroundArea3, >E_GroundArea4, >E_GroundArea5, >E_GroundArea6
      .db >E_GroundArea7, >E_GroundArea8, >E_GroundArea9, >E_GroundArea10, >E_GroundArea11, >E_GroundArea12
      .db >E_GroundArea13, >E_GroundArea14, >E_GroundArea15, >E_GroundArea16, >E_GroundArea17, >E_GroundArea18
      .db >E_GroundArea19, >E_GroundArea20, >E_GroundArea21, >E_GroundArea22, >E_UndergroundArea1
      .db >E_UndergroundArea2, >E_UndergroundArea3, >E_WaterArea1, >E_WaterArea2, >E_WaterArea3

AreaDataHOffsets:
      .db $00, $03, $19, $1c

AreaDataAddrLow:
      .db <L_WaterArea1, <L_WaterArea2, <L_WaterArea3, <L_GroundArea1, <L_GroundArea2, <L_GroundArea3
      .db <L_GroundArea4, <L_GroundArea5, <L_GroundArea6, <L_GroundArea7, <L_GroundArea8, <L_GroundArea9
      .db <L_GroundArea10, <L_GroundArea11, <L_GroundArea12, <L_GroundArea13, <L_GroundArea14, <L_GroundArea15
      .db <L_GroundArea16, <L_GroundArea17, <L_GroundArea18, <L_GroundArea19, <L_GroundArea20, <L_GroundArea21
      .db <L_GroundArea22, <L_UndergroundArea1, <L_UndergroundArea2, <L_UndergroundArea3, <L_CastleArea1
      .db <L_CastleArea2, <L_CastleArea3, <L_CastleArea4, <L_CastleArea5, <L_CastleArea6

AreaDataAddrHigh:
      .db >L_WaterArea1, >L_WaterArea2, >L_WaterArea3, >L_GroundArea1, >L_GroundArea2, >L_GroundArea3
      .db >L_GroundArea4, >L_GroundArea5, >L_GroundArea6, >L_GroundArea7, >L_GroundArea8, >L_GroundArea9
      .db >L_GroundArea10, >L_GroundArea11, >L_GroundArea12, >L_GroundArea13, >L_GroundArea14, >L_GroundArea15
      .db >L_GroundArea16, >L_GroundArea17, >L_GroundArea18, >L_GroundArea19, >L_GroundArea20, >L_GroundArea21
      .db >L_GroundArea22, >L_UndergroundArea1, >L_UndergroundArea2, >L_UndergroundArea3, >L_CastleArea1
      .db >L_CastleArea2, >L_CastleArea3, >L_CastleArea4, >L_CastleArea5, >L_CastleArea6

;ENEMY OBJECT DATA

;level 1-4/6-4
E_CastleArea1:
      .db $76, $dd, $bb, $4c, $ea, $1d, $1b, $cc, $56, $5d
      .db $16, $9d, $c6, $1d, $36, $9d, $c9, $1d, $04, $db
      .db $49, $1d, $84, $1b, $c9, $5d, $88, $95, $0f, $08
      .db $30, $4c, $78, $2d, $a6, $28, $90, $b5
      .db $ff

;level 4-4
E_CastleArea2:
      .db $0f, $03, $56, $1b, $c9, $1b, $0f, $07, $36, $1b
      .db $aa, $1b, $48, $95, $0f, $0a, $2a, $1b, $5b, $0c
      .db $78, $2d, $90, $b5
      .db $ff

;level 2-4/5-4
E_CastleArea3:
      .db $0b, $8c, $4b, $4c, $77, $5f, $eb, $0c, $bd, $db
      .db $19, $9d, $75, $1d, $7d, $5b, $d9, $1d, $3d, $dd
      .db $99, $1d, $26, $9d, $5a, $2b, $8a, $2c, $ca, $1b
      .db $20, $95, $7b, $5c, $db, $4c, $1b, $cc, $3b, $cc
      .db $78, $2d, $a6, $28, $90, $b5
      .db $ff

;level 3-4
E_CastleArea4:
      .db $0b, $8c, $3b, $1d, $8b, $1d, $ab, $0c, $db, $1d
      .db $0f, $03, $65, $1d, $6b, $1b, $05, $9d, $0b, $1b
      .db $05, $9b, $0b, $1d, $8b, $0c, $1b, $8c, $70, $15
      .db $7b, $0c, $db, $0c, $0f, $08, $78, $2d, $a6, $28
      .db $90, $b5
      .db $ff

;level 7-4
E_CastleArea5:
      .db $27, $a9, $4b, $0c, $68, $29, $0f, $06, $77, $1b
      .db $0f, $0b, $60, $15, $4b, $8c, $78, $2d, $90, $b5
      .db $ff

;level 8-4
E_CastleArea6:
      .db $0f, $03, $8e, $65, $e1, $bb, $38, $6d, $a8, $3e, $e5, $e7
      .db $0f, $08, $0b, $02, $2b, $02, $5e, $65, $e1, $bb, $0e
      .db $db, $0e, $bb, $8e, $db, $0e, $fe, $65, $ec, $0f, $0d
      .db $4e, $65, $e1, $0f, $0e, $4e, $02, $e0, $0f, $10, $fe, $e5, $e1
      .db $1b, $85, $7b, $0c, $5b, $95, $78, $2d, $90, $b5
      .db $ff

;level 3-3
E_GroundArea1:
      .db $a5, $86, $e4, $28, $18, $a8, $45, $83, $69, $03
      .db $c6, $29, $9b, $83, $16, $a4, $88, $24, $e9, $28
      .db $05, $a8, $7b, $28, $24, $8f, $c8, $03, $e8, $03
      .db $46, $a8, $85, $24, $c8, $24
      .db $ff

;level 8-3
E_GroundArea2:
      .db $eb, $8e, $0f, $03, $fb, $05, $17, $85, $db, $8e
      .db $0f, $07, $57, $05, $7b, $05, $9b, $80, $2b, $85
      .db $fb, $05, $0f, $0b, $1b, $05, $9b, $05
      .db $ff

;level 4-1
E_GroundArea3:
      .db $2e, $c2, $66, $e2, $11, $0f, $07, $02, $11, $0f, $0c
      .db $12, $11
      .db $ff

;level 6-2
E_GroundArea4:
      .db $0e, $c2, $a8, $ab, $00, $bb, $8e, $6b, $82, $de, $00, $a0
      .db $33, $86, $43, $06, $3e, $b4, $a0, $cb, $02, $0f, $07
      .db $7e, $42, $a6, $83, $02, $0f, $0a, $3b, $02, $cb, $37
      .db $0f, $0c, $e3, $0e
      .db $ff

;level 3-1
E_GroundArea5:
      .db $9b, $8e, $ca, $0e, $ee, $42, $44, $5b, $86, $80, $b8
      .db $1b, $80, $50, $ba, $10, $b7, $5b, $00, $17, $85
      .db $4b, $05, $fe, $34, $40, $b7, $86, $c6, $06, $5b, $80
      .db $83, $00, $d0, $38, $5b, $8e, $8a, $0e, $a6, $00
      .db $bb, $0e, $c5, $80, $f3, $00
      .db $ff

;level 1-1
E_GroundArea6:
      .db $1e, $c2, $00, $6b, $06, $8b, $86, $63, $b7, $0f, $05
      .db $03, $06, $23, $06, $4b, $b7, $bb, $00, $5b, $b7
      .db $fb, $37, $3b, $b7, $0f, $0b, $1b, $37
      .db $ff

;level 1-3/5-3
E_GroundArea7:
      .db $2b, $d7, $e3, $03, $c2, $86, $e2, $06, $76, $a5
      .db $a3, $8f, $03, $86, $2b, $57, $68, $28, $e9, $28
      .db $e5, $83, $24, $8f, $36, $a8, $5b, $03
      .db $ff

;level 2-3/7-3
E_GroundArea8:
      .db $0f, $02, $78, $40, $48, $ce, $f8, $c3, $f8, $c3
      .db $0f, $07, $7b, $43, $c6, $d0, $0f, $8a, $c8, $50
      .db $ff

;level 2-1
E_GroundArea9:
      .db $85, $86, $0b, $80, $1b, $00, $db, $37, $77, $80
      .db $eb, $37, $fe, $2b, $20, $2b, $80, $7b, $38, $ab, $b8
      .db $77, $86, $fe, $42, $20, $49, $86, $8b, $06, $9b, $80
      .db $7b, $8e, $5b, $b7, $9b, $0e, $bb, $0e, $9b, $80
;end of data terminator here is also used by pipe intro area
E_GroundArea10:
      .db $ff

;level 5-1
E_GroundArea11:
      .db $0b, $80, $60, $38, $10, $b8, $c0, $3b, $db, $8e
      .db $40, $b8, $f0, $38, $7b, $8e, $a0, $b8, $c0, $b8
      .db $fb, $00, $a0, $b8, $30, $bb, $ee, $42, $88, $0f, $0b
      .db $2b, $0e, $67, $0e
      .db $ff

;cloud level used in levels 2-1 and 5-2
E_GroundArea12:
      .db $0a, $aa, $0e, $28, $2a, $0e, $31, $88
      .db $ff

;level 4-3
E_GroundArea13:
      .db $c7, $83, $d7, $03, $42, $8f, $7a, $03, $05, $a4
      .db $78, $24, $a6, $25, $e4, $25, $4b, $83, $e3, $03
      .db $05, $a4, $89, $24, $b5, $24, $09, $a4, $65, $24
      .db $c9, $24, $0f, $08, $85, $25
      .db $ff

;level 6-3
E_GroundArea14:
      .db $cd, $a5, $b5, $a8, $07, $a8, $76, $28, $cc, $25
      .db $65, $a4, $a9, $24, $e5, $24, $19, $a4, $0f, $07
      .db $95, $28, $e6, $24, $19, $a4, $d7, $29, $16, $a9
      .db $58, $29, $97, $29
      .db $ff

;level 6-1
E_GroundArea15:
      .db $0f, $02, $02, $11, $0f, $07, $02, $11
      .db $ff

;warp zone area used in level 4-2
E_GroundArea16:
      .db $ff

;level 8-1
E_GroundArea17:
      .db $2b, $82, $ab, $38, $de, $42, $e2, $1b, $b8, $eb
      .db $3b, $db, $80, $8b, $b8, $1b, $82, $fb, $b8, $7b
      .db $80, $fb, $3c, $5b, $bc, $7b, $b8, $1b, $8e, $cb
      .db $0e, $1b, $8e, $0f, $0d, $2b, $3b, $bb, $b8, $eb, $82
      .db $4b, $b8, $bb, $38, $3b, $b7, $bb, $02, $0f, $13
      .db $1b, $00, $cb, $80, $6b, $bc
      .db $ff

;level 5-2
E_GroundArea18:
      .db $7b, $80, $ae, $00, $80, $8b, $8e, $e8, $05, $f9, $86
      .db $17, $86, $16, $85, $4e, $2b, $80, $ab, $8e, $87, $85
      .db $c3, $05, $8b, $82, $9b, $02, $ab, $02, $bb, $86
      .db $cb, $06, $d3, $03, $3b, $8e, $6b, $0e, $a7, $8e
      .db $ff

;level 8-2
E_GroundArea19:
      .db $29, $8e, $52, $11, $83, $0e, $0f, $03, $9b, $0e
      .db $2b, $8e, $5b, $0e, $cb, $8e, $fb, $0e, $fb, $82
      .db $9b, $82, $bb, $02, $fe, $42, $e8, $bb, $8e, $0f, $0a
      .db $ab, $0e, $cb, $0e, $f9, $0e, $88, $86, $a6, $06
      .db $db, $02, $b6, $8e
      .db $ff

;level 7-1
E_GroundArea20:
      .db $ab, $ce, $de, $42, $c0, $cb, $ce, $5b, $8e, $1b, $ce
      .db $4b, $85, $67, $45, $0f, $07, $2b, $00, $7b, $85
      .db $97, $05, $0f, $0a, $92, $02
      .db $ff

;cloud level used in levels 3-1 and 6-2
E_GroundArea21:
      .db $0a, $aa, $0e, $24, $4a, $1e, $23, $aa
      .db $ff

;level 3-2
E_GroundArea22:
      .db $1b, $80, $bb, $38, $4b, $bc, $eb, $3b, $0f, $04
      .db $2b, $00, $ab, $38, $eb, $00, $cb, $8e, $fb, $80
      .db $ab, $b8, $6b, $80, $fb, $3c, $9b, $bb, $5b, $bc
      .db $fb, $00, $6b, $b8, $fb, $38
      .db $ff

;level 1-2
E_UndergroundArea1:
      .db $0b, $86, $1a, $06, $db, $06, $de, $c2, $02, $f0, $3b
      .db $bb, $80, $eb, $06, $0b, $86, $93, $06, $f0, $39
      .db $0f, $06, $60, $b8, $1b, $86, $a0, $b9, $b7, $27
      .db $bd, $27, $2b, $83, $a1, $26, $a9, $26, $ee, $25, $0b
      .db $27, $b4
      .db $ff

;level 4-2
E_UndergroundArea2:
      .db $0f, $02, $1e, $2f, $60, $e0, $3a, $a5, $a7, $db, $80
      .db $3b, $82, $8b, $02, $fe, $42, $68, $70, $bb, $25, $a7
      .db $2c, $27, $b2, $26, $b9, $26, $9b, $80, $a8, $82
      .db $b5, $27, $bc, $27, $b0, $bb, $3b, $82, $87, $34
      .db $ee, $25, $6b
      .db $ff

;underground bonus rooms area used in many levels
E_UndergroundArea3:
      .db $1e, $a5, $0a, $2e, $28, $27, $2e, $33, $c7, $0f, $03, $1e, $40, $07
      .db $2e, $30, $e7, $0f, $05, $1e, $24, $44, $0f, $07, $1e, $22, $6a
      .db $2e, $23, $ab, $0f, $09, $1e, $41, $68, $1e, $2a, $8a, $2e, $23, $a2
      .db $2e, $32, $ea
      .db $ff

;water area used in levels 5-2 and 6-2
E_WaterArea1:
      .db $3b, $87, $66, $27, $cc, $27, $ee, $31, $87, $ee, $23, $a7
      .db $3b, $87, $db, $07
      .db $ff

;level 2-2/7-2
E_WaterArea2:
      .db $0f, $01, $2e, $25, $2b, $2e, $25, $4b, $4e, $25, $cb, $6b, $07
      .db $97, $47, $e9, $87, $47, $c7, $7a, $07, $d6, $c7
      .db $78, $07, $38, $87, $ab, $47, $e3, $07, $9b, $87
      .db $0f, $09, $68, $47, $db, $c7, $3b, $c7
      .db $ff

;water area used in level 8-4
E_WaterArea3:
      .db $47, $9b, $cb, $07, $fa, $1d, $86, $9b, $3a, $87
      .db $56, $07, $88, $1b, $07, $9d, $2e, $65, $f0
      .db $ff

;AREA OBJECT DATA

;level 1-4/6-4
L_CastleArea1:
      .db $9b, $07
      .db $05, $32, $06, $33, $07, $34, $ce, $03, $dc, $51
      .db $ee, $07, $73, $e0, $74, $0a, $7e, $06, $9e, $0a
      .db $ce, $06, $e4, $00, $e8, $0a, $fe, $0a, $2e, $89
      .db $4e, $0b, $54, $0a, $14, $8a, $c4, $0a, $34, $8a
      .db $7e, $06, $c7, $0a, $01, $e0, $02, $0a, $47, $0a
      .db $81, $60, $82, $0a, $c7, $0a, $0e, $87, $7e, $02
      .db $a7, $02, $b3, $02, $d7, $02, $e3, $02, $07, $82
      .db $13, $02, $3e, $06, $7e, $02, $ae, $07, $fe, $0a
      .db $0d, $c4, $cd, $43, $ce, $09, $de, $0b, $dd, $42
      .db $fe, $02, $5d, $c7
      .db $fd

;level 4-4
L_CastleArea2:
      .db $5b, $07
      .db $05, $32, $06, $33, $07, $34, $5e, $0a, $68, $64
      .db $98, $64, $a8, $64, $ce, $06, $fe, $02, $0d, $01
      .db $1e, $0e, $7e, $02, $94, $63, $b4, $63, $d4, $63
      .db $f4, $63, $14, $e3, $2e, $0e, $5e, $02, $64, $35
      .db $88, $72, $be, $0e, $0d, $04, $ae, $02, $ce, $08
      .db $cd, $4b, $fe, $02, $0d, $05, $68, $31, $7e, $0a
      .db $96, $31, $a9, $63, $a8, $33, $d5, $30, $ee, $02
      .db $e6, $62, $f4, $61, $04, $b1, $08, $3f, $44, $33
      .db $94, $63, $a4, $31, $e4, $31, $04, $bf, $08, $3f
      .db $04, $bf, $08, $3f, $cd, $4b, $03, $e4, $0e, $03
      .db $2e, $01, $7e, $06, $be, $02, $de, $06, $fe, $0a
      .db $0d, $c4, $cd, $43, $ce, $09, $de, $0b, $dd, $42
      .db $fe, $02, $5d, $c7
      .db $fd

;level 2-4/5-4
L_CastleArea3:
      .db $9b, $07
      .db $05, $32, $06, $33, $07, $34, $fe, $00, $27, $b1
      .db $65, $32, $75, $0a, $71, $00, $b7, $31, $08, $e4
      .db $18, $64, $1e, $04, $57, $3b, $bb, $0a, $17, $8a
      .db $27, $3a, $73, $0a, $7b, $0a, $d7, $0a, $e7, $3a
      .db $3b, $8a, $97, $0a, $fe, $08, $24, $8a, $2e, $00
      .db $3e, $40, $38, $64, $6f, $00, $9f, $00, $be, $43
      .db $c8, $0a, $c9, $63, $ce, $07, $fe, $07, $2e, $81
      .db $66, $42, $6a, $42, $79, $0a, $be, $00, $c8, $64
      .db $f8, $64, $08, $e4, $2e, $07, $7e, $03, $9e, $07
      .db $be, $03, $de, $07, $fe, $0a, $03, $a5, $0d, $44
      .db $cd, $43, $ce, $09, $dd, $42, $de, $0b, $fe, $02
      .db $5d, $c7
      .db $fd

;level 3-4
L_CastleArea4:
      .db $9b, $07
      .db $05, $32, $06, $33, $07, $34, $fe, $06, $0c, $81
      .db $39, $0a, $5c, $01, $89, $0a, $ac, $01, $d9, $0a
      .db $fc, $01, $2e, $83, $a7, $01, $b7, $00, $c7, $01
      .db $de, $0a, $fe, $02, $4e, $83, $5a, $32, $63, $0a
      .db $69, $0a, $7e, $02, $ee, $03, $fa, $32, $03, $8a
      .db $09, $0a, $1e, $02, $ee, $03, $fa, $32, $03, $8a
      .db $09, $0a, $14, $42, $1e, $02, $7e, $0a, $9e, $07
      .db $fe, $0a, $2e, $86, $5e, $0a, $8e, $06, $be, $0a
      .db $ee, $07, $3e, $83, $5e, $07, $fe, $0a, $0d, $c4
      .db $41, $52, $51, $52, $cd, $43, $ce, $09, $de, $0b
      .db $dd, $42, $fe, $02, $5d, $c7
      .db $fd

;level 7-4
L_CastleArea5:
      .db $5b, $07
      .db $05, $32, $06, $33, $07, $34, $fe, $0a, $ae, $86
      .db $be, $07, $fe, $02, $0d, $02, $27, $32, $46, $61
      .db $55, $62, $5e, $0e, $1e, $82, $68, $3c, $74, $3a
      .db $7d, $4b, $5e, $8e, $7d, $4b, $7e, $82, $84, $62
      .db $94, $61, $a4, $31, $bd, $4b, $ce, $06, $fe, $02
      .db $0d, $06, $34, $31, $3e, $0a, $64, $32, $75, $0a
      .db $7b, $61, $a4, $33, $ae, $02, $de, $0e, $3e, $82
      .db $64, $32, $78, $32, $b4, $36, $c8, $36, $dd, $4b
      .db $44, $b2, $58, $32, $94, $63, $a4, $3e, $ba, $30
      .db $c9, $61, $ce, $06, $dd, $4b, $ce, $86, $dd, $4b
      .db $fe, $02, $2e, $86, $5e, $02, $7e, $06, $fe, $02
      .db $1e, $86, $3e, $02, $5e, $06, $7e, $02, $9e, $06
      .db $fe, $0a, $0d, $c4, $cd, $43, $ce, $09, $de, $0b
      .db $dd, $42, $fe, $02, $5d, $c7
      .db $fd

;level 8-4
L_CastleArea6:
      .db $5b, $06
      .db $05, $32, $06, $33, $07, $34, $5e, $0a, $ae, $02
      .db $0d, $01, $39, $73, $0d, $03, $39, $7b, $4d, $4b
      .db $de, $06, $1e, $8a, $ae, $06, $c4, $33, $16, $fe
      .db $a5, $77, $fe, $02, $fe, $82, $0d, $07, $39, $73
      .db $a8, $74, $ed, $4b, $49, $fb, $e8, $74, $fe, $0a
      .db $2e, $82, $67, $02, $84, $7a, $87, $31, $0d, $0b
      .db $fe, $02, $0d, $0c, $39, $73, $5e, $06, $c6, $76
      .db $45, $ff, $be, $0a, $dd, $48, $fe, $06, $3d, $cb
      .db $46, $7e, $ad, $4a, $fe, $82, $39, $f3, $a9, $7b
      .db $4e, $8a, $9e, $07, $fe, $0a, $0d, $c4, $cd, $43
      .db $ce, $09, $de, $0b, $dd, $42, $fe, $02, $5d, $c7
      .db $fd

;level 3-3
L_GroundArea1:
      .db $94, $11
      .db $0f, $26, $fe, $10, $28, $94, $65, $15, $eb, $12
      .db $fa, $41, $4a, $96, $54, $40, $a4, $42, $b7, $13
      .db $e9, $19, $f5, $15, $11, $80, $47, $42, $71, $13
      .db $80, $41, $15, $92, $1b, $1f, $24, $40, $55, $12
      .db $64, $40, $95, $12, $a4, $40, $d2, $12, $e1, $40
      .db $13, $c0, $2c, $17, $2f, $12, $49, $13, $83, $40
      .db $9f, $14, $a3, $40, $17, $92, $83, $13, $92, $41
      .db $b9, $14, $c5, $12, $c8, $40, $d4, $40, $4b, $92
      .db $78, $1b, $9c, $94, $9f, $11, $df, $14, $fe, $11
      .db $7d, $c1, $9e, $42, $cf, $20
      .db $fd

;level 8-3
L_GroundArea2:
      .db $90, $b1
      .db $0f, $26, $29, $91, $7e, $42, $fe, $40, $28, $92
      .db $4e, $42, $2e, $c0, $57, $73, $c3, $25, $c7, $27
      .db $23, $84, $33, $20, $5c, $01, $77, $63, $88, $62
      .db $99, $61, $aa, $60, $bc, $01, $ee, $42, $4e, $c0
      .db $69, $11, $7e, $42, $de, $40, $f8, $62, $0e, $c2
      .db $ae, $40, $d7, $63, $e7, $63, $33, $a7, $37, $27
      .db $43, $04, $cc, $01, $e7, $73, $0c, $81, $3e, $42
      .db $0d, $0a, $5e, $40, $88, $72, $be, $42, $e7, $87
      .db $fe, $40, $39, $e1, $4e, $00, $69, $60, $87, $60
      .db $a5, $60, $c3, $31, $fe, $31, $6d, $c1, $be, $42
      .db $ef, $20
      .db $fd

;level 4-1
L_GroundArea3:
      .db $52, $21
      .db $0f, $20, $6e, $40, $58, $f2, $93, $01, $97, $00
      .db $0c, $81, $97, $40, $a6, $41, $c7, $40, $0d, $04
      .db $03, $01, $07, $01, $23, $01, $27, $01, $ec, $03
      .db $ac, $f3, $c3, $03, $78, $e2, $94, $43, $47, $f3
      .db $74, $43, $47, $fb, $74, $43, $2c, $f1, $4c, $63
      .db $47, $00, $57, $21, $5c, $01, $7c, $72, $39, $f1
      .db $ec, $02, $4c, $81, $d8, $62, $ec, $01, $0d, $0d
      .db $0f, $38, $c7, $07, $ed, $4a, $1d, $c1, $5f, $26
      .db $fd

;level 6-2
L_GroundArea4:
      .db $54, $21
      .db $0f, $26, $a7, $22, $37, $fb, $73, $20, $83, $07
      .db $87, $02, $93, $20, $c7, $73, $04, $f1, $06, $31
      .db $39, $71, $59, $71, $e7, $73, $37, $a0, $47, $04
      .db $86, $7c, $e5, $71, $e7, $31, $33, $a4, $39, $71
      .db $a9, $71, $d3, $23, $08, $f2, $13, $05, $27, $02
      .db $49, $71, $75, $75, $e8, $72, $67, $f3, $99, $71
      .db $e7, $20, $f4, $72, $f7, $31, $17, $a0, $33, $20
      .db $39, $71, $73, $28, $bc, $05, $39, $f1, $79, $71
      .db $a6, $21, $c3, $06, $d3, $20, $dc, $00, $fc, $00
      .db $07, $a2, $13, $21, $5f, $32, $8c, $00, $98, $7a
      .db $c7, $63, $d9, $61, $03, $a2, $07, $22, $74, $72
      .db $77, $31, $e7, $73, $39, $f1, $58, $72, $77, $73
      .db $d8, $72, $7f, $b1, $97, $73, $b6, $64, $c5, $65
      .db $d4, $66, $e3, $67, $f3, $67, $8d, $c1, $cf, $26
      .db $fd

;level 3-1
L_GroundArea5:
      .db $52, $31
      .db $0f, $20, $6e, $66, $07, $81, $36, $01, $66, $00
      .db $a7, $22, $08, $f2, $67, $7b, $dc, $02, $98, $f2
      .db $d7, $20, $39, $f1, $9f, $33, $dc, $27, $dc, $57
      .db $23, $83, $57, $63, $6c, $51, $87, $63, $99, $61
      .db $a3, $06, $b3, $21, $77, $f3, $f3, $21, $f7, $2a
      .db $13, $81, $23, $22, $53, $00, $63, $22, $e9, $0b
      .db $0c, $83, $13, $21, $16, $22, $33, $05, $8f, $35
      .db $ec, $01, $63, $a0, $67, $20, $73, $01, $77, $01
      .db $83, $20, $87, $20, $b3, $20, $b7, $20, $c3, $01
      .db $c7, $00, $d3, $20, $d7, $20, $67, $a0, $77, $07
      .db $87, $22, $e8, $62, $f5, $65, $1c, $82, $7f, $38
      .db $8d, $c1, $cf, $26
      .db $fd

;level 1-1
L_GroundArea6:
      .db $50, $21
      .db $07, $81, $47, $24, $57, $00, $63, $01, $77, $01
      .db $c9, $71, $68, $f2, $e7, $73, $97, $fb, $06, $83
      .db $5c, $01, $d7, $22, $e7, $00, $03, $a7, $6c, $02
      .db $b3, $22, $e3, $01, $e7, $07, $47, $a0, $57, $06
      .db $a7, $01, $d3, $00, $d7, $01, $07, $81, $67, $20
      .db $93, $22, $03, $a3, $1c, $61, $17, $21, $6f, $33
      .db $c7, $63, $d8, $62, $e9, $61, $fa, $60, $4f, $b3
      .db $87, $63, $9c, $01, $b7, $63, $c8, $62, $d9, $61
      .db $ea, $60, $39, $f1, $87, $21, $a7, $01, $b7, $20
      .db $39, $f1, $5f, $38, $6d, $c1, $af, $26
      .db $fd

;level 1-3/5-3
L_GroundArea7:
      .db $90, $11
      .db $0f, $26, $fe, $10, $2a, $93, $87, $17, $a3, $14
      .db $b2, $42, $0a, $92, $19, $40, $36, $14, $50, $41
      .db $82, $16, $2b, $93, $24, $41, $bb, $14, $b8, $00
      .db $c2, $43, $c3, $13, $1b, $94, $67, $12, $c4, $15
      .db $53, $c1, $d2, $41, $12, $c1, $29, $13, $85, $17
      .db $1b, $92, $1a, $42, $47, $13, $83, $41, $a7, $13
      .db $0e, $91, $a7, $63, $b7, $63, $c5, $65, $d5, $65
      .db $dd, $4a, $e3, $67, $f3, $67, $8d, $c1, $ae, $42
      .db $df, $20
      .db $fd

;level 2-3/7-3
L_GroundArea8:
      .db $90, $11
      .db $0f, $26, $6e, $10, $8b, $17, $af, $32, $d8, $62
      .db $e8, $62, $fc, $3f, $ad, $c8, $f8, $64, $0c, $be
      .db $43, $43, $f8, $64, $0c, $bf, $73, $40, $84, $40
      .db $93, $40, $a4, $40, $b3, $40, $f8, $64, $48, $e4
      .db $5c, $39, $83, $40, $92, $41, $b3, $40, $f8, $64
      .db $48, $e4, $5c, $39, $f8, $64, $13, $c2, $37, $65
      .db $4c, $24, $63, $00, $97, $65, $c3, $42, $0b, $97
      .db $ac, $32, $f8, $64, $0c, $be, $53, $45, $9d, $48
      .db $f8, $64, $2a, $e2, $3c, $47, $56, $43, $ba, $62
      .db $f8, $64, $0c, $b7, $88, $64, $bc, $31, $d4, $45
      .db $fc, $31, $3c, $b1, $78, $64, $8c, $38, $0b, $9c
      .db $1a, $33, $18, $61, $28, $61, $39, $60, $5d, $4a
      .db $ee, $11, $0f, $b8, $1d, $c1, $3e, $42, $6f, $20
      .db $fd

;level 2-1
L_GroundArea9:
      .db $52, $31
      .db $0f, $20, $6e, $40, $f7, $20, $07, $84, $17, $20
      .db $4f, $34, $c3, $03, $c7, $02, $d3, $22, $27, $e3
      .db $39, $61, $e7, $73, $5c, $e4, $57, $00, $6c, $73
      .db $47, $a0, $53, $06, $63, $22, $a7, $73, $fc, $73
      .db $13, $a1, $33, $05, $43, $21, $5c, $72, $c3, $23
      .db $cc, $03, $77, $fb, $ac, $02, $39, $f1, $a7, $73
      .db $d3, $04, $e8, $72, $e3, $22, $26, $f4, $bc, $02
      .db $8c, $81, $a8, $62, $17, $87, $43, $24, $a7, $01
      .db $c3, $04, $08, $f2, $97, $21, $a3, $02, $c9, $0b
      .db $e1, $69, $f1, $69, $8d, $c1, $cf, $26
      .db $fd

;pipe intro area
L_GroundArea10:
      .db $38, $11
      .db $0f, $26, $ad, $40, $3d, $c7
      .db $fd

;level 5-1
L_GroundArea11:
      .db $95, $b1
      .db $0f, $26, $0d, $02, $c8, $72, $1c, $81, $38, $72
      .db $0d, $05, $97, $34, $98, $62, $a3, $20, $b3, $06
      .db $c3, $20, $cc, $03, $f9, $91, $2c, $81, $48, $62
      .db $0d, $09, $37, $63, $47, $03, $57, $21, $8c, $02
      .db $c5, $79, $c7, $31, $f9, $11, $39, $f1, $a9, $11
      .db $6f, $b4, $d3, $65, $e3, $65, $7d, $c1, $bf, $26
      .db $fd

;cloud level used in levels 2-1 and 5-2
L_GroundArea12:
      .db $00, $c1
      .db $4c, $00, $f4, $4f, $0d, $02, $02, $42, $43, $4f
      .db $52, $c2, $de, $00, $5a, $c2, $4d, $c7
      .db $fd

;level 4-3
L_GroundArea13:
      .db $90, $51
      .db $0f, $26, $ee, $10, $0b, $94, $33, $14, $42, $42
      .db $77, $16, $86, $44, $02, $92, $4a, $16, $69, $42
      .db $73, $14, $b0, $00, $c7, $12, $05, $c0, $1c, $17
      .db $1f, $11, $36, $12, $8f, $14, $91, $40, $1b, $94
      .db $35, $12, $34, $42, $60, $42, $61, $12, $87, $12
      .db $96, $40, $a3, $14, $1c, $98, $1f, $11, $47, $12
      .db $9f, $15, $cc, $15, $cf, $11, $05, $c0, $1f, $15
      .db $39, $12, $7c, $16, $7f, $11, $82, $40, $98, $12
      .db $df, $15, $16, $c4, $17, $14, $54, $12, $9b, $16
      .db $28, $94, $ce, $01, $3d, $c1, $5e, $42, $8f, $20
      .db $fd

;level 6-3
L_GroundArea14:
      .db $97, $11
      .db $0f, $26, $fe, $10, $2b, $92, $57, $12, $8b, $12
      .db $c0, $41, $f7, $13, $5b, $92, $69, $0b, $bb, $12
      .db $b2, $46, $19, $93, $71, $00, $17, $94, $7c, $14
      .db $7f, $11, $93, $41, $bf, $15, $fc, $13, $ff, $11
      .db $2f, $95, $50, $42, $51, $12, $58, $14, $a6, $12
      .db $db, $12, $1b, $93, $46, $43, $7b, $12, $8d, $49
      .db $b7, $14, $1b, $94, $49, $0b, $bb, $12, $fc, $13
      .db $ff, $12, $03, $c1, $2f, $15, $43, $12, $4b, $13
      .db $77, $13, $9d, $4a, $15, $c1, $a1, $41, $c3, $12
      .db $fe, $01, $7d, $c1, $9e, $42, $cf, $20
      .db $fd

;level 6-1
L_GroundArea15:
      .db $52, $21
      .db $0f, $20, $6e, $44, $0c, $f1, $4c, $01, $aa, $35
      .db $d9, $34, $ee, $20, $08, $b3, $37, $32, $43, $04
      .db $4e, $21, $53, $20, $7c, $01, $97, $21, $b7, $07
      .db $9c, $81, $e7, $42, $5f, $b3, $97, $63, $ac, $02
      .db $c5, $41, $49, $e0, $58, $61, $76, $64, $85, $65
      .db $94, $66, $a4, $22, $a6, $03, $c8, $22, $dc, $02
      .db $68, $f2, $96, $42, $13, $82, $17, $02, $af, $34
      .db $f6, $21, $fc, $06, $26, $80, $2a, $24, $36, $01
      .db $8c, $00, $ff, $35, $4e, $a0, $55, $21, $77, $20
      .db $87, $07, $89, $22, $ae, $21, $4c, $82, $9f, $34
      .db $ec, $01, $03, $e7, $13, $67, $8d, $4a, $ad, $41
      .db $0f, $a6
      .db $fd

;warp zone area used in level 4-2
L_GroundArea16:
      .db $10, $51
      .db $4c, $00, $c7, $12, $c6, $42, $03, $92, $02, $42
      .db $29, $12, $63, $12, $62, $42, $69, $14, $a5, $12
      .db $a4, $42, $e2, $14, $e1, $44, $f8, $16, $37, $c1
      .db $8f, $38, $02, $bb, $28, $7a, $68, $7a, $a8, $7a
      .db $e0, $6a, $f0, $6a, $6d, $c5
      .db $fd

;level 8-1
L_GroundArea17:
      .db $92, $31
      .db $0f, $20, $6e, $40, $0d, $02, $37, $73, $ec, $00
      .db $0c, $80, $3c, $00, $6c, $00, $9c, $00, $06, $c0
      .db $c7, $73, $06, $83, $28, $72, $96, $40, $e7, $73
      .db $26, $c0, $87, $7b, $d2, $41, $39, $f1, $c8, $f2
      .db $97, $e3, $a3, $23, $e7, $02, $e3, $07, $f3, $22
      .db $37, $e3, $9c, $00, $bc, $00, $ec, $00, $0c, $80
      .db $3c, $00, $86, $21, $a6, $06, $b6, $24, $5c, $80
      .db $7c, $00, $9c, $00, $29, $e1, $dc, $05, $f6, $41
      .db $dc, $80, $e8, $72, $0c, $81, $27, $73, $4c, $01
      .db $66, $74, $0d, $11, $3f, $35, $b6, $41, $2c, $82
      .db $36, $40, $7c, $02, $86, $40, $f9, $61, $39, $e1
      .db $ac, $04, $c6, $41, $0c, $83, $16, $41, $88, $f2
      .db $39, $f1, $7c, $00, $89, $61, $9c, $00, $a7, $63
      .db $bc, $00, $c5, $65, $dc, $00, $e3, $67, $f3, $67
      .db $8d, $c1, $cf, $26
      .db $fd

;level 5-2
L_GroundArea18:
      .db $55, $b1
      .db $0f, $26, $cf, $33, $07, $b2, $15, $11, $52, $42
      .db $99, $0b, $ac, $02, $d3, $24, $d6, $42, $d7, $25
      .db $23, $84, $cf, $33, $07, $e3, $19, $61, $78, $7a
      .db $ef, $33, $2c, $81, $46, $64, $55, $65, $65, $65
      .db $ec, $74, $47, $82, $53, $05, $63, $21, $62, $41
      .db $96, $22, $9a, $41, $cc, $03, $b9, $91, $39, $f1
      .db $63, $26, $67, $27, $d3, $06, $fc, $01, $18, $e2
      .db $d9, $07, $e9, $04, $0c, $86, $37, $22, $93, $24
      .db $87, $84, $ac, $02, $c2, $41, $c3, $23, $d9, $71
      .db $fc, $01, $7f, $b1, $9c, $00, $a7, $63, $b6, $64
      .db $cc, $00, $d4, $66, $e3, $67, $f3, $67, $8d, $c1
      .db $cf, $26
      .db $fd

;level 8-2
L_GroundArea19:
      .db $50, $b1
      .db $0f, $26, $fc, $00, $1f, $b3, $5c, $00, $65, $65
      .db $74, $66, $83, $67, $93, $67, $dc, $73, $4c, $80
      .db $b3, $20, $c9, $0b, $c3, $08, $d3, $2f, $dc, $00
      .db $2c, $80, $4c, $00, $8c, $00, $d3, $2e, $ed, $4a
      .db $fc, $00, $d7, $a1, $ec, $01, $4c, $80, $59, $11
      .db $d8, $11, $da, $10, $37, $a0, $47, $04, $99, $11
      .db $e7, $21, $3a, $90, $67, $20, $76, $10, $77, $60
      .db $87, $07, $d8, $12, $39, $f1, $ac, $00, $e9, $71
      .db $0c, $80, $2c, $00, $4c, $05, $c7, $7b, $39, $f1
      .db $ec, $00, $f9, $11, $0c, $82, $6f, $34, $f8, $11
      .db $fa, $10, $7f, $b2, $ac, $00, $b6, $64, $cc, $01
      .db $e3, $67, $f3, $67, $8d, $c1, $cf, $26
      .db $fd

;level 7-1
L_GroundArea20:
      .db $52, $b1
      .db $0f, $20, $6e, $45, $39, $91, $b3, $04, $c3, $21
      .db $c8, $11, $ca, $10, $49, $91, $7c, $73, $e8, $12
      .db $88, $91, $8a, $10, $e7, $21, $05, $91, $07, $30
      .db $17, $07, $27, $20, $49, $11, $9c, $01, $c8, $72
      .db $23, $a6, $27, $26, $d3, $03, $d8, $7a, $89, $91
      .db $d8, $72, $39, $f1, $a9, $11, $09, $f1, $63, $24
      .db $67, $24, $d8, $62, $28, $91, $2a, $10, $56, $21
      .db $70, $04, $79, $0b, $8c, $00, $94, $21, $9f, $35
      .db $2f, $b8, $3d, $c1, $7f, $26
      .db $fd

;cloud level used in levels 3-1 and 6-2
L_GroundArea21:
      .db $06, $c1
      .db $4c, $00, $f4, $4f, $0d, $02, $06, $20, $24, $4f
      .db $35, $a0, $36, $20, $53, $46, $d5, $20, $d6, $20
      .db $34, $a1, $73, $49, $74, $20, $94, $20, $b4, $20
      .db $d4, $20, $f4, $20, $2e, $80, $59, $42, $4d, $c7
      .db $fd

;level 3-2
L_GroundArea22:
      .db $96, $31
      .db $0f, $26, $0d, $03, $1a, $60, $77, $42, $c4, $00
      .db $c8, $62, $b9, $e1, $d3, $06, $d7, $07, $f9, $61
      .db $0c, $81, $4e, $b1, $8e, $b1, $bc, $01, $e4, $50
      .db $e9, $61, $0c, $81, $0d, $0a, $84, $43, $98, $72
      .db $0d, $0c, $0f, $38, $1d, $c1, $5f, $26
      .db $fd

;level 1-2
L_UndergroundArea1:
      .db $48, $0f
      .db $0e, $01, $5e, $02, $a7, $00, $bc, $73, $1a, $e0
      .db $39, $61, $58, $62, $77, $63, $97, $63, $b8, $62
      .db $d6, $07, $f8, $62, $19, $e1, $75, $52, $86, $40
      .db $87, $50, $95, $52, $93, $43, $a5, $21, $c5, $52
      .db $d6, $40, $d7, $20, $e5, $06, $e6, $51, $3e, $8d
      .db $5e, $03, $67, $52, $77, $52, $7e, $02, $9e, $03
      .db $a6, $43, $a7, $23, $de, $05, $fe, $02, $1e, $83
      .db $33, $54, $46, $40, $47, $21, $56, $04, $5e, $02
      .db $83, $54, $93, $52, $96, $07, $97, $50, $be, $03
      .db $c7, $23, $fe, $02, $0c, $82, $43, $45, $45, $24
      .db $46, $24, $90, $08, $95, $51, $78, $fa, $d7, $73
      .db $39, $f1, $8c, $01, $a8, $52, $b8, $52, $cc, $01
      .db $5f, $b3, $97, $63, $9e, $00, $0e, $81, $16, $24
      .db $66, $04, $8e, $00, $fe, $01, $08, $d2, $0e, $06
      .db $6f, $47, $9e, $0f, $0e, $82, $2d, $47, $28, $7a
      .db $68, $7a, $a8, $7a, $ae, $01, $de, $0f, $6d, $c5
      .db $fd

;level 4-2
L_UndergroundArea2:
      .db $48, $0f
      .db $0e, $01, $5e, $02, $bc, $01, $fc, $01, $2c, $82
      .db $41, $52, $4e, $04, $67, $25, $68, $24, $69, $24
      .db $ba, $42, $c7, $04, $de, $0b, $b2, $87, $fe, $02
      .db $2c, $e1, $2c, $71, $67, $01, $77, $00, $87, $01
      .db $8e, $00, $ee, $01, $f6, $02, $03, $85, $05, $02
      .db $13, $21, $16, $02, $27, $02, $2e, $02, $88, $72
      .db $c7, $20, $d7, $07, $e4, $76, $07, $a0, $17, $06
      .db $48, $7a, $76, $20, $98, $72, $79, $e1, $88, $62
      .db $9c, $01, $b7, $73, $dc, $01, $f8, $62, $fe, $01
      .db $08, $e2, $0e, $00, $6e, $02, $73, $20, $77, $23
      .db $83, $04, $93, $20, $ae, $00, $fe, $0a, $0e, $82
      .db $39, $71, $a8, $72, $e7, $73, $0c, $81, $8f, $32
      .db $ae, $00, $fe, $04, $04, $d1, $17, $04, $26, $49
      .db $27, $29, $df, $33, $fe, $02, $44, $f6, $7c, $01
      .db $8e, $06, $bf, $47, $ee, $0f, $4d, $c7, $0e, $82
      .db $68, $7a, $ae, $01, $de, $0f, $6d, $c5
      .db $fd

;underground bonus rooms area used in many levels
L_UndergroundArea3:
      .db $48, $01
      .db $0e, $01, $00, $5a, $3e, $06, $45, $46, $47, $46
      .db $53, $44, $ae, $01, $df, $4a, $4d, $c7, $0e, $81
      .db $00, $5a, $2e, $04, $37, $28, $3a, $48, $46, $47
      .db $c7, $07, $ce, $0f, $df, $4a, $4d, $c7, $0e, $81
      .db $00, $5a, $33, $53, $43, $51, $46, $40, $47, $50
      .db $53, $04, $55, $40, $56, $50, $62, $43, $64, $40
      .db $65, $50, $71, $41, $73, $51, $83, $51, $94, $40
      .db $95, $50, $a3, $50, $a5, $40, $a6, $50, $b3, $51
      .db $b6, $40, $b7, $50, $c3, $53, $df, $4a, $4d, $c7
      .db $0e, $81, $00, $5a, $2e, $02, $36, $47, $37, $52
      .db $3a, $49, $47, $25, $a7, $52, $d7, $04, $df, $4a
      .db $4d, $c7, $0e, $81, $00, $5a, $3e, $02, $44, $51
      .db $53, $44, $54, $44, $55, $24, $a1, $54, $ae, $01
      .db $b4, $21, $df, $4a, $e5, $07, $4d, $c7
      .db $fd

;water area used in levels 5-2 and 6-2
L_WaterArea1:
      .db $41, $01
      .db $b4, $34, $c8, $52, $f2, $51, $47, $d3, $6c, $03
      .db $65, $49, $9e, $07, $be, $01, $cc, $03, $fe, $07
      .db $0d, $c9, $1e, $01, $6c, $01, $62, $35, $63, $53
      .db $8a, $41, $ac, $01, $b3, $53, $e9, $51, $26, $c3
      .db $27, $33, $63, $43, $64, $33, $ba, $60, $c9, $61
      .db $ce, $0b, $e5, $09, $ee, $0f, $7d, $ca, $7d, $47
      .db $fd

;level 2-2/7-2
L_WaterArea2:
      .db $41, $01
      .db $b8, $52, $ea, $41, $27, $b2, $b3, $42, $16, $d4
      .db $4a, $42, $a5, $51, $a7, $31, $27, $d3, $08, $e2
      .db $16, $64, $2c, $04, $38, $42, $76, $64, $88, $62
      .db $de, $07, $fe, $01, $0d, $c9, $23, $32, $31, $51
      .db $98, $52, $0d, $c9, $59, $42, $63, $53, $67, $31
      .db $14, $c2, $36, $31, $87, $53, $17, $e3, $29, $61
      .db $30, $62, $3c, $08, $42, $37, $59, $40, $6a, $42
      .db $99, $40, $c9, $61, $d7, $63, $39, $d1, $58, $52
      .db $c3, $67, $d3, $31, $dc, $06, $f7, $42, $fa, $42
      .db $23, $b1, $43, $67, $c3, $34, $c7, $34, $d1, $51
      .db $43, $b3, $47, $33, $9a, $30, $a9, $61, $b8, $62
      .db $be, $0b, $d5, $09, $de, $0f, $0d, $ca, $7d, $47
      .db $fd

;water area used in level 8-4
L_WaterArea3:
      .db $49, $0f
      .db $1e, $01, $39, $73, $5e, $07, $ae, $0b, $1e, $82
      .db $6e, $88, $9e, $02, $0d, $04, $2e, $0b, $45, $09
      .db $4e, $0f, $ed, $47
      .db $fd

;-------------------------------------------------------------------------------------

;unused space
      .db $ff

;-------------------------------------------------------------------------------------

;indirect jump routine called when
;$0770 is set to 1
GameMode:
      lda OperMode_Task
      jsr JumpEngine

      .dw InitializeArea
      .dw ScreenRoutines
      .dw SecondaryGameSetup
      .dw GameCoreRoutine

;-------------------------------------------------------------------------------------

GameCoreRoutine:
      ldx CurrentPlayer          ;get which player is on the screen
      lda SavedJoypadBits,x      ;use appropriate player's controller bits
      sta SavedJoypadBits        ;as the master controller bits
      jsr GameRoutines           ;execute one of many possible subs
      lda OperMode_Task          ;check major task of operating mode
      cmp #$03                   ;if we are supposed to be here,
      bcs GameEngine             ;branch to the game engine itself
      rts

GameEngine:
              jsr ProcFireball_Bubble    ;process fireballs and air bubbles
              ldx #$00
ProcELoop:    stx ObjectOffset           ;put incremented offset in X as enemy object offset
              jsr EnemiesAndLoopsCore    ;process enemy objects
              jsr FloateyNumbersRoutine  ;process floatey numbers
              inx
              cpx #$06                   ;do these two subroutines until the whole buffer is done
              bne ProcELoop
              jsr GetPlayerOffscreenBits ;get offscreen bits for player object
              jsr RelativePlayerPosition ;get relative coordinates for player object
              jsr PlayerGfxHandler       ;draw the player
              jsr BlockObjMT_Updater     ;replace block objects with metatiles if necessary
              ldx #$01
              stx ObjectOffset           ;set offset for second
              jsr BlockObjectsCore       ;process second block object
              dex
              stx ObjectOffset           ;set offset for first
              jsr BlockObjectsCore       ;process first block object
              jsr MiscObjectsCore        ;process misc objects (hammer, jumping coins)
              jsr ProcessCannons         ;process bullet bill cannons
              jsr ProcessWhirlpools      ;process whirlpools
              jsr FlagpoleRoutine        ;process the flagpole
              jsr RunGameTimer           ;count down the game timer
              jsr ColorRotation          ;cycle one of the background colors
              lda Player_Y_HighPos
              cmp #$02                   ;if player is below the screen, don't bother with the music
              bpl NoChgMus
              lda StarInvincibleTimer    ;if star mario invincibility timer at zero,
              beq ClrPlrPal              ;skip this part
              cmp #$04
              bne NoChgMus               ;if not yet at a certain point, continue
              lda IntervalTimerControl   ;if interval timer not yet expired,
              bne NoChgMus               ;branch ahead, don't bother with the music
              jsr GetAreaMusic           ;to re-attain appropriate level music
NoChgMus:     ldy StarInvincibleTimer    ;get invincibility timer
              lda FrameCounter           ;get frame counter
              cpy #$08                   ;if timer still above certain point,
              bcs CycleTwo               ;branch to cycle player's palette quickly
              lsr                        ;otherwise, divide by 8 to cycle every eighth frame
              lsr
CycleTwo:     lsr                        ;if branched here, divide by 2 to cycle every other frame
              jsr CyclePlayerPalette     ;do sub to cycle the palette (note: shares fire flower code)
              jmp SaveAB                 ;then skip this sub to finish up the game engine
ClrPlrPal:    jsr ResetPalStar           ;do sub to clear player's palette bits in attributes
SaveAB:       lda A_B_Buttons            ;save current A and B button
              sta PreviousA_B_Buttons    ;into temp variable to be used on next frame
              lda #$00
              sta Left_Right_Buttons     ;nullify left and right buttons temp variable
UpdScrollVar: lda VRAM_Buffer_AddrCtrl
              cmp #$06                   ;if vram address controller set to 6 (one of two $0341s)
              beq ExitEng                ;then branch to leave
              lda AreaParserTaskNum      ;otherwise check number of tasks
              bne RunParser
              lda ScrollThirtyTwo        ;get horizontal scroll in 0-31 or $00-$20 range
              cmp #$20                   ;check to see if exceeded $21
              bmi ExitEng                ;branch to leave if not
              lda ScrollThirtyTwo
              sbc #$20                   ;otherwise subtract $20 to set appropriately
              sta ScrollThirtyTwo        ;and store
              lda #$00                   ;reset vram buffer offset used in conjunction with
              sta VRAM_Buffer2_Offset    ;level graphics buffer at $0341-$035f
RunParser:    jsr AreaParserTaskHandler  ;update the name table with more level graphics
ExitEng:      rts                        ;and after all that, we're finally done!

;-------------------------------------------------------------------------------------

ScrollHandler:
            lda Player_X_Scroll       ;load value saved here
            clc
            adc Platform_X_Scroll     ;add value used by left/right platforms
            sta Player_X_Scroll       ;save as new value here to impose force on scroll
            lda ScrollLock            ;check scroll lock flag
            bne InitScrlAmt           ;skip a bunch of code here if set
            lda Player_Pos_ForScroll
            cmp #$50                  ;check player's horizontal screen position
            bcc InitScrlAmt           ;if less than 80 pixels to the right, branch
            lda SideCollisionTimer    ;if timer related to player's side collision
            bne InitScrlAmt           ;not expired, branch
            ldy Player_X_Scroll       ;get value and decrement by one
            dey                       ;if value originally set to zero or otherwise
            bmi InitScrlAmt           ;negative for left movement, branch
            iny
            cpy #$02                  ;if value $01, branch and do not decrement
            bcc ChkNearMid
            dey                       ;otherwise decrement by one
ChkNearMid: lda Player_Pos_ForScroll
            cmp #$70                  ;check player's horizontal screen position
            bcc ScrollScreen          ;if less than 112 pixels to the right, branch
            ldy Player_X_Scroll       ;otherwise get original value undecremented

ScrollScreen:
              tya
              sta ScrollAmount          ;save value here
              clc
              adc ScrollThirtyTwo       ;add to value already set here
              sta ScrollThirtyTwo       ;save as new value here
              tya
              clc
              adc ScreenLeft_X_Pos      ;add to left side coordinate
              sta ScreenLeft_X_Pos      ;save as new left side coordinate
              sta HorizontalScroll      ;save here also
              lda ScreenLeft_PageLoc
              adc #$00                  ;add carry to page location for left
              sta ScreenLeft_PageLoc    ;side of the screen
              and #$01                  ;get LSB of page location
              sta $00                   ;save as temp variable for PPU register 1 mirror
              lda Mirror_PPU_CTRL_REG1  ;get PPU register 1 mirror
              and #%11111110            ;save all bits except d0
              ora $00                   ;get saved bit here and save in PPU register 1
              sta Mirror_PPU_CTRL_REG1  ;mirror to be used to set name table later
              jsr GetScreenPosition     ;figure out where the right side is
              lda #$08
              sta ScrollIntervalTimer   ;set scroll timer (residual, not used elsewhere)
              jmp ChkPOffscr            ;skip this part
InitScrlAmt:  lda #$00
              sta ScrollAmount          ;initialize value here
ChkPOffscr:   ldx #$00                  ;set X for player offset
              jsr GetXOffscreenBits     ;get horizontal offscreen bits for player
              sta $00                   ;save them here
              ldy #$00                  ;load default offset (left side)
              asl                       ;if d7 of offscreen bits are set,
              bcs KeepOnscr             ;branch with default offset
              iny                         ;otherwise use different offset (right side)
              lda $00
              and #%00100000              ;check offscreen bits for d5 set
              beq InitPlatScrl            ;if not set, branch ahead of this part
KeepOnscr:    lda ScreenEdge_X_Pos,y      ;get left or right side coordinate based on offset
              sec
              sbc X_SubtracterData,y      ;subtract amount based on offset
              sta Player_X_Position       ;store as player position to prevent movement further
              lda ScreenEdge_PageLoc,y    ;get left or right page location based on offset
              sbc #$00                    ;subtract borrow
              sta Player_PageLoc          ;save as player's page location
              lda Left_Right_Buttons      ;check saved controller bits
              cmp OffscrJoypadBitsData,y  ;against bits based on offset
              beq InitPlatScrl            ;if not equal, branch
              lda #$00
              sta Player_X_Speed          ;otherwise nullify horizontal speed of player
InitPlatScrl: lda #$00                    ;nullify platform force imposed on scroll
              sta Platform_X_Scroll
              rts

X_SubtracterData:
      .db $00, $10

OffscrJoypadBitsData:
      .db $01, $02

;-------------------------------------------------------------------------------------

GetScreenPosition:
      lda ScreenLeft_X_Pos    ;get coordinate of screen's left boundary
      clc
      adc #$ff                ;add 255 pixels
      sta ScreenRight_X_Pos   ;store as coordinate of screen's right boundary
      lda ScreenLeft_PageLoc  ;get page number where left boundary is
      adc #$00                ;add carry from before
      sta ScreenRight_PageLoc ;store as page number where right boundary is
      rts

;-------------------------------------------------------------------------------------

GameRoutines:
      lda GameEngineSubroutine  ;run routine based on number (a few of these routines are
      jsr JumpEngine            ;merely placeholders as conditions for other routines)

      .dw Entrance_GameTimerSetup
      .dw Vine_AutoClimb
      .dw SideExitPipeEntry
      .dw VerticalPipeEntry
      .dw FlagpoleSlide
      .dw PlayerEndLevel
      .dw PlayerLoseLife
      .dw PlayerEntrance
      .dw PlayerCtrlRoutine
      .dw PlayerChangeSize
      .dw PlayerInjuryBlink
      .dw PlayerDeath
      .dw PlayerFireFlower

;-------------------------------------------------------------------------------------

PlayerEntrance:
            lda AltEntranceControl    ;check for mode of alternate entry
            cmp #$02
            beq EntrMode2             ;if found, branch to enter from pipe or with vine
            lda #$00
            ldy Player_Y_Position     ;if vertical position above a certain
            cpy #$30                  ;point, nullify controller bits and continue
            bcc AutoControlPlayer     ;with player movement code, do not return
            lda PlayerEntranceCtrl    ;check player entry bits from header
            cmp #$06
            beq ChkBehPipe            ;if set to 6 or 7, execute pipe intro code
            cmp #$07                  ;otherwise branch to normal entry
            bne PlayerRdy
ChkBehPipe: lda Player_SprAttrib      ;check for sprite attributes
            bne IntroEntr             ;branch if found
            lda #$01
            jmp AutoControlPlayer     ;force player to walk to the right
IntroEntr:  jsr EnterSidePipe         ;execute sub to move player to the right
            dec ChangeAreaTimer       ;decrement timer for change of area
            bne ExitEntr              ;branch to exit if not yet expired
            inc DisableIntermediate   ;set flag to skip world and lives display
            jmp NextArea              ;jump to increment to next area and set modes
EntrMode2:  lda JoypadOverride        ;if controller override bits set here,
            bne VineEntr              ;branch to enter with vine
            lda #$ff                  ;otherwise, set value here then execute sub
            jsr MovePlayerYAxis       ;to move player upwards (note $ff = -1)
            lda Player_Y_Position     ;check to see if player is at a specific coordinate
            cmp #$91                  ;if player risen to a certain point (this requires pipes
            bcc PlayerRdy             ;to be at specific height to look/function right) branch
            rts                       ;to the last part, otherwise leave
VineEntr:   lda VineHeight
            cmp #$60                  ;check vine height
            bne ExitEntr              ;if vine not yet reached maximum height, branch to leave
            lda Player_Y_Position     ;get player's vertical coordinate
            cmp #$99                  ;check player's vertical coordinate against preset value
            ldy #$00                  ;load default values to be written to
            lda #$01                  ;this value moves player to the right off the vine
            bcc OffVine               ;if vertical coordinate < preset value, use defaults
            lda #$03
            sta Player_State          ;otherwise set player state to climbing
            iny                       ;increment value in Y
            lda #$08                  ;set block in block buffer to cover hole, then
            sta Block_Buffer_1+$b4    ;use same value to force player to climb
OffVine:    sty DisableCollisionDet   ;set collision detection disable flag
            jsr AutoControlPlayer     ;use contents of A to move player up or right, execute sub
            lda Player_X_Position
            cmp #$48                  ;check player's horizontal position
            bcc ExitEntr              ;if not far enough to the right, branch to leave
PlayerRdy:  lda #$08                  ;set routine to be executed by game engine next frame
            sta GameEngineSubroutine
            lda #$01                  ;set to face player to the right
            sta PlayerFacingDir
            lsr                       ;init A
            sta AltEntranceControl    ;init mode of entry
            sta DisableCollisionDet   ;init collision detection disable flag
            sta JoypadOverride        ;nullify controller override bits
ExitEntr:   rts                       ;leave!

;-------------------------------------------------------------------------------------
;$07 - used to hold upper limit of high byte when player falls down hole

AutoControlPlayer:
      sta SavedJoypadBits         ;override controller bits with contents of A if executing here

PlayerCtrlRoutine:
            lda GameEngineSubroutine    ;check task here
            cmp #$0b                    ;if certain value is set, branch to skip controller bit loading
            beq SizeChk
            lda AreaType                ;are we in a water type area?
            bne SaveJoyp                ;if not, branch
            ldy Player_Y_HighPos
            dey                         ;if not in vertical area between
            bne DisJoyp                 ;status bar and bottom, branch
            lda Player_Y_Position
            cmp #$d0                    ;if nearing the bottom of the screen or
            bcc SaveJoyp                ;not in the vertical area between status bar or bottom,
DisJoyp:    lda #$00                    ;disable controller bits
            sta SavedJoypadBits
SaveJoyp:   lda SavedJoypadBits         ;otherwise store A and B buttons in $0a
            and #%11000000
            sta A_B_Buttons
            lda SavedJoypadBits         ;store left and right buttons in $0c
            and #%00000011
            sta Left_Right_Buttons
            lda SavedJoypadBits         ;store up and down buttons in $0b
            and #%00001100
            sta Up_Down_Buttons
            and #%00000100              ;check for pressing down
            beq SizeChk                 ;if not, branch
            lda Player_State            ;check player's state
            bne SizeChk                 ;if not on the ground, branch
            ldy Left_Right_Buttons      ;check left and right
            beq SizeChk                 ;if neither pressed, branch
            lda #$00
            sta Left_Right_Buttons      ;if pressing down while on the ground,
            sta Up_Down_Buttons         ;nullify directional bits
SizeChk:    jsr PlayerMovementSubs      ;run movement subroutines
            ldy #$01                    ;is player small?
            lda PlayerSize
            bne ChkMoveDir
            ldy #$00                    ;check for if crouching
            lda CrouchingFlag
            beq ChkMoveDir              ;if not, branch ahead
            ldy #$02                    ;if big and crouching, load y with 2
ChkMoveDir: sty Player_BoundBoxCtrl     ;set contents of Y as player's bounding box size control
            lda #$01                    ;set moving direction to right by default
            ldy Player_X_Speed          ;check player's horizontal speed
            beq PlayerSubs              ;if not moving at all horizontally, skip this part
            bpl SetMoveDir              ;if moving to the right, use default moving direction
            asl                         ;otherwise change to move to the left
SetMoveDir: sta Player_MovingDir        ;set moving direction
PlayerSubs: jsr ScrollHandler           ;move the screen if necessary
            jsr GetPlayerOffscreenBits  ;get player's offscreen bits
            jsr RelativePlayerPosition  ;get coordinates relative to the screen
            ldx #$00                    ;set offset for player object
            jsr BoundingBoxCore         ;get player's bounding box coordinates
            jsr PlayerBGCollision       ;do collision detection and process
            lda Player_Y_Position
            cmp #$40                    ;check to see if player is higher than 64th pixel
            bcc PlayerHole              ;if so, branch ahead
            lda GameEngineSubroutine
            cmp #$05                    ;if running end-of-level routine, branch ahead
            beq PlayerHole
            cmp #$07                    ;if running player entrance routine, branch ahead
            beq PlayerHole
            cmp #$04                    ;if running routines $00-$03, branch ahead
            bcc PlayerHole
            lda Player_SprAttrib
            and #%11011111              ;otherwise nullify player's
            sta Player_SprAttrib        ;background priority flag
PlayerHole: lda Player_Y_HighPos        ;check player's vertical high byte
            cmp #$02                    ;for below the screen
            bmi ExitCtrl                ;branch to leave if not that far down
            ldx #$01
            stx ScrollLock              ;set scroll lock
            ldy #$04
            sty $07                     ;set value here
            ldx #$00                    ;use X as flag, and clear for cloud level
            ldy GameTimerExpiredFlag    ;check game timer expiration flag
            bne HoleDie                 ;if set, branch
            ldy CloudTypeOverride       ;check for cloud type override
            bne ChkHoleX                ;skip to last part if found
HoleDie:    inx                         ;set flag in X for player death
            ldy GameEngineSubroutine
            cpy #$0b                    ;check for some other routine running
            beq ChkHoleX                ;if so, branch ahead
            ldy DeathMusicLoaded        ;check value here
            bne HoleBottom              ;if already set, branch to next part
            iny
            sty EventMusicQueue         ;otherwise play death music
            sty DeathMusicLoaded        ;and set value here
HoleBottom: ldy #$06
            sty $07                     ;change value here
ChkHoleX:   cmp $07                     ;compare vertical high byte with value set here
            bmi ExitCtrl                ;if less, branch to leave
            dex                         ;otherwise decrement flag in X
            bmi CloudExit               ;if flag was clear, branch to set modes and other values
            ldy EventMusicBuffer        ;check to see if music is still playing
            bne ExitCtrl                ;branch to leave if so
            lda #$06                    ;otherwise set to run lose life routine
            sta GameEngineSubroutine    ;on next frame
ExitCtrl:   rts                         ;leave

CloudExit:
      lda #$00
      sta JoypadOverride      ;clear controller override bits if any are set
      jsr SetEntr             ;do sub to set secondary mode
      inc AltEntranceControl  ;set mode of entry to 3
      rts

;-------------------------------------------------------------------------------------

Vine_AutoClimb:
           lda Player_Y_HighPos   ;check to see whether player reached position
           bne AutoClimb          ;above the status bar yet and if so, set modes
           lda Player_Y_Position
           cmp #$e4
           bcc SetEntr
AutoClimb: lda #%00001000         ;set controller bits override to up
           sta JoypadOverride
           ldy #$03               ;set player state to climbing
           sty Player_State
           jmp AutoControlPlayer
SetEntr:   lda #$02               ;set starting position to override
           sta AltEntranceControl
           jmp ChgAreaMode        ;set modes

;-------------------------------------------------------------------------------------

VerticalPipeEntry:
      lda #$01             ;set 1 as movement amount
      jsr MovePlayerYAxis  ;do sub to move player downwards
      jsr ScrollHandler    ;do sub to scroll screen with saved force if necessary
      ldy #$00             ;load default mode of entry
      lda WarpZoneControl  ;check warp zone control variable/flag
      bne ChgAreaPipe      ;if set, branch to use mode 0
      iny
      lda AreaType         ;check for castle level type
      cmp #$03
      bne ChgAreaPipe      ;if not castle type level, use mode 1
      iny
      jmp ChgAreaPipe      ;otherwise use mode 2

MovePlayerYAxis:
      clc
      adc Player_Y_Position ;add contents of A to player position
      sta Player_Y_Position
      rts

;-------------------------------------------------------------------------------------

SideExitPipeEntry:
             jsr EnterSidePipe         ;execute sub to move player to the right
             ldy #$02
ChgAreaPipe: dec ChangeAreaTimer       ;decrement timer for change of area
             bne ExitCAPipe
             sty AltEntranceControl    ;when timer expires set mode of alternate entry
ChgAreaMode: inc DisableScreenFlag     ;set flag to disable screen output
             lda #$00
             sta OperMode_Task         ;set secondary mode of operation
             sta Sprite0HitDetectFlag  ;disable sprite 0 check
ExitCAPipe:  rts                       ;leave

EnterSidePipe:
           lda #$08               ;set player's horizontal speed
           sta Player_X_Speed
           ldy #$01               ;set controller right button by default
           lda Player_X_Position  ;mask out higher nybble of player's
           and #%00001111         ;horizontal position
           bne RightPipe
           sta Player_X_Speed     ;if lower nybble = 0, set as horizontal speed
           tay                    ;and nullify controller bit override here
RightPipe: tya                    ;use contents of Y to
           jsr AutoControlPlayer  ;execute player control routine with ctrl bits nulled
           rts

;-------------------------------------------------------------------------------------

PlayerChangeSize:
             lda TimerControl    ;check master timer control
             cmp #$f8            ;for specific moment in time
             bne EndChgSize      ;branch if before or after that point
             jmp InitChangeSize  ;otherwise run code to get growing/shrinking going
EndChgSize:  cmp #$c4            ;check again for another specific moment
             bne ExitChgSize     ;and branch to leave if before or after that point
             jsr DonePlayerTask  ;otherwise do sub to init timer control and set routine
ExitChgSize: rts                 ;and then leave

;-------------------------------------------------------------------------------------

PlayerInjuryBlink:
           lda TimerControl       ;check master timer control
           cmp #$f0               ;for specific moment in time
           bcs ExitBlink          ;branch if before that point
           cmp #$c8               ;check again for another specific point
           beq DonePlayerTask     ;branch if at that point, and not before or after
           jmp PlayerCtrlRoutine  ;otherwise run player control routine
ExitBlink: bne ExitBoth           ;do unconditional branch to leave

InitChangeSize:
          ldy PlayerChangeSizeFlag  ;if growing/shrinking flag already set
          bne ExitBoth              ;then branch to leave
          sty PlayerAnimCtrl        ;otherwise initialize player's animation frame control
          inc PlayerChangeSizeFlag  ;set growing/shrinking flag
          lda PlayerSize
          eor #$01                  ;invert player's size
          sta PlayerSize
ExitBoth: rts                       ;leave

;-------------------------------------------------------------------------------------
;$00 - used in CyclePlayerPalette to store current palette to cycle

PlayerDeath:
      lda TimerControl       ;check master timer control
      cmp #$f0               ;for specific moment in time
      bcs ExitDeath          ;branch to leave if before that point
      jmp PlayerCtrlRoutine  ;otherwise run player control routine

DonePlayerTask:
      lda #$00
      sta TimerControl          ;initialize master timer control to continue timers
      lda #$08
      sta GameEngineSubroutine  ;set player control routine to run next frame
      rts                       ;leave

PlayerFireFlower:
      lda TimerControl       ;check master timer control
      cmp #$c0               ;for specific moment in time
      beq ResetPalFireFlower ;branch if at moment, not before or after
      lda FrameCounter       ;get frame counter
      lsr
      lsr                    ;divide by four to change every four frames

CyclePlayerPalette:
      and #$03              ;mask out all but d1-d0 (previously d3-d2)
      sta $00               ;store result here to use as palette bits
      lda Player_SprAttrib  ;get player attributes
      and #%11111100        ;save any other bits but palette bits
      ora $00               ;add palette bits
      sta Player_SprAttrib  ;store as new player attributes
      rts                   ;and leave

ResetPalFireFlower:
      jsr DonePlayerTask    ;do sub to init timer control and run player control routine

ResetPalStar:
      lda Player_SprAttrib  ;get player attributes
      and #%11111100        ;mask out palette bits to force palette 0
      sta Player_SprAttrib  ;store as new player attributes
      rts                   ;and leave

ExitDeath:
      rts          ;leave from death routine

;-------------------------------------------------------------------------------------

FlagpoleSlide:
             lda Enemy_ID+5           ;check special use enemy slot
             cmp #FlagpoleFlagObject  ;for flagpole flag object
             bne NoFPObj              ;if not found, branch to something residual
             lda FlagpoleSoundQueue   ;load flagpole sound
             sta Square1SoundQueue    ;into square 1's sfx queue
             lda #$00
             sta FlagpoleSoundQueue   ;init flagpole sound queue
             ldy Player_Y_Position
             cpy #$9e                 ;check to see if player has slid down
             bcs SlidePlayer          ;far enough, and if so, branch with no controller bits set
             lda #$04                 ;otherwise force player to climb down (to slide)
SlidePlayer: jmp AutoControlPlayer    ;jump to player control routine
NoFPObj:     inc GameEngineSubroutine ;increment to next routine (this may
             rts                      ;be residual code)

;-------------------------------------------------------------------------------------

Hidden1UpCoinAmts:
      .db $15, $23, $16, $1b, $17, $18, $23, $63

PlayerEndLevel:
          lda #$01                  ;force player to walk to the right
          jsr AutoControlPlayer
          lda Player_Y_Position     ;check player's vertical position
          cmp #$ae
          bcc ChkStop               ;if player is not yet off the flagpole, skip this part
          lda ScrollLock            ;if scroll lock not set, branch ahead to next part
          beq ChkStop               ;because we only need to do this part once
          lda #EndOfLevelMusic
          sta EventMusicQueue       ;load win level music in event music queue
          lda #$00
          sta ScrollLock            ;turn off scroll lock to skip this part later
ChkStop:  lda Player_CollisionBits  ;get player collision bits
          lsr                       ;check for d0 set
          bcs RdyNextA              ;if d0 set, skip to next part
          lda StarFlagTaskControl   ;if star flag task control already set,
          bne InCastle              ;go ahead with the rest of the code
          inc StarFlagTaskControl   ;otherwise set task control now (this gets ball rolling!)
InCastle: lda #%00100000            ;set player's background priority bit to
          sta Player_SprAttrib      ;give illusion of being inside the castle
RdyNextA: lda StarFlagTaskControl
          cmp #$05                  ;if star flag task control not yet set
          bne ExitNA                ;beyond last valid task number, branch to leave
          inc LevelNumber           ;increment level number used for game logic
          lda LevelNumber
          cmp #$03                  ;check to see if we have yet reached level -4
          bne NextArea              ;and skip this last part here if not
          ldy WorldNumber           ;get world number as offset
          lda CoinTallyFor1Ups      ;check third area coin tally for bonus 1-ups
          cmp Hidden1UpCoinAmts,y   ;against minimum value, if player has not collected
          bcc NextArea              ;at least this number of coins, leave flag clear
          inc Hidden1UpFlag         ;otherwise set hidden 1-up box control flag
NextArea: inc AreaNumber            ;increment area number used for address loader
          jsr LoadAreaPointer       ;get new level pointer
          inc FetchNewGameTimerFlag ;set flag to load new game timer
          jsr ChgAreaMode           ;do sub to set secondary mode, disable screen and sprite 0
          sta HalfwayPage           ;reset halfway page to 0 (beginning)
          lda #Silence
          sta EventMusicQueue       ;silence music and leave
ExitNA:   rts

;-------------------------------------------------------------------------------------

PlayerMovementSubs:
           lda #$00                  ;set A to init crouch flag by default
           ldy PlayerSize            ;is player small?
           bne SetCrouch             ;if so, branch
           lda Player_State          ;check state of player
           bne ProcMove              ;if not on the ground, branch
           lda Up_Down_Buttons       ;load controller bits for up and down
           and #%00000100            ;single out bit for down button
SetCrouch: sta CrouchingFlag         ;store value in crouch flag
ProcMove:  jsr PlayerPhysicsSub      ;run sub related to jumping and swimming
           lda PlayerChangeSizeFlag  ;if growing/shrinking flag set,
           bne NoMoveSub             ;branch to leave
           lda Player_State
           cmp #$03                  ;get player state
           beq MoveSubs              ;if climbing, branch ahead, leave timer unset
           ldy #$18
           sty ClimbSideTimer        ;otherwise reset timer now
MoveSubs:  jsr JumpEngine

      .dw OnGroundStateSub
      .dw JumpSwimSub
      .dw FallingSub
      .dw ClimbingSub

NoMoveSub: rts

;-------------------------------------------------------------------------------------
;$00 - used by ClimbingSub to store high vertical adder

OnGroundStateSub:
         jsr GetPlayerAnimSpeed     ;do a sub to set animation frame timing
         lda Left_Right_Buttons
         beq GndMove                ;if left/right controller bits not set, skip instruction
         sta PlayerFacingDir        ;otherwise set new facing direction
GndMove: jsr ImposeFriction         ;do a sub to impose friction on player's walk/run
         jsr MovePlayerHorizontally ;do another sub to move player horizontally
         sta Player_X_Scroll        ;set returned value as player's movement speed for scroll
         rts

;--------------------------------

FallingSub:
      lda VerticalForceDown
      sta VerticalForce      ;dump vertical movement force for falling into main one
      jmp LRAir              ;movement force, then skip ahead to process left/right movement

;--------------------------------

JumpSwimSub:
          ldy Player_Y_Speed         ;if player's vertical speed zero
          bpl DumpFall               ;or moving downwards, branch to falling
          lda A_B_Buttons
          and #A_Button              ;check to see if A button is being pressed
          and PreviousA_B_Buttons    ;and was pressed in previous frame
          bne ProcSwim               ;if so, branch elsewhere
          lda JumpOrigin_Y_Position  ;get vertical position player jumped from
          sec
          sbc Player_Y_Position      ;subtract current from original vertical coordinate
          cmp DiffToHaltJump         ;compare to value set here to see if player is in mid-jump
          bcc ProcSwim               ;or just starting to jump, if just starting, skip ahead
DumpFall: lda VerticalForceDown      ;otherwise dump falling into main fractional
          sta VerticalForce
ProcSwim: lda SwimmingFlag           ;if swimming flag not set,
          beq LRAir                  ;branch ahead to last part
          jsr GetPlayerAnimSpeed     ;do a sub to get animation frame timing
          lda Player_Y_Position
          cmp #$14                   ;check vertical position against preset value
          bcs LRWater                ;if not yet reached a certain position, branch ahead
          lda #$18
          sta VerticalForce          ;otherwise set fractional
LRWater:  lda Left_Right_Buttons     ;check left/right controller bits (check for swimming)
          beq LRAir                  ;if not pressing any, skip
          sta PlayerFacingDir        ;otherwise set facing direction accordingly
LRAir:    lda Left_Right_Buttons     ;check left/right controller bits (check for jumping/falling)
          beq JSMove                 ;if not pressing any, skip
          jsr ImposeFriction         ;otherwise process horizontal movement
JSMove:   jsr MovePlayerHorizontally ;do a sub to move player horizontally
          sta Player_X_Scroll        ;set player's speed here, to be used for scroll later
          lda GameEngineSubroutine
          cmp #$0b                   ;check for specific routine selected
          bne ExitMov1               ;branch if not set to run
          lda #$28
          sta VerticalForce          ;otherwise set fractional
ExitMov1: jmp MovePlayerVertically   ;jump to move player vertically, then leave

;--------------------------------

ClimbAdderLow:
      .db $0e, $04, $fc, $f2
ClimbAdderHigh:
      .db $00, $00, $ff, $ff

ClimbingSub:
             lda Player_YMF_Dummy
             clc                      ;add movement force to dummy variable
             adc Player_Y_MoveForce   ;save with carry
             sta Player_YMF_Dummy
             ldy #$00                 ;set default adder here
             lda Player_Y_Speed       ;get player's vertical speed
             bpl MoveOnVine           ;if not moving upwards, branch
             dey                      ;otherwise set adder to $ff
MoveOnVine:  sty $00                  ;store adder here
             adc Player_Y_Position    ;add carry to player's vertical position
             sta Player_Y_Position    ;and store to move player up or down
             lda Player_Y_HighPos
             adc $00                  ;add carry to player's page location
             sta Player_Y_HighPos     ;and store
             lda Left_Right_Buttons   ;compare left/right controller bits
             and Player_CollisionBits ;to collision flag
             beq InitCSTimer          ;if not set, skip to end
             ldy ClimbSideTimer       ;otherwise check timer
             bne ExitCSub             ;if timer not expired, branch to leave
             ldy #$18
             sty ClimbSideTimer       ;otherwise set timer now
             ldx #$00                 ;set default offset here
             ldy PlayerFacingDir      ;get facing direction
             lsr                      ;move right button controller bit to carry
             bcs ClimbFD              ;if controller right pressed, branch ahead
             inx
             inx                      ;otherwise increment offset by 2 bytes
ClimbFD:     dey                      ;check to see if facing right
             beq CSetFDir             ;if so, branch, do not increment
             inx                      ;otherwise increment by 1 byte
CSetFDir:    lda Player_X_Position
             clc                      ;add or subtract from player's horizontal position
             adc ClimbAdderLow,x      ;using value here as adder and X as offset
             sta Player_X_Position
             lda Player_PageLoc       ;add or subtract carry or borrow using value here
             adc ClimbAdderHigh,x     ;from the player's page location
             sta Player_PageLoc
             lda Left_Right_Buttons   ;get left/right controller bits again
             eor #%00000011           ;invert them and store them while player
             sta PlayerFacingDir      ;is on vine to face player in opposite direction
ExitCSub:    rts                      ;then leave
InitCSTimer: sta ClimbSideTimer       ;initialize timer here
             rts

;-------------------------------------------------------------------------------------
;$00 - used to store offset to friction data

JumpMForceData:
      .db $20, $20, $1e, $28, $28, $0d, $04

FallMForceData:
      .db $70, $70, $60, $90, $90, $0a, $09

PlayerYSpdData:
      .db $fc, $fc, $fc, $fb, $fb, $fe, $ff

InitMForceData:
      .db $00, $00, $00, $00, $00, $80, $00

MaxLeftXSpdData:
      .db $d8, $e8, $f0

MaxRightXSpdData:
      .db $28, $18, $10
      .db $0c ;used for pipe intros

FrictionData:
      .db $e4, $98, $d0

Climb_Y_SpeedData:
      .db $00, $ff, $01

Climb_Y_MForceData:
      .db $00, $20, $ff

PlayerPhysicsSub:
           lda Player_State          ;check player state
           cmp #$03
           bne CheckForJumping       ;if not climbing, branch
           ldy #$00
           lda Up_Down_Buttons       ;get controller bits for up/down
           and Player_CollisionBits  ;check against player's collision detection bits
           beq ProcClimb             ;if not pressing up or down, branch
           iny
           and #%00001000            ;check for pressing up
           bne ProcClimb
           iny
ProcClimb: ldx Climb_Y_MForceData,y  ;load value here
           stx Player_Y_MoveForce    ;store as vertical movement force
           lda #$08                  ;load default animation timing
           ldx Climb_Y_SpeedData,y   ;load some other value here
           stx Player_Y_Speed        ;store as vertical speed
           bmi SetCAnim              ;if climbing down, use default animation timing value
           lsr                       ;otherwise divide timer setting by 2
SetCAnim:  sta PlayerAnimTimerSet    ;store animation timer setting and leave
           rts

CheckForJumping:
        lda JumpspringAnimCtrl    ;if jumpspring animating,
        bne NoJump                ;skip ahead to something else
        lda A_B_Buttons           ;check for A button press
        and #A_Button
        beq NoJump                ;if not, branch to something else
        and PreviousA_B_Buttons   ;if button not pressed in previous frame, branch
        beq ProcJumping
NoJump: jmp X_Physics             ;otherwise, jump to something else

ProcJumping:
           lda Player_State           ;check player state
           beq InitJS                 ;if on the ground, branch
           lda SwimmingFlag           ;if swimming flag not set, jump to do something else
           beq NoJump                 ;to prevent midair jumping, otherwise continue
           lda JumpSwimTimer          ;if jump/swim timer nonzero, branch
           bne InitJS
           lda Player_Y_Speed         ;check player's vertical speed
           bpl InitJS                 ;if player's vertical speed motionless or down, branch
           jmp X_Physics              ;if timer at zero and player still rising, do not swim
InitJS:    lda #$20                   ;set jump/swim timer
           sta JumpSwimTimer
           ldy #$00                   ;initialize vertical force and dummy variable
           sty Player_YMF_Dummy
           sty Player_Y_MoveForce
           lda Player_Y_HighPos       ;get vertical high and low bytes of jump origin
           sta JumpOrigin_Y_HighPos   ;and store them next to each other here
           lda Player_Y_Position
           sta JumpOrigin_Y_Position
           lda #$01                   ;set player state to jumping/swimming
           sta Player_State
           lda Player_XSpeedAbsolute  ;check value related to walking/running speed
           cmp #$09
           bcc ChkWtr                 ;branch if below certain values, increment Y
           iny                        ;for each amount equal or exceeded
           cmp #$10
           bcc ChkWtr
           iny
           cmp #$19
           bcc ChkWtr
           iny
           cmp #$1c
           bcc ChkWtr                 ;note that for jumping, range is 0-4 for Y
           iny
ChkWtr:    lda #$01                   ;set value here (apparently always set to 1)
           sta DiffToHaltJump
           lda SwimmingFlag           ;if swimming flag disabled, branch
           beq GetYPhy
           ldy #$05                   ;otherwise set Y to 5, range is 5-6
           lda Whirlpool_Flag         ;if whirlpool flag not set, branch
           beq GetYPhy
           iny                        ;otherwise increment to 6
GetYPhy:   lda JumpMForceData,y       ;store appropriate jump/swim
           sta VerticalForce          ;data here
           lda FallMForceData,y
           sta VerticalForceDown
           lda InitMForceData,y
           sta Player_Y_MoveForce
           lda PlayerYSpdData,y
           sta Player_Y_Speed
           lda SwimmingFlag           ;if swimming flag disabled, branch
           beq PJumpSnd
           lda #Sfx_EnemyStomp        ;load swim/goomba stomp sound into
           sta Square1SoundQueue      ;square 1's sfx queue
           lda Player_Y_Position
           cmp #$14                   ;check vertical low byte of player position
           bcs X_Physics              ;if below a certain point, branch
           lda #$00                   ;otherwise reset player's vertical speed
           sta Player_Y_Speed         ;and jump to something else to keep player
           jmp X_Physics              ;from swimming above water level
PJumpSnd:  lda #Sfx_BigJump           ;load big mario's jump sound by default
           ldy PlayerSize             ;is mario big?
           beq SJumpSnd
           lda #Sfx_SmallJump         ;if not, load small mario's jump sound
SJumpSnd:  sta Square1SoundQueue      ;store appropriate jump sound in square 1 sfx queue
X_Physics: ldy #$00
           sty $00                    ;init value here
           lda Player_State           ;if mario is on the ground, branch
           beq ProcPRun
           lda Player_XSpeedAbsolute  ;check something that seems to be related
           cmp #$19                   ;to mario's speed
           bcs GetXPhy                ;if =>$19 branch here
           bcc ChkRFast               ;if not branch elsewhere
ProcPRun:  iny                        ;if mario on the ground, increment Y
           lda AreaType               ;check area type
           beq ChkRFast               ;if water type, branch
           dey                        ;decrement Y by default for non-water type area
           lda Left_Right_Buttons     ;get left/right controller bits
           cmp Player_MovingDir       ;check against moving direction
           bne ChkRFast               ;if controller bits <> moving direction, skip this part
           lda A_B_Buttons            ;check for b button pressed
           and #B_Button
           bne SetRTmr                ;if pressed, skip ahead to set timer
           lda RunningTimer           ;check for running timer set
           bne GetXPhy                ;if set, branch
ChkRFast:  iny                        ;if running timer not set or level type is water,
           inc $00                    ;increment Y again and temp variable in memory
           lda RunningSpeed
           bne FastXSp                ;if running speed set here, branch
           lda Player_XSpeedAbsolute
           cmp #$21                   ;otherwise check player's walking/running speed
           bcc GetXPhy                ;if less than a certain amount, branch ahead
FastXSp:   inc $00                    ;if running speed set or speed => $21 increment $00
           jmp GetXPhy                ;and jump ahead
SetRTmr:   lda #$0a                   ;if b button pressed, set running timer
           sta RunningTimer
GetXPhy:   lda MaxLeftXSpdData,y      ;get maximum speed to the left
           sta MaximumLeftSpeed
           lda GameEngineSubroutine   ;check for specific routine running
           cmp #$07                   ;(player entrance)
           bne GetXPhy2               ;if not running, skip and use old value of Y
           ldy #$03                   ;otherwise set Y to 3
GetXPhy2:  lda MaxRightXSpdData,y     ;get maximum speed to the right
           sta MaximumRightSpeed
           ldy $00                    ;get other value in memory
           lda FrictionData,y         ;get value using value in memory as offset
           sta FrictionAdderLow
           lda #$00
           sta FrictionAdderHigh      ;init something here
           lda PlayerFacingDir
           cmp Player_MovingDir       ;check facing direction against moving direction
           beq ExitPhy                ;if the same, branch to leave
           asl FrictionAdderLow       ;otherwise shift d7 of friction adder low into carry
           rol FrictionAdderHigh      ;then rotate carry onto d0 of friction adder high
ExitPhy:   rts                        ;and then leave

;-------------------------------------------------------------------------------------

PlayerAnimTmrData:
      .db $02, $04, $07

GetPlayerAnimSpeed:
            ldy #$00                   ;initialize offset in Y
            lda Player_XSpeedAbsolute  ;check player's walking/running speed
            cmp #$1c                   ;against preset amount
            bcs SetRunSpd              ;if greater than a certain amount, branch ahead
            iny                        ;otherwise increment Y
            cmp #$0e                   ;compare against lower amount
            bcs ChkSkid                ;if greater than this but not greater than first, skip increment
            iny                        ;otherwise increment Y again
ChkSkid:    lda SavedJoypadBits        ;get controller bits
            and #%01111111             ;mask out A button
            beq SetAnimSpd             ;if no other buttons pressed, branch ahead of all this
            and #$03                   ;mask out all others except left and right
            cmp Player_MovingDir       ;check against moving direction
            bne ProcSkid               ;if left/right controller bits <> moving direction, branch
            lda #$00                   ;otherwise set zero value here
SetRunSpd:  sta RunningSpeed           ;store zero or running speed here
            jmp SetAnimSpd
ProcSkid:   lda Player_XSpeedAbsolute  ;check player's walking/running speed
            cmp #$0b                   ;against one last amount
            bcs SetAnimSpd             ;if greater than this amount, branch
            lda PlayerFacingDir
            sta Player_MovingDir       ;otherwise use facing direction to set moving direction
            lda #$00
            sta Player_X_Speed         ;nullify player's horizontal speed
            sta Player_X_MoveForce     ;and dummy variable for player
SetAnimSpd: lda PlayerAnimTmrData,y    ;get animation timer setting using Y as offset
            sta PlayerAnimTimerSet
            rts

;-------------------------------------------------------------------------------------

ImposeFriction:
           and Player_CollisionBits  ;perform AND between left/right controller bits and collision flag
           cmp #$00                  ;then compare to zero (this instruction is redundant)
           bne JoypFrict             ;if any bits set, branch to next part
           lda Player_X_Speed
           beq SetAbsSpd             ;if player has no horizontal speed, branch ahead to last part
           bpl RghtFrict             ;if player moving to the right, branch to slow
           bmi LeftFrict             ;otherwise logic dictates player moving left, branch to slow
JoypFrict: lsr                       ;put right controller bit into carry
           bcc RghtFrict             ;if left button pressed, carry = 0, thus branch
LeftFrict: lda Player_X_MoveForce    ;load value set here
           clc
           adc FrictionAdderLow      ;add to it another value set here
           sta Player_X_MoveForce    ;store here
           lda Player_X_Speed
           adc FrictionAdderHigh     ;add value plus carry to horizontal speed
           sta Player_X_Speed        ;set as new horizontal speed
           cmp MaximumRightSpeed     ;compare against maximum value for right movement
           bmi XSpdSign              ;if horizontal speed greater negatively, branch
           lda MaximumRightSpeed     ;otherwise set preset value as horizontal speed
           sta Player_X_Speed        ;thus slowing the player's left movement down
           jmp SetAbsSpd             ;skip to the end
RghtFrict: lda Player_X_MoveForce    ;load value set here
           sec
           sbc FrictionAdderLow      ;subtract from it another value set here
           sta Player_X_MoveForce    ;store here
           lda Player_X_Speed
           sbc FrictionAdderHigh     ;subtract value plus borrow from horizontal speed
           sta Player_X_Speed        ;set as new horizontal speed
           cmp MaximumLeftSpeed      ;compare against maximum value for left movement
           bpl XSpdSign              ;if horizontal speed greater positively, branch
           lda MaximumLeftSpeed      ;otherwise set preset value as horizontal speed
           sta Player_X_Speed        ;thus slowing the player's right movement down
XSpdSign:  cmp #$00                  ;if player not moving or moving to the right,
           bpl SetAbsSpd             ;branch and leave horizontal speed value unmodified
           eor #$ff
           clc                       ;otherwise get two's compliment to get absolute
           adc #$01                  ;unsigned walking/running speed
SetAbsSpd: sta Player_XSpeedAbsolute ;store walking/running speed here and leave
           rts

;-------------------------------------------------------------------------------------
;$00 - used to store downward movement force in FireballObjCore
;$02 - used to store maximum vertical speed in FireballObjCore
;$07 - used to store pseudorandom bit in BubbleCheck

ProcFireball_Bubble:
      lda PlayerStatus           ;check player's status
      cmp #$02
      bcc ProcAirBubbles         ;if not fiery, branch
      lda A_B_Buttons
      and #B_Button              ;check for b button pressed
      beq ProcFireballs          ;branch if not pressed
      and PreviousA_B_Buttons
      bne ProcFireballs          ;if button pressed in previous frame, branch
      lda FireballCounter        ;load fireball counter
      and #%00000001             ;get LSB and use as offset for buffer
      tax
      lda Fireball_State,x       ;load fireball state
      bne ProcFireballs          ;if not inactive, branch
      ldy Player_Y_HighPos       ;if player too high or too low, branch
      dey
      bne ProcFireballs
      lda CrouchingFlag          ;if player crouching, branch
      bne ProcFireballs
      lda Player_State           ;if player's state = climbing, branch
      cmp #$03
      beq ProcFireballs
      lda #Sfx_Fireball          ;play fireball sound effect
      sta Square1SoundQueue
      lda #$02                   ;load state
      sta Fireball_State,x
      ldy PlayerAnimTimerSet     ;copy animation frame timer setting
      sty FireballThrowingTimer  ;into fireball throwing timer
      dey
      sty PlayerAnimTimer        ;decrement and store in player's animation timer
      inc FireballCounter        ;increment fireball counter

ProcFireballs:
      ldx #$00
      jsr FireballObjCore  ;process first fireball object
      ldx #$01
      jsr FireballObjCore  ;process second fireball object, then do air bubbles

ProcAirBubbles:
          lda AreaType                ;if not water type level, skip the rest of this
          bne BublExit
          ldx #$02                    ;otherwise load counter and use as offset
BublLoop: stx ObjectOffset            ;store offset
          jsr BubbleCheck             ;check timers and coordinates, create air bubble
          jsr RelativeBubblePosition  ;get relative coordinates
          jsr GetBubbleOffscreenBits  ;get offscreen information
          jsr DrawBubble              ;draw the air bubble
          dex
          bpl BublLoop                ;do this until all three are handled
BublExit: rts                         ;then leave

FireballXSpdData:
      .db $40, $c0

FireballObjCore:
         stx ObjectOffset             ;store offset as current object
         lda Fireball_State,x         ;check for d7 = 1
         asl
         bcs FireballExplosion        ;if so, branch to get relative coordinates and draw explosion
         ldy Fireball_State,x         ;if fireball inactive, branch to leave
         beq NoFBall
         dey                          ;if fireball state set to 1, skip this part and just run it
         beq RunFB
         lda Player_X_Position        ;get player's horizontal position
         adc #$04                     ;add four pixels and store as fireball's horizontal position
         sta Fireball_X_Position,x
         lda Player_PageLoc           ;get player's page location
         adc #$00                     ;add carry and store as fireball's page location
         sta Fireball_PageLoc,x
         lda Player_Y_Position        ;get player's vertical position and store
         sta Fireball_Y_Position,x
         lda #$01                     ;set high byte of vertical position
         sta Fireball_Y_HighPos,x
         ldy PlayerFacingDir          ;get player's facing direction
         dey                          ;decrement to use as offset here
         lda FireballXSpdData,y       ;set horizontal speed of fireball accordingly
         sta Fireball_X_Speed,x
         lda #$04                     ;set vertical speed of fireball
         sta Fireball_Y_Speed,x
         lda #$07
         sta Fireball_BoundBoxCtrl,x  ;set bounding box size control for fireball
         dec Fireball_State,x         ;decrement state to 1 to skip this part from now on
RunFB:   txa                          ;add 7 to offset to use
         clc                          ;as fireball offset for next routines
         adc #$07
         tax
         lda #$50                     ;set downward movement force here
         sta $00
         lda #$03                     ;set maximum speed here
         sta $02
         lda #$00
         jsr ImposeGravity            ;do sub here to impose gravity on fireball and move vertically
         jsr MoveObjectHorizontally   ;do another sub to move it horizontally
         ldx ObjectOffset             ;return fireball offset to X
         jsr RelativeFireballPosition ;get relative coordinates
         jsr GetFireballOffscreenBits ;get offscreen information
         jsr GetFireballBoundBox      ;get bounding box coordinates
         jsr FireballBGCollision      ;do fireball to background collision detection
         lda FBall_OffscreenBits      ;get fireball offscreen bits
         and #%11001100               ;mask out certain bits
         bne EraseFB                  ;if any bits still set, branch to kill fireball
         jsr FireballEnemyCollision   ;do fireball to enemy collision detection and deal with collisions
         jmp DrawFireball             ;draw fireball appropriately and leave
EraseFB: lda #$00                     ;erase fireball state
         sta Fireball_State,x
NoFBall: rts                          ;leave

FireballExplosion:
      jsr RelativeFireballPosition
      jmp DrawExplosion_Fireball

BubbleCheck:
      lda PseudoRandomBitReg+1,x  ;get part of LSFR
      and #$01
      sta $07                     ;store pseudorandom bit here
      lda Bubble_Y_Position,x     ;get vertical coordinate for air bubble
      cmp #$f8                    ;if offscreen coordinate not set,
      bne MoveBubl                ;branch to move air bubble
      lda AirBubbleTimer          ;if air bubble timer not expired,
      bne ExitBubl                ;branch to leave, otherwise create new air bubble

SetupBubble:
          ldy #$00                 ;load default value here
          lda PlayerFacingDir      ;get player's facing direction
          lsr                      ;move d0 to carry
          bcc PosBubl              ;branch to use default value if facing left
          ldy #$08                 ;otherwise load alternate value here
PosBubl:  tya                      ;use value loaded as adder
          adc Player_X_Position    ;add to player's horizontal position
          sta Bubble_X_Position,x  ;save as horizontal position for airbubble
          lda Player_PageLoc
          adc #$00                 ;add carry to player's page location
          sta Bubble_PageLoc,x     ;save as page location for airbubble
          lda Player_Y_Position
          clc                      ;add eight pixels to player's vertical position
          adc #$08
          sta Bubble_Y_Position,x  ;save as vertical position for air bubble
          lda #$01
          sta Bubble_Y_HighPos,x   ;set vertical high byte for air bubble
          ldy $07                  ;get pseudorandom bit, use as offset
          lda BubbleTimerData,y    ;get data for air bubble timer
          sta AirBubbleTimer       ;set air bubble timer
MoveBubl: ldy $07                  ;get pseudorandom bit again, use as offset
          lda Bubble_YMF_Dummy,x
          sec                      ;subtract pseudorandom amount from dummy variable
          sbc Bubble_MForceData,y
          sta Bubble_YMF_Dummy,x   ;save dummy variable
          lda Bubble_Y_Position,x
          sbc #$00                 ;subtract borrow from airbubble's vertical coordinate
          cmp #$20                 ;if below the status bar,
          bcs Y_Bubl               ;branch to go ahead and use to move air bubble upwards
          lda #$f8                 ;otherwise set offscreen coordinate
Y_Bubl:   sta Bubble_Y_Position,x  ;store as new vertical coordinate for air bubble
ExitBubl: rts                      ;leave

Bubble_MForceData:
      .db $ff, $50

BubbleTimerData:
      .db $40, $20

;-------------------------------------------------------------------------------------

RunGameTimer:
           lda OperMode               ;get primary mode of operation
           beq ExGTimer               ;branch to leave if in title screen mode
           lda GameEngineSubroutine
           cmp #$08                   ;if routine number less than eight running,
           bcc ExGTimer               ;branch to leave
           cmp #$0b                   ;if running death routine,
           beq ExGTimer               ;branch to leave
           lda Player_Y_HighPos
           cmp #$02                   ;if player below the screen,
           bcs ExGTimer               ;branch to leave regardless of level type
           lda GameTimerCtrlTimer     ;if game timer control not yet expired,
           bne ExGTimer               ;branch to leave
           lda GameTimerDisplay
           ora GameTimerDisplay+1     ;otherwise check game timer digits
           ora GameTimerDisplay+2
           beq TimeUpOn               ;if game timer digits at 000, branch to time-up code
           ldy GameTimerDisplay       ;otherwise check first digit
           dey                        ;if first digit not on 1,
           bne ResGTCtrl              ;branch to reset game timer control
           lda GameTimerDisplay+1     ;otherwise check second and third digits
           ora GameTimerDisplay+2
           bne ResGTCtrl              ;if timer not at 100, branch to reset game timer control
           lda #TimeRunningOutMusic
           sta EventMusicQueue        ;otherwise load time running out music
ResGTCtrl: lda #$18                   ;reset game timer control
           sta GameTimerCtrlTimer
           ldy #$23                   ;set offset for last digit
           lda #$ff                   ;set value to decrement game timer digit
           sta DigitModifier+5
           jsr DigitsMathRoutine      ;do sub to decrement game timer slowly
           lda #$a4                   ;set status nybbles to update game timer display
           jmp PrintStatusBarNumbers  ;do sub to update the display
TimeUpOn:  sta PlayerStatus           ;init player status (note A will always be zero here)
           jsr ForceInjury            ;do sub to kill the player (note player is small here)
           inc GameTimerExpiredFlag   ;set game timer expiration flag
ExGTimer:  rts                        ;leave

;-------------------------------------------------------------------------------------

WarpZoneObject:
      lda ScrollLock         ;check for scroll lock flag
      beq ExGTimer           ;branch if not set to leave
      lda Player_Y_Position  ;check to see if player's vertical coordinate has
      and Player_Y_HighPos   ;same bits set as in vertical high byte (why?)
      bne ExGTimer           ;if so, branch to leave
      sta ScrollLock         ;otherwise nullify scroll lock flag
      inc WarpZoneControl    ;increment warp zone flag to make warp pipes for warp zone
      jmp EraseEnemyObject   ;kill this object

;-------------------------------------------------------------------------------------
;$00 - used in WhirlpoolActivate to store whirlpool length / 2, page location of center of whirlpool
;and also to store movement force exerted on player
;$01 - used in ProcessWhirlpools to store page location of right extent of whirlpool
;and in WhirlpoolActivate to store center of whirlpool
;$02 - used in ProcessWhirlpools to store right extent of whirlpool and in
;WhirlpoolActivate to store maximum vertical speed

ProcessWhirlpools:
        lda AreaType                ;check for water type level
        bne ExitWh                  ;branch to leave if not found
        sta Whirlpool_Flag          ;otherwise initialize whirlpool flag
        lda TimerControl            ;if master timer control set,
        bne ExitWh                  ;branch to leave
        ldy #$04                    ;otherwise start with last whirlpool data
WhLoop: lda Whirlpool_LeftExtent,y  ;get left extent of whirlpool
        clc
        adc Whirlpool_Length,y      ;add length of whirlpool
        sta $02                     ;store result as right extent here
        lda Whirlpool_PageLoc,y     ;get page location
        beq NextWh                  ;if none or page 0, branch to get next data
        adc #$00                    ;add carry
        sta $01                     ;store result as page location of right extent here
        lda Player_X_Position       ;get player's horizontal position
        sec
        sbc Whirlpool_LeftExtent,y  ;subtract left extent
        lda Player_PageLoc          ;get player's page location
        sbc Whirlpool_PageLoc,y     ;subtract borrow
        bmi NextWh                  ;if player too far left, branch to get next data
        lda $02                     ;otherwise get right extent
        sec
        sbc Player_X_Position       ;subtract player's horizontal coordinate
        lda $01                     ;get right extent's page location
        sbc Player_PageLoc          ;subtract borrow
        bpl WhirlpoolActivate       ;if player within right extent, branch to whirlpool code
NextWh: dey                         ;move onto next whirlpool data
        bpl WhLoop                  ;do this until all whirlpools are checked
ExitWh: rts                         ;leave

WhirlpoolActivate:
        lda Whirlpool_Length,y      ;get length of whirlpool
        lsr                         ;divide by 2
        sta $00                     ;save here
        lda Whirlpool_LeftExtent,y  ;get left extent of whirlpool
        clc
        adc $00                     ;add length divided by 2
        sta $01                     ;save as center of whirlpool
        lda Whirlpool_PageLoc,y     ;get page location
        adc #$00                    ;add carry
        sta $00                     ;save as page location of whirlpool center
        lda FrameCounter            ;get frame counter
        lsr                         ;shift d0 into carry (to run on every other frame)
        bcc WhPull                  ;if d0 not set, branch to last part of code
        lda $01                     ;get center
        sec
        sbc Player_X_Position       ;subtract player's horizontal coordinate
        lda $00                     ;get page location of center
        sbc Player_PageLoc          ;subtract borrow
        bpl LeftWh                  ;if player to the left of center, branch
        lda Player_X_Position       ;otherwise slowly pull player left, towards the center
        sec
        sbc #$01                    ;subtract one pixel
        sta Player_X_Position       ;set player's new horizontal coordinate
        lda Player_PageLoc
        sbc #$00                    ;subtract borrow
        jmp SetPWh                  ;jump to set player's new page location
LeftWh: lda Player_CollisionBits    ;get player's collision bits
        lsr                         ;shift d0 into carry
        bcc WhPull                  ;if d0 not set, branch
        lda Player_X_Position       ;otherwise slowly pull player right, towards the center
        clc
        adc #$01                    ;add one pixel
        sta Player_X_Position       ;set player's new horizontal coordinate
        lda Player_PageLoc
        adc #$00                    ;add carry
SetPWh: sta Player_PageLoc          ;set player's new page location
WhPull: lda #$10
        sta $00                     ;set vertical movement force
        lda #$01
        sta Whirlpool_Flag          ;set whirlpool flag to be used later
        sta $02                     ;also set maximum vertical speed
        lsr
        tax                         ;set X for player offset
        jmp ImposeGravity           ;jump to put whirlpool effect on player vertically, do not return

;-------------------------------------------------------------------------------------

FlagpoleScoreMods:
      .db $05, $02, $08, $04, $01

FlagpoleScoreDigits:
      .db $03, $03, $04, $04, $04

FlagpoleRoutine:
           ldx #$05                  ;set enemy object offset
           stx ObjectOffset          ;to special use slot
           lda Enemy_ID,x
           cmp #FlagpoleFlagObject   ;if flagpole flag not found,
           bne ExitFlagP             ;branch to leave
           lda GameEngineSubroutine
           cmp #$04                  ;if flagpole slide routine not running,
           bne SkipScore             ;branch to near the end of code
           lda Player_State
           cmp #$03                  ;if player state not climbing,
           bne SkipScore             ;branch to near the end of code
           lda Enemy_Y_Position,x    ;check flagpole flag's vertical coordinate
           cmp #$aa                  ;if flagpole flag down to a certain point,
           bcs GiveFPScr             ;branch to end the level
           lda Player_Y_Position     ;check player's vertical coordinate
           cmp #$a2                  ;if player down to a certain point,
           bcs GiveFPScr             ;branch to end the level
           lda Enemy_YMF_Dummy,x
           adc #$ff                  ;add movement amount to dummy variable
           sta Enemy_YMF_Dummy,x     ;save dummy variable
           lda Enemy_Y_Position,x    ;get flag's vertical coordinate
           adc #$01                  ;add 1 plus carry to move flag, and
           sta Enemy_Y_Position,x    ;store vertical coordinate
           lda FlagpoleFNum_YMFDummy
           sec                       ;subtract movement amount from dummy variable
           sbc #$ff
           sta FlagpoleFNum_YMFDummy ;save dummy variable
           lda FlagpoleFNum_Y_Pos
           sbc #$01                  ;subtract one plus borrow to move floatey number,
           sta FlagpoleFNum_Y_Pos    ;and store vertical coordinate here
SkipScore: jmp FPGfx                 ;jump to skip ahead and draw flag and floatey number
GiveFPScr: ldy FlagpoleScore         ;get score offset from earlier (when player touched flagpole)
           lda FlagpoleScoreMods,y   ;get amount to award player points
           ldx FlagpoleScoreDigits,y ;get digit with which to award points
           sta DigitModifier,x       ;store in digit modifier
           jsr AddToScore            ;do sub to award player points depending on height of collision
           lda #$05
           sta GameEngineSubroutine  ;set to run end-of-level subroutine on next frame
FPGfx:     jsr GetEnemyOffscreenBits ;get offscreen information
           jsr RelativeEnemyPosition ;get relative coordinates
           jsr FlagpoleGfxHandler    ;draw flagpole flag and floatey number
ExitFlagP: rts

;-------------------------------------------------------------------------------------

Jumpspring_Y_PosData:
      .db $08, $10, $08, $00

JumpspringHandler:
           jsr GetEnemyOffscreenBits   ;get offscreen information
           lda TimerControl            ;check master timer control
           bne DrawJSpr                ;branch to last section if set
           lda JumpspringAnimCtrl      ;check jumpspring frame control
           beq DrawJSpr                ;branch to last section if not set
           tay
           dey                         ;subtract one from frame control,
           tya                         ;the only way a poor nmos 6502 can
           and #%00000010              ;mask out all but d1, original value still in Y
           bne DownJSpr                ;if set, branch to move player up
           inc Player_Y_Position
           inc Player_Y_Position       ;move player's vertical position down two pixels
           jmp PosJSpr                 ;skip to next part
DownJSpr:  dec Player_Y_Position       ;move player's vertical position up two pixels
           dec Player_Y_Position
PosJSpr:   lda Jumpspring_FixedYPos,x  ;get permanent vertical position
           clc
           adc Jumpspring_Y_PosData,y  ;add value using frame control as offset
           sta Enemy_Y_Position,x      ;store as new vertical position
           cpy #$01                    ;check frame control offset (second frame is $00)
           bcc BounceJS                ;if offset not yet at third frame ($01), skip to next part
           lda A_B_Buttons
           and #A_Button               ;check saved controller bits for A button press
           beq BounceJS                ;skip to next part if A not pressed
           and PreviousA_B_Buttons     ;check for A button pressed in previous frame
           bne BounceJS                ;skip to next part if so
           lda #$f4
           sta JumpspringForce         ;otherwise write new jumpspring force here
BounceJS:  cpy #$03                    ;check frame control offset again
           bne DrawJSpr                ;skip to last part if not yet at fifth frame ($03)
           lda JumpspringForce
           sta Player_Y_Speed          ;store jumpspring force as player's new vertical speed
           lda #$00
           sta JumpspringAnimCtrl      ;initialize jumpspring frame control
DrawJSpr:  jsr RelativeEnemyPosition   ;get jumpspring's relative coordinates
           jsr EnemyGfxHandler         ;draw jumpspring
           jsr OffscreenBoundsCheck    ;check to see if we need to kill it
           lda JumpspringAnimCtrl      ;if frame control at zero, don't bother
           beq ExJSpring               ;trying to animate it, just leave
           lda JumpspringTimer
           bne ExJSpring               ;if jumpspring timer not expired yet, leave
           lda #$04
           sta JumpspringTimer         ;otherwise initialize jumpspring timer
           inc JumpspringAnimCtrl      ;increment frame control to animate jumpspring
ExJSpring: rts                         ;leave

;-------------------------------------------------------------------------------------

Setup_Vine:
        lda #VineObject          ;load identifier for vine object
        sta Enemy_ID,x           ;store in buffer
        lda #$01
        sta Enemy_Flag,x         ;set flag for enemy object buffer
        lda Block_PageLoc,y
        sta Enemy_PageLoc,x      ;copy page location from previous object
        lda Block_X_Position,y
        sta Enemy_X_Position,x   ;copy horizontal coordinate from previous object
        lda Block_Y_Position,y
        sta Enemy_Y_Position,x   ;copy vertical coordinate from previous object
        ldy VineFlagOffset       ;load vine flag/offset to next available vine slot
        bne NextVO               ;if set at all, don't bother to store vertical
        sta VineStart_Y_Position ;otherwise store vertical coordinate here
NextVO: txa                      ;store object offset to next available vine slot
        sta VineObjOffset,y      ;using vine flag as offset
        inc VineFlagOffset       ;increment vine flag offset
        lda #Sfx_GrowVine
        sta Square2SoundQueue    ;load vine grow sound
        rts

;-------------------------------------------------------------------------------------
;$06-$07 - used as address to block buffer data
;$02 - used as vertical high nybble of block buffer offset

VineHeightData:
      .db $30, $60

VineObjectHandler:
           cpx #$05                  ;check enemy offset for special use slot
           bne ExitVH                ;if not in last slot, branch to leave
           ldy VineFlagOffset
           dey                       ;decrement vine flag in Y, use as offset
           lda VineHeight
           cmp VineHeightData,y      ;if vine has reached certain height,
           beq RunVSubs              ;branch ahead to skip this part
           lda FrameCounter          ;get frame counter
           lsr                       ;shift d1 into carry
           lsr
           bcc RunVSubs              ;if d1 not set (2 frames every 4) skip this part
           lda Enemy_Y_Position+5
           sbc #$01                  ;subtract vertical position of vine
           sta Enemy_Y_Position+5    ;one pixel every frame it's time
           inc VineHeight            ;increment vine height
RunVSubs:  lda VineHeight            ;if vine still very small,
           cmp #$08                  ;branch to leave
           bcc ExitVH
           jsr RelativeEnemyPosition ;get relative coordinates of vine,
           jsr GetEnemyOffscreenBits ;and any offscreen bits
           ldy #$00                  ;initialize offset used in draw vine sub
VDrawLoop: jsr DrawVine              ;draw vine
           iny                       ;increment offset
           cpy VineFlagOffset        ;if offset in Y and offset here
           bne VDrawLoop             ;do not yet match, loop back to draw more vine
           lda Enemy_OffscreenBits
           and #%00001100            ;mask offscreen bits
           beq WrCMTile              ;if none of the saved offscreen bits set, skip ahead
           dey                       ;otherwise decrement Y to get proper offset again
KillVine:  ldx VineObjOffset,y       ;get enemy object offset for this vine object
           jsr EraseEnemyObject      ;kill this vine object
           dey                       ;decrement Y
           bpl KillVine              ;if any vine objects left, loop back to kill it
           sta VineFlagOffset        ;initialize vine flag/offset
           sta VineHeight            ;initialize vine height
WrCMTile:  lda VineHeight            ;check vine height
           cmp #$20                  ;if vine small (less than 32 pixels tall)
           bcc ExitVH                ;then branch ahead to leave
           ldx #$06                  ;set offset in X to last enemy slot
           lda #$01                  ;set A to obtain horizontal in $04, but we don't care
           ldy #$1b                  ;set Y to offset to get block at ($04, $10) of coordinates
           jsr BlockBufferCollision  ;do a sub to get block buffer address set, return contents
           ldy $02
           cpy #$d0                  ;if vertical high nybble offset beyond extent of
           bcs ExitVH                ;current block buffer, branch to leave, do not write
           lda ($06),y               ;otherwise check contents of block buffer at
           bne ExitVH                ;current offset, if not empty, branch to leave
           lda #$26
           sta ($06),y               ;otherwise, write climbing metatile to block buffer
ExitVH:    ldx ObjectOffset          ;get enemy object offset and leave
           rts

;-------------------------------------------------------------------------------------

CannonBitmasks:
      .db %00001111, %00000111

ProcessCannons:
           lda AreaType                ;get area type
           beq ExCannon                ;if water type area, branch to leave
           ldx #$02
ThreeSChk: stx ObjectOffset            ;start at third enemy slot
           lda Enemy_Flag,x            ;check enemy buffer flag
           bne Chk_BB                  ;if set, branch to check enemy
           lda PseudoRandomBitReg+1,x  ;otherwise get part of LSFR
           ldy SecondaryHardMode       ;get secondary hard mode flag, use as offset
           and CannonBitmasks,y        ;mask out bits of LSFR as decided by flag
           cmp #$06                    ;check to see if lower nybble is above certain value
           bcs Chk_BB                  ;if so, branch to check enemy
           tay                         ;transfer masked contents of LSFR to Y as pseudorandom offset
           lda Cannon_PageLoc,y        ;get page location
           beq Chk_BB                  ;if not set or on page 0, branch to check enemy
           lda Cannon_Timer,y          ;get cannon timer
           beq FireCannon              ;if expired, branch to fire cannon
           sbc #$00                    ;otherwise subtract borrow (note carry will always be clear here)
           sta Cannon_Timer,y          ;to count timer down
           jmp Chk_BB                  ;then jump ahead to check enemy

FireCannon:
          lda TimerControl           ;if master timer control set,
          bne Chk_BB                 ;branch to check enemy
          lda #$0e                   ;otherwise we start creating one
          sta Cannon_Timer,y         ;first, reset cannon timer
          lda Cannon_PageLoc,y       ;get page location of cannon
          sta Enemy_PageLoc,x        ;save as page location of bullet bill
          lda Cannon_X_Position,y    ;get horizontal coordinate of cannon
          sta Enemy_X_Position,x     ;save as horizontal coordinate of bullet bill
          lda Cannon_Y_Position,y    ;get vertical coordinate of cannon
          sec
          sbc #$08                   ;subtract eight pixels (because enemies are 24 pixels tall)
          sta Enemy_Y_Position,x     ;save as vertical coordinate of bullet bill
          lda #$01
          sta Enemy_Y_HighPos,x      ;set vertical high byte of bullet bill
          sta Enemy_Flag,x           ;set buffer flag
          lsr                        ;shift right once to init A
          sta Enemy_State,x          ;then initialize enemy's state
          lda #$09
          sta Enemy_BoundBoxCtrl,x   ;set bounding box size control for bullet bill
          lda #BulletBill_CannonVar
          sta Enemy_ID,x             ;load identifier for bullet bill (cannon variant)
          jmp Next3Slt               ;move onto next slot
Chk_BB:   lda Enemy_ID,x             ;check enemy identifier for bullet bill (cannon variant)
          cmp #BulletBill_CannonVar
          bne Next3Slt               ;if not found, branch to get next slot
          jsr OffscreenBoundsCheck   ;otherwise, check to see if it went offscreen
          lda Enemy_Flag,x           ;check enemy buffer flag
          beq Next3Slt               ;if not set, branch to get next slot
          jsr GetEnemyOffscreenBits  ;otherwise, get offscreen information
          jsr BulletBillHandler      ;then do sub to handle bullet bill
Next3Slt: dex                        ;move onto next slot
          bpl ThreeSChk              ;do this until first three slots are checked
ExCannon: rts                        ;then leave

;--------------------------------

BulletBillXSpdData:
      .db $18, $e8

BulletBillHandler:
           lda TimerControl          ;if master timer control set,
           bne RunBBSubs             ;branch to run subroutines except movement sub
           lda Enemy_State,x
           bne ChkDSte               ;if bullet bill's state set, branch to check defeated state
           lda Enemy_OffscreenBits   ;otherwise load offscreen bits
           and #%00001100            ;mask out bits
           cmp #%00001100            ;check to see if all bits are set
           beq KillBB                ;if so, branch to kill this object
           ldy #$01                  ;set to move right by default
           jsr PlayerEnemyDiff       ;get horizontal difference between player and bullet bill
           bmi SetupBB               ;if enemy to the left of player, branch
           iny                       ;otherwise increment to move left
SetupBB:   sty Enemy_MovingDir,x     ;set bullet bill's moving direction
           dey                       ;decrement to use as offset
           lda BulletBillXSpdData,y  ;get horizontal speed based on moving direction
           sta Enemy_X_Speed,x       ;and store it
           lda $00                   ;get horizontal difference
           adc #$28                  ;add 40 pixels
           cmp #$50                  ;if less than a certain amount, player is too close
           bcc KillBB                ;to cannon either on left or right side, thus branch
           lda #$01
           sta Enemy_State,x         ;otherwise set bullet bill's state
           lda #$0a
           sta EnemyFrameTimer,x     ;set enemy frame timer
           lda #Sfx_Blast
           sta Square2SoundQueue     ;play fireworks/gunfire sound
ChkDSte:   lda Enemy_State,x         ;check enemy state for d5 set
           and #%00100000
           beq BBFly                 ;if not set, skip to move horizontally
           jsr MoveD_EnemyVertically ;otherwise do sub to move bullet bill vertically
BBFly:     jsr MoveEnemyHorizontally ;do sub to move bullet bill horizontally
RunBBSubs: jsr GetEnemyOffscreenBits ;get offscreen information
           jsr RelativeEnemyPosition ;get relative coordinates
           jsr GetEnemyBoundBox      ;get bounding box coordinates
           jsr PlayerEnemyCollision  ;handle player to enemy collisions
           jmp EnemyGfxHandler       ;draw the bullet bill and leave
KillBB:    jsr EraseEnemyObject      ;kill bullet bill and leave
           rts

;-------------------------------------------------------------------------------------

HammerEnemyOfsData:
      .db $04, $04, $04, $05, $05, $05
      .db $06, $06, $06

HammerXSpdData:
      .db $10, $f0

SpawnHammerObj:
          lda PseudoRandomBitReg+1 ;get pseudorandom bits from
          and #%00000111           ;second part of LSFR
          bne SetMOfs              ;if any bits are set, branch and use as offset
          lda PseudoRandomBitReg+1
          and #%00001000           ;get d3 from same part of LSFR
SetMOfs:  tay                      ;use either d3 or d2-d0 for offset here
          lda Misc_State,y         ;if any values loaded in
          bne NoHammer             ;$2a-$32 where offset is then leave with carry clear
          ldx HammerEnemyOfsData,y ;get offset of enemy slot to check using Y as offset
          lda Enemy_Flag,x         ;check enemy buffer flag at offset
          bne NoHammer             ;if buffer flag set, branch to leave with carry clear
          ldx ObjectOffset         ;get original enemy object offset
          txa
          sta HammerEnemyOffset,y  ;save here
          lda #$90
          sta Misc_State,y         ;save hammer's state here
          lda #$07
          sta Misc_BoundBoxCtrl,y  ;set something else entirely, here
          sec                      ;return with carry set
          rts
NoHammer: ldx ObjectOffset         ;get original enemy object offset
          clc                      ;return with carry clear
          rts

;--------------------------------
;$00 - used to set downward force
;$01 - used to set upward force (residual)
;$02 - used to set maximum speed

ProcHammerObj:
          lda TimerControl           ;if master timer control set
          bne RunHSubs               ;skip all of this code and go to last subs at the end
          lda Misc_State,x           ;otherwise get hammer's state
          and #%01111111             ;mask out d7
          ldy HammerEnemyOffset,x    ;get enemy object offset that spawned this hammer
          cmp #$02                   ;check hammer's state
          beq SetHSpd                ;if currently at 2, branch
          bcs SetHPos                ;if greater than 2, branch elsewhere
          txa
          clc                        ;add 13 bytes to use
          adc #$0d                   ;proper misc object
          tax                        ;return offset to X
          lda #$10
          sta $00                    ;set downward movement force
          lda #$0f
          sta $01                    ;set upward movement force (not used)
          lda #$04
          sta $02                    ;set maximum vertical speed
          lda #$00                   ;set A to impose gravity on hammer
          jsr ImposeGravity          ;do sub to impose gravity on hammer and move vertically
          jsr MoveObjectHorizontally ;do sub to move it horizontally
          ldx ObjectOffset           ;get original misc object offset
          jmp RunAllH                ;branch to essential subroutines
SetHSpd:  lda #$fe
          sta Misc_Y_Speed,x         ;set hammer's vertical speed
          lda Enemy_State,y          ;get enemy object state
          and #%11110111             ;mask out d3
          sta Enemy_State,y          ;store new state
          ldx Enemy_MovingDir,y      ;get enemy's moving direction
          dex                        ;decrement to use as offset
          lda HammerXSpdData,x       ;get proper speed to use based on moving direction
          ldx ObjectOffset           ;reobtain hammer's buffer offset
          sta Misc_X_Speed,x         ;set hammer's horizontal speed
SetHPos:  dec Misc_State,x           ;decrement hammer's state
          lda Enemy_X_Position,y     ;get enemy's horizontal position
          clc
          adc #$02                   ;set position 2 pixels to the right
          sta Misc_X_Position,x      ;store as hammer's horizontal position
          lda Enemy_PageLoc,y        ;get enemy's page location
          adc #$00                   ;add carry
          sta Misc_PageLoc,x         ;store as hammer's page location
          lda Enemy_Y_Position,y     ;get enemy's vertical position
          sec
          sbc #$0a                   ;move position 10 pixels upward
          sta Misc_Y_Position,x      ;store as hammer's vertical position
          lda #$01
          sta Misc_Y_HighPos,x       ;set hammer's vertical high byte
          bne RunHSubs               ;unconditional branch to skip first routine
RunAllH:  jsr PlayerHammerCollision  ;handle collisions
RunHSubs: jsr GetMiscOffscreenBits   ;get offscreen information
          jsr RelativeMiscPosition   ;get relative coordinates
          jsr GetMiscBoundBox        ;get bounding box coordinates
          jsr DrawHammer             ;draw the hammer
          rts                        ;and we are done here

;-------------------------------------------------------------------------------------
;$02 - used to store vertical high nybble offset from block buffer routine
;$06 - used to store low byte of block buffer address

CoinBlock:
      jsr FindEmptyMiscSlot   ;set offset for empty or last misc object buffer slot
      lda Block_PageLoc,x     ;get page location of block object
      sta Misc_PageLoc,y      ;store as page location of misc object
      lda Block_X_Position,x  ;get horizontal coordinate of block object
      ora #$05                ;add 5 pixels
      sta Misc_X_Position,y   ;store as horizontal coordinate of misc object
      lda Block_Y_Position,x  ;get vertical coordinate of block object
      sbc #$10                ;subtract 16 pixels
      sta Misc_Y_Position,y   ;store as vertical coordinate of misc object
      jmp JCoinC              ;jump to rest of code as applies to this misc object

SetupJumpCoin:
        jsr FindEmptyMiscSlot  ;set offset for empty or last misc object buffer slot
        lda Block_PageLoc2,x   ;get page location saved earlier
        sta Misc_PageLoc,y     ;and save as page location for misc object
        lda $06                ;get low byte of block buffer offset
        asl
        asl                    ;multiply by 16 to use lower nybble
        asl
        asl
        ora #$05               ;add five pixels
        sta Misc_X_Position,y  ;save as horizontal coordinate for misc object
        lda $02                ;get vertical high nybble offset from earlier
        adc #$20               ;add 32 pixels for the status bar
        sta Misc_Y_Position,y  ;store as vertical coordinate
JCoinC: lda #$fb
        sta Misc_Y_Speed,y     ;set vertical speed
        lda #$01
        sta Misc_Y_HighPos,y   ;set vertical high byte
        sta Misc_State,y       ;set state for misc object
        sta Square2SoundQueue  ;load coin grab sound
        stx ObjectOffset       ;store current control bit as misc object offset
        jsr GiveOneCoin        ;update coin tally on the screen and coin amount variable
        inc CoinTallyFor1Ups   ;increment coin tally used to activate 1-up block flag
        rts

FindEmptyMiscSlot:
           ldy #$08                ;start at end of misc objects buffer
FMiscLoop: lda Misc_State,y        ;get misc object state
           beq UseMiscS            ;branch if none found to use current offset
           dey                     ;decrement offset
           cpy #$05                ;do this for three slots
           bne FMiscLoop           ;do this until all slots are checked
           ldy #$08                ;if no empty slots found, use last slot
UseMiscS:  sty JumpCoinMiscOffset  ;store offset of misc object buffer here (residual)
           rts

;-------------------------------------------------------------------------------------

MiscObjectsCore:
          ldx #$08          ;set at end of misc object buffer
MiscLoop: stx ObjectOffset  ;store misc object offset here
          lda Misc_State,x  ;check misc object state
          beq MiscLoopBack  ;branch to check next slot
          asl               ;otherwise shift d7 into carry
          bcc ProcJumpCoin  ;if d7 not set, jumping coin, thus skip to rest of code here
          jsr ProcHammerObj ;otherwise go to process hammer,
          jmp MiscLoopBack  ;then check next slot

;--------------------------------
;$00 - used to set downward force
;$01 - used to set upward force (residual)
;$02 - used to set maximum speed

ProcJumpCoin:
           ldy Misc_State,x          ;check misc object state
           dey                       ;decrement to see if it's set to 1
           beq JCoinRun              ;if so, branch to handle jumping coin
           inc Misc_State,x          ;otherwise increment state to either start off or as timer
           lda Misc_X_Position,x     ;get horizontal coordinate for misc object
           clc                       ;whether its jumping coin (state 0 only) or floatey number
           adc ScrollAmount          ;add current scroll speed
           sta Misc_X_Position,x     ;store as new horizontal coordinate
           lda Misc_PageLoc,x        ;get page location
           adc #$00                  ;add carry
           sta Misc_PageLoc,x        ;store as new page location
           lda Misc_State,x
           cmp #$30                  ;check state of object for preset value
           bne RunJCSubs             ;if not yet reached, branch to subroutines
           lda #$00
           sta Misc_State,x          ;otherwise nullify object state
           jmp MiscLoopBack          ;and move onto next slot
JCoinRun:  txa
           clc                       ;add 13 bytes to offset for next subroutine
           adc #$0d
           tax
           lda #$50                  ;set downward movement amount
           sta $00
           lda #$06                  ;set maximum vertical speed
           sta $02
           lsr                       ;divide by 2 and set
           sta $01                   ;as upward movement amount (apparently residual)
           lda #$00                  ;set A to impose gravity on jumping coin
           jsr ImposeGravity         ;do sub to move coin vertically and impose gravity on it
           ldx ObjectOffset          ;get original misc object offset
           lda Misc_Y_Speed,x        ;check vertical speed
           cmp #$05
           bne RunJCSubs             ;if not moving downward fast enough, keep state as-is
           inc Misc_State,x          ;otherwise increment state to change to floatey number
RunJCSubs: jsr RelativeMiscPosition  ;get relative coordinates
           jsr GetMiscOffscreenBits  ;get offscreen information
           jsr GetMiscBoundBox       ;get bounding box coordinates (why?)
           jsr JCoinGfxHandler       ;draw the coin or floatey number

MiscLoopBack:
           dex                       ;decrement misc object offset
           bpl MiscLoop              ;loop back until all misc objects handled
           rts                       ;then leave

;-------------------------------------------------------------------------------------

CoinTallyOffsets:
      .db $17, $1d

ScoreOffsets:
      .db $0b, $11

StatusBarNybbles:
      .db $02, $13

GiveOneCoin:
      lda #$01               ;set digit modifier to add 1 coin
      sta DigitModifier+5    ;to the current player's coin tally
      ldx CurrentPlayer      ;get current player on the screen
      ldy CoinTallyOffsets,x ;get offset for player's coin tally
      jsr DigitsMathRoutine  ;update the coin tally
      inc CoinTally          ;increment onscreen player's coin amount
      lda CoinTally
      cmp #100               ;does player have 100 coins yet?
      bne CoinPoints         ;if not, skip all of this
      lda #$00
      sta CoinTally          ;otherwise, reinitialize coin amount
      inc NumberofLives      ;give the player an extra life
      lda #Sfx_ExtraLife
      sta Square2SoundQueue  ;play 1-up sound

CoinPoints:
      lda #$02               ;set digit modifier to award
      sta DigitModifier+4    ;200 points to the player

AddToScore:
      ldx CurrentPlayer      ;get current player
      ldy ScoreOffsets,x     ;get offset for player's score
      jsr DigitsMathRoutine  ;update the score internally with value in digit modifier

GetSBNybbles:
      ldy CurrentPlayer      ;get current player
      lda StatusBarNybbles,y ;get nybbles based on player, use to update score and coins

UpdateNumber:
        jsr PrintStatusBarNumbers ;print status bar numbers based on nybbles, whatever they be
        ldy VRAM_Buffer1_Offset
        lda VRAM_Buffer1-6,y      ;check highest digit of score
        bne NoZSup                ;if zero, overwrite with space tile for zero suppression
        lda #$24
        sta VRAM_Buffer1-6,y
NoZSup: ldx ObjectOffset          ;get enemy object buffer offset
        rts

;-------------------------------------------------------------------------------------

SetupPowerUp:
           lda #PowerUpObject        ;load power-up identifier into
           sta Enemy_ID+5            ;special use slot of enemy object buffer
           lda Block_PageLoc,x       ;store page location of block object
           sta Enemy_PageLoc+5       ;as page location of power-up object
           lda Block_X_Position,x    ;store horizontal coordinate of block object
           sta Enemy_X_Position+5    ;as horizontal coordinate of power-up object
           lda #$01
           sta Enemy_Y_HighPos+5     ;set vertical high byte of power-up object
           lda Block_Y_Position,x    ;get vertical coordinate of block object
           sec
           sbc #$08                  ;subtract 8 pixels
           sta Enemy_Y_Position+5    ;and use as vertical coordinate of power-up object
PwrUpJmp:  lda #$01                  ;this is a residual jump point in enemy object jump table
           sta Enemy_State+5         ;set power-up object's state
           sta Enemy_Flag+5          ;set buffer flag
           lda #$03
           sta Enemy_BoundBoxCtrl+5  ;set bounding box size control for power-up object
           lda PowerUpType
           cmp #$02                  ;check currently loaded power-up type
           bcs PutBehind             ;if star or 1-up, branch ahead
           lda PlayerStatus          ;otherwise check player's current status
           cmp #$02
           bcc StrType               ;if player not fiery, use status as power-up type
           lsr                       ;otherwise shift right to force fire flower type
StrType:   sta PowerUpType           ;store type here
PutBehind: lda #%00100000
           sta Enemy_SprAttrib+5     ;set background priority bit
           lda #Sfx_GrowPowerUp
           sta Square2SoundQueue     ;load power-up reveal sound and leave
           rts

;-------------------------------------------------------------------------------------

PowerUpObjHandler:
         ldx #$05                   ;set object offset for last slot in enemy object buffer
         stx ObjectOffset
         lda Enemy_State+5          ;check power-up object's state
         beq ExitPUp                ;if not set, branch to leave
         asl                        ;shift to check if d7 was set in object state
         bcc GrowThePowerUp         ;if not set, branch ahead to skip this part
         lda TimerControl           ;if master timer control set,
         bne RunPUSubs              ;branch ahead to enemy object routines
         lda PowerUpType            ;check power-up type
         beq ShroomM                ;if normal mushroom, branch ahead to move it
         cmp #$03
         beq ShroomM                ;if 1-up mushroom, branch ahead to move it
         cmp #$02
         bne RunPUSubs              ;if not star, branch elsewhere to skip movement
         jsr MoveJumpingEnemy       ;otherwise impose gravity on star power-up and make it jump
         jsr EnemyJump              ;note that green paratroopa shares the same code here
         jmp RunPUSubs              ;then jump to other power-up subroutines
ShroomM: jsr MoveNormalEnemy        ;do sub to make mushrooms move
         jsr EnemyToBGCollisionDet  ;deal with collisions
         jmp RunPUSubs              ;run the other subroutines

GrowThePowerUp:
           lda FrameCounter           ;get frame counter
           and #$03                   ;mask out all but 2 LSB
           bne ChkPUSte               ;if any bits set here, branch
           dec Enemy_Y_Position+5     ;otherwise decrement vertical coordinate slowly
           lda Enemy_State+5          ;load power-up object state
           inc Enemy_State+5          ;increment state for next frame (to make power-up rise)
           cmp #$11                   ;if power-up object state not yet past 16th pixel,
           bcc ChkPUSte               ;branch ahead to last part here
           lda #$10
           sta Enemy_X_Speed,x        ;otherwise set horizontal speed
           lda #%10000000
           sta Enemy_State+5          ;and then set d7 in power-up object's state
           asl                        ;shift once to init A
           sta Enemy_SprAttrib+5      ;initialize background priority bit set here
           rol                        ;rotate A to set right moving direction
           sta Enemy_MovingDir,x      ;set moving direction
ChkPUSte:  lda Enemy_State+5          ;check power-up object's state
           cmp #$06                   ;for if power-up has risen enough
           bcc ExitPUp                ;if not, don't even bother running these routines
RunPUSubs: jsr RelativeEnemyPosition  ;get coordinates relative to screen
           jsr GetEnemyOffscreenBits  ;get offscreen bits
           jsr GetEnemyBoundBox       ;get bounding box coordinates
           jsr DrawPowerUp            ;draw the power-up object
           jsr PlayerEnemyCollision   ;check for collision with player
           jsr OffscreenBoundsCheck   ;check to see if it went offscreen
ExitPUp:   rts                        ;and we're done

;-------------------------------------------------------------------------------------
;These apply to all routines in this section unless otherwise noted:
;$00 - used to store metatile from block buffer routine
;$02 - used to store vertical high nybble offset from block buffer routine
;$05 - used to store metatile stored in A at beginning of PlayerHeadCollision
;$06-$07 - used as block buffer address indirect

BlockYPosAdderData:
      .db $04, $12

PlayerHeadCollision:
           pha                      ;store metatile number to stack
           lda #$11                 ;load unbreakable block object state by default
           ldx SprDataOffset_Ctrl   ;load offset control bit here
           ldy PlayerSize           ;check player's size
           bne DBlockSte            ;if small, branch
           lda #$12                 ;otherwise load breakable block object state
DBlockSte: sta Block_State,x        ;store into block object buffer
           jsr DestroyBlockMetatile ;store blank metatile in vram buffer to write to name table
           ldx SprDataOffset_Ctrl   ;load offset control bit
           lda $02                  ;get vertical high nybble offset used in block buffer routine
           sta Block_Orig_YPos,x    ;set as vertical coordinate for block object
           tay
           lda $06                  ;get low byte of block buffer address used in same routine
           sta Block_BBuf_Low,x     ;save as offset here to be used later
           lda ($06),y              ;get contents of block buffer at old address at $06, $07
           jsr BlockBumpedChk       ;do a sub to check which block player bumped head on
           sta $00                  ;store metatile here
           ldy PlayerSize           ;check player's size
           bne ChkBrick             ;if small, use metatile itself as contents of A
           tya                      ;otherwise init A (note: big = 0)
ChkBrick:  bcc PutMTileB            ;if no match was found in previous sub, skip ahead
           ldy #$11                 ;otherwise load unbreakable state into block object buffer
           sty Block_State,x        ;note this applies to both player sizes
           lda #$c4                 ;load empty block metatile into A for now
           ldy $00                  ;get metatile from before
           cpy #$58                 ;is it brick with coins (with line)?
           beq StartBTmr            ;if so, branch
           cpy #$5d                 ;is it brick with coins (without line)?
           bne PutMTileB            ;if not, branch ahead to store empty block metatile
StartBTmr: lda BrickCoinTimerFlag   ;check brick coin timer flag
           bne ContBTmr             ;if set, timer expired or counting down, thus branch
           lda #$0b
           sta BrickCoinTimer       ;if not set, set brick coin timer
           inc BrickCoinTimerFlag   ;and set flag linked to it
ContBTmr:  lda BrickCoinTimer       ;check brick coin timer
           bne PutOldMT             ;if not yet expired, branch to use current metatile
           ldy #$c4                 ;otherwise use empty block metatile
PutOldMT:  tya                      ;put metatile into A
PutMTileB: sta Block_Metatile,x     ;store whatever metatile be appropriate here
           jsr InitBlock_XY_Pos     ;get block object horizontal coordinates saved
           ldy $02                  ;get vertical high nybble offset
           lda #$23
           sta ($06),y              ;write blank metatile $23 to block buffer
           lda #$10
           sta BlockBounceTimer     ;set block bounce timer
           pla                      ;pull original metatile from stack
           sta $05                  ;and save here
           ldy #$00                 ;set default offset
           lda CrouchingFlag        ;is player crouching?
           bne SmallBP              ;if so, branch to increment offset
           lda PlayerSize           ;is player big?
           beq BigBP                ;if so, branch to use default offset
SmallBP:   iny                      ;increment for small or big and crouching
BigBP:     lda Player_Y_Position    ;get player's vertical coordinate
           clc
           adc BlockYPosAdderData,y ;add value determined by size
           and #$f0                 ;mask out low nybble to get 16-pixel correspondence
           sta Block_Y_Position,x   ;save as vertical coordinate for block object
           ldy Block_State,x        ;get block object state
           cpy #$11
           beq Unbreak              ;if set to value loaded for unbreakable, branch
           jsr BrickShatter         ;execute code for breakable brick
           jmp InvOBit              ;skip subroutine to do last part of code here
Unbreak:   jsr BumpBlock            ;execute code for unbreakable brick or question block
InvOBit:   lda SprDataOffset_Ctrl   ;invert control bit used by block objects
           eor #$01                 ;and floatey numbers
           sta SprDataOffset_Ctrl
           rts                      ;leave!

;--------------------------------

InitBlock_XY_Pos:
      lda Player_X_Position   ;get player's horizontal coordinate
      clc
      adc #$08                ;add eight pixels
      and #$f0                ;mask out low nybble to give 16-pixel correspondence
      sta Block_X_Position,x  ;save as horizontal coordinate for block object
      lda Player_PageLoc
      adc #$00                ;add carry to page location of player
      sta Block_PageLoc,x     ;save as page location of block object
      sta Block_PageLoc2,x    ;save elsewhere to be used later
      lda Player_Y_HighPos
      sta Block_Y_HighPos,x   ;save vertical high byte of player into
      rts                     ;vertical high byte of block object and leave

;--------------------------------

BumpBlock:
           jsr CheckTopOfBlock     ;check to see if there's a coin directly above this block
           lda #Sfx_Bump
           sta Square1SoundQueue   ;play bump sound
           lda #$00
           sta Block_X_Speed,x     ;initialize horizontal speed for block object
           sta Block_Y_MoveForce,x ;init fractional movement force
           sta Player_Y_Speed      ;init player's vertical speed
           lda #$fe
           sta Block_Y_Speed,x     ;set vertical speed for block object
           lda $05                 ;get original metatile from stack
           jsr BlockBumpedChk      ;do a sub to check which block player bumped head on
           bcc ExitBlockChk        ;if no match was found, branch to leave
           tya                     ;move block number to A
           cmp #$09                ;if block number was within 0-8 range,
           bcc BlockCode           ;branch to use current number
           sbc #$05                ;otherwise subtract 5 for second set to get proper number
BlockCode: jsr JumpEngine          ;run appropriate subroutine depending on block number

      .dw MushFlowerBlock
      .dw CoinBlock
      .dw CoinBlock
      .dw ExtraLifeMushBlock
      .dw MushFlowerBlock
      .dw VineBlock
      .dw StarBlock
      .dw CoinBlock
      .dw ExtraLifeMushBlock

;--------------------------------

MushFlowerBlock:
      lda #$00       ;load mushroom/fire flower into power-up type
      .db $2c        ;BIT instruction opcode

StarBlock:
      lda #$02       ;load star into power-up type
      .db $2c        ;BIT instruction opcode

ExtraLifeMushBlock:
      lda #$03         ;load 1-up mushroom into power-up type
      sta $39          ;store correct power-up type
      jmp SetupPowerUp

VineBlock:
      ldx #$05                ;load last slot for enemy object buffer
      ldy SprDataOffset_Ctrl  ;get control bit
      jsr Setup_Vine          ;set up vine object

ExitBlockChk:
      rts                     ;leave

;--------------------------------

BrickQBlockMetatiles:
      .db $c1, $c0, $5f, $60 ;used by question blocks

      ;these two sets are functionally identical, but look different
      .db $55, $56, $57, $58, $59 ;used by ground level types
      .db $5a, $5b, $5c, $5d, $5e ;used by other level types

BlockBumpedChk:
             ldy #$0d                    ;start at end of metatile data
BumpChkLoop: cmp BrickQBlockMetatiles,y  ;check to see if current metatile matches
             beq MatchBump               ;metatile found in block buffer, branch if so
             dey                         ;otherwise move onto next metatile
             bpl BumpChkLoop             ;do this until all metatiles are checked
             clc                         ;if none match, return with carry clear
MatchBump:   rts                         ;note carry is set if found match

;--------------------------------

BrickShatter:
      jsr CheckTopOfBlock    ;check to see if there's a coin directly above this block
      lda #Sfx_BrickShatter
      sta Block_RepFlag,x    ;set flag for block object to immediately replace metatile
      sta NoiseSoundQueue    ;load brick shatter sound
      jsr SpawnBrickChunks   ;create brick chunk objects
      lda #$fe
      sta Player_Y_Speed     ;set vertical speed for player
      lda #$05
      sta DigitModifier+5    ;set digit modifier to give player 50 points
      jsr AddToScore         ;do sub to update the score
      ldx SprDataOffset_Ctrl ;load control bit and leave
      rts

;--------------------------------

CheckTopOfBlock:
       ldx SprDataOffset_Ctrl  ;load control bit
       ldy $02                 ;get vertical high nybble offset used in block buffer
       beq TopEx               ;branch to leave if set to zero, because we're at the top
       tya                     ;otherwise set to A
       sec
       sbc #$10                ;subtract $10 to move up one row in the block buffer
       sta $02                 ;store as new vertical high nybble offset
       tay
       lda ($06),y             ;get contents of block buffer in same column, one row up
       cmp #$c2                ;is it a coin? (not underwater)
       bne TopEx               ;if not, branch to leave
       lda #$00
       sta ($06),y             ;otherwise put blank metatile where coin was
       jsr RemoveCoin_Axe      ;write blank metatile to vram buffer
       ldx SprDataOffset_Ctrl  ;get control bit
       jsr SetupJumpCoin       ;create jumping coin object and update coin variables
TopEx: rts                     ;leave!

;--------------------------------

SpawnBrickChunks:
      lda Block_X_Position,x     ;set horizontal coordinate of block object
      sta Block_Orig_XPos,x      ;as original horizontal coordinate here
      lda #$f0
      sta Block_X_Speed,x        ;set horizontal speed for brick chunk objects
      sta Block_X_Speed+2,x
      lda #$fa
      sta Block_Y_Speed,x        ;set vertical speed for one
      lda #$fc
      sta Block_Y_Speed+2,x      ;set lower vertical speed for the other
      lda #$00
      sta Block_Y_MoveForce,x    ;init fractional movement force for both
      sta Block_Y_MoveForce+2,x
      lda Block_PageLoc,x
      sta Block_PageLoc+2,x      ;copy page location
      lda Block_X_Position,x
      sta Block_X_Position+2,x   ;copy horizontal coordinate
      lda Block_Y_Position,x
      clc                        ;add 8 pixels to vertical coordinate
      adc #$08                   ;and save as vertical coordinate for one of them
      sta Block_Y_Position+2,x
      lda #$fa
      sta Block_Y_Speed,x        ;set vertical speed...again??? (redundant)
      rts

;-------------------------------------------------------------------------------------

BlockObjectsCore:
        lda Block_State,x           ;get state of block object
        beq UpdSte                  ;if not set, branch to leave
        and #$0f                    ;mask out high nybble
        pha                         ;push to stack
        tay                         ;put in Y for now
        txa
        clc
        adc #$09                    ;add 9 bytes to offset (note two block objects are created
        tax                         ;when using brick chunks, but only one offset for both)
        dey                         ;decrement Y to check for solid block state
        beq BouncingBlockHandler    ;branch if found, otherwise continue for brick chunks
        jsr ImposeGravityBlock      ;do sub to impose gravity on one block object object
        jsr MoveObjectHorizontally  ;do another sub to move horizontally
        txa
        clc                         ;move onto next block object
        adc #$02
        tax
        jsr ImposeGravityBlock      ;do sub to impose gravity on other block object
        jsr MoveObjectHorizontally  ;do another sub to move horizontally
        ldx ObjectOffset            ;get block object offset used for both
        jsr RelativeBlockPosition   ;get relative coordinates
        jsr GetBlockOffscreenBits   ;get offscreen information
        jsr DrawBrickChunks         ;draw the brick chunks
        pla                         ;get lower nybble of saved state
        ldy Block_Y_HighPos,x       ;check vertical high byte of block object
        beq UpdSte                  ;if above the screen, branch to kill it
        pha                         ;otherwise save state back into stack
        lda #$f0
        cmp Block_Y_Position+2,x    ;check to see if bottom block object went
        bcs ChkTop                  ;to the bottom of the screen, and branch if not
        sta Block_Y_Position+2,x    ;otherwise set offscreen coordinate
ChkTop: lda Block_Y_Position,x      ;get top block object's vertical coordinate
        cmp #$f0                    ;see if it went to the bottom of the screen
        pla                         ;pull block object state from stack
        bcc UpdSte                  ;if not, branch to save state
        bcs KillBlock               ;otherwise do unconditional branch to kill it

BouncingBlockHandler:
           jsr ImposeGravityBlock     ;do sub to impose gravity on block object
           ldx ObjectOffset           ;get block object offset
           jsr RelativeBlockPosition  ;get relative coordinates
           jsr GetBlockOffscreenBits  ;get offscreen information
           jsr DrawBlock              ;draw the block
           lda Block_Y_Position,x     ;get vertical coordinate
           and #$0f                   ;mask out high nybble
           cmp #$05                   ;check to see if low nybble wrapped around
           pla                        ;pull state from stack
           bcs UpdSte                 ;if still above amount, not time to kill block yet, thus branch
           lda #$01
           sta Block_RepFlag,x        ;otherwise set flag to replace metatile
KillBlock: lda #$00                   ;if branched here, nullify object state
UpdSte:    sta Block_State,x          ;store contents of A in block object state
           rts

;-------------------------------------------------------------------------------------
;$02 - used to store offset to block buffer
;$06-$07 - used to store block buffer address

BlockObjMT_Updater:
            ldx #$01                  ;set offset to start with second block object
UpdateLoop: stx ObjectOffset          ;set offset here
            lda VRAM_Buffer1          ;if vram buffer already being used here,
            bne NextBUpd              ;branch to move onto next block object
            lda Block_RepFlag,x       ;if flag for block object already clear,
            beq NextBUpd              ;branch to move onto next block object
            lda Block_BBuf_Low,x      ;get low byte of block buffer
            sta $06                   ;store into block buffer address
            lda #$05
            sta $07                   ;set high byte of block buffer address
            lda Block_Orig_YPos,x     ;get original vertical coordinate of block object
            sta $02                   ;store here and use as offset to block buffer
            tay
            lda Block_Metatile,x      ;get metatile to be written
            sta ($06),y               ;write it to the block buffer
            jsr ReplaceBlockMetatile  ;do sub to replace metatile where block object is
            lda #$00
            sta Block_RepFlag,x       ;clear block object flag
NextBUpd:   dex                       ;decrement block object offset
            bpl UpdateLoop            ;do this until both block objects are dealt with
            rts                       ;then leave

;-------------------------------------------------------------------------------------
;$00 - used to store high nybble of horizontal speed as adder
;$01 - used to store low nybble of horizontal speed
;$02 - used to store adder to page location

MoveEnemyHorizontally:
      inx                         ;increment offset for enemy offset
      jsr MoveObjectHorizontally  ;position object horizontally according to
      ldx ObjectOffset            ;counters, return with saved value in A,
      rts                         ;put enemy offset back in X and leave

MovePlayerHorizontally:
      lda JumpspringAnimCtrl  ;if jumpspring currently animating,
      bne ExXMove             ;branch to leave
      tax                     ;otherwise set zero for offset to use player's stuff

MoveObjectHorizontally:
          lda SprObject_X_Speed,x     ;get currently saved value (horizontal
          asl                         ;speed, secondary counter, whatever)
          asl                         ;and move low nybble to high
          asl
          asl
          sta $01                     ;store result here
          lda SprObject_X_Speed,x     ;get saved value again
          lsr                         ;move high nybble to low
          lsr
          lsr
          lsr
          cmp #$08                    ;if < 8, branch, do not change
          bcc SaveXSpd
          ora #%11110000              ;otherwise alter high nybble
SaveXSpd: sta $00                     ;save result here
          ldy #$00                    ;load default Y value here
          cmp #$00                    ;if result positive, leave Y alone
          bpl UseAdder
          dey                         ;otherwise decrement Y
UseAdder: sty $02                     ;save Y here
          lda SprObject_X_MoveForce,x ;get whatever number's here
          clc
          adc $01                     ;add low nybble moved to high
          sta SprObject_X_MoveForce,x ;store result here
          lda #$00                    ;init A
          rol                         ;rotate carry into d0
          pha                         ;push onto stack
          ror                         ;rotate d0 back onto carry
          lda SprObject_X_Position,x
          adc $00                     ;add carry plus saved value (high nybble moved to low
          sta SprObject_X_Position,x  ;plus $f0 if necessary) to object's horizontal position
          lda SprObject_PageLoc,x
          adc $02                     ;add carry plus other saved value to the
          sta SprObject_PageLoc,x     ;object's page location and save
          pla
          clc                         ;pull old carry from stack and add
          adc $00                     ;to high nybble moved to low
ExXMove:  rts                         ;and leave

;-------------------------------------------------------------------------------------
;$00 - used for downward force
;$01 - used for upward force
;$02 - used for maximum vertical speed

MovePlayerVertically:
         ldx #$00                ;set X for player offset
         lda TimerControl
         bne NoJSChk             ;if master timer control set, branch ahead
         lda JumpspringAnimCtrl  ;otherwise check to see if jumpspring is animating
         bne ExXMove             ;branch to leave if so
NoJSChk: lda VerticalForce       ;dump vertical force
         sta $00
         lda #$04                ;set maximum vertical speed here
         jmp ImposeGravitySprObj ;then jump to move player vertically

;--------------------------------

MoveD_EnemyVertically:
      ldy #$3d           ;set quick movement amount downwards
      lda Enemy_State,x  ;then check enemy state
      cmp #$05           ;if not set to unique state for spiny's egg, go ahead
      bne ContVMove      ;and use, otherwise set different movement amount, continue on

MoveFallingPlatform:
           ldy #$20       ;set movement amount
ContVMove: jmp SetHiMax   ;jump to skip the rest of this

;--------------------------------

MoveRedPTroopaDown:
      ldy #$00            ;set Y to move downwards
      jmp MoveRedPTroopa  ;skip to movement routine

MoveRedPTroopaUp:
      ldy #$01            ;set Y to move upwards

MoveRedPTroopa:
      inx                 ;increment X for enemy offset
      lda #$03
      sta $00             ;set downward movement amount here
      lda #$06
      sta $01             ;set upward movement amount here
      lda #$02
      sta $02             ;set maximum speed here
      tya                 ;set movement direction in A, and
      jmp RedPTroopaGrav  ;jump to move this thing

;--------------------------------

MoveDropPlatform:
      ldy #$7f      ;set movement amount for drop platform
      bne SetMdMax  ;skip ahead of other value set here

MoveEnemySlowVert:
          ldy #$0f         ;set movement amount for bowser/other objects
SetMdMax: lda #$02         ;set maximum speed in A
          bne SetXMoveAmt  ;unconditional branch

;--------------------------------

MoveJ_EnemyVertically:
             ldy #$1c                ;set movement amount for podoboo/other objects
SetHiMax:    lda #$03                ;set maximum speed in A
SetXMoveAmt: sty $00                 ;set movement amount here
             inx                     ;increment X for enemy offset
             jsr ImposeGravitySprObj ;do a sub to move enemy object downwards
             ldx ObjectOffset        ;get enemy object buffer offset and leave
             rts

;--------------------------------

MaxSpdBlockData:
      .db $06, $08

ResidualGravityCode:
      ldy #$00       ;this part appears to be residual,
      .db $2c        ;no code branches or jumps to it...

ImposeGravityBlock:
      ldy #$01       ;set offset for maximum speed
      lda #$50       ;set movement amount here
      sta $00
      lda MaxSpdBlockData,y    ;get maximum speed

ImposeGravitySprObj:
      sta $02            ;set maximum speed here
      lda #$00           ;set value to move downwards
      jmp ImposeGravity  ;jump to the code that actually moves it

;--------------------------------

MovePlatformDown:
      lda #$00    ;save value to stack (if branching here, execute next
      .db $2c     ;part as BIT instruction)

MovePlatformUp:
           lda #$01        ;save value to stack
           pha
           ldy Enemy_ID,x  ;get enemy object identifier
           inx             ;increment offset for enemy object
           lda #$05        ;load default value here
           cpy #$29        ;residual comparison, object #29 never executes
           bne SetDplSpd   ;this code, thus unconditional branch here
           lda #$09        ;residual code
SetDplSpd: sta $00         ;save downward movement amount here
           lda #$0a        ;save upward movement amount here
           sta $01
           lda #$03        ;save maximum vertical speed here
           sta $02
           pla             ;get value from stack
           tay             ;use as Y, then move onto code shared by red koopa

RedPTroopaGrav:
      jsr ImposeGravity  ;do a sub to move object gradually
      ldx ObjectOffset   ;get enemy object offset and leave
      rts

;-------------------------------------------------------------------------------------
;$00 - used for downward force
;$01 - used for upward force
;$07 - used as adder for vertical position

ImposeGravity:
         pha                          ;push value to stack
         lda SprObject_YMF_Dummy,x
         clc                          ;add value in movement force to contents of dummy variable
         adc SprObject_Y_MoveForce,x
         sta SprObject_YMF_Dummy,x
         ldy #$00                     ;set Y to zero by default
         lda SprObject_Y_Speed,x      ;get current vertical speed
         bpl AlterYP                  ;if currently moving downwards, do not decrement Y
         dey                          ;otherwise decrement Y
AlterYP: sty $07                      ;store Y here
         adc SprObject_Y_Position,x   ;add vertical position to vertical speed plus carry
         sta SprObject_Y_Position,x   ;store as new vertical position
         lda SprObject_Y_HighPos,x
         adc $07                      ;add carry plus contents of $07 to vertical high byte
         sta SprObject_Y_HighPos,x    ;store as new vertical high byte
         lda SprObject_Y_MoveForce,x
         clc
         adc $00                      ;add downward movement amount to contents of $0433
         sta SprObject_Y_MoveForce,x
         lda SprObject_Y_Speed,x      ;add carry to vertical speed and store
         adc #$00
         sta SprObject_Y_Speed,x
         cmp $02                      ;compare to maximum speed
         bmi ChkUpM                   ;if less than preset value, skip this part
         lda SprObject_Y_MoveForce,x
         cmp #$80                     ;if less positively than preset maximum, skip this part
         bcc ChkUpM
         lda $02
         sta SprObject_Y_Speed,x      ;keep vertical speed within maximum value
         lda #$00
         sta SprObject_Y_MoveForce,x  ;clear fractional
ChkUpM:  pla                          ;get value from stack
         beq ExVMove                  ;if set to zero, branch to leave
         lda $02
         eor #%11111111               ;otherwise get two's compliment of maximum speed
         tay
         iny
         sty $07                      ;store two's compliment here
         lda SprObject_Y_MoveForce,x
         sec                          ;subtract upward movement amount from contents
         sbc $01                      ;of movement force, note that $01 is twice as large as $00,
         sta SprObject_Y_MoveForce,x  ;thus it effectively undoes add we did earlier
         lda SprObject_Y_Speed,x
         sbc #$00                     ;subtract borrow from vertical speed and store
         sta SprObject_Y_Speed,x
         cmp $07                      ;compare vertical speed to two's compliment
         bpl ExVMove                  ;if less negatively than preset maximum, skip this part
         lda SprObject_Y_MoveForce,x
         cmp #$80                     ;check if fractional part is above certain amount,
         bcs ExVMove                  ;and if so, branch to leave
         lda $07
         sta SprObject_Y_Speed,x      ;keep vertical speed within maximum value
         lda #$ff
         sta SprObject_Y_MoveForce,x  ;clear fractional
ExVMove: rts                          ;leave!

;-------------------------------------------------------------------------------------

EnemiesAndLoopsCore:
            lda Enemy_Flag,x         ;check data here for MSB set
            pha                      ;save in stack
            asl
            bcs ChkBowserF           ;if MSB set in enemy flag, branch ahead of jumps
            pla                      ;get from stack
            beq ChkAreaTsk           ;if data zero, branch
            jmp RunEnemyObjectsCore  ;otherwise, jump to run enemy subroutines
ChkAreaTsk: lda AreaParserTaskNum    ;check number of tasks to perform
            and #$07
            cmp #$07                 ;if at a specific task, jump and leave
            beq ExitELCore
            jmp ProcLoopCommand      ;otherwise, jump to process loop command/load enemies
ChkBowserF: pla                      ;get data from stack
            and #%00001111           ;mask out high nybble
            tay
            lda Enemy_Flag,y         ;use as pointer and load same place with different offset
            bne ExitELCore
            sta Enemy_Flag,x         ;if second enemy flag not set, also clear first one
ExitELCore: rts

;--------------------------------

;loop command data
LoopCmdWorldNumber:
      .db $03, $03, $06, $06, $06, $06, $06, $06, $07, $07, $07

LoopCmdPageNumber:
      .db $05, $09, $04, $05, $06, $08, $09, $0a, $06, $0b, $10

LoopCmdYPosition:
      .db $40, $b0, $b0, $80, $40, $40, $80, $40, $f0, $f0, $f0

ExecGameLoopback:
      lda Player_PageLoc        ;send player back four pages
      sec
      sbc #$04
      sta Player_PageLoc
      lda CurrentPageLoc        ;send current page back four pages
      sec
      sbc #$04
      sta CurrentPageLoc
      lda ScreenLeft_PageLoc    ;subtract four from page location
      sec                       ;of screen's left border
      sbc #$04
      sta ScreenLeft_PageLoc
      lda ScreenRight_PageLoc   ;do the same for the page location
      sec                       ;of screen's right border
      sbc #$04
      sta ScreenRight_PageLoc
      lda AreaObjectPageLoc     ;subtract four from page control
      sec                       ;for area objects
      sbc #$04
      sta AreaObjectPageLoc
      lda #$00                  ;initialize page select for both
      sta EnemyObjectPageSel    ;area and enemy objects
      sta AreaObjectPageSel
      sta EnemyDataOffset       ;initialize enemy object data offset
      sta EnemyObjectPageLoc    ;and enemy object page control
      lda AreaDataOfsLoopback,y ;adjust area object offset based on
      sta AreaDataOffset        ;which loop command we encountered
      rts

ProcLoopCommand:
          lda LoopCommand           ;check if loop command was found
          beq ChkEnemyFrenzy
          lda CurrentColumnPos      ;check to see if we're still on the first page
          bne ChkEnemyFrenzy        ;if not, do not loop yet
          ldy #$0b                  ;start at the end of each set of loop data
FindLoop: dey
          bmi ChkEnemyFrenzy        ;if all data is checked and not match, do not loop
          lda WorldNumber           ;check to see if one of the world numbers
          cmp LoopCmdWorldNumber,y  ;matches our current world number
          bne FindLoop
          lda CurrentPageLoc        ;check to see if one of the page numbers
          cmp LoopCmdPageNumber,y   ;matches the page we're currently on
          bne FindLoop
          lda Player_Y_Position     ;check to see if the player is at the correct position
          cmp LoopCmdYPosition,y    ;if not, branch to check for world 7
          bne WrongChk
          lda Player_State          ;check to see if the player is
          cmp #$00                  ;on solid ground (i.e. not jumping or falling)
          bne WrongChk              ;if not, player fails to pass loop, and loopback
          lda WorldNumber           ;are we in world 7? (check performed on correct
          cmp #World7               ;vertical position and on solid ground)
          bne InitMLp               ;if not, initialize flags used there, otherwise
          inc MultiLoopCorrectCntr  ;increment counter for correct progression
IncMLoop: inc MultiLoopPassCntr     ;increment master multi-part counter
          lda MultiLoopPassCntr     ;have we done all three parts?
          cmp #$03
          bne InitLCmd              ;if not, skip this part
          lda MultiLoopCorrectCntr  ;if so, have we done them all correctly?
          cmp #$03
          beq InitMLp               ;if so, branch past unnecessary check here
          bne DoLpBack              ;unconditional branch if previous branch fails
WrongChk: lda WorldNumber           ;are we in world 7? (check performed on
          cmp #World7               ;incorrect vertical position or not on solid ground)
          beq IncMLoop
DoLpBack: jsr ExecGameLoopback      ;if player is not in right place, loop back
          jsr KillAllEnemies
InitMLp:  lda #$00                  ;initialize counters used for multi-part loop commands
          sta MultiLoopPassCntr
          sta MultiLoopCorrectCntr
InitLCmd: lda #$00                  ;initialize loop command flag
          sta LoopCommand

;--------------------------------

ChkEnemyFrenzy:
      lda EnemyFrenzyQueue  ;check for enemy object in frenzy queue
      beq ProcessEnemyData  ;if not, skip this part
      sta Enemy_ID,x        ;store as enemy object identifier here
      lda #$01
      sta Enemy_Flag,x      ;activate enemy object flag
      lda #$00
      sta Enemy_State,x     ;initialize state and frenzy queue
      sta EnemyFrenzyQueue
      jmp InitEnemyObject   ;and then jump to deal with this enemy

;--------------------------------
;$06 - used to hold page location of extended right boundary
;$07 - used to hold high nybble of position of extended right boundary

ProcessEnemyData:
        ldy EnemyDataOffset      ;get offset of enemy object data
        lda (EnemyData),y        ;load first byte
        cmp #$ff                 ;check for EOD terminator
        bne CheckEndofBuffer
        jmp CheckFrenzyBuffer    ;if found, jump to check frenzy buffer, otherwise

CheckEndofBuffer:
        and #%00001111           ;check for special row $0e
        cmp #$0e
        beq CheckRightBounds     ;if found, branch, otherwise
        cpx #$05                 ;check for end of buffer
        bcc CheckRightBounds     ;if not at end of buffer, branch
        iny
        lda (EnemyData),y        ;check for specific value here
        and #%00111111           ;not sure what this was intended for, exactly
        cmp #$2e                 ;this part is quite possibly residual code
        beq CheckRightBounds     ;but it has the effect of keeping enemies out of
        rts                      ;the sixth slot

CheckRightBounds:
        lda ScreenRight_X_Pos    ;add 48 to pixel coordinate of right boundary
        clc
        adc #$30
        and #%11110000           ;store high nybble
        sta $07
        lda ScreenRight_PageLoc  ;add carry to page location of right boundary
        adc #$00
        sta $06                  ;store page location + carry
        ldy EnemyDataOffset
        iny
        lda (EnemyData),y        ;if MSB of enemy object is clear, branch to check for row $0f
        asl
        bcc CheckPageCtrlRow
        lda EnemyObjectPageSel   ;if page select already set, do not set again
        bne CheckPageCtrlRow
        inc EnemyObjectPageSel   ;otherwise, if MSB is set, set page select
        inc EnemyObjectPageLoc   ;and increment page control

CheckPageCtrlRow:
        dey
        lda (EnemyData),y        ;reread first byte
        and #$0f
        cmp #$0f                 ;check for special row $0f
        bne PositionEnemyObj     ;if not found, branch to position enemy object
        lda EnemyObjectPageSel   ;if page select set,
        bne PositionEnemyObj     ;branch without reading second byte
        iny
        lda (EnemyData),y        ;otherwise, get second byte, mask out 2 MSB
        and #%00111111
        sta EnemyObjectPageLoc   ;store as page control for enemy object data
        inc EnemyDataOffset      ;increment enemy object data offset 2 bytes
        inc EnemyDataOffset
        inc EnemyObjectPageSel   ;set page select for enemy object data and
        jmp ProcLoopCommand      ;jump back to process loop commands again

PositionEnemyObj:
        lda EnemyObjectPageLoc   ;store page control as page location
        sta Enemy_PageLoc,x      ;for enemy object
        lda (EnemyData),y        ;get first byte of enemy object
        and #%11110000
        sta Enemy_X_Position,x   ;store column position
        cmp ScreenRight_X_Pos    ;check column position against right boundary
        lda Enemy_PageLoc,x      ;without subtracting, then subtract borrow
        sbc ScreenRight_PageLoc  ;from page location
        bcs CheckRightExtBounds  ;if enemy object beyond or at boundary, branch
        lda (EnemyData),y
        and #%00001111           ;check for special row $0e
        cmp #$0e                 ;if found, jump elsewhere
        beq ParseRow0e
        jmp CheckThreeBytes      ;if not found, unconditional jump

CheckRightExtBounds:
        lda $07                  ;check right boundary + 48 against
        cmp Enemy_X_Position,x   ;column position without subtracting,
        lda $06                  ;then subtract borrow from page control temp
        sbc Enemy_PageLoc,x      ;plus carry
        bcc CheckFrenzyBuffer    ;if enemy object beyond extended boundary, branch
        lda #$01                 ;store value in vertical high byte
        sta Enemy_Y_HighPos,x
        lda (EnemyData),y        ;get first byte again
        asl                      ;multiply by four to get the vertical
        asl                      ;coordinate
        asl
        asl
        sta Enemy_Y_Position,x
        cmp #$e0                 ;do one last check for special row $0e
        beq ParseRow0e           ;(necessary if branched to $c1cb)
        iny
        lda (EnemyData),y        ;get second byte of object
        and #%01000000           ;check to see if hard mode bit is set
        beq CheckForEnemyGroup   ;if not, branch to check for group enemy objects
        lda SecondaryHardMode    ;if set, check to see if secondary hard mode flag
        beq Inc2B                ;is on, and if not, branch to skip this object completely

CheckForEnemyGroup:
        lda (EnemyData),y      ;get second byte and mask out 2 MSB
        and #%00111111
        cmp #$37               ;check for value below $37
        bcc BuzzyBeetleMutate
        cmp #$3f               ;if $37 or greater, check for value
        bcc DoGroup            ;below $3f, branch if below $3f

BuzzyBeetleMutate:
        cmp #Goomba          ;if below $37, check for goomba
        bne StrID            ;value ($3f or more always fails)
        ldy PrimaryHardMode  ;check if primary hard mode flag is set
        beq StrID            ;and if so, change goomba to buzzy beetle
        lda #BuzzyBeetle
StrID:  sta Enemy_ID,x       ;store enemy object number into buffer
        lda #$01
        sta Enemy_Flag,x     ;set flag for enemy in buffer
        jsr InitEnemyObject
        lda Enemy_Flag,x     ;check to see if flag is set
        bne Inc2B            ;if not, leave, otherwise branch
        rts

CheckFrenzyBuffer:
        lda EnemyFrenzyBuffer    ;if enemy object stored in frenzy buffer
        bne StrFre               ;then branch ahead to store in enemy object buffer
        lda VineFlagOffset       ;otherwise check vine flag offset
        cmp #$01
        bne ExEPar               ;if other value <> 1, leave
        lda #VineObject          ;otherwise put vine in enemy identifier
StrFre: sta Enemy_ID,x           ;store contents of frenzy buffer into enemy identifier value

InitEnemyObject:
        lda #$00                 ;initialize enemy state
        sta Enemy_State,x
        jsr CheckpointEnemyID    ;jump ahead to run jump engine and subroutines
ExEPar: rts                      ;then leave

DoGroup:
        jmp HandleGroupEnemies   ;handle enemy group objects

ParseRow0e:
        iny                      ;increment Y to load third byte of object
        iny
        lda (EnemyData),y
        lsr                      ;move 3 MSB to the bottom, effectively
        lsr                      ;making %xxx00000 into %00000xxx
        lsr
        lsr
        lsr
        cmp WorldNumber          ;is it the same world number as we're on?
        bne NotUse               ;if not, do not use (this allows multiple uses
        dey                      ;of the same area, like the underground bonus areas)
        lda (EnemyData),y        ;otherwise, get second byte and use as offset
        sta AreaPointer          ;to addresses for level and enemy object data
        iny
        lda (EnemyData),y        ;get third byte again, and this time mask out
        and #%00011111           ;the 3 MSB from before, save as page number to be
        sta EntrancePage         ;used upon entry to area, if area is entered
NotUse: jmp Inc3B

CheckThreeBytes:
        ldy EnemyDataOffset      ;load current offset for enemy object data
        lda (EnemyData),y        ;get first byte
        and #%00001111           ;check for special row $0e
        cmp #$0e
        bne Inc2B
Inc3B:  inc EnemyDataOffset      ;if row = $0e, increment three bytes
Inc2B:  inc EnemyDataOffset      ;otherwise increment two bytes
        inc EnemyDataOffset
        lda #$00                 ;init page select for enemy objects
        sta EnemyObjectPageSel
        ldx ObjectOffset         ;reload current offset in enemy buffers
        rts                      ;and leave

CheckpointEnemyID:
        lda Enemy_ID,x
        cmp #$15                     ;check enemy object identifier for $15 or greater
        bcs InitEnemyRoutines        ;and branch straight to the jump engine if found
        tay                          ;save identifier in Y register for now
        lda Enemy_Y_Position,x
        adc #$08                     ;add eight pixels to what will eventually be the
        sta Enemy_Y_Position,x       ;enemy object's vertical coordinate ($00-$14 only)
        lda #$01
        sta EnemyOffscrBitsMasked,x  ;set offscreen masked bit
        tya                          ;get identifier back and use as offset for jump engine

InitEnemyRoutines:
        jsr JumpEngine

;jump engine table for newly loaded enemy objects

      .dw InitNormalEnemy  ;for objects $00-$0f
      .dw InitNormalEnemy
      .dw InitNormalEnemy
      .dw InitRedKoopa
      .dw NoInitCode
      .dw InitHammerBro
      .dw InitGoomba
      .dw InitBloober
      .dw InitBulletBill
      .dw NoInitCode
      .dw InitCheepCheep
      .dw InitCheepCheep
      .dw InitPodoboo
      .dw InitPiranhaPlant
      .dw InitJumpGPTroopa
      .dw InitRedPTroopa

      .dw InitHorizFlySwimEnemy  ;for objects $10-$1f
      .dw InitLakitu
      .dw InitEnemyFrenzy
      .dw NoInitCode
      .dw InitEnemyFrenzy
      .dw InitEnemyFrenzy
      .dw InitEnemyFrenzy
      .dw InitEnemyFrenzy
      .dw EndFrenzy
      .dw NoInitCode
      .dw NoInitCode
      .dw InitShortFirebar
      .dw InitShortFirebar
      .dw InitShortFirebar
      .dw InitShortFirebar
      .dw InitLongFirebar

      .dw NoInitCode ;for objects $20-$2f
      .dw NoInitCode
      .dw NoInitCode
      .dw NoInitCode
      .dw InitBalPlatform
      .dw InitVertPlatform
      .dw LargeLiftUp
      .dw LargeLiftDown
      .dw InitHoriPlatform
      .dw InitDropPlatform
      .dw InitHoriPlatform
      .dw PlatLiftUp
      .dw PlatLiftDown
      .dw InitBowser
      .dw PwrUpJmp   ;possibly dummy value
      .dw Setup_Vine

      .dw NoInitCode ;for objects $30-$36
      .dw NoInitCode
      .dw NoInitCode
      .dw NoInitCode
      .dw NoInitCode
      .dw InitRetainerObj
      .dw EndOfEnemyInitCode

;-------------------------------------------------------------------------------------

NoInitCode:
      rts               ;this executed when enemy object has no init code

;--------------------------------

InitGoomba:
      jsr InitNormalEnemy  ;set appropriate horizontal speed
      jmp SmallBBox        ;set $09 as bounding box control, set other values

;--------------------------------

InitPodoboo:
      lda #$02                  ;set enemy position to below
      sta Enemy_Y_HighPos,x     ;the bottom of the screen
      sta Enemy_Y_Position,x
      lsr
      sta EnemyIntervalTimer,x  ;set timer for enemy
      lsr
      sta Enemy_State,x         ;initialize enemy state, then jump to use
      jmp SmallBBox             ;$09 as bounding box size and set other things

;--------------------------------

InitRetainerObj:
      lda #$b8                ;set fixed vertical position for
      sta Enemy_Y_Position,x  ;princess/mushroom retainer object
      rts

;--------------------------------

NormalXSpdData:
      .db $f8, $f4

InitNormalEnemy:
         ldy #$01              ;load offset of 1 by default
         lda PrimaryHardMode   ;check for primary hard mode flag set
         bne GetESpd
         dey                   ;if not set, decrement offset
GetESpd: lda NormalXSpdData,y  ;get appropriate horizontal speed
SetESpd: sta Enemy_X_Speed,x   ;store as speed for enemy object
         jmp TallBBox          ;branch to set bounding box control and other data

;--------------------------------

InitRedKoopa:
      jsr InitNormalEnemy   ;load appropriate horizontal speed
      lda #$01              ;set enemy state for red koopa troopa $03
      sta Enemy_State,x
      rts

;--------------------------------

HBroWalkingTimerData:
      .db $80, $50

InitHammerBro:
      lda #$00                    ;init horizontal speed and timer used by hammer bro
      sta HammerThrowingTimer,x   ;apparently to time hammer throwing
      sta Enemy_X_Speed,x
      ldy SecondaryHardMode       ;get secondary hard mode flag
      lda HBroWalkingTimerData,y
      sta EnemyIntervalTimer,x    ;set value as delay for hammer bro to walk left
      lda #$0b                    ;set specific value for bounding box size control
      jmp SetBBox

;--------------------------------

InitHorizFlySwimEnemy:
      lda #$00        ;initialize horizontal speed
      jmp SetESpd

;--------------------------------

InitBloober:
           lda #$00               ;initialize horizontal speed
           sta BlooperMoveSpeed,x
SmallBBox: lda #$09               ;set specific bounding box size control
           bne SetBBox            ;unconditional branch

;--------------------------------

InitRedPTroopa:
          ldy #$30                    ;load central position adder for 48 pixels down
          lda Enemy_Y_Position,x      ;set vertical coordinate into location to
          sta RedPTroopaOrigXPos,x    ;be used as original vertical coordinate
          bpl GetCent                 ;if vertical coordinate < $80
          ldy #$e0                    ;if => $80, load position adder for 32 pixels up
GetCent:  tya                         ;send central position adder to A
          adc Enemy_Y_Position,x      ;add to current vertical coordinate
          sta RedPTroopaCenterYPos,x  ;store as central vertical coordinate
TallBBox: lda #$03                    ;set specific bounding box size control
SetBBox:  sta Enemy_BoundBoxCtrl,x    ;set bounding box control here
          lda #$02                    ;set moving direction for left
          sta Enemy_MovingDir,x
InitVStf: lda #$00                    ;initialize vertical speed
          sta Enemy_Y_Speed,x         ;and movement force
          sta Enemy_Y_MoveForce,x
          rts

;--------------------------------

InitBulletBill:
      lda #$02                  ;set moving direction for left
      sta Enemy_MovingDir,x
      lda #$09                  ;set bounding box control for $09
      sta Enemy_BoundBoxCtrl,x
      rts

;--------------------------------

InitCheepCheep:
      jsr SmallBBox              ;set vertical bounding box, speed, init others
      lda PseudoRandomBitReg,x   ;check one portion of LSFR
      and #%00010000             ;get d4 from it
      sta CheepCheepMoveMFlag,x  ;save as movement flag of some sort
      lda Enemy_Y_Position,x
      sta CheepCheepOrigYPos,x   ;save original vertical coordinate here
      rts

;--------------------------------

InitLakitu:
      lda EnemyFrenzyBuffer      ;check to see if an enemy is already in
      bne KillLakitu             ;the frenzy buffer, and branch to kill lakitu if so

SetupLakitu:
      lda #$00                   ;erase counter for lakitu's reappearance
      sta LakituReappearTimer
      jsr InitHorizFlySwimEnemy  ;set $03 as bounding box, set other attributes
      jmp TallBBox2              ;set $03 as bounding box again (not necessary) and leave

KillLakitu:
      jmp EraseEnemyObject

;--------------------------------
;$01-$03 - used to hold pseudorandom difference adjusters

PRDiffAdjustData:
      .db $26, $2c, $32, $38
      .db $20, $22, $24, $26
      .db $13, $14, $15, $16

LakituAndSpinyHandler:
          lda FrenzyEnemyTimer    ;if timer here not expired, leave
          bne ExLSHand
          cpx #$05                ;if we are on the special use slot, leave
          bcs ExLSHand
          lda #$80                ;set timer
          sta FrenzyEnemyTimer
          ldy #$04                ;start with the last enemy slot
ChkLak:   lda Enemy_ID,y          ;check all enemy slots to see
          cmp #Lakitu             ;if lakitu is on one of them
          beq CreateSpiny         ;if so, branch out of this loop
          dey                     ;otherwise check another slot
          bpl ChkLak              ;loop until all slots are checked
          inc LakituReappearTimer ;increment reappearance timer
          lda LakituReappearTimer
          cmp #$07                ;check to see if we're up to a certain value yet
          bcc ExLSHand            ;if not, leave
          ldx #$04                ;start with the last enemy slot again
ChkNoEn:  lda Enemy_Flag,x        ;check enemy buffer flag for non-active enemy slot
          beq CreateL             ;branch out of loop if found
          dex                     ;otherwise check next slot
          bpl ChkNoEn             ;branch until all slots are checked
          bmi RetEOfs             ;if no empty slots were found, branch to leave
CreateL:  lda #$00                ;initialize enemy state
          sta Enemy_State,x
          lda #Lakitu             ;create lakitu enemy object
          sta Enemy_ID,x
          jsr SetupLakitu         ;do a sub to set up lakitu
          lda #$20
          jsr PutAtRightExtent    ;finish setting up lakitu
RetEOfs:  ldx ObjectOffset        ;get enemy object buffer offset again and leave
ExLSHand: rts

;--------------------------------

CreateSpiny:
          lda Player_Y_Position      ;if player above a certain point, branch to leave
          cmp #$2c
          bcc ExLSHand
          lda Enemy_State,y          ;if lakitu is not in normal state, branch to leave
          bne ExLSHand
          lda Enemy_PageLoc,y        ;store horizontal coordinates (high and low) of lakitu
          sta Enemy_PageLoc,x        ;into the coordinates of the spiny we're going to create
          lda Enemy_X_Position,y
          sta Enemy_X_Position,x
          lda #$01                   ;put spiny within vertical screen unit
          sta Enemy_Y_HighPos,x
          lda Enemy_Y_Position,y     ;put spiny eight pixels above where lakitu is
          sec
          sbc #$08
          sta Enemy_Y_Position,x
          lda PseudoRandomBitReg,x   ;get 2 LSB of LSFR and save to Y
          and #%00000011
          tay
          ldx #$02
DifLoop:  lda PRDiffAdjustData,y     ;get three values and save them
          sta $01,x                  ;to $01-$03
          iny
          iny                        ;increment Y four bytes for each value
          iny
          iny
          dex                        ;decrement X for each one
          bpl DifLoop                ;loop until all three are written
          ldx ObjectOffset           ;get enemy object buffer offset
          jsr PlayerLakituDiff       ;move enemy, change direction, get value - difference
          ldy Player_X_Speed         ;check player's horizontal speed
          cpy #$08
          bcs SetSpSpd               ;if moving faster than a certain amount, branch elsewhere
          tay                        ;otherwise save value in A to Y for now
          lda PseudoRandomBitReg+1,x
          and #%00000011             ;get one of the LSFR parts and save the 2 LSB
          beq UsePosv                ;branch if neither bits are set
          tya
          eor #%11111111             ;otherwise get two's compliment of Y
          tay
          iny
UsePosv:  tya                        ;put value from A in Y back to A (they will be lost anyway)
SetSpSpd: jsr SmallBBox              ;set bounding box control, init attributes, lose contents of A
          ldy #$02
          sta Enemy_X_Speed,x        ;set horizontal speed to zero because previous contents
          cmp #$00                   ;of A were lost...branch here will never be taken for
          bmi SpinyRte               ;the same reason
          dey
SpinyRte: sty Enemy_MovingDir,x      ;set moving direction to the right
          lda #$fd
          sta Enemy_Y_Speed,x        ;set vertical speed to move upwards
          lda #$01
          sta Enemy_Flag,x           ;enable enemy object by setting flag
          lda #$05
          sta Enemy_State,x          ;put spiny in egg state and leave
ChpChpEx: rts

;--------------------------------

FirebarSpinSpdData:
      .db $28, $38, $28, $38, $28

FirebarSpinDirData:
      .db $00, $00, $10, $10, $00

InitLongFirebar:
      jsr DuplicateEnemyObj       ;create enemy object for long firebar

InitShortFirebar:
      lda #$00                    ;initialize low byte of spin state
      sta FirebarSpinState_Low,x
      lda Enemy_ID,x              ;subtract $1b from enemy identifier
      sec                         ;to get proper offset for firebar data
      sbc #$1b
      tay
      lda FirebarSpinSpdData,y    ;get spinning speed of firebar
      sta FirebarSpinSpeed,x
      lda FirebarSpinDirData,y    ;get spinning direction of firebar
      sta FirebarSpinDirection,x
      lda Enemy_Y_Position,x
      clc                         ;add four pixels to vertical coordinate
      adc #$04
      sta Enemy_Y_Position,x
      lda Enemy_X_Position,x
      clc                         ;add four pixels to horizontal coordinate
      adc #$04
      sta Enemy_X_Position,x
      lda Enemy_PageLoc,x
      adc #$00                    ;add carry to page location
      sta Enemy_PageLoc,x
      jmp TallBBox2               ;set bounding box control (not used) and leave

;--------------------------------
;$00-$01 - used to hold pseudorandom bits

FlyCCXPositionData:
      .db $80, $30, $40, $80
      .db $30, $50, $50, $70
      .db $20, $40, $80, $a0
      .db $70, $40, $90, $68

FlyCCXSpeedData:
      .db $0e, $05, $06, $0e
      .db $1c, $20, $10, $0c
      .db $1e, $22, $18, $14

FlyCCTimerData:
      .db $10, $60, $20, $48

InitFlyingCheepCheep:
         lda FrenzyEnemyTimer       ;if timer here not expired yet, branch to leave
         bne ChpChpEx
         jsr SmallBBox              ;jump to set bounding box size $09 and init other values
         lda PseudoRandomBitReg+1,x
         and #%00000011             ;set pseudorandom offset here
         tay
         lda FlyCCTimerData,y       ;load timer with pseudorandom offset
         sta FrenzyEnemyTimer
         ldy #$03                   ;load Y with default value
         lda SecondaryHardMode
         beq MaxCC                  ;if secondary hard mode flag not set, do not increment Y
         iny                        ;otherwise, increment Y to allow as many as four onscreen
MaxCC:   sty $00                    ;store whatever pseudorandom bits are in Y
         cpx $00                    ;compare enemy object buffer offset with Y
         bcs ChpChpEx               ;if X => Y, branch to leave
         lda PseudoRandomBitReg,x
         and #%00000011             ;get last two bits of LSFR, first part
         sta $00                    ;and store in two places
         sta $01
         lda #$fb                   ;set vertical speed for cheep-cheep
         sta Enemy_Y_Speed,x
         lda #$00                   ;load default value
         ldy Player_X_Speed         ;check player's horizontal speed
         beq GSeed                  ;if player not moving left or right, skip this part
         lda #$04
         cpy #$19                   ;if moving to the right but not very quickly,
         bcc GSeed                  ;do not change A
         asl                        ;otherwise, multiply A by 2
GSeed:   pha                        ;save to stack
         clc
         adc $00                    ;add to last two bits of LSFR we saved earlier
         sta $00                    ;save it there
         lda PseudoRandomBitReg+1,x
         and #%00000011             ;if neither of the last two bits of second LSFR set,
         beq RSeed                  ;skip this part and save contents of $00
         lda PseudoRandomBitReg+2,x
         and #%00001111             ;otherwise overwrite with lower nybble of
         sta $00                    ;third LSFR part
RSeed:   pla                        ;get value from stack we saved earlier
         clc
         adc $01                    ;add to last two bits of LSFR we saved in other place
         tay                        ;use as pseudorandom offset here
         lda FlyCCXSpeedData,y      ;get horizontal speed using pseudorandom offset
         sta Enemy_X_Speed,x
         lda #$01                   ;set to move towards the right
         sta Enemy_MovingDir,x
         lda Player_X_Speed         ;if player moving left or right, branch ahead of this part
         bne D2XPos1
         ldy $00                    ;get first LSFR or third LSFR lower nybble
         tya                        ;and check for d1 set
         and #%00000010
         beq D2XPos1                ;if d1 not set, branch
         lda Enemy_X_Speed,x
         eor #$ff                   ;if d1 set, change horizontal speed
         clc                        ;into two's compliment, thus moving in the opposite
         adc #$01                   ;direction
         sta Enemy_X_Speed,x
         inc Enemy_MovingDir,x      ;increment to move towards the left
D2XPos1: tya                        ;get first LSFR or third LSFR lower nybble again
         and #%00000010
         beq D2XPos2                ;check for d1 set again, branch again if not set
         lda Player_X_Position      ;get player's horizontal position
         clc
         adc FlyCCXPositionData,y   ;if d1 set, add value obtained from pseudorandom offset
         sta Enemy_X_Position,x     ;and save as enemy's horizontal position
         lda Player_PageLoc         ;get player's page location
         adc #$00                   ;add carry and jump past this part
         jmp FinCCSt
D2XPos2: lda Player_X_Position      ;get player's horizontal position
         sec
         sbc FlyCCXPositionData,y   ;if d1 not set, subtract value obtained from pseudorandom
         sta Enemy_X_Position,x     ;offset and save as enemy's horizontal position
         lda Player_PageLoc         ;get player's page location
         sbc #$00                   ;subtract borrow
FinCCSt: sta Enemy_PageLoc,x        ;save as enemy's page location
         lda #$01
         sta Enemy_Flag,x           ;set enemy's buffer flag
         sta Enemy_Y_HighPos,x      ;set enemy's high vertical byte
         lda #$f8
         sta Enemy_Y_Position,x     ;put enemy below the screen, and we are done
         rts

;--------------------------------

InitBowser:
      jsr DuplicateEnemyObj     ;jump to create another bowser object
      stx BowserFront_Offset    ;save offset of first here
      lda #$00
      sta BowserBodyControls    ;initialize bowser's body controls
      sta BridgeCollapseOffset  ;and bridge collapse offset
      lda Enemy_X_Position,x
      sta BowserOrigXPos        ;store original horizontal position here
      lda #$df
      sta BowserFireBreathTimer ;store something here
      sta Enemy_MovingDir,x     ;and in moving direction
      lda #$20
      sta BowserFeetCounter     ;set bowser's feet timer and in enemy timer
      sta EnemyFrameTimer,x
      lda #$05
      sta BowserHitPoints       ;give bowser 5 hit points
      lsr
      sta BowserMovementSpeed   ;set default movement speed here
      rts

;--------------------------------

DuplicateEnemyObj:
        ldy #$ff                ;start at beginning of enemy slots
FSLoop: iny                     ;increment one slot
        lda Enemy_Flag,y        ;check enemy buffer flag for empty slot
        bne FSLoop              ;if set, branch and keep checking
        sty DuplicateObj_Offset ;otherwise set offset here
        txa                     ;transfer original enemy buffer offset
        ora #%10000000          ;store with d7 set as flag in new enemy
        sta Enemy_Flag,y        ;slot as well as enemy offset
        lda Enemy_PageLoc,x
        sta Enemy_PageLoc,y     ;copy page location and horizontal coordinates
        lda Enemy_X_Position,x  ;from original enemy to new enemy
        sta Enemy_X_Position,y
        lda #$01
        sta Enemy_Flag,x        ;set flag as normal for original enemy
        sta Enemy_Y_HighPos,y   ;set high vertical byte for new enemy
        lda Enemy_Y_Position,x
        sta Enemy_Y_Position,y  ;copy vertical coordinate from original to new
FlmEx:  rts                     ;and then leave

;--------------------------------

FlameYPosData:
      .db $90, $80, $70, $90

FlameYMFAdderData:
      .db $ff, $01

InitBowserFlame:
        lda FrenzyEnemyTimer        ;if timer not expired yet, branch to leave
        bne FlmEx
        sta Enemy_Y_MoveForce,x     ;reset something here
        lda NoiseSoundQueue
        ora #Sfx_BowserFlame        ;load bowser's flame sound into queue
        sta NoiseSoundQueue
        ldy BowserFront_Offset      ;get bowser's buffer offset
        lda Enemy_ID,y              ;check for bowser
        cmp #Bowser
        beq SpawnFromMouth          ;branch if found
        jsr SetFlameTimer           ;get timer data based on flame counter
        clc
        adc #$20                    ;add 32 frames by default
        ldy SecondaryHardMode
        beq SetFrT                  ;if secondary mode flag not set, use as timer setting
        sec
        sbc #$10                    ;otherwise subtract 16 frames for secondary hard mode
SetFrT: sta FrenzyEnemyTimer        ;set timer accordingly
        lda PseudoRandomBitReg,x
        and #%00000011              ;get 2 LSB from first part of LSFR
        sta BowserFlamePRandomOfs,x ;set here
        tay                         ;use as offset
        lda FlameYPosData,y         ;load vertical position based on pseudorandom offset

PutAtRightExtent:
      sta Enemy_Y_Position,x    ;set vertical position
      lda ScreenRight_X_Pos
      clc
      adc #$20                  ;place enemy 32 pixels beyond right side of screen
      sta Enemy_X_Position,x
      lda ScreenRight_PageLoc
      adc #$00                  ;add carry
      sta Enemy_PageLoc,x
      jmp FinishFlame           ;skip this part to finish setting values

SpawnFromMouth:
       lda Enemy_X_Position,y    ;get bowser's horizontal position
       sec
       sbc #$0e                  ;subtract 14 pixels
       sta Enemy_X_Position,x    ;save as flame's horizontal position
       lda Enemy_PageLoc,y
       sta Enemy_PageLoc,x       ;copy page location from bowser to flame
       lda Enemy_Y_Position,y
       clc                       ;add 8 pixels to bowser's vertical position
       adc #$08
       sta Enemy_Y_Position,x    ;save as flame's vertical position
       lda PseudoRandomBitReg,x
       and #%00000011            ;get 2 LSB from first part of LSFR
       sta Enemy_YMF_Dummy,x     ;save here
       tay                       ;use as offset
       lda FlameYPosData,y       ;get value here using bits as offset
       ldy #$00                  ;load default offset
       cmp Enemy_Y_Position,x    ;compare value to flame's current vertical position
       bcc SetMF                 ;if less, do not increment offset
       iny                       ;otherwise increment now
SetMF: lda FlameYMFAdderData,y   ;get value here and save
       sta Enemy_Y_MoveForce,x   ;to vertical movement force
       lda #$00
       sta EnemyFrenzyBuffer     ;clear enemy frenzy buffer

FinishFlame:
      lda #$08                 ;set $08 for bounding box control
      sta Enemy_BoundBoxCtrl,x
      lda #$01                 ;set high byte of vertical and
      sta Enemy_Y_HighPos,x    ;enemy buffer flag
      sta Enemy_Flag,x
      lsr
      sta Enemy_X_MoveForce,x  ;initialize horizontal movement force, and
      sta Enemy_State,x        ;enemy state
      rts

;--------------------------------

FireworksXPosData:
      .db $00, $30, $60, $60, $00, $20

FireworksYPosData:
      .db $60, $40, $70, $40, $60, $30

InitFireworks:
          lda FrenzyEnemyTimer         ;if timer not expired yet, branch to leave
          bne ExitFWk
          lda #$20                     ;otherwise reset timer
          sta FrenzyEnemyTimer
          dec FireworksCounter         ;decrement for each explosion
          ldy #$06                     ;start at last slot
StarFChk: dey
          lda Enemy_ID,y               ;check for presence of star flag object
          cmp #StarFlagObject          ;if there isn't a star flag object,
          bne StarFChk                 ;routine goes into infinite loop = crash
          lda Enemy_X_Position,y
          sec                          ;get horizontal coordinate of star flag object, then
          sbc #$30                     ;subtract 48 pixels from it and save to
          pha                          ;the stack
          lda Enemy_PageLoc,y
          sbc #$00                     ;subtract the carry from the page location
          sta $00                      ;of the star flag object
          lda FireworksCounter         ;get fireworks counter
          clc
          adc Enemy_State,y            ;add state of star flag object (possibly not necessary)
          tay                          ;use as offset
          pla                          ;get saved horizontal coordinate of star flag - 48 pixels
          clc
          adc FireworksXPosData,y      ;add number based on offset of fireworks counter
          sta Enemy_X_Position,x       ;store as the fireworks object horizontal coordinate
          lda $00
          adc #$00                     ;add carry and store as page location for
          sta Enemy_PageLoc,x          ;the fireworks object
          lda FireworksYPosData,y      ;get vertical position using same offset
          sta Enemy_Y_Position,x       ;and store as vertical coordinate for fireworks object
          lda #$01
          sta Enemy_Y_HighPos,x        ;store in vertical high byte
          sta Enemy_Flag,x             ;and activate enemy buffer flag
          lsr
          sta ExplosionGfxCounter,x    ;initialize explosion counter
          lda #$08
          sta ExplosionTimerCounter,x  ;set explosion timing counter
ExitFWk:  rts

;--------------------------------

Bitmasks:
      .db %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

Enemy17YPosData:
      .db $40, $30, $90, $50, $20, $60, $a0, $70

SwimCC_IDData:
      .db $0a, $0b

BulletBillCheepCheep:
         lda FrenzyEnemyTimer      ;if timer not expired yet, branch to leave
         bne ExF17
         lda AreaType              ;are we in a water-type level?
         bne DoBulletBills         ;if not, branch elsewhere
         cpx #$03                  ;are we past third enemy slot?
         bcs ExF17                 ;if so, branch to leave
         ldy #$00                  ;load default offset
         lda PseudoRandomBitReg,x
         cmp #$aa                  ;check first part of LSFR against preset value
         bcc ChkW2                 ;if less than preset, do not increment offset
         iny                       ;otherwise increment
ChkW2:   lda WorldNumber           ;check world number
         cmp #World2
         beq Get17ID               ;if we're on world 2, do not increment offset
         iny                       ;otherwise increment
Get17ID: tya
         and #%00000001            ;mask out all but last bit of offset
         tay
         lda SwimCC_IDData,y       ;load identifier for cheep-cheeps
Set17ID: sta Enemy_ID,x            ;store whatever's in A as enemy identifier
         lda BitMFilter
         cmp #$ff                  ;if not all bits set, skip init part and compare bits
         bne GetRBit
         lda #$00                  ;initialize vertical position filter
         sta BitMFilter
GetRBit: lda PseudoRandomBitReg,x  ;get first part of LSFR
         and #%00000111            ;mask out all but 3 LSB
ChkRBit: tay                       ;use as offset
         lda Bitmasks,y            ;load bitmask
         bit BitMFilter            ;perform AND on filter without changing it
         beq AddFBit
         iny                       ;increment offset
         tya
         and #%00000111            ;mask out all but 3 LSB thus keeping it 0-7
         jmp ChkRBit               ;do another check
AddFBit: ora BitMFilter            ;add bit to already set bits in filter
         sta BitMFilter            ;and store
         lda Enemy17YPosData,y     ;load vertical position using offset
         jsr PutAtRightExtent      ;set vertical position and other values
         sta Enemy_YMF_Dummy,x     ;initialize dummy variable
         lda #$20                  ;set timer
         sta FrenzyEnemyTimer
         jmp CheckpointEnemyID     ;process our new enemy object

DoBulletBills:
          ldy #$ff                   ;start at beginning of enemy slots
BB_SLoop: iny                        ;move onto the next slot
          cpy #$05                   ;branch to play sound if we've done all slots
          bcs FireBulletBill
          lda Enemy_Flag,y           ;if enemy buffer flag not set,
          beq BB_SLoop               ;loop back and check another slot
          lda Enemy_ID,y
          cmp #BulletBill_FrenzyVar  ;check enemy identifier for
          bne BB_SLoop               ;bullet bill object (frenzy variant)
ExF17:    rts                        ;if found, leave

FireBulletBill:
      lda Square2SoundQueue
      ora #Sfx_Blast            ;play fireworks/gunfire sound
      sta Square2SoundQueue
      lda #BulletBill_FrenzyVar ;load identifier for bullet bill object
      bne Set17ID               ;unconditional branch

;--------------------------------
;$00 - used to store Y position of group enemies
;$01 - used to store enemy ID
;$02 - used to store page location of right side of screen
;$03 - used to store X position of right side of screen

HandleGroupEnemies:
        ldy #$00                  ;load value for green koopa troopa
        sec
        sbc #$37                  ;subtract $37 from second byte read
        pha                       ;save result in stack for now
        cmp #$04                  ;was byte in $3b-$3e range?
        bcs SnglID                ;if so, branch
        pha                       ;save another copy to stack
        ldy #Goomba               ;load value for goomba enemy
        lda PrimaryHardMode       ;if primary hard mode flag not set,
        beq PullID                ;branch, otherwise change to value
        ldy #BuzzyBeetle          ;for buzzy beetle
PullID: pla                       ;get second copy from stack
SnglID: sty $01                   ;save enemy id here
        ldy #$b0                  ;load default y coordinate
        and #$02                  ;check to see if d1 was set
        beq SetYGp                ;if so, move y coordinate up,
        ldy #$70                  ;otherwise branch and use default
SetYGp: sty $00                   ;save y coordinate here
        lda ScreenRight_PageLoc   ;get page number of right edge of screen
        sta $02                   ;save here
        lda ScreenRight_X_Pos     ;get pixel coordinate of right edge
        sta $03                   ;save here
        ldy #$02                  ;load two enemies by default
        pla                       ;get first copy from stack
        lsr                       ;check to see if d0 was set
        bcc CntGrp                ;if not, use default value
        iny                       ;otherwise increment to three enemies
CntGrp: sty NumberofGroupEnemies  ;save number of enemies here
GrLoop: ldx #$ff                  ;start at beginning of enemy buffers
GSltLp: inx                       ;increment and branch if past
        cpx #$05                  ;end of buffers
        bcs NextED
        lda Enemy_Flag,x          ;check to see if enemy is already
        bne GSltLp                ;stored in buffer, and branch if so
        lda $01
        sta Enemy_ID,x            ;store enemy object identifier
        lda $02
        sta Enemy_PageLoc,x       ;store page location for enemy object
        lda $03
        sta Enemy_X_Position,x    ;store x coordinate for enemy object
        clc
        adc #$18                  ;add 24 pixels for next enemy
        sta $03
        lda $02                   ;add carry to page location for
        adc #$00                  ;next enemy
        sta $02
        lda $00                   ;store y coordinate for enemy object
        sta Enemy_Y_Position,x
        lda #$01                  ;activate flag for buffer, and
        sta Enemy_Y_HighPos,x     ;put enemy within the screen vertically
        sta Enemy_Flag,x
        jsr CheckpointEnemyID     ;process each enemy object separately
        dec NumberofGroupEnemies  ;do this until we run out of enemy objects
        bne GrLoop
NextED: jmp Inc2B                 ;jump to increment data offset and leave

;--------------------------------

InitPiranhaPlant:
      lda #$01                     ;set initial speed
      sta PiranhaPlant_Y_Speed,x
      lsr
      sta Enemy_State,x            ;initialize enemy state and what would normally
      sta PiranhaPlant_MoveFlag,x  ;be used as vertical speed, but not in this case
      lda Enemy_Y_Position,x
      sta PiranhaPlantDownYPos,x   ;save original vertical coordinate here
      sec
      sbc #$18
      sta PiranhaPlantUpYPos,x     ;save original vertical coordinate - 24 pixels here
      lda #$09
      jmp SetBBox2                 ;set specific value for bounding box control

;--------------------------------

InitEnemyFrenzy:
      lda Enemy_ID,x        ;load enemy identifier
      sta EnemyFrenzyBuffer ;save in enemy frenzy buffer
      sec
      sbc #$12              ;subtract 12 and use as offset for jump engine
      jsr JumpEngine

;frenzy object jump table
      .dw LakituAndSpinyHandler
      .dw NoFrenzyCode
      .dw InitFlyingCheepCheep
      .dw InitBowserFlame
      .dw InitFireworks
      .dw BulletBillCheepCheep

;--------------------------------

NoFrenzyCode:
      rts

;--------------------------------

EndFrenzy:
           ldy #$05               ;start at last slot
LakituChk: lda Enemy_ID,y         ;check enemy identifiers
           cmp #Lakitu            ;for lakitu
           bne NextFSlot
           lda #$01               ;if found, set state
           sta Enemy_State,y
NextFSlot: dey                    ;move onto the next slot
           bpl LakituChk          ;do this until all slots are checked
           lda #$00
           sta EnemyFrenzyBuffer  ;empty enemy frenzy buffer
           sta Enemy_Flag,x       ;disable enemy buffer flag for this object
           rts

;--------------------------------

InitJumpGPTroopa:
           lda #$02                  ;set for movement to the left
           sta Enemy_MovingDir,x
           lda #$f8                  ;set horizontal speed
           sta Enemy_X_Speed,x
TallBBox2: lda #$03                  ;set specific value for bounding box control
SetBBox2:  sta Enemy_BoundBoxCtrl,x  ;set bounding box control then leave
           rts

;--------------------------------

InitBalPlatform:
        dec Enemy_Y_Position,x    ;raise vertical position by two pixels
        dec Enemy_Y_Position,x
        ldy SecondaryHardMode     ;if secondary hard mode flag not set,
        bne AlignP                ;branch ahead
        ldy #$02                  ;otherwise set value here
        jsr PosPlatform           ;do a sub to add or subtract pixels
AlignP: ldy #$ff                  ;set default value here for now
        lda BalPlatformAlignment  ;get current balance platform alignment
        sta Enemy_State,x         ;set platform alignment to object state here
        bpl SetBPA                ;if old alignment $ff, put $ff as alignment for negative
        txa                       ;if old contents already $ff, put
        tay                       ;object offset as alignment to make next positive
SetBPA: sty BalPlatformAlignment  ;store whatever value's in Y here
        lda #$00
        sta Enemy_MovingDir,x     ;init moving direction
        tay                       ;init Y
        jsr PosPlatform           ;do a sub to add 8 pixels, then run shared code here

;--------------------------------

InitDropPlatform:
      lda #$ff
      sta PlatformCollisionFlag,x  ;set some value here
      jmp CommonPlatCode           ;then jump ahead to execute more code

;--------------------------------

InitHoriPlatform:
      lda #$00
      sta XMoveSecondaryCounter,x  ;init one of the moving counters
      jmp CommonPlatCode           ;jump ahead to execute more code

;--------------------------------

InitVertPlatform:
       ldy #$40                    ;set default value here
       lda Enemy_Y_Position,x      ;check vertical position
       bpl SetYO                   ;if above a certain point, skip this part
       eor #$ff
       clc                         ;otherwise get two's compliment
       adc #$01
       ldy #$c0                    ;get alternate value to add to vertical position
SetYO: sta YPlatformTopYPos,x      ;save as top vertical position
       tya
       clc                         ;load value from earlier, add number of pixels
       adc Enemy_Y_Position,x      ;to vertical position
       sta YPlatformCenterYPos,x   ;save result as central vertical position

;--------------------------------

CommonPlatCode:
        jsr InitVStf              ;do a sub to init certain other values
SPBBox: lda #$05                  ;set default bounding box size control
        ldy AreaType
        cpy #$03                  ;check for castle-type level
        beq CasPBB                ;use default value if found
        ldy SecondaryHardMode     ;otherwise check for secondary hard mode flag
        bne CasPBB                ;if set, use default value
        lda #$06                  ;use alternate value if not castle or secondary not set
CasPBB: sta Enemy_BoundBoxCtrl,x  ;set bounding box size control here and leave
        rts

;--------------------------------

LargeLiftUp:
      jsr PlatLiftUp       ;execute code for platforms going up
      jmp LargeLiftBBox    ;overwrite bounding box for large platforms

LargeLiftDown:
      jsr PlatLiftDown     ;execute code for platforms going down

LargeLiftBBox:
      jmp SPBBox           ;jump to overwrite bounding box size control

;--------------------------------

PlatLiftUp:
      lda #$10                 ;set movement amount here
      sta Enemy_Y_MoveForce,x
      lda #$ff                 ;set moving speed for platforms going up
      sta Enemy_Y_Speed,x
      jmp CommonSmallLift      ;skip ahead to part we should be executing

;--------------------------------

PlatLiftDown:
      lda #$f0                 ;set movement amount here
      sta Enemy_Y_MoveForce,x
      lda #$00                 ;set moving speed for platforms going down
      sta Enemy_Y_Speed,x

;--------------------------------

CommonSmallLift:
      ldy #$01
      jsr PosPlatform           ;do a sub to add 12 pixels due to preset value
      lda #$04
      sta Enemy_BoundBoxCtrl,x  ;set bounding box control for small platforms
      rts

;--------------------------------

PlatPosDataLow:
      .db $08,$0c,$f8

PlatPosDataHigh:
      .db $00,$00,$ff

PosPlatform:
      lda Enemy_X_Position,x  ;get horizontal coordinate
      clc
      adc PlatPosDataLow,y    ;add or subtract pixels depending on offset
      sta Enemy_X_Position,x  ;store as new horizontal coordinate
      lda Enemy_PageLoc,x
      adc PlatPosDataHigh,y   ;add or subtract page location depending on offset
      sta Enemy_PageLoc,x     ;store as new page location
      rts                     ;and go back

;--------------------------------

EndOfEnemyInitCode:
      rts

;-------------------------------------------------------------------------------------

RunEnemyObjectsCore:
       ldx ObjectOffset  ;get offset for enemy object buffer
       lda #$00          ;load value 0 for jump engine by default
       ldy Enemy_ID,x
       cpy #$15          ;if enemy object < $15, use default value
       bcc JmpEO
       tya               ;otherwise subtract $14 from the value and use
       sbc #$14          ;as value for jump engine
JmpEO: jsr JumpEngine

      .dw RunNormalEnemies  ;for objects $00-$14

      .dw RunBowserFlame    ;for objects $15-$1f
      .dw RunFireworks
      .dw NoRunCode
      .dw NoRunCode
      .dw NoRunCode
      .dw NoRunCode
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw RunFirebarObj

      .dw RunFirebarObj     ;for objects $20-$2f
      .dw RunFirebarObj
      .dw RunFirebarObj
      .dw NoRunCode
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunLargePlatform
      .dw RunSmallPlatform
      .dw RunSmallPlatform
      .dw RunBowser
      .dw PowerUpObjHandler
      .dw VineObjectHandler

      .dw NoRunCode         ;for objects $30-$35
      .dw RunStarFlagObj
      .dw JumpspringHandler
      .dw NoRunCode
      .dw WarpZoneObject
      .dw RunRetainerObj

;--------------------------------

NoRunCode:
      rts

;--------------------------------

RunRetainerObj:
      jsr GetEnemyOffscreenBits
      jsr RelativeEnemyPosition
      jmp EnemyGfxHandler

;--------------------------------

RunNormalEnemies:
          lda #$00                  ;init sprite attributes
          sta Enemy_SprAttrib,x
          jsr GetEnemyOffscreenBits
          jsr RelativeEnemyPosition
          jsr EnemyGfxHandler
          jsr GetEnemyBoundBox
          jsr EnemyToBGCollisionDet
          jsr EnemiesCollision
          jsr PlayerEnemyCollision
          ldy TimerControl          ;if master timer control set, skip to last routine
          bne SkipMove
          jsr EnemyMovementSubs
SkipMove: jmp OffscreenBoundsCheck

EnemyMovementSubs:
      lda Enemy_ID,x
      jsr JumpEngine

      .dw MoveNormalEnemy      ;only objects $00-$14 use this table
      .dw MoveNormalEnemy
      .dw MoveNormalEnemy
      .dw MoveNormalEnemy
      .dw MoveNormalEnemy
      .dw ProcHammerBro
      .dw MoveNormalEnemy
      .dw MoveBloober
      .dw MoveBulletBill
      .dw NoMoveCode
      .dw MoveSwimmingCheepCheep
      .dw MoveSwimmingCheepCheep
      .dw MovePodoboo
      .dw MovePiranhaPlant
      .dw MoveJumpingEnemy
      .dw ProcMoveRedPTroopa
      .dw MoveFlyGreenPTroopa
      .dw MoveLakitu
      .dw MoveNormalEnemy
      .dw NoMoveCode   ;dummy
      .dw MoveFlyingCheepCheep

;--------------------------------

NoMoveCode:
      rts

;--------------------------------

RunBowserFlame:
      jsr ProcBowserFlame
      jsr GetEnemyOffscreenBits
      jsr RelativeEnemyPosition
      jsr GetEnemyBoundBox
      jsr PlayerEnemyCollision
      jmp OffscreenBoundsCheck

;--------------------------------

RunFirebarObj:
      jsr ProcFirebar
      jmp OffscreenBoundsCheck

;--------------------------------

RunSmallPlatform:
      jsr GetEnemyOffscreenBits
      jsr RelativeEnemyPosition
      jsr SmallPlatformBoundBox
      jsr SmallPlatformCollision
      jsr RelativeEnemyPosition
      jsr DrawSmallPlatform
      jsr MoveSmallPlatform
      jmp OffscreenBoundsCheck

;--------------------------------

RunLargePlatform:
        jsr GetEnemyOffscreenBits
        jsr RelativeEnemyPosition
        jsr LargePlatformBoundBox
        jsr LargePlatformCollision
        lda TimerControl             ;if master timer control set,
        bne SkipPT                   ;skip subroutine tree
        jsr LargePlatformSubroutines
SkipPT: jsr RelativeEnemyPosition
        jsr DrawLargePlatform
        jmp OffscreenBoundsCheck

;--------------------------------

LargePlatformSubroutines:
      lda Enemy_ID,x  ;subtract $24 to get proper offset for jump table
      sec
      sbc #$24
      jsr JumpEngine

      .dw BalancePlatform   ;table used by objects $24-$2a
      .dw YMovingPlatform
      .dw MoveLargeLiftPlat
      .dw MoveLargeLiftPlat
      .dw XMovingPlatform
      .dw DropPlatform
      .dw RightPlatform

;-------------------------------------------------------------------------------------

EraseEnemyObject:
      lda #$00                 ;clear all enemy object variables
      sta Enemy_Flag,x
      sta Enemy_ID,x
      sta Enemy_State,x
      sta FloateyNum_Control,x
      sta EnemyIntervalTimer,x
      sta ShellChainCounter,x
      sta Enemy_SprAttrib,x
      sta EnemyFrameTimer,x
      rts

;-------------------------------------------------------------------------------------

MovePodoboo:
      lda EnemyIntervalTimer,x   ;check enemy timer
      bne PdbM                   ;branch to move enemy if not expired
      jsr InitPodoboo            ;otherwise set up podoboo again
      lda PseudoRandomBitReg+1,x ;get part of LSFR
      ora #%10000000             ;set d7
      sta Enemy_Y_MoveForce,x    ;store as movement force
      and #%00001111             ;mask out high nybble
      ora #$06                   ;set for at least six intervals
      sta EnemyIntervalTimer,x   ;store as new enemy timer
      lda #$f9
      sta Enemy_Y_Speed,x        ;set vertical speed to move podoboo upwards
PdbM: jmp MoveJ_EnemyVertically  ;branch to impose gravity on podoboo

;--------------------------------
;$00 - used in HammerBroJumpCode as bitmask

HammerThrowTmrData:
      .db $30, $1c

XSpeedAdderData:
      .db $00, $e8, $00, $18

RevivedXSpeed:
      .db $08, $f8, $0c, $f4

ProcHammerBro:
       lda Enemy_State,x          ;check hammer bro's enemy state for d5 set
       and #%00100000
       beq ChkJH                  ;if not set, go ahead with code
       jmp MoveDefeatedEnemy      ;otherwise jump to something else
ChkJH: lda HammerBroJumpTimer,x   ;check jump timer
       beq HammerBroJumpCode      ;if expired, branch to jump
       dec HammerBroJumpTimer,x   ;otherwise decrement jump timer
       lda Enemy_OffscreenBits
       and #%00001100             ;check offscreen bits
       bne MoveHammerBroXDir      ;if hammer bro a little offscreen, skip to movement code
       lda HammerThrowingTimer,x  ;check hammer throwing timer
       bne DecHT                  ;if not expired, skip ahead, do not throw hammer
       ldy SecondaryHardMode      ;otherwise get secondary hard mode flag
       lda HammerThrowTmrData,y   ;get timer data using flag as offset
       sta HammerThrowingTimer,x  ;set as new timer
       jsr SpawnHammerObj         ;do a sub here to spawn hammer object
       bcc DecHT                  ;if carry clear, hammer not spawned, skip to decrement timer
       lda Enemy_State,x
       ora #%00001000             ;set d3 in enemy state for hammer throw
       sta Enemy_State,x
       jmp MoveHammerBroXDir      ;jump to move hammer bro
DecHT: dec HammerThrowingTimer,x  ;decrement timer
       jmp MoveHammerBroXDir      ;jump to move hammer bro

HammerBroJumpLData:
      .db $20, $37

HammerBroJumpCode:
       lda Enemy_State,x           ;get hammer bro's enemy state
       and #%00000111              ;mask out all but 3 LSB
       cmp #$01                    ;check for d0 set (for jumping)
       beq MoveHammerBroXDir       ;if set, branch ahead to moving code
       lda #$00                    ;load default value here
       sta $00                     ;save into temp variable for now
       ldy #$fa                    ;set default vertical speed
       lda Enemy_Y_Position,x      ;check hammer bro's vertical coordinate
       bmi SetHJ                   ;if on the bottom half of the screen, use current speed
       ldy #$fd                    ;otherwise set alternate vertical speed
       cmp #$70                    ;check to see if hammer bro is above the middle of screen
       inc $00                     ;increment preset value to $01
       bcc SetHJ                   ;if above the middle of the screen, use current speed and $01
       dec $00                     ;otherwise return value to $00
       lda PseudoRandomBitReg+1,x  ;get part of LSFR, mask out all but LSB
       and #$01
       bne SetHJ                   ;if d0 of LSFR set, branch and use current speed and $00
       ldy #$fa                    ;otherwise reset to default vertical speed
SetHJ: sty Enemy_Y_Speed,x         ;set vertical speed for jumping
       lda Enemy_State,x           ;set d0 in enemy state for jumping
       ora #$01
       sta Enemy_State,x
       lda $00                     ;load preset value here to use as bitmask
       and PseudoRandomBitReg+2,x  ;and do bit-wise comparison with part of LSFR
       tay                         ;then use as offset
       lda SecondaryHardMode       ;check secondary hard mode flag
       bne HJump
       tay                         ;if secondary hard mode flag clear, set offset to 0
HJump: lda HammerBroJumpLData,y    ;get jump length timer data using offset from before
       sta EnemyFrameTimer,x       ;save in enemy timer
       lda PseudoRandomBitReg+1,x
       ora #%11000000              ;get contents of part of LSFR, set d7 and d6, then
       sta HammerBroJumpTimer,x    ;store in jump timer

MoveHammerBroXDir:
         ldy #$fc                  ;move hammer bro a little to the left
         lda FrameCounter
         and #%01000000            ;change hammer bro's direction every 64 frames
         bne Shimmy
         ldy #$04                  ;if d6 set in counter, move him a little to the right
Shimmy:  sty Enemy_X_Speed,x       ;store horizontal speed
         ldy #$01                  ;set to face right by default
         jsr PlayerEnemyDiff       ;get horizontal difference between player and hammer bro
         bmi SetShim               ;if enemy to the left of player, skip this part
         iny                       ;set to face left
         lda EnemyIntervalTimer,x  ;check walking timer
         bne SetShim               ;if not yet expired, skip to set moving direction
         lda #$f8
         sta Enemy_X_Speed,x       ;otherwise, make the hammer bro walk left towards player
SetShim: sty Enemy_MovingDir,x     ;set moving direction

MoveNormalEnemy:
       ldy #$00                   ;init Y to leave horizontal movement as-is
       lda Enemy_State,x
       and #%01000000             ;check enemy state for d6 set, if set skip
       bne FallE                  ;to move enemy vertically, then horizontally if necessary
       lda Enemy_State,x
       asl                        ;check enemy state for d7 set
       bcs SteadM                 ;if set, branch to move enemy horizontally
       lda Enemy_State,x
       and #%00100000             ;check enemy state for d5 set
       bne MoveDefeatedEnemy      ;if set, branch to move defeated enemy object
       lda Enemy_State,x
       and #%00000111             ;check d2-d0 of enemy state for any set bits
       beq SteadM                 ;if enemy in normal state, branch to move enemy horizontally
       cmp #$05
       beq FallE                  ;if enemy in state used by spiny's egg, go ahead here
       cmp #$03
       bcs ReviveStunned          ;if enemy in states $03 or $04, skip ahead to yet another part
FallE: jsr MoveD_EnemyVertically  ;do a sub here to move enemy downwards
       ldy #$00
       lda Enemy_State,x          ;check for enemy state $02
       cmp #$02
       beq MEHor                  ;if found, branch to move enemy horizontally
       and #%01000000             ;check for d6 set
       beq SteadM                 ;if not set, branch to something else
       lda Enemy_ID,x
       cmp #PowerUpObject         ;check for power-up object
       beq SteadM
       bne SlowM                  ;if any other object where d6 set, jump to set Y
MEHor: jmp MoveEnemyHorizontally  ;jump here to move enemy horizontally for <> $2e and d6 set

SlowM:  ldy #$01                  ;if branched here, increment Y to slow horizontal movement
SteadM: lda Enemy_X_Speed,x       ;get current horizontal speed
        pha                       ;save to stack
        bpl AddHS                 ;if not moving or moving right, skip, leave Y alone
        iny
        iny                       ;otherwise increment Y to next data
AddHS:  clc
        adc XSpeedAdderData,y     ;add value here to slow enemy down if necessary
        sta Enemy_X_Speed,x       ;save as horizontal speed temporarily
        jsr MoveEnemyHorizontally ;then do a sub to move horizontally
        pla
        sta Enemy_X_Speed,x       ;get old horizontal speed from stack and return to
        rts                       ;original memory location, then leave

ReviveStunned:
         lda EnemyIntervalTimer,x  ;if enemy timer not expired yet,
         bne ChkKillGoomba         ;skip ahead to something else
         sta Enemy_State,x         ;otherwise initialize enemy state to normal
         lda FrameCounter
         and #$01                  ;get d0 of frame counter
         tay                       ;use as Y and increment for movement direction
         iny
         sty Enemy_MovingDir,x     ;store as pseudorandom movement direction
         dey                       ;decrement for use as pointer
         lda PrimaryHardMode       ;check primary hard mode flag
         beq SetRSpd               ;if not set, use pointer as-is
         iny
         iny                       ;otherwise increment 2 bytes to next data
SetRSpd: lda RevivedXSpeed,y       ;load and store new horizontal speed
         sta Enemy_X_Speed,x       ;and leave
         rts

MoveDefeatedEnemy:
      jsr MoveD_EnemyVertically      ;execute sub to move defeated enemy downwards
      jmp MoveEnemyHorizontally      ;now move defeated enemy horizontally

ChkKillGoomba:
        cmp #$0e              ;check to see if enemy timer has reached
        bne NKGmba            ;a certain point, and branch to leave if not
        lda Enemy_ID,x
        cmp #Goomba           ;check for goomba object
        bne NKGmba            ;branch if not found
        jsr EraseEnemyObject  ;otherwise, kill this goomba object
NKGmba: rts                   ;leave!

;--------------------------------

MoveJumpingEnemy:
      jsr MoveJ_EnemyVertically  ;do a sub to impose gravity on green paratroopa
      jmp MoveEnemyHorizontally  ;jump to move enemy horizontally

;--------------------------------

ProcMoveRedPTroopa:
          lda Enemy_Y_Speed,x
          ora Enemy_Y_MoveForce,x     ;check for any vertical force or speed
          bne MoveRedPTUpOrDown       ;branch if any found
          sta Enemy_YMF_Dummy,x       ;initialize something here
          lda Enemy_Y_Position,x      ;check current vs. original vertical coordinate
          cmp RedPTroopaOrigXPos,x
          bcs MoveRedPTUpOrDown       ;if current => original, skip ahead to more code
          lda FrameCounter            ;get frame counter
          and #%00000111              ;mask out all but 3 LSB
          bne NoIncPT                 ;if any bits set, branch to leave
          inc Enemy_Y_Position,x      ;otherwise increment red paratroopa's vertical position
NoIncPT:  rts                         ;leave

MoveRedPTUpOrDown:
          lda Enemy_Y_Position,x      ;check current vs. central vertical coordinate
          cmp RedPTroopaCenterYPos,x
          bcc MovPTDwn                ;if current < central, jump to move downwards
          jmp MoveRedPTroopaUp        ;otherwise jump to move upwards
MovPTDwn: jmp MoveRedPTroopaDown      ;move downwards

;--------------------------------
;$00 - used to store adder for movement, also used as adder for platform
;$01 - used to store maximum value for secondary counter

MoveFlyGreenPTroopa:
        jsr XMoveCntr_GreenPTroopa ;do sub to increment primary and secondary counters
        jsr MoveWithXMCntrs        ;do sub to move green paratroopa accordingly, and horizontally
        ldy #$01                   ;set Y to move green paratroopa down
        lda FrameCounter
        and #%00000011             ;check frame counter 2 LSB for any bits set
        bne NoMGPT                 ;branch to leave if set to move up/down every fourth frame
        lda FrameCounter
        and #%01000000             ;check frame counter for d6 set
        bne YSway                  ;branch to move green paratroopa down if set
        ldy #$ff                   ;otherwise set Y to move green paratroopa up
YSway:  sty $00                    ;store adder here
        lda Enemy_Y_Position,x
        clc                        ;add or subtract from vertical position
        adc $00                    ;to give green paratroopa a wavy flight
        sta Enemy_Y_Position,x
NoMGPT: rts                        ;leave!

XMoveCntr_GreenPTroopa:
         lda #$13                    ;load preset maximum value for secondary counter

XMoveCntr_Platform:
         sta $01                     ;store value here
         lda FrameCounter
         and #%00000011              ;branch to leave if not on
         bne NoIncXM                 ;every fourth frame
         ldy XMoveSecondaryCounter,x ;get secondary counter
         lda XMovePrimaryCounter,x   ;get primary counter
         lsr
         bcs DecSeXM                 ;if d0 of primary counter set, branch elsewhere
         cpy $01                     ;compare secondary counter to preset maximum value
         beq IncPXM                  ;if equal, branch ahead of this part
         inc XMoveSecondaryCounter,x ;increment secondary counter and leave
NoIncXM: rts
IncPXM:  inc XMovePrimaryCounter,x   ;increment primary counter and leave
         rts
DecSeXM: tya                         ;put secondary counter in A
         beq IncPXM                  ;if secondary counter at zero, branch back
         dec XMoveSecondaryCounter,x ;otherwise decrement secondary counter and leave
         rts

MoveWithXMCntrs:
         lda XMoveSecondaryCounter,x  ;save secondary counter to stack
         pha
         ldy #$01                     ;set value here by default
         lda XMovePrimaryCounter,x
         and #%00000010               ;if d1 of primary counter is
         bne XMRight                  ;set, branch ahead of this part here
         lda XMoveSecondaryCounter,x
         eor #$ff                     ;otherwise change secondary
         clc                          ;counter to two's compliment
         adc #$01
         sta XMoveSecondaryCounter,x
         ldy #$02                     ;load alternate value here
XMRight: sty Enemy_MovingDir,x        ;store as moving direction
         jsr MoveEnemyHorizontally
         sta $00                      ;save value obtained from sub here
         pla                          ;get secondary counter from stack
         sta XMoveSecondaryCounter,x  ;and return to original place
         rts

;--------------------------------

BlooberBitmasks:
      .db %00111111, %00000011

MoveBloober:
        lda Enemy_State,x
        and #%00100000             ;check enemy state for d5 set
        bne MoveDefeatedBloober    ;branch if set to move defeated bloober
        ldy SecondaryHardMode      ;use secondary hard mode flag as offset
        lda PseudoRandomBitReg+1,x ;get LSFR
        and BlooberBitmasks,y      ;mask out bits in LSFR using bitmask loaded with offset
        bne BlooberSwim            ;if any bits set, skip ahead to make swim
        txa
        lsr                        ;check to see if on second or fourth slot (1 or 3)
        bcc FBLeft                 ;if not, branch to figure out moving direction
        ldy Player_MovingDir       ;otherwise, load player's moving direction and
        bcs SBMDir                 ;do an unconditional branch to set
FBLeft: ldy #$02                   ;set left moving direction by default
        jsr PlayerEnemyDiff        ;get horizontal difference between player and bloober
        bpl SBMDir                 ;if enemy to the right of player, keep left
        dey                        ;otherwise decrement to set right moving direction
SBMDir: sty Enemy_MovingDir,x      ;set moving direction of bloober, then continue on here

BlooberSwim:
       jsr ProcSwimmingB        ;execute sub to make bloober swim characteristically
       lda Enemy_Y_Position,x   ;get vertical coordinate
       sec
       sbc Enemy_Y_MoveForce,x  ;subtract movement force
       cmp #$20                 ;check to see if position is above edge of status bar
       bcc SwimX                ;if so, don't do it
       sta Enemy_Y_Position,x   ;otherwise, set new vertical position, make bloober swim
SwimX: ldy Enemy_MovingDir,x    ;check moving direction
       dey
       bne LeftSwim             ;if moving to the left, branch to second part
       lda Enemy_X_Position,x
       clc                      ;add movement speed to horizontal coordinate
       adc BlooperMoveSpeed,x
       sta Enemy_X_Position,x   ;store result as new horizontal coordinate
       lda Enemy_PageLoc,x
       adc #$00                 ;add carry to page location
       sta Enemy_PageLoc,x      ;store as new page location and leave
       rts

LeftSwim:
      lda Enemy_X_Position,x
      sec                      ;subtract movement speed from horizontal coordinate
      sbc BlooperMoveSpeed,x
      sta Enemy_X_Position,x   ;store result as new horizontal coordinate
      lda Enemy_PageLoc,x
      sbc #$00                 ;subtract borrow from page location
      sta Enemy_PageLoc,x      ;store as new page location and leave
      rts

MoveDefeatedBloober:
      jmp MoveEnemySlowVert    ;jump to move defeated bloober downwards

ProcSwimmingB:
        lda BlooperMoveCounter,x  ;get enemy's movement counter
        and #%00000010            ;check for d1 set
        bne ChkForFloatdown       ;branch if set
        lda FrameCounter
        and #%00000111            ;get 3 LSB of frame counter
        pha                       ;and save it to the stack
        lda BlooperMoveCounter,x  ;get enemy's movement counter
        lsr                       ;check for d0 set
        bcs SlowSwim              ;branch if set
        pla                       ;pull 3 LSB of frame counter from the stack
        bne BSwimE                ;branch to leave, execute code only every eighth frame
        lda Enemy_Y_MoveForce,x
        clc                       ;add to movement force to speed up swim
        adc #$01
        sta Enemy_Y_MoveForce,x   ;set movement force
        sta BlooperMoveSpeed,x    ;set as movement speed
        cmp #$02
        bne BSwimE                ;if certain horizontal speed, branch to leave
        inc BlooperMoveCounter,x  ;otherwise increment movement counter
BSwimE: rts

SlowSwim:
       pla                      ;pull 3 LSB of frame counter from the stack
       bne NoSSw                ;branch to leave, execute code only every eighth frame
       lda Enemy_Y_MoveForce,x
       sec                      ;subtract from movement force to slow swim
       sbc #$01
       sta Enemy_Y_MoveForce,x  ;set movement force
       sta BlooperMoveSpeed,x   ;set as movement speed
       bne NoSSw                ;if any speed, branch to leave
       inc BlooperMoveCounter,x ;otherwise increment movement counter
       lda #$02
       sta EnemyIntervalTimer,x ;set enemy's timer
NoSSw: rts                      ;leave

ChkForFloatdown:
      lda EnemyIntervalTimer,x ;get enemy timer
      beq ChkNearPlayer        ;branch if expired

Floatdown:
      lda FrameCounter        ;get frame counter
      lsr                     ;check for d0 set
      bcs NoFD                ;branch to leave on every other frame
      inc Enemy_Y_Position,x  ;otherwise increment vertical coordinate
NoFD: rts                     ;leave

ChkNearPlayer:
      lda Enemy_Y_Position,x    ;get vertical coordinate
      adc #$10                  ;add sixteen pixels
      cmp Player_Y_Position     ;compare result with player's vertical coordinate
      bcc Floatdown             ;if modified vertical less than player's, branch
      lda #$00
      sta BlooperMoveCounter,x  ;otherwise nullify movement counter
      rts

;--------------------------------

MoveBulletBill:
         lda Enemy_State,x          ;check bullet bill's enemy object state for d5 set
         and #%00100000
         beq NotDefB                ;if not set, continue with movement code
         jmp MoveJ_EnemyVertically  ;otherwise jump to move defeated bullet bill downwards
NotDefB: lda #$e8                   ;set bullet bill's horizontal speed
         sta Enemy_X_Speed,x        ;and move it accordingly (note: this bullet bill
         jmp MoveEnemyHorizontally  ;object occurs in frenzy object $17, not from cannons)

;--------------------------------
;$02 - used to hold preset values
;$03 - used to hold enemy state

SwimCCXMoveData:
      .db $40, $80
      .db $04, $04 ;residual data, not used

MoveSwimmingCheepCheep:
        lda Enemy_State,x         ;check cheep-cheep's enemy object state
        and #%00100000            ;for d5 set
        beq CCSwim                ;if not set, continue with movement code
        jmp MoveEnemySlowVert     ;otherwise jump to move defeated cheep-cheep downwards
CCSwim: sta $03                   ;save enemy state in $03
        lda Enemy_ID,x            ;get enemy identifier
        sec
        sbc #$0a                  ;subtract ten for cheep-cheep identifiers
        tay                       ;use as offset
        lda SwimCCXMoveData,y     ;load value here
        sta $02
        lda Enemy_X_MoveForce,x   ;load horizontal force
        sec
        sbc $02                   ;subtract preset value from horizontal force
        sta Enemy_X_MoveForce,x   ;store as new horizontal force
        lda Enemy_X_Position,x    ;get horizontal coordinate
        sbc #$00                  ;subtract borrow (thus moving it slowly)
        sta Enemy_X_Position,x    ;and save as new horizontal coordinate
        lda Enemy_PageLoc,x
        sbc #$00                  ;subtract borrow again, this time from the
        sta Enemy_PageLoc,x       ;page location, then save
        lda #$20
        sta $02                   ;save new value here
        cpx #$02                  ;check enemy object offset
        bcc ExSwCC                ;if in first or second slot, branch to leave
        lda CheepCheepMoveMFlag,x ;check movement flag
        cmp #$10                  ;if movement speed set to $00,
        bcc CCSwimUpwards         ;branch to move upwards
        lda Enemy_YMF_Dummy,x
        clc
        adc $02                   ;add preset value to dummy variable to get carry
        sta Enemy_YMF_Dummy,x     ;and save dummy
        lda Enemy_Y_Position,x    ;get vertical coordinate
        adc $03                   ;add carry to it plus enemy state to slowly move it downwards
        sta Enemy_Y_Position,x    ;save as new vertical coordinate
        lda Enemy_Y_HighPos,x
        adc #$00                  ;add carry to page location and
        jmp ChkSwimYPos           ;jump to end of movement code

CCSwimUpwards:
        lda Enemy_YMF_Dummy,x
        sec
        sbc $02                   ;subtract preset value to dummy variable to get borrow
        sta Enemy_YMF_Dummy,x     ;and save dummy
        lda Enemy_Y_Position,x    ;get vertical coordinate
        sbc $03                   ;subtract borrow to it plus enemy state to slowly move it upwards
        sta Enemy_Y_Position,x    ;save as new vertical coordinate
        lda Enemy_Y_HighPos,x
        sbc #$00                  ;subtract borrow from page location

ChkSwimYPos:
        sta Enemy_Y_HighPos,x     ;save new page location here
        ldy #$00                  ;load movement speed to upwards by default
        lda Enemy_Y_Position,x    ;get vertical coordinate
        sec
        sbc CheepCheepOrigYPos,x  ;subtract original coordinate from current
        bpl YPDiff                ;if result positive, skip to next part
        ldy #$10                  ;otherwise load movement speed to downwards
        eor #$ff
        clc                       ;get two's compliment of result
        adc #$01                  ;to obtain total difference of original vs. current
YPDiff: cmp #$0f                  ;if difference between original vs. current vertical
        bcc ExSwCC                ;coordinates < 15 pixels, leave movement speed alone
        tya
        sta CheepCheepMoveMFlag,x ;otherwise change movement speed
ExSwCC: rts                       ;leave

;--------------------------------
;$00 - used as counter for firebar parts
;$01 - used for oscillated high byte of spin state or to hold horizontal adder
;$02 - used for oscillated high byte of spin state or to hold vertical adder
;$03 - used for mirror data
;$04 - used to store player's sprite 1 X coordinate
;$05 - used to evaluate mirror data
;$06 - used to store either screen X coordinate or sprite data offset
;$07 - used to store screen Y coordinate
;$ed - used to hold maximum length of firebar
;$ef - used to hold high byte of spinstate

;horizontal adder is at first byte + high byte of spinstate,
;vertical adder is same + 8 bytes, two's compliment
;if greater than $08 for proper oscillation
FirebarPosLookupTbl:
      .db $00, $01, $03, $04, $05, $06, $07, $07, $08
      .db $00, $03, $06, $09, $0b, $0d, $0e, $0f, $10
      .db $00, $04, $09, $0d, $10, $13, $16, $17, $18
      .db $00, $06, $0c, $12, $16, $1a, $1d, $1f, $20
      .db $00, $07, $0f, $16, $1c, $21, $25, $27, $28
      .db $00, $09, $12, $1b, $21, $27, $2c, $2f, $30
      .db $00, $0b, $15, $1f, $27, $2e, $33, $37, $38
      .db $00, $0c, $18, $24, $2d, $35, $3b, $3e, $40
      .db $00, $0e, $1b, $28, $32, $3b, $42, $46, $48
      .db $00, $0f, $1f, $2d, $38, $42, $4a, $4e, $50
      .db $00, $11, $22, $31, $3e, $49, $51, $56, $58

FirebarMirrorData:
      .db $01, $03, $02, $00

FirebarTblOffsets:
      .db $00, $09, $12, $1b, $24, $2d
      .db $36, $3f, $48, $51, $5a, $63

FirebarYPos:
      .db $0c, $18

ProcFirebar:
          jsr GetEnemyOffscreenBits   ;get offscreen information
          lda Enemy_OffscreenBits     ;check for d3 set
          and #%00001000              ;if so, branch to leave
          bne SkipFBar
          lda TimerControl            ;if master timer control set, branch
          bne SusFbar                 ;ahead of this part
          lda FirebarSpinSpeed,x      ;load spinning speed of firebar
          jsr FirebarSpin             ;modify current spinstate
          and #%00011111              ;mask out all but 5 LSB
          sta FirebarSpinState_High,x ;and store as new high byte of spinstate
SusFbar:  lda FirebarSpinState_High,x ;get high byte of spinstate
          ldy Enemy_ID,x              ;check enemy identifier
          cpy #$1f
          bcc SetupGFB                ;if < $1f (long firebar), branch
          cmp #$08                    ;check high byte of spinstate
          beq SkpFSte                 ;if eight, branch to change
          cmp #$18
          bne SetupGFB                ;if not at twenty-four branch to not change
SkpFSte:  clc
          adc #$01                    ;add one to spinning thing to avoid horizontal state
          sta FirebarSpinState_High,x
SetupGFB: sta $ef                     ;save high byte of spinning thing, modified or otherwise
          jsr RelativeEnemyPosition   ;get relative coordinates to screen
          jsr GetFirebarPosition      ;do a sub here (residual, too early to be used now)
          ldy Enemy_SprDataOffset,x   ;get OAM data offset
          lda Enemy_Rel_YPos          ;get relative vertical coordinate
          sta Sprite_Y_Position,y     ;store as Y in OAM data
          sta $07                     ;also save here
          lda Enemy_Rel_XPos          ;get relative horizontal coordinate
          sta Sprite_X_Position,y     ;store as X in OAM data
          sta $06                     ;also save here
          lda #$01
          sta $00                     ;set $01 value here (not necessary)
          jsr FirebarCollision        ;draw fireball part and do collision detection
          ldy #$05                    ;load value for short firebars by default
          lda Enemy_ID,x
          cmp #$1f                    ;are we doing a long firebar?
          bcc SetMFbar                ;no, branch then
          ldy #$0b                    ;otherwise load value for long firebars
SetMFbar: sty $ed                     ;store maximum value for length of firebars
          lda #$00
          sta $00                     ;initialize counter here
DrawFbar: lda $ef                     ;load high byte of spinstate
          jsr GetFirebarPosition      ;get fireball position data depending on firebar part
          jsr DrawFirebar_Collision   ;position it properly, draw it and do collision detection
          lda $00                     ;check which firebar part
          cmp #$04
          bne NextFbar
          ldy DuplicateObj_Offset     ;if we arrive at fifth firebar part,
          lda Enemy_SprDataOffset,y   ;get offset from long firebar and load OAM data offset
          sta $06                     ;using long firebar offset, then store as new one here
NextFbar: inc $00                     ;move onto the next firebar part
          lda $00
          cmp $ed                     ;if we end up at the maximum part, go on and leave
          bcc DrawFbar                ;otherwise go back and do another
SkipFBar: rts

DrawFirebar_Collision:
         lda $03                  ;store mirror data elsewhere
         sta $05
         ldy $06                  ;load OAM data offset for firebar
         lda $01                  ;load horizontal adder we got from position loader
         lsr $05                  ;shift LSB of mirror data
         bcs AddHA                ;if carry was set, skip this part
         eor #$ff
         adc #$01                 ;otherwise get two's compliment of horizontal adder
AddHA:   clc                      ;add horizontal coordinate relative to screen to
         adc Enemy_Rel_XPos       ;horizontal adder, modified or otherwise
         sta Sprite_X_Position,y  ;store as X coordinate here
         sta $06                  ;store here for now, note offset is saved in Y still
         cmp Enemy_Rel_XPos       ;compare X coordinate of sprite to original X of firebar
         bcs SubtR1               ;if sprite coordinate => original coordinate, branch
         lda Enemy_Rel_XPos
         sec                      ;otherwise subtract sprite X from the
         sbc $06                  ;original one and skip this part
         jmp ChkFOfs
SubtR1:  sec                      ;subtract original X from the
         sbc Enemy_Rel_XPos       ;current sprite X
ChkFOfs: cmp #$59                 ;if difference of coordinates within a certain range,
         bcc VAHandl              ;continue by handling vertical adder
         lda #$f8                 ;otherwise, load offscreen Y coordinate
         bne SetVFbr              ;and unconditionally branch to move sprite offscreen
VAHandl: lda Enemy_Rel_YPos       ;if vertical relative coordinate offscreen,
         cmp #$f8                 ;skip ahead of this part and write into sprite Y coordinate
         beq SetVFbr
         lda $02                  ;load vertical adder we got from position loader
         lsr $05                  ;shift LSB of mirror data one more time
         bcs AddVA                ;if carry was set, skip this part
         eor #$ff
         adc #$01                 ;otherwise get two's compliment of second part
AddVA:   clc                      ;add vertical coordinate relative to screen to
         adc Enemy_Rel_YPos       ;the second data, modified or otherwise
SetVFbr: sta Sprite_Y_Position,y  ;store as Y coordinate here
         sta $07                  ;also store here for now

FirebarCollision:
         jsr DrawFirebar          ;run sub here to draw current tile of firebar
         tya                      ;return OAM data offset and save
         pha                      ;to the stack for now
         lda StarInvincibleTimer  ;if star mario invincibility timer
         ora TimerControl         ;or master timer controls set
         bne NoColFB              ;then skip all of this
         sta $05                  ;otherwise initialize counter
         ldy Player_Y_HighPos
         dey                      ;if player's vertical high byte offscreen,
         bne NoColFB              ;skip all of this
         ldy Player_Y_Position    ;get player's vertical position
         lda PlayerSize           ;get player's size
         bne AdjSm                ;if player small, branch to alter variables
         lda CrouchingFlag
         beq BigJp                ;if player big and not crouching, jump ahead
AdjSm:   inc $05                  ;if small or big but crouching, execute this part
         inc $05                  ;first increment our counter twice (setting $02 as flag)
         tya
         clc                      ;then add 24 pixels to the player's
         adc #$18                 ;vertical coordinate
         tay
BigJp:   tya                      ;get vertical coordinate, altered or otherwise, from Y
FBCLoop: sec                      ;subtract vertical position of firebar
         sbc $07                  ;from the vertical coordinate of the player
         bpl ChkVFBD              ;if player lower on the screen than firebar,
         eor #$ff                 ;skip two's compliment part
         clc                      ;otherwise get two's compliment
         adc #$01
ChkVFBD: cmp #$08                 ;if difference => 8 pixels, skip ahead of this part
         bcs Chk2Ofs
         lda $06                  ;if firebar on far right on the screen, skip this,
         cmp #$f0                 ;because, really, what's the point?
         bcs Chk2Ofs
         lda Sprite_X_Position+4  ;get OAM X coordinate for sprite #1
         clc
         adc #$04                 ;add four pixels
         sta $04                  ;store here
         sec                      ;subtract horizontal coordinate of firebar
         sbc $06                  ;from the X coordinate of player's sprite 1
         bpl ChkFBCl              ;if modded X coordinate to the right of firebar
         eor #$ff                 ;skip two's compliment part
         clc                      ;otherwise get two's compliment
         adc #$01
ChkFBCl: cmp #$08                 ;if difference < 8 pixels, collision, thus branch
         bcc ChgSDir              ;to process
Chk2Ofs: lda $05                  ;if value of $02 was set earlier for whatever reason,
         cmp #$02                 ;branch to increment OAM offset and leave, no collision
         beq NoColFB
         ldy $05                  ;otherwise get temp here and use as offset
         lda Player_Y_Position
         clc
         adc FirebarYPos,y        ;add value loaded with offset to player's vertical coordinate
         inc $05                  ;then increment temp and jump back
         jmp FBCLoop
ChgSDir: ldx #$01                 ;set movement direction by default
         lda $04                  ;if OAM X coordinate of player's sprite 1
         cmp $06                  ;is greater than horizontal coordinate of firebar
         bcs SetSDir              ;then do not alter movement direction
         inx                      ;otherwise increment it
SetSDir: stx Enemy_MovingDir      ;store movement direction here
         ldx #$00
         lda $00                  ;save value written to $00 to stack
         pha
         jsr InjurePlayer         ;perform sub to hurt or kill player
         pla
         sta $00                  ;get value of $00 from stack
NoColFB: pla                      ;get OAM data offset
         clc                      ;add four to it and save
         adc #$04
         sta $06
         ldx ObjectOffset         ;get enemy object buffer offset and leave
         rts

GetFirebarPosition:
           pha                        ;save high byte of spinstate to the stack
           and #%00001111             ;mask out low nybble
           cmp #$09
           bcc GetHAdder              ;if lower than $09, branch ahead
           eor #%00001111             ;otherwise get two's compliment to oscillate
           clc
           adc #$01
GetHAdder: sta $01                    ;store result, modified or not, here
           ldy $00                    ;load number of firebar ball where we're at
           lda FirebarTblOffsets,y    ;load offset to firebar position data
           clc
           adc $01                    ;add oscillated high byte of spinstate
           tay                        ;to offset here and use as new offset
           lda FirebarPosLookupTbl,y  ;get data here and store as horizontal adder
           sta $01
           pla                        ;pull whatever was in A from the stack
           pha                        ;save it again because we still need it
           clc
           adc #$08                   ;add eight this time, to get vertical adder
           and #%00001111             ;mask out high nybble
           cmp #$09                   ;if lower than $09, branch ahead
           bcc GetVAdder
           eor #%00001111             ;otherwise get two's compliment
           clc
           adc #$01
GetVAdder: sta $02                    ;store result here
           ldy $00
           lda FirebarTblOffsets,y    ;load offset to firebar position data again
           clc
           adc $02                    ;this time add value in $02 to offset here and use as offset
           tay
           lda FirebarPosLookupTbl,y  ;get data here and store as vertica adder
           sta $02
           pla                        ;pull out whatever was in A one last time
           lsr                        ;divide by eight or shift three to the right
           lsr
           lsr
           tay                        ;use as offset
           lda FirebarMirrorData,y    ;load mirroring data here
           sta $03                    ;store
           rts

;--------------------------------

PRandomSubtracter:
      .db $f8, $a0, $70, $bd, $00

FlyCCBPriority:
      .db $20, $20, $20, $00, $00

MoveFlyingCheepCheep:
        lda Enemy_State,x          ;check cheep-cheep's enemy state
        and #%00100000             ;for d5 set
        beq FlyCC                  ;branch to continue code if not set
        lda #$00
        sta Enemy_SprAttrib,x      ;otherwise clear sprite attributes
        jmp MoveJ_EnemyVertically  ;and jump to move defeated cheep-cheep downwards
FlyCC:  jsr MoveEnemyHorizontally  ;move cheep-cheep horizontally based on speed and force
        ldy #$0d                   ;set vertical movement amount
        lda #$05                   ;set maximum speed
        jsr SetXMoveAmt            ;branch to impose gravity on flying cheep-cheep
        lda Enemy_Y_MoveForce,x
        lsr                        ;get vertical movement force and
        lsr                        ;move high nybble to low
        lsr
        lsr
        tay                        ;save as offset (note this tends to go into reach of code)
        lda Enemy_Y_Position,x     ;get vertical position
        sec                        ;subtract pseudorandom value based on offset from position
        sbc PRandomSubtracter,y
        bpl AddCCF                  ;if result within top half of screen, skip this part
        eor #$ff
        clc                        ;otherwise get two's compliment
        adc #$01
AddCCF: cmp #$08                   ;if result or two's compliment greater than eight,
        bcs BPGet                  ;skip to the end without changing movement force
        lda Enemy_Y_MoveForce,x
        clc
        adc #$10                   ;otherwise add to it
        sta Enemy_Y_MoveForce,x
        lsr                        ;move high nybble to low again
        lsr
        lsr
        lsr
        tay
BPGet:  lda FlyCCBPriority,y       ;load bg priority data and store (this is very likely
        sta Enemy_SprAttrib,x      ;broken or residual code, value is overwritten before
        rts                        ;drawing it next frame), then leave

;--------------------------------
;$00 - used to hold horizontal difference
;$01-$03 - used to hold difference adjusters

LakituDiffAdj:
      .db $15, $30, $40

MoveLakitu:
         lda Enemy_State,x          ;check lakitu's enemy state
         and #%00100000             ;for d5 set
         beq ChkLS                  ;if not set, continue with code
         jmp MoveD_EnemyVertically  ;otherwise jump to move defeated lakitu downwards
ChkLS:   lda Enemy_State,x          ;if lakitu's enemy state not set at all,
         beq Fr12S                  ;go ahead and continue with code
         lda #$00
         sta LakituMoveDirection,x  ;otherwise initialize moving direction to move to left
         sta EnemyFrenzyBuffer      ;initialize frenzy buffer
         lda #$10
         bne SetLSpd                ;load horizontal speed and do unconditional branch
Fr12S:   lda #Spiny
         sta EnemyFrenzyBuffer      ;set spiny identifier in frenzy buffer
         ldy #$02
LdLDa:   lda LakituDiffAdj,y        ;load values
         sta $0001,y                ;store in zero page
         dey
         bpl LdLDa                  ;do this until all values are stired
         jsr PlayerLakituDiff       ;execute sub to set speed and create spinys
SetLSpd: sta LakituMoveSpeed,x      ;set movement speed returned from sub
         ldy #$01                   ;set moving direction to right by default
         lda LakituMoveDirection,x
         and #$01                   ;get LSB of moving direction
         bne SetLMov                ;if set, branch to the end to use moving direction
         lda LakituMoveSpeed,x
         eor #$ff                   ;get two's compliment of moving speed
         clc
         adc #$01
         sta LakituMoveSpeed,x      ;store as new moving speed
         iny                        ;increment moving direction to left
SetLMov: sty Enemy_MovingDir,x      ;store moving direction
         jmp MoveEnemyHorizontally  ;move lakitu horizontally

PlayerLakituDiff:
           ldy #$00                   ;set Y for default value
           jsr PlayerEnemyDiff        ;get horizontal difference between enemy and player
           bpl ChkLakDif              ;branch if enemy is to the right of the player
           iny                        ;increment Y for left of player
           lda $00
           eor #$ff                   ;get two's compliment of low byte of horizontal difference
           clc
           adc #$01                   ;store two's compliment as horizontal difference
           sta $00
ChkLakDif: lda $00                    ;get low byte of horizontal difference
           cmp #$3c                   ;if within a certain distance of player, branch
           bcc ChkPSpeed
           lda #$3c                   ;otherwise set maximum distance
           sta $00
           lda Enemy_ID,x             ;check if lakitu is in our current enemy slot
           cmp #Lakitu
           bne ChkPSpeed              ;if not, branch elsewhere
           tya                        ;compare contents of Y, now in A
           cmp LakituMoveDirection,x  ;to what is being used as horizontal movement direction
           beq ChkPSpeed              ;if moving toward the player, branch, do not alter
           lda LakituMoveDirection,x  ;if moving to the left beyond maximum distance,
           beq SetLMovD               ;branch and alter without delay
           dec LakituMoveSpeed,x      ;decrement horizontal speed
           lda LakituMoveSpeed,x      ;if horizontal speed not yet at zero, branch to leave
           bne ExMoveLak
SetLMovD:  tya                        ;set horizontal direction depending on horizontal
           sta LakituMoveDirection,x  ;difference between enemy and player if necessary
ChkPSpeed: lda $00
           and #%00111100             ;mask out all but four bits in the middle
           lsr                        ;divide masked difference by four
           lsr
           sta $00                    ;store as new value
           ldy #$00                   ;init offset
           lda Player_X_Speed
           beq SubDifAdj              ;if player not moving horizontally, branch
           lda ScrollAmount
           beq SubDifAdj              ;if scroll speed not set, branch to same place
           iny                        ;otherwise increment offset
           lda Player_X_Speed
           cmp #$19                   ;if player not running, branch
           bcc ChkSpinyO
           lda ScrollAmount
           cmp #$02                   ;if scroll speed below a certain amount, branch
           bcc ChkSpinyO              ;to same place
           iny                        ;otherwise increment once more
ChkSpinyO: lda Enemy_ID,x             ;check for spiny object
           cmp #Spiny
           bne ChkEmySpd              ;branch if not found
           lda Player_X_Speed         ;if player not moving, skip this part
           bne SubDifAdj
ChkEmySpd: lda Enemy_Y_Speed,x        ;check vertical speed
           bne SubDifAdj              ;branch if nonzero
           ldy #$00                   ;otherwise reinit offset
SubDifAdj: lda $0001,y                ;get one of three saved values from earlier
           ldy $00                    ;get saved horizontal difference
SPixelLak: sec                        ;subtract one for each pixel of horizontal difference
           sbc #$01                   ;from one of three saved values
           dey
           bpl SPixelLak              ;branch until all pixels are subtracted, to adjust difference
ExMoveLak: rts                        ;leave!!!

;-------------------------------------------------------------------------------------
;$04-$05 - used to store name table address in little endian order

BridgeCollapseData:
      .db $1a ;axe
      .db $58 ;chain
      .db $98, $96, $94, $92, $90, $8e, $8c ;bridge
      .db $8a, $88, $86, $84, $82, $80

BridgeCollapse:
       ldx BowserFront_Offset    ;get enemy offset for bowser
       lda Enemy_ID,x            ;check enemy object identifier for bowser
       cmp #Bowser               ;if not found, branch ahead,
       bne SetM2                 ;metatile removal not necessary
       stx ObjectOffset          ;store as enemy offset here
       lda Enemy_State,x         ;if bowser in normal state, skip all of this
       beq RemoveBridge
       and #%01000000            ;if bowser's state has d6 clear, skip to silence music
       beq SetM2
       lda Enemy_Y_Position,x    ;check bowser's vertical coordinate
       cmp #$e0                  ;if bowser not yet low enough, skip this part ahead
       bcc MoveD_Bowser
SetM2: lda #Silence              ;silence music
       sta EventMusicQueue
       inc OperMode_Task         ;move onto next secondary mode in autoctrl mode
       jmp KillAllEnemies        ;jump to empty all enemy slots and then leave

MoveD_Bowser:
       jsr MoveEnemySlowVert     ;do a sub to move bowser downwards
       jmp BowserGfxHandler      ;jump to draw bowser's front and rear, then leave

RemoveBridge:
         dec BowserFeetCounter     ;decrement timer to control bowser's feet
         bne NoBFall               ;if not expired, skip all of this
         lda #$04
         sta BowserFeetCounter     ;otherwise, set timer now
         lda BowserBodyControls
         eor #$01                  ;invert bit to control bowser's feet
         sta BowserBodyControls
         lda #$22                  ;put high byte of name table address here for now
         sta $05
         ldy BridgeCollapseOffset  ;get bridge collapse offset here
         lda BridgeCollapseData,y  ;load low byte of name table address and store here
         sta $04
         ldy VRAM_Buffer1_Offset   ;increment vram buffer offset
         iny
         ldx #$0c                  ;set offset for tile data for sub to draw blank metatile
         jsr RemBridge             ;do sub here to remove bowser's bridge metatiles
         ldx ObjectOffset          ;get enemy offset
         jsr MoveVOffset           ;set new vram buffer offset
         lda #Sfx_Blast            ;load the fireworks/gunfire sound into the square 2 sfx
         sta Square2SoundQueue     ;queue while at the same time loading the brick
         lda #Sfx_BrickShatter     ;shatter sound into the noise sfx queue thus
         sta NoiseSoundQueue       ;producing the unique sound of the bridge collapsing
         inc BridgeCollapseOffset  ;increment bridge collapse offset
         lda BridgeCollapseOffset
         cmp #$0f                  ;if bridge collapse offset has not yet reached
         bne NoBFall               ;the end, go ahead and skip this part
         jsr InitVStf              ;initialize whatever vertical speed bowser has
         lda #%01000000
         sta Enemy_State,x         ;set bowser's state to one of defeated states (d6 set)
         lda #Sfx_BowserFall
         sta Square2SoundQueue     ;play bowser defeat sound
NoBFall: jmp BowserGfxHandler      ;jump to code that draws bowser

;--------------------------------

PRandomRange:
      .db $21, $41, $11, $31

RunBowser:
      lda Enemy_State,x       ;if d5 in enemy state is not set
      and #%00100000          ;then branch elsewhere to run bowser
      beq BowserControl
      lda Enemy_Y_Position,x  ;otherwise check vertical position
      cmp #$e0                ;if above a certain point, branch to move defeated bowser
      bcc MoveD_Bowser        ;otherwise proceed to KillAllEnemies

KillAllEnemies:
          ldx #$04              ;start with last enemy slot
KillLoop: jsr EraseEnemyObject  ;branch to kill enemy objects
          dex                   ;move onto next enemy slot
          bpl KillLoop          ;do this until all slots are emptied
          sta EnemyFrenzyBuffer ;empty frenzy buffer
          ldx ObjectOffset      ;get enemy object offset and leave
          rts

BowserControl:
           lda #$00
           sta EnemyFrenzyBuffer      ;empty frenzy buffer
           lda TimerControl           ;if master timer control not set,
           beq ChkMouth               ;skip jump and execute code here
           jmp SkipToFB               ;otherwise, jump over a bunch of code
ChkMouth:  lda BowserBodyControls     ;check bowser's mouth
           bpl FeetTmr                ;if bit clear, go ahead with code here
           jmp HammerChk              ;otherwise skip a whole section starting here
FeetTmr:   dec BowserFeetCounter      ;decrement timer to control bowser's feet
           bne ResetMDr               ;if not expired, skip this part
           lda #$20                   ;otherwise, reset timer
           sta BowserFeetCounter
           lda BowserBodyControls     ;and invert bit used
           eor #%00000001             ;to control bowser's feet
           sta BowserBodyControls
ResetMDr:  lda FrameCounter           ;check frame counter
           and #%00001111             ;if not on every sixteenth frame, skip
           bne B_FaceP                ;ahead to continue code
           lda #$02                   ;otherwise reset moving/facing direction every
           sta Enemy_MovingDir,x      ;sixteen frames
B_FaceP:   lda EnemyFrameTimer,x      ;if timer set here expired,
           beq GetPRCmp               ;branch to next section
           jsr PlayerEnemyDiff        ;get horizontal difference between player and bowser,
           bpl GetPRCmp               ;and branch if bowser to the right of the player
           lda #$01
           sta Enemy_MovingDir,x      ;set bowser to move and face to the right
           lda #$02
           sta BowserMovementSpeed    ;set movement speed
           lda #$20
           sta EnemyFrameTimer,x      ;set timer here
           sta BowserFireBreathTimer  ;set timer used for bowser's flame
           lda Enemy_X_Position,x
           cmp #$c8                   ;if bowser to the right past a certain point,
           bcs HammerChk              ;skip ahead to some other section
GetPRCmp:  lda FrameCounter           ;get frame counter
           and #%00000011
           bne HammerChk              ;execute this code every fourth frame, otherwise branch
           lda Enemy_X_Position,x
           cmp BowserOrigXPos         ;if bowser not at original horizontal position,
           bne GetDToO                ;branch to skip this part
           lda PseudoRandomBitReg,x
           and #%00000011             ;get pseudorandom offset
           tay
           lda PRandomRange,y         ;load value using pseudorandom offset
           sta MaxRangeFromOrigin     ;and store here
GetDToO:   lda Enemy_X_Position,x
           clc                        ;add movement speed to bowser's horizontal
           adc BowserMovementSpeed    ;coordinate and save as new horizontal position
           sta Enemy_X_Position,x
           ldy Enemy_MovingDir,x
           cpy #$01                   ;if bowser moving and facing to the right, skip ahead
           beq HammerChk
           ldy #$ff                   ;set default movement speed here (move left)
           sec                        ;get difference of current vs. original
           sbc BowserOrigXPos         ;horizontal position
           bpl CompDToO               ;if current position to the right of original, skip ahead
           eor #$ff
           clc                        ;get two's compliment
           adc #$01
           ldy #$01                   ;set alternate movement speed here (move right)
CompDToO:  cmp MaxRangeFromOrigin     ;compare difference with pseudorandom value
           bcc HammerChk              ;if difference < pseudorandom value, leave speed alone
           sty BowserMovementSpeed    ;otherwise change bowser's movement speed
HammerChk: lda EnemyFrameTimer,x      ;if timer set here not expired yet, skip ahead to
           bne MakeBJump              ;some other section of code
           jsr MoveEnemySlowVert      ;otherwise start by moving bowser downwards
           lda WorldNumber            ;check world number
           cmp #World6
           bcc SetHmrTmr              ;if world 1-5, skip this part (not time to throw hammers yet)
           lda FrameCounter
           and #%00000011             ;check to see if it's time to execute sub
           bne SetHmrTmr              ;if not, skip sub, otherwise
           jsr SpawnHammerObj         ;execute sub on every fourth frame to spawn misc object (hammer)
SetHmrTmr: lda Enemy_Y_Position,x     ;get current vertical position
           cmp #$80                   ;if still above a certain point
           bcc ChkFireB               ;then skip to world number check for flames
           lda PseudoRandomBitReg,x
           and #%00000011             ;get pseudorandom offset
           tay
           lda PRandomRange,y         ;get value using pseudorandom offset
           sta EnemyFrameTimer,x      ;set for timer here
SkipToFB:  jmp ChkFireB               ;jump to execute flames code
MakeBJump: cmp #$01                   ;if timer not yet about to expire,
           bne ChkFireB               ;skip ahead to next part
           dec Enemy_Y_Position,x     ;otherwise decrement vertical coordinate
           jsr InitVStf               ;initialize movement amount
           lda #$fe
           sta Enemy_Y_Speed,x        ;set vertical speed to move bowser upwards
ChkFireB:  lda WorldNumber            ;check world number here
           cmp #World8                ;world 8?
           beq SpawnFBr               ;if so, execute this part here
           cmp #World6                ;world 6-7?
           bcs BowserGfxHandler       ;if so, skip this part here
SpawnFBr:  lda BowserFireBreathTimer  ;check timer here
           bne BowserGfxHandler       ;if not expired yet, skip all of this
           lda #$20
           sta BowserFireBreathTimer  ;set timer here
           lda BowserBodyControls
           eor #%10000000             ;invert bowser's mouth bit to open
           sta BowserBodyControls     ;and close bowser's mouth
           bmi ChkFireB               ;if bowser's mouth open, loop back
           jsr SetFlameTimer          ;get timing for bowser's flame
           ldy SecondaryHardMode
           beq SetFBTmr               ;if secondary hard mode flag not set, skip this
           sec
           sbc #$10                   ;otherwise subtract from value in A
SetFBTmr:  sta BowserFireBreathTimer  ;set value as timer here
           lda #BowserFlame           ;put bowser's flame identifier
           sta EnemyFrenzyBuffer      ;in enemy frenzy buffer

;--------------------------------

BowserGfxHandler:
          jsr ProcessBowserHalf    ;do a sub here to process bowser's front
          ldy #$10                 ;load default value here to position bowser's rear
          lda Enemy_MovingDir,x    ;check moving direction
          lsr
          bcc CopyFToR             ;if moving left, use default
          ldy #$f0                 ;otherwise load alternate positioning value here
CopyFToR: tya                      ;move bowser's rear object position value to A
          clc
          adc Enemy_X_Position,x   ;add to bowser's front object horizontal coordinate
          ldy DuplicateObj_Offset  ;get bowser's rear object offset
          sta Enemy_X_Position,y   ;store A as bowser's rear horizontal coordinate
          lda Enemy_Y_Position,x
          clc                      ;add eight pixels to bowser's front object
          adc #$08                 ;vertical coordinate and store as vertical coordinate
          sta Enemy_Y_Position,y   ;for bowser's rear
          lda Enemy_State,x
          sta Enemy_State,y        ;copy enemy state directly from front to rear
          lda Enemy_MovingDir,x
          sta Enemy_MovingDir,y    ;copy moving direction also
          lda ObjectOffset         ;save enemy object offset of front to stack
          pha
          ldx DuplicateObj_Offset  ;put enemy object offset of rear as current
          stx ObjectOffset
          lda #Bowser              ;set bowser's enemy identifier
          sta Enemy_ID,x           ;store in bowser's rear object
          jsr ProcessBowserHalf    ;do a sub here to process bowser's rear
          pla
          sta ObjectOffset         ;get original enemy object offset
          tax
          lda #$00                 ;nullify bowser's front/rear graphics flag
          sta BowserGfxFlag
ExBGfxH:  rts                      ;leave!

ProcessBowserHalf:
      inc BowserGfxFlag         ;increment bowser's graphics flag, then run subroutines
      jsr RunRetainerObj        ;to get offscreen bits, relative position and draw bowser (finally!)
      lda Enemy_State,x
      bne ExBGfxH               ;if either enemy object not in normal state, branch to leave
      lda #$0a
      sta Enemy_BoundBoxCtrl,x  ;set bounding box size control
      jsr GetEnemyBoundBox      ;get bounding box coordinates
      jmp PlayerEnemyCollision  ;do player-to-enemy collision detection

;-------------------------------------------------------------------------------------
;$00 - used to hold movement force and tile number
;$01 - used to hold sprite attribute data

FlameTimerData:
      .db $bf, $40, $bf, $bf, $bf, $40, $40, $bf

SetFlameTimer:
      ldy BowserFlameTimerCtrl  ;load counter as offset
      inc BowserFlameTimerCtrl  ;increment
      lda BowserFlameTimerCtrl  ;mask out all but 3 LSB
      and #%00000111            ;to keep in range of 0-7
      sta BowserFlameTimerCtrl
      lda FlameTimerData,y      ;load value to be used then leave
ExFl: rts

ProcBowserFlame:
         lda TimerControl            ;if master timer control flag set,
         bne SetGfxF                 ;skip all of this
         lda #$40                    ;load default movement force
         ldy SecondaryHardMode
         beq SFlmX                   ;if secondary hard mode flag not set, use default
         lda #$60                    ;otherwise load alternate movement force to go faster
SFlmX:   sta $00                     ;store value here
         lda Enemy_X_MoveForce,x
         sec                         ;subtract value from movement force
         sbc $00
         sta Enemy_X_MoveForce,x     ;save new value
         lda Enemy_X_Position,x
         sbc #$01                    ;subtract one from horizontal position to move
         sta Enemy_X_Position,x      ;to the left
         lda Enemy_PageLoc,x
         sbc #$00                    ;subtract borrow from page location
         sta Enemy_PageLoc,x
         ldy BowserFlamePRandomOfs,x ;get some value here and use as offset
         lda Enemy_Y_Position,x      ;load vertical coordinate
         cmp FlameYPosData,y         ;compare against coordinate data using $0417,x as offset
         beq SetGfxF                 ;if equal, branch and do not modify coordinate
         clc
         adc Enemy_Y_MoveForce,x     ;otherwise add value here to coordinate and store
         sta Enemy_Y_Position,x      ;as new vertical coordinate
SetGfxF: jsr RelativeEnemyPosition   ;get new relative coordinates
         lda Enemy_State,x           ;if bowser's flame not in normal state,
         bne ExFl                    ;branch to leave
         lda #$51                    ;otherwise, continue
         sta $00                     ;write first tile number
         ldy #$02                    ;load attributes without vertical flip by default
         lda FrameCounter
         and #%00000010              ;invert vertical flip bit every 2 frames
         beq FlmeAt                  ;if d1 not set, write default value
         ldy #$82                    ;otherwise write value with vertical flip bit set
FlmeAt:  sty $01                     ;set bowser's flame sprite attributes here
         ldy Enemy_SprDataOffset,x   ;get OAM data offset
         ldx #$00

DrawFlameLoop:
         lda Enemy_Rel_YPos         ;get Y relative coordinate of current enemy object
         sta Sprite_Y_Position,y    ;write into Y coordinate of OAM data
         lda $00
         sta Sprite_Tilenumber,y    ;write current tile number into OAM data
         inc $00                    ;increment tile number to draw more bowser's flame
         lda $01
         sta Sprite_Attributes,y    ;write saved attributes into OAM data
         lda Enemy_Rel_XPos
         sta Sprite_X_Position,y    ;write X relative coordinate of current enemy object
         clc
         adc #$08
         sta Enemy_Rel_XPos         ;then add eight to it and store
         iny
         iny
         iny
         iny                        ;increment Y four times to move onto the next OAM
         inx                        ;move onto the next OAM, and branch if three
         cpx #$03                   ;have not yet been done
         bcc DrawFlameLoop
         ldx ObjectOffset           ;reload original enemy offset
         jsr GetEnemyOffscreenBits  ;get offscreen information
         ldy Enemy_SprDataOffset,x  ;get OAM data offset
         lda Enemy_OffscreenBits    ;get enemy object offscreen bits
         lsr                        ;move d0 to carry and result to stack
         pha
         bcc M3FOfs                 ;branch if carry not set
         lda #$f8                   ;otherwise move sprite offscreen, this part likely
         sta Sprite_Y_Position+12,y ;residual since flame is only made of three sprites
M3FOfs:  pla                        ;get bits from stack
         lsr                        ;move d1 to carry and move bits back to stack
         pha
         bcc M2FOfs                 ;branch if carry not set again
         lda #$f8                   ;otherwise move third sprite offscreen
         sta Sprite_Y_Position+8,y
M2FOfs:  pla                        ;get bits from stack again
         lsr                        ;move d2 to carry and move bits back to stack again
         pha
         bcc M1FOfs                 ;branch if carry not set yet again
         lda #$f8                   ;otherwise move second sprite offscreen
         sta Sprite_Y_Position+4,y
M1FOfs:  pla                        ;get bits from stack one last time
         lsr                        ;move d3 to carry
         bcc ExFlmeD                ;branch if carry not set one last time
         lda #$f8
         sta Sprite_Y_Position,y    ;otherwise move first sprite offscreen
ExFlmeD: rts                        ;leave

;--------------------------------

RunFireworks:
           dec ExplosionTimerCounter,x ;decrement explosion timing counter here
           bne SetupExpl               ;if not expired, skip this part
           lda #$08
           sta ExplosionTimerCounter,x ;reset counter
           inc ExplosionGfxCounter,x   ;increment explosion graphics counter
           lda ExplosionGfxCounter,x
           cmp #$03                    ;check explosion graphics counter
           bcs FireworksSoundScore     ;if at a certain point, branch to kill this object
SetupExpl: jsr RelativeEnemyPosition   ;get relative coordinates of explosion
           lda Enemy_Rel_YPos          ;copy relative coordinates
           sta Fireball_Rel_YPos       ;from the enemy object to the fireball object
           lda Enemy_Rel_XPos          ;first vertical, then horizontal
           sta Fireball_Rel_XPos
           ldy Enemy_SprDataOffset,x   ;get OAM data offset
           lda ExplosionGfxCounter,x   ;get explosion graphics counter
           jsr DrawExplosion_Fireworks ;do a sub to draw the explosion then leave
           rts

FireworksSoundScore:
      lda #$00               ;disable enemy buffer flag
      sta Enemy_Flag,x
      lda #Sfx_Blast         ;play fireworks/gunfire sound
      sta Square2SoundQueue
      lda #$05               ;set part of score modifier for 500 points
      sta DigitModifier+4
      jmp EndAreaPoints     ;jump to award points accordingly then leave

;--------------------------------

StarFlagYPosAdder:
      .db $00, $00, $08, $08

StarFlagXPosAdder:
      .db $00, $08, $00, $08

StarFlagTileData:
      .db $54, $55, $56, $57

RunStarFlagObj:
      lda #$00                 ;initialize enemy frenzy buffer
      sta EnemyFrenzyBuffer
      lda StarFlagTaskControl  ;check star flag object task number here
      cmp #$05                 ;if greater than 5, branch to exit
      bcs StarFlagExit
      jsr JumpEngine           ;otherwise jump to appropriate sub

      .dw StarFlagExit
      .dw GameTimerFireworks
      .dw AwardGameTimerPoints
      .dw RaiseFlagSetoffFWorks
      .dw DelayToAreaEnd

GameTimerFireworks:
        ldy #$05               ;set default state for star flag object
        lda GameTimerDisplay+2 ;get game timer's last digit
        cmp #$01
        beq SetFWC             ;if last digit of game timer set to 1, skip ahead
        ldy #$03               ;otherwise load new value for state
        cmp #$03
        beq SetFWC             ;if last digit of game timer set to 3, skip ahead
        ldy #$00               ;otherwise load one more potential value for state
        cmp #$06
        beq SetFWC             ;if last digit of game timer set to 6, skip ahead
        lda #$ff               ;otherwise set value for no fireworks
SetFWC: sta FireworksCounter   ;set fireworks counter here
        sty Enemy_State,x      ;set whatever state we have in star flag object

IncrementSFTask1:
      inc StarFlagTaskControl  ;increment star flag object task number

StarFlagExit:
      rts                      ;leave

AwardGameTimerPoints:
         lda GameTimerDisplay   ;check all game timer digits for any intervals left
         ora GameTimerDisplay+1
         ora GameTimerDisplay+2
         beq IncrementSFTask1   ;if no time left on game timer at all, branch to next task
         lda FrameCounter
         and #%00000100         ;check frame counter for d2 set (skip ahead
         beq NoTTick            ;for four frames every four frames) branch if not set
         lda #Sfx_TimerTick
         sta Square2SoundQueue  ;load timer tick sound
NoTTick: ldy #$23               ;set offset here to subtract from game timer's last digit
         lda #$ff               ;set adder here to $ff, or -1, to subtract one
         sta DigitModifier+5    ;from the last digit of the game timer
         jsr DigitsMathRoutine  ;subtract digit
         lda #$05               ;set now to add 50 points
         sta DigitModifier+5    ;per game timer interval subtracted

EndAreaPoints:
         ldy #$0b               ;load offset for mario's score by default
         lda CurrentPlayer      ;check player on the screen
         beq ELPGive            ;if mario, do not change
         ldy #$11               ;otherwise load offset for luigi's score
ELPGive: jsr DigitsMathRoutine  ;award 50 points per game timer interval
         lda CurrentPlayer      ;get player on the screen (or 500 points per
         asl                    ;fireworks explosion if branched here from there)
         asl                    ;shift to high nybble
         asl
         asl
         ora #%00000100         ;add four to set nybble for game timer
         jmp UpdateNumber       ;jump to print the new score and game timer

RaiseFlagSetoffFWorks:
         lda Enemy_Y_Position,x  ;check star flag's vertical position
         cmp #$72                ;against preset value
         bcc SetoffF             ;if star flag higher vertically, branch to other code
         dec Enemy_Y_Position,x  ;otherwise, raise star flag by one pixel
         jmp DrawStarFlag        ;and skip this part here
SetoffF: lda FireworksCounter    ;check fireworks counter
         beq DrawFlagSetTimer    ;if no fireworks left to go off, skip this part
         bmi DrawFlagSetTimer    ;if no fireworks set to go off, skip this part
         lda #Fireworks
         sta EnemyFrenzyBuffer   ;otherwise set fireworks object in frenzy queue

DrawStarFlag:
         jsr RelativeEnemyPosition  ;get relative coordinates of star flag
         ldy Enemy_SprDataOffset,x  ;get OAM data offset
         ldx #$03                   ;do four sprites
DSFLoop: lda Enemy_Rel_YPos         ;get relative vertical coordinate
         clc
         adc StarFlagYPosAdder,x    ;add Y coordinate adder data
         sta Sprite_Y_Position,y    ;store as Y coordinate
         lda StarFlagTileData,x     ;get tile number
         sta Sprite_Tilenumber,y    ;store as tile number
         lda #$22                   ;set palette and background priority bits
         sta Sprite_Attributes,y    ;store as attributes
         lda Enemy_Rel_XPos         ;get relative horizontal coordinate
         clc
         adc StarFlagXPosAdder,x    ;add X coordinate adder data
         sta Sprite_X_Position,y    ;store as X coordinate
         iny
         iny                        ;increment OAM data offset four bytes
         iny                        ;for next sprite
         iny
         dex                        ;move onto next sprite
         bpl DSFLoop                ;do this until all sprites are done
         ldx ObjectOffset           ;get enemy object offset and leave
         rts

DrawFlagSetTimer:
      jsr DrawStarFlag          ;do sub to draw star flag
      lda #$06
      sta EnemyIntervalTimer,x  ;set interval timer here

IncrementSFTask2:
      inc StarFlagTaskControl   ;move onto next task
      rts

DelayToAreaEnd:
      jsr DrawStarFlag          ;do sub to draw star flag
      lda EnemyIntervalTimer,x  ;if interval timer set in previous task
      bne StarFlagExit2         ;not yet expired, branch to leave
      lda EventMusicBuffer      ;if event music buffer empty,
      beq IncrementSFTask2      ;branch to increment task

StarFlagExit2:
      rts                       ;otherwise leave

;--------------------------------
;$00 - used to store horizontal difference between player and piranha plant

MovePiranhaPlant:
      lda Enemy_State,x           ;check enemy state
      bne PutinPipe               ;if set at all, branch to leave
      lda EnemyFrameTimer,x       ;check enemy's timer here
      bne PutinPipe               ;branch to end if not yet expired
      lda PiranhaPlant_MoveFlag,x ;check movement flag
      bne SetupToMovePPlant       ;if moving, skip to part ahead
      lda PiranhaPlant_Y_Speed,x  ;if currently rising, branch
      bmi ReversePlantSpeed       ;to move enemy upwards out of pipe
      jsr PlayerEnemyDiff         ;get horizontal difference between player and
      bpl ChkPlayerNearPipe       ;piranha plant, and branch if enemy to right of player
      lda $00                     ;otherwise get saved horizontal difference
      eor #$ff
      clc                         ;and change to two's compliment
      adc #$01
      sta $00                     ;save as new horizontal difference

ChkPlayerNearPipe:
      lda $00                     ;get saved horizontal difference
      cmp #$21
      bcc PutinPipe               ;if player within a certain distance, branch to leave

ReversePlantSpeed:
      lda PiranhaPlant_Y_Speed,x  ;get vertical speed
      eor #$ff
      clc                         ;change to two's compliment
      adc #$01
      sta PiranhaPlant_Y_Speed,x  ;save as new vertical speed
      inc PiranhaPlant_MoveFlag,x ;increment to set movement flag

SetupToMovePPlant:
      lda PiranhaPlantDownYPos,x  ;get original vertical coordinate (lowest point)
      ldy PiranhaPlant_Y_Speed,x  ;get vertical speed
      bpl RiseFallPiranhaPlant    ;branch if moving downwards
      lda PiranhaPlantUpYPos,x    ;otherwise get other vertical coordinate (highest point)

RiseFallPiranhaPlant:
      sta $00                     ;save vertical coordinate here
      lda FrameCounter            ;get frame counter
      lsr
      bcc PutinPipe               ;branch to leave if d0 set (execute code every other frame)
      lda TimerControl            ;get master timer control
      bne PutinPipe               ;branch to leave if set (likely not necessary)
      lda Enemy_Y_Position,x      ;get current vertical coordinate
      clc
      adc PiranhaPlant_Y_Speed,x  ;add vertical speed to move up or down
      sta Enemy_Y_Position,x      ;save as new vertical coordinate
      cmp $00                     ;compare against low or high coordinate
      bne PutinPipe               ;branch to leave if not yet reached
      lda #$00
      sta PiranhaPlant_MoveFlag,x ;otherwise clear movement flag
      lda #$40
      sta EnemyFrameTimer,x       ;set timer to delay piranha plant movement

PutinPipe:
      lda #%00100000              ;set background priority bit in sprite
      sta Enemy_SprAttrib,x       ;attributes to give illusion of being inside pipe
      rts                         ;then leave

;-------------------------------------------------------------------------------------
;$07 - spinning speed

FirebarSpin:
      sta $07                     ;save spinning speed here
      lda FirebarSpinDirection,x  ;check spinning direction
      bne SpinCounterClockwise    ;if moving counter-clockwise, branch to other part
      ldy #$18                    ;possibly residual ldy
      lda FirebarSpinState_Low,x
      clc                         ;add spinning speed to what would normally be
      adc $07                     ;the horizontal speed
      sta FirebarSpinState_Low,x
      lda FirebarSpinState_High,x ;add carry to what would normally be the vertical speed
      adc #$00
      rts

SpinCounterClockwise:
      ldy #$08                    ;possibly residual ldy
      lda FirebarSpinState_Low,x
      sec                         ;subtract spinning speed to what would normally be
      sbc $07                     ;the horizontal speed
      sta FirebarSpinState_Low,x
      lda FirebarSpinState_High,x ;add carry to what would normally be the vertical speed
      sbc #$00
      rts

;-------------------------------------------------------------------------------------
;$00 - used to hold collision flag, Y movement force + 5 or low byte of name table for rope
;$01 - used to hold high byte of name table for rope
;$02 - used to hold page location of rope

BalancePlatform:
       lda Enemy_Y_HighPos,x       ;check high byte of vertical position
       cmp #$03
       bne DoBPl
       jmp EraseEnemyObject        ;if far below screen, kill the object
DoBPl: lda Enemy_State,x           ;get object's state (set to $ff or other platform offset)
       bpl CheckBalPlatform        ;if doing other balance platform, branch to leave
       rts

CheckBalPlatform:
       tay                         ;save offset from state as Y
       lda PlatformCollisionFlag,x ;get collision flag of platform
       sta $00                     ;store here
       lda Enemy_MovingDir,x       ;get moving direction
       beq ChkForFall
       jmp PlatformFall            ;if set, jump here

ChkForFall:
       lda #$2d                    ;check if platform is above a certain point
       cmp Enemy_Y_Position,x
       bcc ChkOtherForFall         ;if not, branch elsewhere
       cpy $00                     ;if collision flag is set to same value as
       beq MakePlatformFall        ;enemy state, branch to make platforms fall
       clc
       adc #$02                    ;otherwise add 2 pixels to vertical position
       sta Enemy_Y_Position,x      ;of current platform and branch elsewhere
       jmp StopPlatforms           ;to make platforms stop

MakePlatformFall:
       jmp InitPlatformFall        ;make platforms fall

ChkOtherForFall:
       cmp Enemy_Y_Position,y      ;check if other platform is above a certain point
       bcc ChkToMoveBalPlat        ;if not, branch elsewhere
       cpx $00                     ;if collision flag is set to same value as
       beq MakePlatformFall        ;enemy state, branch to make platforms fall
       clc
       adc #$02                    ;otherwise add 2 pixels to vertical position
       sta Enemy_Y_Position,y      ;of other platform and branch elsewhere
       jmp StopPlatforms           ;jump to stop movement and do not return

ChkToMoveBalPlat:
        lda Enemy_Y_Position,x      ;save vertical position to stack
        pha
        lda PlatformCollisionFlag,x ;get collision flag
        bpl ColFlg                  ;branch if collision
        lda Enemy_Y_MoveForce,x
        clc                         ;add $05 to contents of moveforce, whatever they be
        adc #$05
        sta $00                     ;store here
        lda Enemy_Y_Speed,x
        adc #$00                    ;add carry to vertical speed
        bmi PlatDn                  ;branch if moving downwards
        bne PlatUp                  ;branch elsewhere if moving upwards
        lda $00
        cmp #$0b                    ;check if there's still a little force left
        bcc PlatSt                  ;if not enough, branch to stop movement
        bcs PlatUp                  ;otherwise keep branch to move upwards
ColFlg: cmp ObjectOffset            ;if collision flag matches
        beq PlatDn                  ;current enemy object offset, branch
PlatUp: jsr MovePlatformUp          ;do a sub to move upwards
        jmp DoOtherPlatform         ;jump ahead to remaining code
PlatSt: jsr StopPlatforms           ;do a sub to stop movement
        jmp DoOtherPlatform         ;jump ahead to remaining code
PlatDn: jsr MovePlatformDown        ;do a sub to move downwards

DoOtherPlatform:
       ldy Enemy_State,x           ;get offset of other platform
       pla                         ;get old vertical coordinate from stack
       sec
       sbc Enemy_Y_Position,x      ;get difference of old vs. new coordinate
       clc
       adc Enemy_Y_Position,y      ;add difference to vertical coordinate of other
       sta Enemy_Y_Position,y      ;platform to move it in the opposite direction
       lda PlatformCollisionFlag,x ;if no collision, skip this part here
       bmi DrawEraseRope
       tax                         ;put offset which collision occurred here
       jsr PositionPlayerOnVPlat   ;and use it to position player accordingly

DrawEraseRope:
         ldy ObjectOffset            ;get enemy object offset
         lda Enemy_Y_Speed,y         ;check to see if current platform is
         ora Enemy_Y_MoveForce,y     ;moving at all
         beq ExitRp                  ;if not, skip all of this and branch to leave
         ldx VRAM_Buffer1_Offset     ;get vram buffer offset
         cpx #$20                    ;if offset beyond a certain point, go ahead
         bcs ExitRp                  ;and skip this, branch to leave
         lda Enemy_Y_Speed,y
         pha                         ;save two copies of vertical speed to stack
         pha
         jsr SetupPlatformRope       ;do a sub to figure out where to put new bg tiles
         lda $01                     ;write name table address to vram buffer
         sta VRAM_Buffer1,x          ;first the high byte, then the low
         lda $00
         sta VRAM_Buffer1+1,x
         lda #$02                    ;set length for 2 bytes
         sta VRAM_Buffer1+2,x
         lda Enemy_Y_Speed,y         ;if platform moving upwards, branch
         bmi EraseR1                 ;to do something else
         lda #$a2
         sta VRAM_Buffer1+3,x        ;otherwise put tile numbers for left
         lda #$a3                    ;and right sides of rope in vram buffer
         sta VRAM_Buffer1+4,x
         jmp OtherRope               ;jump to skip this part
EraseR1: lda #$24                    ;put blank tiles in vram buffer
         sta VRAM_Buffer1+3,x        ;to erase rope
         sta VRAM_Buffer1+4,x

OtherRope:
         lda Enemy_State,y           ;get offset of other platform from state
         tay                         ;use as Y here
         pla                         ;pull second copy of vertical speed from stack
         eor #$ff                    ;invert bits to reverse speed
         jsr SetupPlatformRope       ;do sub again to figure out where to put bg tiles
         lda $01                     ;write name table address to vram buffer
         sta VRAM_Buffer1+5,x        ;this time we're doing putting tiles for
         lda $00                     ;the other platform
         sta VRAM_Buffer1+6,x
         lda #$02
         sta VRAM_Buffer1+7,x        ;set length again for 2 bytes
         pla                         ;pull first copy of vertical speed from stack
         bpl EraseR2                 ;if moving upwards (note inversion earlier), skip this
         lda #$a2
         sta VRAM_Buffer1+8,x        ;otherwise put tile numbers for left
         lda #$a3                    ;and right sides of rope in vram
         sta VRAM_Buffer1+9,x        ;transfer buffer
         jmp EndRp                   ;jump to skip this part
EraseR2: lda #$24                    ;put blank tiles in vram buffer
         sta VRAM_Buffer1+8,x        ;to erase rope
         sta VRAM_Buffer1+9,x
EndRp:   lda #$00                    ;put null terminator at the end
         sta VRAM_Buffer1+10,x
         lda VRAM_Buffer1_Offset     ;add ten bytes to the vram buffer offset
         clc                         ;and store
         adc #10
         sta VRAM_Buffer1_Offset
ExitRp:  ldx ObjectOffset            ;get enemy object buffer offset and leave
         rts

SetupPlatformRope:
        pha                     ;save second/third copy to stack
        lda Enemy_X_Position,y  ;get horizontal coordinate
        clc
        adc #$08                ;add eight pixels
        ldx SecondaryHardMode   ;if secondary hard mode flag set,
        bne GetLRp              ;use coordinate as-is
        clc
        adc #$10                ;otherwise add sixteen more pixels
GetLRp: pha                     ;save modified horizontal coordinate to stack
        lda Enemy_PageLoc,y
        adc #$00                ;add carry to page location
        sta $02                 ;and save here
        pla                     ;pull modified horizontal coordinate
        and #%11110000          ;from the stack, mask out low nybble
        lsr                     ;and shift three bits to the right
        lsr
        lsr
        sta $00                 ;store result here as part of name table low byte
        ldx Enemy_Y_Position,y  ;get vertical coordinate
        pla                     ;get second/third copy of vertical speed from stack
        bpl GetHRp              ;skip this part if moving downwards or not at all
        txa
        clc
        adc #$08                ;add eight to vertical coordinate and
        tax                     ;save as X
GetHRp: txa                     ;move vertical coordinate to A
        ldx VRAM_Buffer1_Offset ;get vram buffer offset
        asl
        rol                     ;rotate d7 to d0 and d6 into carry
        pha                     ;save modified vertical coordinate to stack
        rol                     ;rotate carry to d0, thus d7 and d6 are at 2 LSB
        and #%00000011          ;mask out all bits but d7 and d6, then set
        ora #%00100000          ;d5 to get appropriate high byte of name table
        sta $01                 ;address, then store
        lda $02                 ;get saved page location from earlier
        and #$01                ;mask out all but LSB
        asl
        asl                     ;shift twice to the left and save with the
        ora $01                 ;rest of the bits of the high byte, to get
        sta $01                 ;the proper name table and the right place on it
        pla                     ;get modified vertical coordinate from stack
        and #%11100000          ;mask out low nybble and LSB of high nybble
        clc
        adc $00                 ;add to horizontal part saved here
        sta $00                 ;save as name table low byte
        lda Enemy_Y_Position,y
        cmp #$e8                ;if vertical position not below the
        bcc ExPRp               ;bottom of the screen, we're done, branch to leave
        lda $00
        and #%10111111          ;mask out d6 of low byte of name table address
        sta $00
ExPRp:  rts                     ;leave!

InitPlatformFall:
      tya                        ;move offset of other platform from Y to X
      tax
      jsr GetEnemyOffscreenBits  ;get offscreen bits
      lda #$06
      jsr SetupFloateyNumber     ;award 1000 points to player
      lda Player_Rel_XPos
      sta FloateyNum_X_Pos,x     ;put floatey number coordinates where player is
      lda Player_Y_Position
      sta FloateyNum_Y_Pos,x
      lda #$01                   ;set moving direction as flag for
      sta Enemy_MovingDir,x      ;falling platforms

StopPlatforms:
      jsr InitVStf             ;initialize vertical speed and low byte
      sta Enemy_Y_Speed,y      ;for both platforms and leave
      sta Enemy_Y_MoveForce,y
      rts

PlatformFall:
      tya                         ;save offset for other platform to stack
      pha
      jsr MoveFallingPlatform     ;make current platform fall
      pla
      tax                         ;pull offset from stack and save to X
      jsr MoveFallingPlatform     ;make other platform fall
      ldx ObjectOffset
      lda PlatformCollisionFlag,x ;if player not standing on either platform,
      bmi ExPF                    ;skip this part
      tax                         ;transfer collision flag offset as offset to X
      jsr PositionPlayerOnVPlat   ;and position player appropriately
ExPF: ldx ObjectOffset            ;get enemy object buffer offset and leave
      rts

;--------------------------------

YMovingPlatform:
        lda Enemy_Y_Speed,x          ;if platform moving up or down, skip ahead to
        ora Enemy_Y_MoveForce,x      ;check on other position
        bne ChkYCenterPos
        sta Enemy_YMF_Dummy,x        ;initialize dummy variable
        lda Enemy_Y_Position,x
        cmp YPlatformTopYPos,x       ;if current vertical position => top position, branch
        bcs ChkYCenterPos            ;ahead of all this
        lda FrameCounter
        and #%00000111               ;check for every eighth frame
        bne SkipIY
        inc Enemy_Y_Position,x       ;increase vertical position every eighth frame
SkipIY: jmp ChkYPCollision           ;skip ahead to last part

ChkYCenterPos:
        lda Enemy_Y_Position,x       ;if current vertical position < central position, branch
        cmp YPlatformCenterYPos,x    ;to slow ascent/move downwards
        bcc YMDown
        jsr MovePlatformUp           ;otherwise start slowing descent/moving upwards
        jmp ChkYPCollision
YMDown: jsr MovePlatformDown         ;start slowing ascent/moving downwards

ChkYPCollision:
       lda PlatformCollisionFlag,x  ;if collision flag not set here, branch
       bmi ExYPl                    ;to leave
       jsr PositionPlayerOnVPlat    ;otherwise position player appropriately
ExYPl: rts                          ;leave

;--------------------------------
;$00 - used as adder to position player hotizontally

XMovingPlatform:
      lda #$0e                     ;load preset maximum value for secondary counter
      jsr XMoveCntr_Platform       ;do a sub to increment counters for movement
      jsr MoveWithXMCntrs          ;do a sub to move platform accordingly, and return value
      lda PlatformCollisionFlag,x  ;if no collision with player,
      bmi ExXMP                    ;branch ahead to leave

PositionPlayerOnHPlat:
         lda Player_X_Position
         clc                       ;add saved value from second subroutine to
         adc $00                   ;current player's position to position
         sta Player_X_Position     ;player accordingly in horizontal position
         lda Player_PageLoc        ;get player's page location
         ldy $00                   ;check to see if saved value here is positive or negative
         bmi PPHSubt               ;if negative, branch to subtract
         adc #$00                  ;otherwise add carry to page location
         jmp SetPVar               ;jump to skip subtraction
PPHSubt: sbc #$00                  ;subtract borrow from page location
SetPVar: sta Player_PageLoc        ;save result to player's page location
         sty Platform_X_Scroll     ;put saved value from second sub here to be used later
         jsr PositionPlayerOnVPlat ;position player vertically and appropriately
ExXMP:   rts                       ;and we are done here

;--------------------------------

DropPlatform:
       lda PlatformCollisionFlag,x  ;if no collision between platform and player
       bmi ExDPl                    ;occurred, just leave without moving anything
       jsr MoveDropPlatform         ;otherwise do a sub to move platform down very quickly
       jsr PositionPlayerOnVPlat    ;do a sub to position player appropriately
ExDPl: rts                          ;leave

;--------------------------------
;$00 - residual value from sub

RightPlatform:
       jsr MoveEnemyHorizontally     ;move platform with current horizontal speed, if any
       sta $00                       ;store saved value here (residual code)
       lda PlatformCollisionFlag,x   ;check collision flag, if no collision between player
       bmi ExRPl                     ;and platform, branch ahead, leave speed unaltered
       lda #$10
       sta Enemy_X_Speed,x           ;otherwise set new speed (gets moving if motionless)
       jsr PositionPlayerOnHPlat     ;use saved value from earlier sub to position player
ExRPl: rts                           ;then leave

;--------------------------------

MoveLargeLiftPlat:
      jsr MoveLiftPlatforms  ;execute common to all large and small lift platforms
      jmp ChkYPCollision     ;branch to position player correctly

MoveSmallPlatform:
      jsr MoveLiftPlatforms      ;execute common to all large and small lift platforms
      jmp ChkSmallPlatCollision  ;branch to position player correctly

MoveLiftPlatforms:
      lda TimerControl         ;if master timer control set, skip all of this
      bne ExLiftP              ;and branch to leave
      lda Enemy_YMF_Dummy,x
      clc                      ;add contents of movement amount to whatever's here
      adc Enemy_Y_MoveForce,x
      sta Enemy_YMF_Dummy,x
      lda Enemy_Y_Position,x   ;add whatever vertical speed is set to current
      adc Enemy_Y_Speed,x      ;vertical position plus carry to move up or down
      sta Enemy_Y_Position,x   ;and then leave
      rts

ChkSmallPlatCollision:
         lda PlatformCollisionFlag,x ;get bounding box counter saved in collision flag
         beq ExLiftP                 ;if none found, leave player position alone
         jsr PositionPlayerOnS_Plat  ;use to position player correctly
ExLiftP: rts                         ;then leave

;-------------------------------------------------------------------------------------
;$00 - page location of extended left boundary
;$01 - extended left boundary position
;$02 - page location of extended right boundary
;$03 - extended right boundary position

OffscreenBoundsCheck:
          lda Enemy_ID,x          ;check for cheep-cheep object
          cmp #FlyingCheepCheep   ;branch to leave if found
          beq ExScrnBd
          lda ScreenLeft_X_Pos    ;get horizontal coordinate for left side of screen
          ldy Enemy_ID,x
          cpy #HammerBro          ;check for hammer bro object
          beq LimitB
          cpy #PiranhaPlant       ;check for piranha plant object
          bne ExtendLB            ;these two will be erased sooner than others if too far left
LimitB:   adc #$38                ;add 56 pixels to coordinate if hammer bro or piranha plant
ExtendLB: sbc #$48                ;subtract 72 pixels regardless of enemy object
          sta $01                 ;store result here
          lda ScreenLeft_PageLoc
          sbc #$00                ;subtract borrow from page location of left side
          sta $00                 ;store result here
          lda ScreenRight_X_Pos   ;add 72 pixels to the right side horizontal coordinate
          adc #$48
          sta $03                 ;store result here
          lda ScreenRight_PageLoc
          adc #$00                ;then add the carry to the page location
          sta $02                 ;and store result here
          lda Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
          cmp $01                 ;to modified horizontal left edge coordinate to get carry
          lda Enemy_PageLoc,x
          sbc $00                 ;then subtract it from the page coordinate of the enemy object
          bmi TooFar              ;if enemy object is too far left, branch to erase it
          lda Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
          cmp $03                 ;to modified horizontal right edge coordinate to get carry
          lda Enemy_PageLoc,x
          sbc $02                 ;then subtract it from the page coordinate of the enemy object
          bmi ExScrnBd            ;if enemy object is on the screen, leave, do not erase enemy
          lda Enemy_State,x       ;if at this point, enemy is offscreen to the right, so check
          cmp #HammerBro          ;if in state used by spiny's egg, do not erase
          beq ExScrnBd
          cpy #PiranhaPlant       ;if piranha plant, do not erase
          beq ExScrnBd
          cpy #FlagpoleFlagObject ;if flagpole flag, do not erase
          beq ExScrnBd
          cpy #StarFlagObject     ;if star flag, do not erase
          beq ExScrnBd
          cpy #JumpspringObject   ;if jumpspring, do not erase
          beq ExScrnBd            ;erase all others too far to the right
TooFar:   jsr EraseEnemyObject    ;erase object if necessary
ExScrnBd: rts                     ;leave

;-------------------------------------------------------------------------------------

;some unused space
      .db $ff, $ff, $ff

;-------------------------------------------------------------------------------------
;$01 - enemy buffer offset

FireballEnemyCollision:
      lda Fireball_State,x  ;check to see if fireball state is set at all
      beq ExitFBallEnemy    ;branch to leave if not
      asl
      bcs ExitFBallEnemy    ;branch to leave also if d7 in state is set
      lda FrameCounter
      lsr                   ;get LSB of frame counter
      bcs ExitFBallEnemy    ;branch to leave if set (do routine every other frame)
      txa
      asl                   ;multiply fireball offset by four
      asl
      clc
      adc #$1c              ;then add $1c or 28 bytes to it
      tay                   ;to use fireball's bounding box coordinates
      ldx #$04

FireballEnemyCDLoop:
           stx $01                     ;store enemy object offset here
           tya
           pha                         ;push fireball offset to the stack
           lda Enemy_State,x
           and #%00100000              ;check to see if d5 is set in enemy state
           bne NoFToECol               ;if so, skip to next enemy slot
           lda Enemy_Flag,x            ;check to see if buffer flag is set
           beq NoFToECol               ;if not, skip to next enemy slot
           lda Enemy_ID,x              ;check enemy identifier
           cmp #$24
           bcc GoombaDie               ;if < $24, branch to check further
           cmp #$2b
           bcc NoFToECol               ;if in range $24-$2a, skip to next enemy slot
GoombaDie: cmp #Goomba                 ;check for goomba identifier
           bne NotGoomba               ;if not found, continue with code
           lda Enemy_State,x           ;otherwise check for defeated state
           cmp #$02                    ;if stomped or otherwise defeated,
           bcs NoFToECol               ;skip to next enemy slot
NotGoomba: lda EnemyOffscrBitsMasked,x ;if any masked offscreen bits set,
           bne NoFToECol               ;skip to next enemy slot
           txa
           asl                         ;otherwise multiply enemy offset by four
           asl
           clc
           adc #$04                    ;add 4 bytes to it
           tax                         ;to use enemy's bounding box coordinates
           jsr SprObjectCollisionCore  ;do fireball-to-enemy collision detection
           ldx ObjectOffset            ;return fireball's original offset
           bcc NoFToECol               ;if carry clear, no collision, thus do next enemy slot
           lda #%10000000
           sta Fireball_State,x        ;set d7 in enemy state
           ldx $01                     ;get enemy offset
           jsr HandleEnemyFBallCol     ;jump to handle fireball to enemy collision
NoFToECol: pla                         ;pull fireball offset from stack
           tay                         ;put it in Y
           ldx $01                     ;get enemy object offset
           dex                         ;decrement it
           bpl FireballEnemyCDLoop     ;loop back until collision detection done on all enemies

ExitFBallEnemy:
      ldx ObjectOffset                 ;get original fireball offset and leave
      rts

BowserIdentities:
      .db Goomba, GreenKoopa, BuzzyBeetle, Spiny, Lakitu, Bloober, HammerBro, Bowser

HandleEnemyFBallCol:
      jsr RelativeEnemyPosition  ;get relative coordinate of enemy
      ldx $01                    ;get current enemy object offset
      lda Enemy_Flag,x           ;check buffer flag for d7 set
      bpl ChkBuzzyBeetle         ;branch if not set to continue
      and #%00001111             ;otherwise mask out high nybble and
      tax                        ;use low nybble as enemy offset
      lda Enemy_ID,x
      cmp #Bowser                ;check enemy identifier for bowser
      beq HurtBowser             ;branch if found
      ldx $01                    ;otherwise retrieve current enemy offset

ChkBuzzyBeetle:
      lda Enemy_ID,x
      cmp #BuzzyBeetle           ;check for buzzy beetle
      beq ExHCF                  ;branch if found to leave (buzzy beetles fireproof)
      cmp #Bowser                ;check for bowser one more time (necessary if d7 of flag was clear)
      bne ChkOtherEnemies        ;if not found, branch to check other enemies

HurtBowser:
          dec BowserHitPoints        ;decrement bowser's hit points
          bne ExHCF                  ;if bowser still has hit points, branch to leave
          jsr InitVStf               ;otherwise do sub to init vertical speed and movement force
          sta Enemy_X_Speed,x        ;initialize horizontal speed
          sta EnemyFrenzyBuffer      ;init enemy frenzy buffer
          lda #$fe
          sta Enemy_Y_Speed,x        ;set vertical speed to make defeated bowser jump a little
          ldy WorldNumber            ;use world number as offset
          lda BowserIdentities,y     ;get enemy identifier to replace bowser with
          sta Enemy_ID,x             ;set as new enemy identifier
          lda #$20                   ;set A to use starting value for state
          cpy #$03                   ;check to see if using offset of 3 or more
          bcs SetDBSte               ;branch if so
          ora #$03                   ;otherwise add 3 to enemy state
SetDBSte: sta Enemy_State,x          ;set defeated enemy state
          lda #Sfx_BowserFall
          sta Square2SoundQueue      ;load bowser defeat sound
          ldx $01                    ;get enemy offset
          lda #$09                   ;award 5000 points to player for defeating bowser
          bne EnemySmackScore        ;unconditional branch to award points

ChkOtherEnemies:
      cmp #BulletBill_FrenzyVar
      beq ExHCF                 ;branch to leave if bullet bill (frenzy variant)
      cmp #Podoboo
      beq ExHCF                 ;branch to leave if podoboo
      cmp #$15
      bcs ExHCF                 ;branch to leave if identifier => $15

ShellOrBlockDefeat:
      lda Enemy_ID,x            ;check for piranha plant
      cmp #PiranhaPlant
      bne StnE                  ;branch if not found
      lda Enemy_Y_Position,x
      adc #$18                  ;add 24 pixels to enemy object's vertical position
      sta Enemy_Y_Position,x
StnE: jsr ChkToStunEnemies      ;do yet another sub
      lda Enemy_State,x
      and #%00011111            ;mask out 2 MSB of enemy object's state
      ora #%00100000            ;set d5 to defeat enemy and save as new state
      sta Enemy_State,x
      lda #$02                  ;award 200 points by default
      ldy Enemy_ID,x            ;check for hammer bro
      cpy #HammerBro
      bne GoombaPoints          ;branch if not found
      lda #$06                  ;award 1000 points for hammer bro

GoombaPoints:
      cpy #Goomba               ;check for goomba
      bne EnemySmackScore       ;branch if not found
      lda #$01                  ;award 100 points for goomba

EnemySmackScore:
       jsr SetupFloateyNumber   ;update necessary score variables
       lda #Sfx_EnemySmack      ;play smack enemy sound
       sta Square1SoundQueue
ExHCF: rts                      ;and now let's leave

;-------------------------------------------------------------------------------------

PlayerHammerCollision:
        lda FrameCounter          ;get frame counter
        lsr                       ;shift d0 into carry
        bcc ExPHC                 ;branch to leave if d0 not set to execute every other frame
        lda TimerControl          ;if either master timer control
        ora Misc_OffscreenBits    ;or any offscreen bits for hammer are set,
        bne ExPHC                 ;branch to leave
        txa
        asl                       ;multiply misc object offset by four
        asl
        clc
        adc #$24                  ;add 36 or $24 bytes to get proper offset
        tay                       ;for misc object bounding box coordinates
        jsr PlayerCollisionCore   ;do player-to-hammer collision detection
        ldx ObjectOffset          ;get misc object offset
        bcc ClHCol                ;if no collision, then branch
        lda Misc_Collision_Flag,x ;otherwise read collision flag
        bne ExPHC                 ;if collision flag already set, branch to leave
        lda #$01
        sta Misc_Collision_Flag,x ;otherwise set collision flag now
        lda Misc_X_Speed,x
        eor #$ff                  ;get two's compliment of
        clc                       ;hammer's horizontal speed
        adc #$01
        sta Misc_X_Speed,x        ;set to send hammer flying the opposite direction
        lda StarInvincibleTimer   ;if star mario invincibility timer set,
        bne ExPHC                 ;branch to leave
        jmp InjurePlayer          ;otherwise jump to hurt player, do not return
ClHCol: lda #$00                  ;clear collision flag
        sta Misc_Collision_Flag,x
ExPHC:  rts

;-------------------------------------------------------------------------------------

HandlePowerUpCollision:
      jsr EraseEnemyObject    ;erase the power-up object
      lda #$06
      jsr SetupFloateyNumber  ;award 1000 points to player by default
      lda #Sfx_PowerUpGrab
      sta Square2SoundQueue   ;play the power-up sound
      lda PowerUpType         ;check power-up type
      cmp #$02
      bcc Shroom_Flower_PUp   ;if mushroom or fire flower, branch
      cmp #$03
      beq SetFor1Up           ;if 1-up mushroom, branch
      lda #$23                ;otherwise set star mario invincibility
      sta StarInvincibleTimer ;timer, and load the star mario music
      lda #StarPowerMusic     ;into the area music queue, then leave
      sta AreaMusicQueue
      rts

Shroom_Flower_PUp:
      lda PlayerStatus    ;if player status = small, branch
      beq UpToSuper
      cmp #$01            ;if player status not super, leave
      bne NoPUp
      ldx ObjectOffset    ;get enemy offset, not necessary
      lda #$02            ;set player status to fiery
      sta PlayerStatus
      jsr GetPlayerColors ;run sub to change colors of player
      ldx ObjectOffset    ;get enemy offset again, and again not necessary
      lda #$0c            ;set value to be used by subroutine tree (fiery)
      jmp UpToFiery       ;jump to set values accordingly

SetFor1Up:
      lda #$0b                 ;change 1000 points into 1-up instead
      sta FloateyNum_Control,x ;and then leave
      rts

UpToSuper:
       lda #$01         ;set player status to super
       sta PlayerStatus
       lda #$09         ;set value to be used by subroutine tree (super)

UpToFiery:
       ldy #$00         ;set value to be used as new player state
       jsr SetPRout     ;set values to stop certain things in motion
NoPUp: rts

;--------------------------------

ResidualXSpdData:
      .db $18, $e8

KickedShellXSpdData:
      .db $30, $d0

DemotedKoopaXSpdData:
      .db $08, $f8

PlayerEnemyCollision:
         lda FrameCounter            ;check counter for d0 set
         lsr
         bcs NoPUp                   ;if set, branch to leave
         jsr CheckPlayerVertical     ;if player object is completely offscreen or
         bcs NoPECol                 ;if down past 224th pixel row, branch to leave
         lda EnemyOffscrBitsMasked,x ;if current enemy is offscreen by any amount,
         bne NoPECol                 ;go ahead and branch to leave
         lda GameEngineSubroutine
         cmp #$08                    ;if not set to run player control routine
         bne NoPECol                 ;on next frame, branch to leave
         lda Enemy_State,x
         and #%00100000              ;if enemy state has d5 set, branch to leave
         bne NoPECol
         jsr GetEnemyBoundBoxOfs     ;get bounding box offset for current enemy object
         jsr PlayerCollisionCore     ;do collision detection on player vs. enemy
         ldx ObjectOffset            ;get enemy object buffer offset
         bcs CheckForPUpCollision    ;if collision, branch past this part here
         lda Enemy_CollisionBits,x
         and #%11111110              ;otherwise, clear d0 of current enemy object's
         sta Enemy_CollisionBits,x   ;collision bit
NoPECol: rts

CheckForPUpCollision:
       ldy Enemy_ID,x
       cpy #PowerUpObject            ;check for power-up object
       bne EColl                     ;if not found, branch to next part
       jmp HandlePowerUpCollision    ;otherwise, unconditional jump backwards
EColl: lda StarInvincibleTimer       ;if star mario invincibility timer expired,
       beq HandlePECollisions        ;perform task here, otherwise kill enemy like
       jmp ShellOrBlockDefeat        ;hit with a shell, or from beneath

KickedShellPtsData:
      .db $0a, $06, $04

HandlePECollisions:
       lda Enemy_CollisionBits,x    ;check enemy collision bits for d0 set
       and #%00000001               ;or for being offscreen at all
       ora EnemyOffscrBitsMasked,x
       bne ExPEC                    ;branch to leave if either is true
       lda #$01
       ora Enemy_CollisionBits,x    ;otherwise set d0 now
       sta Enemy_CollisionBits,x
       cpy #Spiny                   ;branch if spiny
       beq ChkForPlayerInjury
       cpy #PiranhaPlant            ;branch if piranha plant
       beq InjurePlayer
       cpy #Podoboo                 ;branch if podoboo
       beq InjurePlayer
       cpy #BulletBill_CannonVar    ;branch if bullet bill
       beq ChkForPlayerInjury
       cpy #$15                     ;branch if object => $15
       bcs InjurePlayer
       lda AreaType                 ;branch if water type level
       beq InjurePlayer
       lda Enemy_State,x            ;branch if d7 of enemy state was set
       asl
       bcs ChkForPlayerInjury
       lda Enemy_State,x            ;mask out all but 3 LSB of enemy state
       and #%00000111
       cmp #$02                     ;branch if enemy is in normal or falling state
       bcc ChkForPlayerInjury
       lda Enemy_ID,x               ;branch to leave if goomba in defeated state
       cmp #Goomba
       beq ExPEC
       lda #Sfx_EnemySmack          ;play smack enemy sound
       sta Square1SoundQueue
       lda Enemy_State,x            ;set d7 in enemy state, thus become moving shell
       ora #%10000000
       sta Enemy_State,x
       jsr EnemyFacePlayer          ;set moving direction and get offset
       lda KickedShellXSpdData,y    ;load and set horizontal speed data with offset
       sta Enemy_X_Speed,x
       lda #$03                     ;add three to whatever the stomp counter contains
       clc                          ;to give points for kicking the shell
       adc StompChainCounter
       ldy EnemyIntervalTimer,x     ;check shell enemy's timer
       cpy #$03                     ;if above a certain point, branch using the points
       bcs KSPts                    ;data obtained from the stomp counter + 3
       lda KickedShellPtsData,y     ;otherwise, set points based on proximity to timer expiration
KSPts: jsr SetupFloateyNumber       ;set values for floatey number now
ExPEC: rts                          ;leave!!!

ChkForPlayerInjury:
          lda Player_Y_Speed     ;check player's vertical speed
          bmi ChkInj             ;perform procedure below if player moving upwards
          bne EnemyStomped       ;or not at all, and branch elsewhere if moving downwards
ChkInj:   lda Enemy_ID,x         ;branch if enemy object < $07
          cmp #Bloober
          bcc ChkETmrs
          lda Player_Y_Position  ;add 12 pixels to player's vertical position
          clc
          adc #$0c
          cmp Enemy_Y_Position,x ;compare modified player's position to enemy's position
          bcc EnemyStomped       ;branch if this player's position above (less than) enemy's
ChkETmrs: lda StompTimer         ;check stomp timer
          bne EnemyStomped       ;branch if set
          lda InjuryTimer        ;check to see if injured invincibility timer still
          bne ExInjColRoutines   ;counting down, and branch elsewhere to leave if so
          lda Player_Rel_XPos
          cmp Enemy_Rel_XPos     ;if player's relative position to the left of enemy's
          bcc TInjE              ;relative position, branch here
          jmp ChkEnemyFaceRight  ;otherwise do a jump here
TInjE:    lda Enemy_MovingDir,x  ;if enemy moving towards the left,
          cmp #$01               ;branch, otherwise do a jump here
          bne InjurePlayer       ;to turn the enemy around
          jmp LInj

InjurePlayer:
      lda InjuryTimer          ;check again to see if injured invincibility timer is
      bne ExInjColRoutines     ;at zero, and branch to leave if so

ForceInjury:
          ldx PlayerStatus          ;check player's status
          beq KillPlayer            ;branch if small
          sta PlayerStatus          ;otherwise set player's status to small
          lda #$08
          sta InjuryTimer           ;set injured invincibility timer
          asl
          sta Square1SoundQueue     ;play pipedown/injury sound
          jsr GetPlayerColors       ;change player's palette if necessary
          lda #$0a                  ;set subroutine to run on next frame
SetKRout: ldy #$01                  ;set new player state
SetPRout: sta GameEngineSubroutine  ;load new value to run subroutine on next frame
          sty Player_State          ;store new player state
          ldy #$ff
          sty TimerControl          ;set master timer control flag to halt timers
          iny
          sty ScrollAmount          ;initialize scroll speed

ExInjColRoutines:
      ldx ObjectOffset              ;get enemy offset and leave
      rts

KillPlayer:
      stx Player_X_Speed   ;halt player's horizontal movement by initializing speed
      inx
      stx EventMusicQueue  ;set event music queue to death music
      lda #$fc
      sta Player_Y_Speed   ;set new vertical speed
      lda #$0b             ;set subroutine to run on next frame
      bne SetKRout         ;branch to set player's state and other things

StompedEnemyPtsData:
      .db $02, $06, $05, $06

EnemyStomped:
      lda Enemy_ID,x             ;check for spiny, branch to hurt player
      cmp #Spiny                 ;if found
      beq InjurePlayer
      lda #Sfx_EnemyStomp        ;otherwise play stomp/swim sound
      sta Square1SoundQueue
      lda Enemy_ID,x
      ldy #$00                   ;initialize points data offset for stomped enemies
      cmp #FlyingCheepCheep      ;branch for cheep-cheep
      beq EnemyStompedPts
      cmp #BulletBill_FrenzyVar  ;branch for either bullet bill object
      beq EnemyStompedPts
      cmp #BulletBill_CannonVar
      beq EnemyStompedPts
      cmp #Podoboo               ;branch for podoboo (this branch is logically impossible
      beq EnemyStompedPts        ;for cpu to take due to earlier checking of podoboo)
      iny                        ;increment points data offset
      cmp #HammerBro             ;branch for hammer bro
      beq EnemyStompedPts
      iny                        ;increment points data offset
      cmp #Lakitu                ;branch for lakitu
      beq EnemyStompedPts
      iny                        ;increment points data offset
      cmp #Bloober               ;branch if NOT bloober
      bne ChkForDemoteKoopa

EnemyStompedPts:
      lda StompedEnemyPtsData,y  ;load points data using offset in Y
      jsr SetupFloateyNumber     ;run sub to set floatey number controls
      lda Enemy_MovingDir,x
      pha                        ;save enemy movement direction to stack
      jsr SetStun                ;run sub to kill enemy
      pla
      sta Enemy_MovingDir,x      ;return enemy movement direction from stack
      lda #%00100000
      sta Enemy_State,x          ;set d5 in enemy state
      jsr InitVStf               ;nullify vertical speed, physics-related thing,
      sta Enemy_X_Speed,x        ;and horizontal speed
      lda #$fd                   ;set player's vertical speed, to give bounce
      sta Player_Y_Speed
      rts

ChkForDemoteKoopa:
      cmp #$09                   ;branch elsewhere if enemy object < $09
      bcc HandleStompedShellE
      and #%00000001             ;demote koopa paratroopas to ordinary troopas
      sta Enemy_ID,x
      ldy #$00                   ;return enemy to normal state
      sty Enemy_State,x
      lda #$03                   ;award 400 points to the player
      jsr SetupFloateyNumber
      jsr InitVStf               ;nullify physics-related thing and vertical speed
      jsr EnemyFacePlayer        ;turn enemy around if necessary
      lda DemotedKoopaXSpdData,y
      sta Enemy_X_Speed,x        ;set appropriate moving speed based on direction
      jmp SBnce                  ;then move onto something else

RevivalRateData:
      .db $10, $0b

HandleStompedShellE:
       lda #$04                   ;set defeated state for enemy
       sta Enemy_State,x
       inc StompChainCounter      ;increment the stomp counter
       lda StompChainCounter      ;add whatever is in the stomp counter
       clc                        ;to whatever is in the stomp timer
       adc StompTimer
       jsr SetupFloateyNumber     ;award points accordingly
       inc StompTimer             ;increment stomp timer of some sort
       ldy PrimaryHardMode        ;check primary hard mode flag
       lda RevivalRateData,y      ;load timer setting according to flag
       sta EnemyIntervalTimer,x   ;set as enemy timer to revive stomped enemy
SBnce: lda #$fc                   ;set player's vertical speed for bounce
       sta Player_Y_Speed         ;and then leave!!!
       rts

ChkEnemyFaceRight:
       lda Enemy_MovingDir,x ;check to see if enemy is moving to the right
       cmp #$01
       bne LInj              ;if not, branch
       jmp InjurePlayer      ;otherwise go back to hurt player
LInj:  jsr EnemyTurnAround   ;turn the enemy around, if necessary
       jmp InjurePlayer      ;go back to hurt player


EnemyFacePlayer:
       ldy #$01               ;set to move right by default
       jsr PlayerEnemyDiff    ;get horizontal difference between player and enemy
       bpl SFcRt              ;if enemy is to the right of player, do not increment
       iny                    ;otherwise, increment to set to move to the left
SFcRt: sty Enemy_MovingDir,x  ;set moving direction here
       dey                    ;then decrement to use as a proper offset
       rts

SetupFloateyNumber:
       sta FloateyNum_Control,x ;set number of points control for floatey numbers
       lda #$30
       sta FloateyNum_Timer,x   ;set timer for floatey numbers
       lda Enemy_Y_Position,x
       sta FloateyNum_Y_Pos,x   ;set vertical coordinate
       lda Enemy_Rel_XPos
       sta FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
ExSFN: rts

;-------------------------------------------------------------------------------------
;$01 - used to hold enemy offset for second enemy

SetBitsMask:
      .db %10000000, %01000000, %00100000, %00010000, %00001000, %00000100, %00000010

ClearBitsMask:
      .db %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101

EnemiesCollision:
        lda FrameCounter            ;check counter for d0 set
        lsr
        bcc ExSFN                   ;if d0 not set, leave
        lda AreaType
        beq ExSFN                   ;if water area type, leave
        lda Enemy_ID,x
        cmp #$15                    ;if enemy object => $15, branch to leave
        bcs ExitECRoutine
        cmp #Lakitu                 ;if lakitu, branch to leave
        beq ExitECRoutine
        cmp #PiranhaPlant           ;if piranha plant, branch to leave
        beq ExitECRoutine
        lda EnemyOffscrBitsMasked,x ;if masked offscreen bits nonzero, branch to leave
        bne ExitECRoutine
        jsr GetEnemyBoundBoxOfs     ;otherwise, do sub, get appropriate bounding box offset for
        dex                         ;first enemy we're going to compare, then decrement for second
        bmi ExitECRoutine           ;branch to leave if there are no other enemies
ECLoop: stx $01                     ;save enemy object buffer offset for second enemy here
        tya                         ;save first enemy's bounding box offset to stack
        pha
        lda Enemy_Flag,x            ;check enemy object enable flag
        beq ReadyNextEnemy          ;branch if flag not set
        lda Enemy_ID,x
        cmp #$15                    ;check for enemy object => $15
        bcs ReadyNextEnemy          ;branch if true
        cmp #Lakitu
        beq ReadyNextEnemy          ;branch if enemy object is lakitu
        cmp #PiranhaPlant
        beq ReadyNextEnemy          ;branch if enemy object is piranha plant
        lda EnemyOffscrBitsMasked,x
        bne ReadyNextEnemy          ;branch if masked offscreen bits set
        txa                         ;get second enemy object's bounding box offset
        asl                         ;multiply by four, then add four
        asl
        clc
        adc #$04
        tax                         ;use as new contents of X
        jsr SprObjectCollisionCore  ;do collision detection using the two enemies here
        ldx ObjectOffset            ;use first enemy offset for X
        ldy $01                     ;use second enemy offset for Y
        bcc NoEnemyCollision        ;if carry clear, no collision, branch ahead of this
        lda Enemy_State,x
        ora Enemy_State,y           ;check both enemy states for d7 set
        and #%10000000
        bne YesEC                   ;branch if at least one of them is set
        lda Enemy_CollisionBits,y   ;load first enemy's collision-related bits
        and SetBitsMask,x           ;check to see if bit connected to second enemy is
        bne ReadyNextEnemy          ;already set, and move onto next enemy slot if set
        lda Enemy_CollisionBits,y
        ora SetBitsMask,x           ;if the bit is not set, set it now
        sta Enemy_CollisionBits,y
YesEC:  jsr ProcEnemyCollisions     ;react according to the nature of collision
        jmp ReadyNextEnemy          ;move onto next enemy slot

NoEnemyCollision:
      lda Enemy_CollisionBits,y     ;load first enemy's collision-related bits
      and ClearBitsMask,x           ;clear bit connected to second enemy
      sta Enemy_CollisionBits,y     ;then move onto next enemy slot

ReadyNextEnemy:
      pla              ;get first enemy's bounding box offset from the stack
      tay              ;use as Y again
      ldx $01          ;get and decrement second enemy's object buffer offset
      dex
      bpl ECLoop       ;loop until all enemy slots have been checked

ExitECRoutine:
      ldx ObjectOffset ;get enemy object buffer offset
      rts              ;leave

ProcEnemyCollisions:
      lda Enemy_State,y        ;check both enemy states for d5 set
      ora Enemy_State,x
      and #%00100000           ;if d5 is set in either state, or both, branch
      bne ExitProcessEColl     ;to leave and do nothing else at this point
      lda Enemy_State,x
      cmp #$06                 ;if second enemy state < $06, branch elsewhere
      bcc ProcSecondEnemyColl
      lda Enemy_ID,x           ;check second enemy identifier for hammer bro
      cmp #HammerBro           ;if hammer bro found in alt state, branch to leave
      beq ExitProcessEColl
      lda Enemy_State,y        ;check first enemy state for d7 set
      asl
      bcc ShellCollisions      ;branch if d7 is clear
      lda #$06
      jsr SetupFloateyNumber   ;award 1000 points for killing enemy
      jsr ShellOrBlockDefeat   ;then kill enemy, then load
      ldy $01                  ;original offset of second enemy

ShellCollisions:
      tya                      ;move Y to X
      tax
      jsr ShellOrBlockDefeat   ;kill second enemy
      ldx ObjectOffset
      lda ShellChainCounter,x  ;get chain counter for shell
      clc
      adc #$04                 ;add four to get appropriate point offset
      ldx $01
      jsr SetupFloateyNumber   ;award appropriate number of points for second enemy
      ldx ObjectOffset         ;load original offset of first enemy
      inc ShellChainCounter,x  ;increment chain counter for additional enemies

ExitProcessEColl:
      rts                      ;leave!!!

ProcSecondEnemyColl:
      lda Enemy_State,y        ;if first enemy state < $06, branch elsewhere
      cmp #$06
      bcc MoveEOfs
      lda Enemy_ID,y           ;check first enemy identifier for hammer bro
      cmp #HammerBro           ;if hammer bro found in alt state, branch to leave
      beq ExitProcessEColl
      jsr ShellOrBlockDefeat   ;otherwise, kill first enemy
      ldy $01
      lda ShellChainCounter,y  ;get chain counter for shell
      clc
      adc #$04                 ;add four to get appropriate point offset
      ldx ObjectOffset
      jsr SetupFloateyNumber   ;award appropriate number of points for first enemy
      ldx $01                  ;load original offset of second enemy
      inc ShellChainCounter,x  ;increment chain counter for additional enemies
      rts                      ;leave!!!

MoveEOfs:
      tya                      ;move Y ($01) to X
      tax
      jsr EnemyTurnAround      ;do the sub here using value from $01
      ldx ObjectOffset         ;then do it again using value from $08

EnemyTurnAround:
       lda Enemy_ID,x           ;check for specific enemies
       cmp #PiranhaPlant
       beq ExTA                 ;if piranha plant, leave
       cmp #Lakitu
       beq ExTA                 ;if lakitu, leave
       cmp #HammerBro
       beq ExTA                 ;if hammer bro, leave
       cmp #Spiny
       beq RXSpd                ;if spiny, turn it around
       cmp #GreenParatroopaJump
       beq RXSpd                ;if green paratroopa, turn it around
       cmp #$07
       bcs ExTA                 ;if any OTHER enemy object => $07, leave
RXSpd: lda Enemy_X_Speed,x      ;load horizontal speed
       eor #$ff                 ;get two's compliment for horizontal speed
       tay
       iny
       sty Enemy_X_Speed,x      ;store as new horizontal speed
       lda Enemy_MovingDir,x
       eor #%00000011           ;invert moving direction and store, then leave
       sta Enemy_MovingDir,x    ;thus effectively turning the enemy around
ExTA:  rts                      ;leave!!!

;-------------------------------------------------------------------------------------
;$00 - vertical position of platform

LargePlatformCollision:
       lda #$ff                     ;save value here
       sta PlatformCollisionFlag,x
       lda TimerControl             ;check master timer control
       bne ExLPC                    ;if set, branch to leave
       lda Enemy_State,x            ;if d7 set in object state,
       bmi ExLPC                    ;branch to leave
       lda Enemy_ID,x
       cmp #$24                     ;check enemy object identifier for
       bne ChkForPlayerC_LargeP     ;balance platform, branch if not found
       lda Enemy_State,x
       tax                          ;set state as enemy offset here
       jsr ChkForPlayerC_LargeP     ;perform code with state offset, then original offset, in X

ChkForPlayerC_LargeP:
       jsr CheckPlayerVertical      ;figure out if player is below a certain point
       bcs ExLPC                    ;or offscreen, branch to leave if true
       txa
       jsr GetEnemyBoundBoxOfsArg   ;get bounding box offset in Y
       lda Enemy_Y_Position,x       ;store vertical coordinate in
       sta $00                      ;temp variable for now
       txa                          ;send offset we're on to the stack
       pha
       jsr PlayerCollisionCore      ;do player-to-platform collision detection
       pla                          ;retrieve offset from the stack
       tax
       bcc ExLPC                    ;if no collision, branch to leave
       jsr ProcLPlatCollisions      ;otherwise collision, perform sub
ExLPC: ldx ObjectOffset             ;get enemy object buffer offset and leave
       rts

;--------------------------------
;$00 - counter for bounding boxes

SmallPlatformCollision:
      lda TimerControl             ;if master timer control set,
      bne ExSPC                    ;branch to leave
      sta PlatformCollisionFlag,x  ;otherwise initialize collision flag
      jsr CheckPlayerVertical      ;do a sub to see if player is below a certain point
      bcs ExSPC                    ;or entirely offscreen, and branch to leave if true
      lda #$02
      sta $00                      ;load counter here for 2 bounding boxes

ChkSmallPlatLoop:
      ldx ObjectOffset           ;get enemy object offset
      jsr GetEnemyBoundBoxOfs    ;get bounding box offset in Y
      and #%00000010             ;if d1 of offscreen lower nybble bits was set
      bne ExSPC                  ;then branch to leave
      lda BoundingBox_UL_YPos,y  ;check top of platform's bounding box for being
      cmp #$20                   ;above a specific point
      bcc MoveBoundBox           ;if so, branch, don't do collision detection
      jsr PlayerCollisionCore    ;otherwise, perform player-to-platform collision detection
      bcs ProcSPlatCollisions    ;skip ahead if collision

MoveBoundBox:
       lda BoundingBox_UL_YPos,y  ;move bounding box vertical coordinates
       clc                        ;128 pixels downwards
       adc #$80
       sta BoundingBox_UL_YPos,y
       lda BoundingBox_DR_YPos,y
       clc
       adc #$80
       sta BoundingBox_DR_YPos,y
       dec $00                    ;decrement counter we set earlier
       bne ChkSmallPlatLoop       ;loop back until both bounding boxes are checked
ExSPC: ldx ObjectOffset           ;get enemy object buffer offset, then leave
       rts

;--------------------------------

ProcSPlatCollisions:
      ldx ObjectOffset             ;return enemy object buffer offset to X, then continue

ProcLPlatCollisions:
      lda BoundingBox_DR_YPos,y    ;get difference by subtracting the top
      sec                          ;of the player's bounding box from the bottom
      sbc BoundingBox_UL_YPos      ;of the platform's bounding box
      cmp #$04                     ;if difference too large or negative,
      bcs ChkForTopCollision       ;branch, do not alter vertical speed of player
      lda Player_Y_Speed           ;check to see if player's vertical speed is moving down
      bpl ChkForTopCollision       ;if so, don't mess with it
      lda #$01                     ;otherwise, set vertical
      sta Player_Y_Speed           ;speed of player to kill jump

ChkForTopCollision:
      lda BoundingBox_DR_YPos      ;get difference by subtracting the top
      sec                          ;of the platform's bounding box from the bottom
      sbc BoundingBox_UL_YPos,y    ;of the player's bounding box
      cmp #$06
      bcs PlatformSideCollisions   ;if difference not close enough, skip all of this
      lda Player_Y_Speed
      bmi PlatformSideCollisions   ;if player's vertical speed moving upwards, skip this
      lda $00                      ;get saved bounding box counter from earlier
      ldy Enemy_ID,x
      cpy #$2b                     ;if either of the two small platform objects are found,
      beq SetCollisionFlag         ;regardless of which one, branch to use bounding box counter
      cpy #$2c                     ;as contents of collision flag
      beq SetCollisionFlag
      txa                          ;otherwise use enemy object buffer offset

SetCollisionFlag:
      ldx ObjectOffset             ;get enemy object buffer offset
      sta PlatformCollisionFlag,x  ;save either bounding box counter or enemy offset here
      lda #$00
      sta Player_State             ;set player state to normal then leave
      rts

PlatformSideCollisions:
         lda #$01                   ;set value here to indicate possible horizontal
         sta $00                    ;collision on left side of platform
         lda BoundingBox_DR_XPos    ;get difference by subtracting platform's left edge
         sec                        ;from player's right edge
         sbc BoundingBox_UL_XPos,y
         cmp #$08                   ;if difference close enough, skip all of this
         bcc SideC
         inc $00                    ;otherwise increment value set here for right side collision
         lda BoundingBox_DR_XPos,y  ;get difference by subtracting player's left edge
         clc                        ;from platform's right edge
         sbc BoundingBox_UL_XPos
         cmp #$09                   ;if difference not close enough, skip subroutine
         bcs NoSideC                ;and instead branch to leave (no collision)
SideC:   jsr ImpedePlayerMove       ;deal with horizontal collision
NoSideC: ldx ObjectOffset           ;return with enemy object buffer offset
         rts

;-------------------------------------------------------------------------------------

PlayerPosSPlatData:
      .db $80, $00

PositionPlayerOnS_Plat:
      tay                        ;use bounding box counter saved in collision flag
      lda Enemy_Y_Position,x     ;for offset
      clc                        ;add positioning data using offset to the vertical
      adc PlayerPosSPlatData-1,y ;coordinate
      .db $2c                    ;BIT instruction opcode

PositionPlayerOnVPlat:
         lda Enemy_Y_Position,x    ;get vertical coordinate
         ldy GameEngineSubroutine
         cpy #$0b                  ;if certain routine being executed on this frame,
         beq ExPlPos               ;skip all of this
         ldy Enemy_Y_HighPos,x
         cpy #$01                  ;if vertical high byte offscreen, skip this
         bne ExPlPos
         sec                       ;subtract 32 pixels from vertical coordinate
         sbc #$20                  ;for the player object's height
         sta Player_Y_Position     ;save as player's new vertical coordinate
         tya
         sbc #$00                  ;subtract borrow and store as player's
         sta Player_Y_HighPos      ;new vertical high byte
         lda #$00
         sta Player_Y_Speed        ;initialize vertical speed and low byte of force
         sta Player_Y_MoveForce    ;and then leave
ExPlPos: rts

;-------------------------------------------------------------------------------------

CheckPlayerVertical:
       lda Player_OffscreenBits  ;if player object is completely offscreen
       cmp #$f0                  ;vertically, leave this routine
       bcs ExCPV
       ldy Player_Y_HighPos      ;if player high vertical byte is not
       dey                       ;within the screen, leave this routine
       bne ExCPV
       lda Player_Y_Position     ;if on the screen, check to see how far down
       cmp #$d0                  ;the player is vertically
ExCPV: rts

;-------------------------------------------------------------------------------------

GetEnemyBoundBoxOfs:
      lda ObjectOffset         ;get enemy object buffer offset

GetEnemyBoundBoxOfsArg:
      asl                      ;multiply A by four, then add four
      asl                      ;to skip player's bounding box
      clc
      adc #$04
      tay                      ;send to Y
      lda Enemy_OffscreenBits  ;get offscreen bits for enemy object
      and #%00001111           ;save low nybble
      cmp #%00001111           ;check for all bits set
      rts

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold many values, essentially temp variables
;$04 - holds lower nybble of vertical coordinate from block buffer routine
;$eb - used to hold block buffer adder

PlayerBGUpperExtent:
      .db $20, $10

PlayerBGCollision:
          lda DisableCollisionDet   ;if collision detection disabled flag set,
          bne ExPBGCol              ;branch to leave
          lda GameEngineSubroutine
          cmp #$0b                  ;if running routine #11 or $0b
          beq ExPBGCol              ;branch to leave
          cmp #$04
          bcc ExPBGCol              ;if running routines $00-$03 branch to leave
          lda #$01                  ;load default player state for swimming
          ldy SwimmingFlag          ;if swimming flag set,
          bne SetPSte               ;branch ahead to set default state
          lda Player_State          ;if player in normal state,
          beq SetFallS              ;branch to set default state for falling
          cmp #$03
          bne ChkOnScr              ;if in any other state besides climbing, skip to next part
SetFallS: lda #$02                  ;load default player state for falling
SetPSte:  sta Player_State          ;set whatever player state is appropriate
ChkOnScr: lda Player_Y_HighPos
          cmp #$01                  ;check player's vertical high byte for still on the screen
          bne ExPBGCol              ;branch to leave if not
          lda #$ff
          sta Player_CollisionBits  ;initialize player's collision flag
          lda Player_Y_Position
          cmp #$cf                  ;check player's vertical coordinate
          bcc ChkCollSize           ;if not too close to the bottom of screen, continue
ExPBGCol: rts                       ;otherwise leave

ChkCollSize:
         ldy #$02                    ;load default offset
         lda CrouchingFlag
         bne GBBAdr                  ;if player crouching, skip ahead
         lda PlayerSize
         bne GBBAdr                  ;if player small, skip ahead
         dey                         ;otherwise decrement offset for big player not crouching
         lda SwimmingFlag
         bne GBBAdr                  ;if swimming flag set, skip ahead
         dey                         ;otherwise decrement offset
GBBAdr:  lda BlockBufferAdderData,y  ;get value using offset
         sta $eb                     ;store value here
         tay                         ;put value into Y, as offset for block buffer routine
         ldx PlayerSize              ;get player's size as offset
         lda CrouchingFlag
         beq HeadChk                 ;if player not crouching, branch ahead
         inx                         ;otherwise increment size as offset
HeadChk: lda Player_Y_Position       ;get player's vertical coordinate
         cmp PlayerBGUpperExtent,x   ;compare with upper extent value based on offset
         bcc DoFootCheck             ;if player is too high, skip this part
         jsr BlockBufferColli_Head   ;do player-to-bg collision detection on top of
         beq DoFootCheck             ;player, and branch if nothing above player's head
         jsr CheckForCoinMTiles      ;check to see if player touched coin with their head
         bcs AwardTouchedCoin        ;if so, branch to some other part of code
         ldy Player_Y_Speed          ;check player's vertical speed
         bpl DoFootCheck             ;if player not moving upwards, branch elsewhere
         ldy $04                     ;check lower nybble of vertical coordinate returned
         cpy #$04                    ;from collision detection routine
         bcc DoFootCheck             ;if low nybble < 4, branch
         jsr CheckForSolidMTiles     ;check to see what player's head bumped on
         bcs SolidOrClimb            ;if player collided with solid metatile, branch
         ldy AreaType                ;otherwise check area type
         beq NYSpd                   ;if water level, branch ahead
         ldy BlockBounceTimer        ;if block bounce timer not expired,
         bne NYSpd                   ;branch ahead, do not process collision
         jsr PlayerHeadCollision     ;otherwise do a sub to process collision
         jmp DoFootCheck             ;jump ahead to skip these other parts here

SolidOrClimb:
       cmp #$26               ;if climbing metatile,
       beq NYSpd              ;branch ahead and do not play sound
       lda #Sfx_Bump
       sta Square1SoundQueue  ;otherwise load bump sound
NYSpd: lda #$01               ;set player's vertical speed to nullify
       sta Player_Y_Speed     ;jump or swim

DoFootCheck:
      ldy $eb                    ;get block buffer adder offset
      lda Player_Y_Position
      cmp #$cf                   ;check to see how low player is
      bcs DoPlayerSideCheck      ;if player is too far down on screen, skip all of this
      jsr BlockBufferColli_Feet  ;do player-to-bg collision detection on bottom left of player
      jsr CheckForCoinMTiles     ;check to see if player touched coin with their left foot
      bcs AwardTouchedCoin       ;if so, branch to some other part of code
      pha                        ;save bottom left metatile to stack
      jsr BlockBufferColli_Feet  ;do player-to-bg collision detection on bottom right of player
      sta $00                    ;save bottom right metatile here
      pla
      sta $01                    ;pull bottom left metatile and save here
      bne ChkFootMTile           ;if anything here, skip this part
      lda $00                    ;otherwise check for anything in bottom right metatile
      beq DoPlayerSideCheck      ;and skip ahead if not
      jsr CheckForCoinMTiles     ;check to see if player touched coin with their right foot
      bcc ChkFootMTile           ;if not, skip unconditional jump and continue code

AwardTouchedCoin:
      jmp HandleCoinMetatile     ;follow the code to erase coin and award to player 1 coin

ChkFootMTile:
          jsr CheckForClimbMTiles    ;check to see if player landed on climbable metatiles
          bcs DoPlayerSideCheck      ;if so, branch
          ldy Player_Y_Speed         ;check player's vertical speed
          bmi DoPlayerSideCheck      ;if player moving upwards, branch
          cmp #$c5
          bne ContChk                ;if player did not touch axe, skip ahead
          jmp HandleAxeMetatile      ;otherwise jump to set modes of operation
ContChk:  jsr ChkInvisibleMTiles     ;do sub to check for hidden coin or 1-up blocks
          beq DoPlayerSideCheck      ;if either found, branch
          ldy JumpspringAnimCtrl     ;if jumpspring animating right now,
          bne InitSteP               ;branch ahead
          ldy $04                    ;check lower nybble of vertical coordinate returned
          cpy #$05                   ;from collision detection routine
          bcc LandPlyr               ;if lower nybble < 5, branch
          lda Player_MovingDir
          sta $00                    ;use player's moving direction as temp variable
          jmp ImpedePlayerMove       ;jump to impede player's movement in that direction
LandPlyr: jsr ChkForLandJumpSpring   ;do sub to check for jumpspring metatiles and deal with it
          lda #$f0
          and Player_Y_Position      ;mask out lower nybble of player's vertical position
          sta Player_Y_Position      ;and store as new vertical position to land player properly
          jsr HandlePipeEntry        ;do sub to process potential pipe entry
          lda #$00
          sta Player_Y_Speed         ;initialize vertical speed and fractional
          sta Player_Y_MoveForce     ;movement force to stop player's vertical movement
          sta StompChainCounter      ;initialize enemy stomp counter
InitSteP: lda #$00
          sta Player_State           ;set player's state to normal

DoPlayerSideCheck:
      ldy $eb       ;get block buffer adder offset
      iny
      iny           ;increment offset 2 bytes to use adders for side collisions
      lda #$02      ;set value here to be used as counter
      sta $00

SideCheckLoop:
       iny                       ;move onto the next one
       sty $eb                   ;store it
       lda Player_Y_Position
       cmp #$20                  ;check player's vertical position
       bcc BHalf                 ;if player is in status bar area, branch ahead to skip this part
       cmp #$e4
       bcs ExSCH                 ;branch to leave if player is too far down
       jsr BlockBufferColli_Side ;do player-to-bg collision detection on one half of player
       beq BHalf                 ;branch ahead if nothing found
       cmp #$1c                  ;otherwise check for pipe metatiles
       beq BHalf                 ;if collided with sideways pipe (top), branch ahead
       cmp #$6b
       beq BHalf                 ;if collided with water pipe (top), branch ahead
       jsr CheckForClimbMTiles   ;do sub to see if player bumped into anything climbable
       bcc CheckSideMTiles       ;if not, branch to alternate section of code
BHalf: ldy $eb                   ;load block adder offset
       iny                       ;increment it
       lda Player_Y_Position     ;get player's vertical position
       cmp #$08
       bcc ExSCH                 ;if too high, branch to leave
       cmp #$d0
       bcs ExSCH                 ;if too low, branch to leave
       jsr BlockBufferColli_Side ;do player-to-bg collision detection on other half of player
       bne CheckSideMTiles       ;if something found, branch
       dec $00                   ;otherwise decrement counter
       bne SideCheckLoop         ;run code until both sides of player are checked
ExSCH: rts                       ;leave

CheckSideMTiles:
          jsr ChkInvisibleMTiles     ;check for hidden or coin 1-up blocks
          beq ExCSM                  ;branch to leave if either found
          jsr CheckForClimbMTiles    ;check for climbable metatiles
          bcc ContSChk               ;if not found, skip and continue with code
          jmp HandleClimbing         ;otherwise jump to handle climbing
ContSChk: jsr CheckForCoinMTiles     ;check to see if player touched coin
          bcs HandleCoinMetatile     ;if so, execute code to erase coin and award to player 1 coin
          jsr ChkJumpspringMetatiles ;check for jumpspring metatiles
          bcc ChkPBtm                ;if not found, branch ahead to continue cude
          lda JumpspringAnimCtrl     ;otherwise check jumpspring animation control
          bne ExCSM                  ;branch to leave if set
          jmp StopPlayerMove         ;otherwise jump to impede player's movement
ChkPBtm:  ldy Player_State           ;get player's state
          cpy #$00                   ;check for player's state set to normal
          bne StopPlayerMove         ;if not, branch to impede player's movement
          ldy PlayerFacingDir        ;get player's facing direction
          dey
          bne StopPlayerMove         ;if facing left, branch to impede movement
          cmp #$6c                   ;otherwise check for pipe metatiles
          beq PipeDwnS               ;if collided with sideways pipe (bottom), branch
          cmp #$1f                   ;if collided with water pipe (bottom), continue
          bne StopPlayerMove         ;otherwise branch to impede player's movement
PipeDwnS: lda Player_SprAttrib       ;check player's attributes
          bne PlyrPipe               ;if already set, branch, do not play sound again
          ldy #Sfx_PipeDown_Injury
          sty Square1SoundQueue      ;otherwise load pipedown/injury sound
PlyrPipe: ora #%00100000
          sta Player_SprAttrib       ;set background priority bit in player attributes
          lda Player_X_Position
          and #%00001111             ;get lower nybble of player's horizontal coordinate
          beq ChkGERtn               ;if at zero, branch ahead to skip this part
          ldy #$00                   ;set default offset for timer setting data
          lda ScreenLeft_PageLoc     ;load page location for left side of screen
          beq SetCATmr               ;if at page zero, use default offset
          iny                        ;otherwise increment offset
SetCATmr: lda AreaChangeTimerData,y  ;set timer for change of area as appropriate
          sta ChangeAreaTimer
ChkGERtn: lda GameEngineSubroutine   ;get number of game engine routine running
          cmp #$07
          beq ExCSM                  ;if running player entrance routine or
          cmp #$08                   ;player control routine, go ahead and branch to leave
          bne ExCSM
          lda #$02
          sta GameEngineSubroutine   ;otherwise set sideways pipe entry routine to run
          rts                        ;and leave

;--------------------------------
;$02 - high nybble of vertical coordinate from block buffer
;$04 - low nybble of horizontal coordinate from block buffer
;$06-$07 - block buffer address

StopPlayerMove:
       jsr ImpedePlayerMove      ;stop player's movement
ExCSM: rts                       ;leave

AreaChangeTimerData:
      .db $a0, $34

HandleCoinMetatile:
      jsr ErACM             ;do sub to erase coin metatile from block buffer
      inc CoinTallyFor1Ups  ;increment coin tally used for 1-up blocks
      jmp GiveOneCoin       ;update coin amount and tally on the screen

HandleAxeMetatile:
       lda #$00
       sta OperMode_Task   ;reset secondary mode
       lda #$02
       sta OperMode        ;set primary mode to autoctrl mode
       lda #$18
       sta Player_X_Speed  ;set horizontal speed and continue to erase axe metatile
ErACM: ldy $02             ;load vertical high nybble offset for block buffer
       lda #$00            ;load blank metatile
       sta ($06),y         ;store to remove old contents from block buffer
       jmp RemoveCoin_Axe  ;update the screen accordingly

;--------------------------------
;$02 - high nybble of vertical coordinate from block buffer
;$04 - low nybble of horizontal coordinate from block buffer
;$06-$07 - block buffer address

ClimbXPosAdder:
      .db $f9, $07

ClimbPLocAdder:
      .db $ff, $00

FlagpoleYPosData:
      .db $18, $22, $50, $68, $90

HandleClimbing:
      ldy $04            ;check low nybble of horizontal coordinate returned from
      cpy #$06           ;collision detection routine against certain values, this
      bcc ExHC           ;makes actual physical part of vine or flagpole thinner
      cpy #$0a           ;than 16 pixels
      bcc ChkForFlagpole
ExHC: rts                ;leave if too far left or too far right

ChkForFlagpole:
      cmp #$24               ;check climbing metatiles
      beq FlagpoleCollision  ;branch if flagpole ball found
      cmp #$25
      bne VineCollision      ;branch to alternate code if flagpole shaft not found

FlagpoleCollision:
      lda GameEngineSubroutine
      cmp #$05                  ;check for end-of-level routine running
      beq PutPlayerOnVine       ;if running, branch to end of climbing code
      lda #$01
      sta PlayerFacingDir       ;set player's facing direction to right
      inc ScrollLock            ;set scroll lock flag
      lda GameEngineSubroutine
      cmp #$04                  ;check for flagpole slide routine running
      beq RunFR                 ;if running, branch to end of flagpole code here
      lda #BulletBill_CannonVar ;load identifier for bullet bills (cannon variant)
      jsr KillEnemies           ;get rid of them
      lda #Silence
      sta EventMusicQueue       ;silence music
      lsr
      sta FlagpoleSoundQueue    ;load flagpole sound into flagpole sound queue
      ldx #$04                  ;start at end of vertical coordinate data
      lda Player_Y_Position
      sta FlagpoleCollisionYPos ;store player's vertical coordinate here to be used later

ChkFlagpoleYPosLoop:
       cmp FlagpoleYPosData,x    ;compare with current vertical coordinate data
       bcs MtchF                 ;if player's => current, branch to use current offset
       dex                       ;otherwise decrement offset to use
       bne ChkFlagpoleYPosLoop   ;do this until all data is checked (use last one if all checked)
MtchF: stx FlagpoleScore         ;store offset here to be used later
RunFR: lda #$04
       sta GameEngineSubroutine  ;set value to run flagpole slide routine
       jmp PutPlayerOnVine       ;jump to end of climbing code

VineCollision:
      cmp #$26                  ;check for climbing metatile used on vines
      bne PutPlayerOnVine
      lda Player_Y_Position     ;check player's vertical coordinate
      cmp #$20                  ;for being in status bar area
      bcs PutPlayerOnVine       ;branch if not that far up
      lda #$01
      sta GameEngineSubroutine  ;otherwise set to run autoclimb routine next frame

PutPlayerOnVine:
         lda #$03                ;set player state to climbing
         sta Player_State
         lda #$00                ;nullify player's horizontal speed
         sta Player_X_Speed      ;and fractional horizontal movement force
         sta Player_X_MoveForce
         lda Player_X_Position   ;get player's horizontal coordinate
         sec
         sbc ScreenLeft_X_Pos    ;subtract from left side horizontal coordinate
         cmp #$10
         bcs SetVXPl             ;if 16 or more pixels difference, do not alter facing direction
         lda #$02
         sta PlayerFacingDir     ;otherwise force player to face left
SetVXPl: ldy PlayerFacingDir     ;get current facing direction, use as offset
         lda $06                 ;get low byte of block buffer address
         asl
         asl                     ;move low nybble to high
         asl
         asl
         clc
         adc ClimbXPosAdder-1,y  ;add pixels depending on facing direction
         sta Player_X_Position   ;store as player's horizontal coordinate
         lda $06                 ;get low byte of block buffer address again
         bne ExPVne              ;if not zero, branch
         lda ScreenRight_PageLoc ;load page location of right side of screen
         clc
         adc ClimbPLocAdder-1,y  ;add depending on facing location
         sta Player_PageLoc      ;store as player's page location
ExPVne:  rts                     ;finally, we're done!

;--------------------------------

ChkInvisibleMTiles:
         cmp #$5f       ;check for hidden coin block
         beq ExCInvT    ;branch to leave if found
         cmp #$60       ;check for hidden 1-up block
ExCInvT: rts            ;leave with zero flag set if either found

;--------------------------------
;$00-$01 - used to hold bottom right and bottom left metatiles (in that order)
;$00 - used as flag by ImpedePlayerMove to restrict specific movement

ChkForLandJumpSpring:
        jsr ChkJumpspringMetatiles  ;do sub to check if player landed on jumpspring
        bcc ExCJSp                  ;if carry not set, jumpspring not found, therefore leave
        lda #$70
        sta VerticalForce           ;otherwise set vertical movement force for player
        lda #$f9
        sta JumpspringForce         ;set default jumpspring force
        lda #$03
        sta JumpspringTimer         ;set jumpspring timer to be used later
        lsr
        sta JumpspringAnimCtrl      ;set jumpspring animation control to start animating
ExCJSp: rts                         ;and leave

ChkJumpspringMetatiles:
         cmp #$67      ;check for top jumpspring metatile
         beq JSFnd     ;branch to set carry if found
         cmp #$68      ;check for bottom jumpspring metatile
         clc           ;clear carry flag
         bne NoJSFnd   ;branch to use cleared carry if not found
JSFnd:   sec           ;set carry if found
NoJSFnd: rts           ;leave

HandlePipeEntry:
         lda Up_Down_Buttons       ;check saved controller bits from earlier
         and #%00000100            ;for pressing down
         beq ExPipeE               ;if not pressing down, branch to leave
         lda $00
         cmp #$11                  ;check right foot metatile for warp pipe right metatile
         bne ExPipeE               ;branch to leave if not found
         lda $01
         cmp #$10                  ;check left foot metatile for warp pipe left metatile
         bne ExPipeE               ;branch to leave if not found
         lda #$30
         sta ChangeAreaTimer       ;set timer for change of area
         lda #$03
         sta GameEngineSubroutine  ;set to run vertical pipe entry routine on next frame
         lda #Sfx_PipeDown_Injury
         sta Square1SoundQueue     ;load pipedown/injury sound
         lda #%00100000
         sta Player_SprAttrib      ;set background priority bit in player's attributes
         lda WarpZoneControl       ;check warp zone control
         beq ExPipeE               ;branch to leave if none found
         and #%00000011            ;mask out all but 2 LSB
         asl
         asl                       ;multiply by four
         tax                       ;save as offset to warp zone numbers (starts at left pipe)
         lda Player_X_Position     ;get player's horizontal position
         cmp #$60
         bcc GetWNum               ;if player at left, not near middle, use offset and skip ahead
         inx                       ;otherwise increment for middle pipe
         cmp #$a0
         bcc GetWNum               ;if player at middle, but not too far right, use offset and skip
         inx                       ;otherwise increment for last pipe
GetWNum: ldy WarpZoneNumbers,x     ;get warp zone numbers
         dey                       ;decrement for use as world number
         sty WorldNumber           ;store as world number and offset
         ldx WorldAddrOffsets,y    ;get offset to where this world's area offsets are
         lda AreaAddrOffsets,x     ;get area offset based on world offset
         sta AreaPointer           ;store area offset here to be used to change areas
         lda #Silence
         sta EventMusicQueue       ;silence music
         lda #$00
         sta EntrancePage          ;initialize starting page number
         sta AreaNumber            ;initialize area number used for area address offset
         sta LevelNumber           ;initialize level number used for world display
         sta AltEntranceControl    ;initialize mode of entry
         inc Hidden1UpFlag         ;set flag for hidden 1-up blocks
         inc FetchNewGameTimerFlag ;set flag to load new game timer
ExPipeE: rts                       ;leave!!!

ImpedePlayerMove:
       lda #$00                  ;initialize value here
       ldy Player_X_Speed        ;get player's horizontal speed
       ldx $00                   ;check value set earlier for
       dex                       ;left side collision
       bne RImpd                 ;if right side collision, skip this part
       inx                       ;return value to X
       cpy #$00                  ;if player moving to the left,
       bmi ExIPM                 ;branch to invert bit and leave
       lda #$ff                  ;otherwise load A with value to be used later
       jmp NXSpd                 ;and jump to affect movement
RImpd: ldx #$02                  ;return $02 to X
       cpy #$01                  ;if player moving to the right,
       bpl ExIPM                 ;branch to invert bit and leave
       lda #$01                  ;otherwise load A with value to be used here
NXSpd: ldy #$10
       sty SideCollisionTimer    ;set timer of some sort
       ldy #$00
       sty Player_X_Speed        ;nullify player's horizontal speed
       cmp #$00                  ;if value set in A not set to $ff,
       bpl PlatF                 ;branch ahead, do not decrement Y
       dey                       ;otherwise decrement Y now
PlatF: sty $00                   ;store Y as high bits of horizontal adder
       clc
       adc Player_X_Position     ;add contents of A to player's horizontal
       sta Player_X_Position     ;position to move player left or right
       lda Player_PageLoc
       adc $00                   ;add high bits and carry to
       sta Player_PageLoc        ;page location if necessary
ExIPM: txa                       ;invert contents of X
       eor #$ff
       and Player_CollisionBits  ;mask out bit that was set here
       sta Player_CollisionBits  ;store to clear bit
       rts

;--------------------------------

SolidMTileUpperExt:
      .db $10, $61, $88, $c4

CheckForSolidMTiles:
      jsr GetMTileAttrib        ;find appropriate offset based on metatile's 2 MSB
      cmp SolidMTileUpperExt,x  ;compare current metatile with solid metatiles
      rts

ClimbMTileUpperExt:
      .db $24, $6d, $8a, $c6

CheckForClimbMTiles:
      jsr GetMTileAttrib        ;find appropriate offset based on metatile's 2 MSB
      cmp ClimbMTileUpperExt,x  ;compare current metatile with climbable metatiles
      rts

CheckForCoinMTiles:
         cmp #$c2              ;check for regular coin
         beq CoinSd            ;branch if found
         cmp #$c3              ;check for underwater coin
         beq CoinSd            ;branch if found
         clc                   ;otherwise clear carry and leave
         rts
CoinSd:  lda #Sfx_CoinGrab
         sta Square2SoundQueue ;load coin grab sound and leave
         rts

GetMTileAttrib:
       tay            ;save metatile value into Y
       and #%11000000 ;mask out all but 2 MSB
       asl
       rol            ;shift and rotate d7-d6 to d1-d0
       rol
       tax            ;use as offset for metatile data
       tya            ;get original metatile value back
ExEBG: rts            ;leave

;-------------------------------------------------------------------------------------
;$06-$07 - address from block buffer routine

EnemyBGCStateData:
      .db $01, $01, $02, $02, $02, $05

EnemyBGCXSpdData:
      .db $10, $f0

EnemyToBGCollisionDet:
      lda Enemy_State,x        ;check enemy state for d6 set
      and #%00100000
      bne ExEBG                ;if set, branch to leave
      jsr SubtEnemyYPos        ;otherwise, do a subroutine here
      bcc ExEBG                ;if enemy vertical coord + 62 < 68, branch to leave
      ldy Enemy_ID,x
      cpy #Spiny               ;if enemy object is not spiny, branch elsewhere
      bne DoIDCheckBGColl
      lda Enemy_Y_Position,x
      cmp #$25                 ;if enemy vertical coordinate < 36 branch to leave
      bcc ExEBG

DoIDCheckBGColl:
       cpy #GreenParatroopaJump ;check for some other enemy object
       bne HBChk                ;branch if not found
       jmp EnemyJump            ;otherwise jump elsewhere
HBChk: cpy #HammerBro           ;check for hammer bro
       bne CInvu                ;branch if not found
       jmp HammerBroBGColl      ;otherwise jump elsewhere
CInvu: cpy #Spiny               ;if enemy object is spiny, branch
       beq YesIn
       cpy #PowerUpObject       ;if special power-up object, branch
       beq YesIn
       cpy #$07                 ;if enemy object =>$07, branch to leave
       bcs ExEBGChk
YesIn: jsr ChkUnderEnemy        ;if enemy object < $07, or = $12 or $2e, do this sub
       bne HandleEToBGCollision ;if block underneath enemy, branch

NoEToBGCollision:
       jmp ChkForRedKoopa       ;otherwise skip and do something else

;--------------------------------
;$02 - vertical coordinate from block buffer routine

HandleEToBGCollision:
      jsr ChkForNonSolids       ;if something is underneath enemy, find out what
      beq NoEToBGCollision      ;if blank $26, coins, or hidden blocks, jump, enemy falls through
      cmp #$23
      bne LandEnemyProperly     ;check for blank metatile $23 and branch if not found
      ldy $02                   ;get vertical coordinate used to find block
      lda #$00                  ;store default blank metatile in that spot so we won't
      sta ($06),y               ;trigger this routine accidentally again
      lda Enemy_ID,x
      cmp #$15                  ;if enemy object => $15, branch ahead
      bcs ChkToStunEnemies
      cmp #Goomba               ;if enemy object not goomba, branch ahead of this routine
      bne GiveOEPoints
      jsr KillEnemyAboveBlock   ;if enemy object IS goomba, do this sub

GiveOEPoints:
      lda #$01                  ;award 100 points for hitting block beneath enemy
      jsr SetupFloateyNumber

ChkToStunEnemies:
          cmp #$09                   ;perform many comparisons on enemy object identifier
          bcc SetStun
          cmp #$11                   ;if the enemy object identifier is equal to the values
          bcs SetStun                ;$09, $0e, $0f or $10, it will be modified, and not
          cmp #$0a                   ;modified if not any of those values, note that piranha plant will
          bcc Demote                 ;always fail this test because A will still have vertical
          cmp #PiranhaPlant          ;coordinate from previous addition, also these comparisons
          bcc SetStun                ;are only necessary if branching from $d7a1
Demote:   and #%00000001             ;erase all but LSB, essentially turning enemy object
          sta Enemy_ID,x             ;into green or red koopa troopa to demote them
SetStun:  lda Enemy_State,x          ;load enemy state
          and #%11110000             ;save high nybble
          ora #%00000010
          sta Enemy_State,x          ;set d1 of enemy state
          dec Enemy_Y_Position,x
          dec Enemy_Y_Position,x     ;subtract two pixels from enemy's vertical position
          lda Enemy_ID,x
          cmp #Bloober               ;check for bloober object
          beq SetWYSpd
          lda #$fd                   ;set default vertical speed
          ldy AreaType
          bne SetNotW                ;if area type not water, set as speed, otherwise
SetWYSpd: lda #$ff                   ;change the vertical speed
SetNotW:  sta Enemy_Y_Speed,x        ;set vertical speed now
          ldy #$01
          jsr PlayerEnemyDiff        ;get horizontal difference between player and enemy object
          bpl ChkBBill               ;branch if enemy is to the right of player
          iny                        ;increment Y if not
ChkBBill: lda Enemy_ID,x
          cmp #BulletBill_CannonVar  ;check for bullet bill (cannon variant)
          beq NoCDirF
          cmp #BulletBill_FrenzyVar  ;check for bullet bill (frenzy variant)
          beq NoCDirF                ;branch if either found, direction does not change
          sty Enemy_MovingDir,x      ;store as moving direction
NoCDirF:  dey                        ;decrement and use as offset
          lda EnemyBGCXSpdData,y     ;get proper horizontal speed
          sta Enemy_X_Speed,x        ;and store, then leave
ExEBGChk: rts

;--------------------------------
;$04 - low nybble of vertical coordinate from block buffer routine

LandEnemyProperly:
       lda $04                 ;check lower nybble of vertical coordinate saved earlier
       sec
       sbc #$08                ;subtract eight pixels
       cmp #$05                ;used to determine whether enemy landed from falling
       bcs ChkForRedKoopa      ;branch if lower nybble in range of $0d-$0f before subtract
       lda Enemy_State,x
       and #%01000000          ;branch if d6 in enemy state is set
       bne LandEnemyInitState
       lda Enemy_State,x
       asl                     ;branch if d7 in enemy state is not set
       bcc ChkLandedEnemyState
SChkA: jmp DoEnemySideCheck    ;if lower nybble < $0d, d7 set but d6 not set, jump here

ChkLandedEnemyState:
           lda Enemy_State,x         ;if enemy in normal state, branch back to jump here
           beq SChkA
           cmp #$05                  ;if in state used by spiny's egg
           beq ProcEnemyDirection    ;then branch elsewhere
           cmp #$03                  ;if already in state used by koopas and buzzy beetles
           bcs ExSteChk              ;or in higher numbered state, branch to leave
           lda Enemy_State,x         ;load enemy state again (why?)
           cmp #$02                  ;if not in $02 state (used by koopas and buzzy beetles)
           bne ProcEnemyDirection    ;then branch elsewhere
           lda #$10                  ;load default timer here
           ldy Enemy_ID,x            ;check enemy identifier for spiny
           cpy #Spiny
           bne SetForStn             ;branch if not found
           lda #$00                  ;set timer for $00 if spiny
SetForStn: sta EnemyIntervalTimer,x  ;set timer here
           lda #$03                  ;set state here, apparently used to render
           sta Enemy_State,x         ;upside-down koopas and buzzy beetles
           jsr EnemyLanding          ;then land it properly
ExSteChk:  rts                       ;then leave

ProcEnemyDirection:
         lda Enemy_ID,x            ;check enemy identifier for goomba
         cmp #Goomba               ;branch if found
         beq LandEnemyInitState
         cmp #Spiny                ;check for spiny
         bne InvtD                 ;branch if not found
         lda #$01
         sta Enemy_MovingDir,x     ;send enemy moving to the right by default
         lda #$08
         sta Enemy_X_Speed,x       ;set horizontal speed accordingly
         lda FrameCounter
         and #%00000111            ;if timed appropriately, spiny will skip over
         beq LandEnemyInitState    ;trying to face the player
InvtD:   ldy #$01                  ;load 1 for enemy to face the left (inverted here)
         jsr PlayerEnemyDiff       ;get horizontal difference between player and enemy
         bpl CNwCDir               ;if enemy to the right of player, branch
         iny                       ;if to the left, increment by one for enemy to face right (inverted)
CNwCDir: tya
         cmp Enemy_MovingDir,x     ;compare direction in A with current direction in memory
         bne LandEnemyInitState
         jsr ChkForBump_HammerBroJ ;if equal, not facing in correct dir, do sub to turn around

LandEnemyInitState:
      jsr EnemyLanding       ;land enemy properly
      lda Enemy_State,x
      and #%10000000         ;if d7 of enemy state is set, branch
      bne NMovShellFallBit
      lda #$00               ;otherwise initialize enemy state and leave
      sta Enemy_State,x      ;note this will also turn spiny's egg into spiny
      rts

NMovShellFallBit:
      lda Enemy_State,x   ;nullify d6 of enemy state, save other bits
      and #%10111111      ;and store, then leave
      sta Enemy_State,x
      rts

;--------------------------------

ChkForRedKoopa:
             lda Enemy_ID,x            ;check for red koopa troopa $03
             cmp #RedKoopa
             bne Chk2MSBSt             ;branch if not found
             lda Enemy_State,x
             beq ChkForBump_HammerBroJ ;if enemy found and in normal state, branch
Chk2MSBSt:   lda Enemy_State,x         ;save enemy state into Y
             tay
             asl                       ;check for d7 set
             bcc GetSteFromD           ;branch if not set
             lda Enemy_State,x
             ora #%01000000            ;set d6
             jmp SetD6Ste              ;jump ahead of this part
GetSteFromD: lda EnemyBGCStateData,y   ;load new enemy state with old as offset
SetD6Ste:    sta Enemy_State,x         ;set as new state

;--------------------------------
;$00 - used to store bitmask (not used but initialized here)
;$eb - used in DoEnemySideCheck as counter and to compare moving directions

DoEnemySideCheck:
          lda Enemy_Y_Position,x     ;if enemy within status bar, branch to leave
          cmp #$20                   ;because there's nothing there that impedes movement
          bcc ExESdeC
          ldy #$16                   ;start by finding block to the left of enemy ($00,$14)
          lda #$02                   ;set value here in what is also used as
          sta $eb                    ;OAM data offset
SdeCLoop: lda $eb                    ;check value
          cmp Enemy_MovingDir,x      ;compare value against moving direction
          bne NextSdeC               ;branch if different and do not seek block there
          lda #$01                   ;set flag in A for save horizontal coordinate
          jsr BlockBufferChk_Enemy   ;find block to left or right of enemy object
          beq NextSdeC               ;if nothing found, branch
          jsr ChkForNonSolids        ;check for non-solid blocks
          bne ChkForBump_HammerBroJ  ;branch if not found
NextSdeC: dec $eb                    ;move to the next direction
          iny
          cpy #$18                   ;increment Y, loop only if Y < $18, thus we check
          bcc SdeCLoop               ;enemy ($00, $14) and ($10, $14) pixel coordinates
ExESdeC:  rts

ChkForBump_HammerBroJ:
        cpx #$05               ;check if we're on the special use slot
        beq NoBump             ;and if so, branch ahead and do not play sound
        lda Enemy_State,x      ;if enemy state d7 not set, branch
        asl                    ;ahead and do not play sound
        bcc NoBump
        lda #Sfx_Bump          ;otherwise, play bump sound
        sta Square1SoundQueue  ;sound will never be played if branching from ChkForRedKoopa
NoBump: lda Enemy_ID,x         ;check for hammer bro
        cmp #$05
        bne InvEnemyDir        ;branch if not found
        lda #$00
        sta $00                ;initialize value here for bitmask
        ldy #$fa               ;load default vertical speed for jumping
        jmp SetHJ              ;jump to code that makes hammer bro jump

InvEnemyDir:
      jmp RXSpd     ;jump to turn the enemy around

;--------------------------------
;$00 - used to hold horizontal difference between player and enemy

PlayerEnemyDiff:
      lda Enemy_X_Position,x  ;get distance between enemy object's
      sec                     ;horizontal coordinate and the player's
      sbc Player_X_Position   ;horizontal coordinate
      sta $00                 ;and store here
      lda Enemy_PageLoc,x
      sbc Player_PageLoc      ;subtract borrow, then leave
      rts

;--------------------------------

EnemyLanding:
      jsr InitVStf            ;do something here to vertical speed and something else
      lda Enemy_Y_Position,x
      and #%11110000          ;save high nybble of vertical coordinate, and
      ora #%00001000          ;set d3, then store, probably used to set enemy object
      sta Enemy_Y_Position,x  ;neatly on whatever it's landing on
      rts

SubtEnemyYPos:
      lda Enemy_Y_Position,x  ;add 62 pixels to enemy object's
      clc                     ;vertical coordinate
      adc #$3e
      cmp #$44                ;compare against a certain range
      rts                     ;and leave with flags set for conditional branch

EnemyJump:
        jsr SubtEnemyYPos     ;do a sub here
        bcc DoSide            ;if enemy vertical coord + 62 < 68, branch to leave
        lda Enemy_Y_Speed,x
        clc                   ;add two to vertical speed
        adc #$02
        cmp #$03              ;if green paratroopa not falling, branch ahead
        bcc DoSide
        jsr ChkUnderEnemy     ;otherwise, check to see if green paratroopa is
        beq DoSide            ;standing on anything, then branch to same place if not
        jsr ChkForNonSolids   ;check for non-solid blocks
        beq DoSide            ;branch if found
        jsr EnemyLanding      ;change vertical coordinate and speed
        lda #$fd
        sta Enemy_Y_Speed,x   ;make the paratroopa jump again
DoSide: jmp DoEnemySideCheck  ;check for horizontal blockage, then leave

;--------------------------------

HammerBroBGColl:
      jsr ChkUnderEnemy    ;check to see if hammer bro is standing on anything
      beq NoUnderHammerBro
      cmp #$23             ;check for blank metatile $23 and branch if not found
      bne UnderHammerBro

KillEnemyAboveBlock:
      jsr ShellOrBlockDefeat  ;do this sub to kill enemy
      lda #$fc                ;alter vertical speed of enemy and leave
      sta Enemy_Y_Speed,x
      rts

UnderHammerBro:
      lda EnemyFrameTimer,x ;check timer used by hammer bro
      bne NoUnderHammerBro  ;branch if not expired
      lda Enemy_State,x
      and #%10001000        ;save d7 and d3 from enemy state, nullify other bits
      sta Enemy_State,x     ;and store
      jsr EnemyLanding      ;modify vertical coordinate, speed and something else
      jmp DoEnemySideCheck  ;then check for horizontal blockage and leave

NoUnderHammerBro:
      lda Enemy_State,x  ;if hammer bro is not standing on anything, set d0
      ora #$01           ;in the enemy state to indicate jumping or falling, then leave
      sta Enemy_State,x
      rts

ChkUnderEnemy:
      lda #$00                  ;set flag in A for save vertical coordinate
      ldy #$15                  ;set Y to check the bottom middle (8,18) of enemy object
      jmp BlockBufferChk_Enemy  ;hop to it!

ChkForNonSolids:
       cmp #$26       ;blank metatile used for vines?
       beq NSFnd
       cmp #$c2       ;regular coin?
       beq NSFnd
       cmp #$c3       ;underwater coin?
       beq NSFnd
       cmp #$5f       ;hidden coin block?
       beq NSFnd
       cmp #$60       ;hidden 1-up block?
NSFnd: rts

;-------------------------------------------------------------------------------------

FireballBGCollision:
      lda Fireball_Y_Position,x   ;check fireball's vertical coordinate
      cmp #$18
      bcc ClearBounceFlag         ;if within the status bar area of the screen, branch ahead
      jsr BlockBufferChk_FBall    ;do fireball to background collision detection on bottom of it
      beq ClearBounceFlag         ;if nothing underneath fireball, branch
      jsr ChkForNonSolids         ;check for non-solid metatiles
      beq ClearBounceFlag         ;branch if any found
      lda Fireball_Y_Speed,x      ;if fireball's vertical speed set to move upwards,
      bmi InitFireballExplode     ;branch to set exploding bit in fireball's state
      lda FireballBouncingFlag,x  ;if bouncing flag already set,
      bne InitFireballExplode     ;branch to set exploding bit in fireball's state
      lda #$fd
      sta Fireball_Y_Speed,x      ;otherwise set vertical speed to move upwards (give it bounce)
      lda #$01
      sta FireballBouncingFlag,x  ;set bouncing flag
      lda Fireball_Y_Position,x
      and #$f8                    ;modify vertical coordinate to land it properly
      sta Fireball_Y_Position,x   ;store as new vertical coordinate
      rts                         ;leave

ClearBounceFlag:
      lda #$00
      sta FireballBouncingFlag,x  ;clear bouncing flag by default
      rts                         ;leave

InitFireballExplode:
      lda #$80
      sta Fireball_State,x        ;set exploding flag in fireball's state
      lda #Sfx_Bump
      sta Square1SoundQueue       ;load bump sound
      rts                         ;leave

;-------------------------------------------------------------------------------------
;$00 - used to hold one of bitmasks, or offset
;$01 - used for relative X coordinate, also used to store middle screen page location
;$02 - used for relative Y coordinate, also used to store middle screen coordinate

;this data added to relative coordinates of sprite objects
;stored in order: left edge, top edge, right edge, bottom edge
BoundBoxCtrlData:
      .db $02, $08, $0e, $20
      .db $03, $14, $0d, $20
      .db $02, $14, $0e, $20
      .db $02, $09, $0e, $15
      .db $00, $00, $18, $06
      .db $00, $00, $20, $0d
      .db $00, $00, $30, $0d
      .db $00, $00, $08, $08
      .db $06, $04, $0a, $08
      .db $03, $0e, $0d, $14
      .db $00, $02, $10, $15
      .db $04, $04, $0c, $1c

GetFireballBoundBox:
      txa         ;add seven bytes to offset
      clc         ;to use in routines as offset for fireball
      adc #$07
      tax
      ldy #$02    ;set offset for relative coordinates
      bne FBallB  ;unconditional branch

GetMiscBoundBox:
        txa                       ;add nine bytes to offset
        clc                       ;to use in routines as offset for misc object
        adc #$09
        tax
        ldy #$06                  ;set offset for relative coordinates
FBallB: jsr BoundingBoxCore       ;get bounding box coordinates
        jmp CheckRightScreenBBox  ;jump to handle any offscreen coordinates

GetEnemyBoundBox:
      ldy #$48                 ;store bitmask here for now
      sty $00
      ldy #$44                 ;store another bitmask here for now and jump
      jmp GetMaskedOffScrBits

SmallPlatformBoundBox:
      ldy #$08                 ;store bitmask here for now
      sty $00
      ldy #$04                 ;store another bitmask here for now

GetMaskedOffScrBits:
        lda Enemy_X_Position,x      ;get enemy object position relative
        sec                         ;to the left side of the screen
        sbc ScreenLeft_X_Pos
        sta $01                     ;store here
        lda Enemy_PageLoc,x         ;subtract borrow from current page location
        sbc ScreenLeft_PageLoc      ;of left side
        bmi CMBits                  ;if enemy object is beyond left edge, branch
        ora $01
        beq CMBits                  ;if precisely at the left edge, branch
        ldy $00                     ;if to the right of left edge, use value in $00 for A
CMBits: tya                         ;otherwise use contents of Y
        and Enemy_OffscreenBits     ;preserve bitwise whatever's in here
        sta EnemyOffscrBitsMasked,x ;save masked offscreen bits here
        bne MoveBoundBoxOffscreen   ;if anything set here, branch
        jmp SetupEOffsetFBBox       ;otherwise, do something else

LargePlatformBoundBox:
      inx                        ;increment X to get the proper offset
      jsr GetXOffscreenBits      ;then jump directly to the sub for horizontal offscreen bits
      dex                        ;decrement to return to original offset
      cmp #$fe                   ;if completely offscreen, branch to put entire bounding
      bcs MoveBoundBoxOffscreen  ;box offscreen, otherwise start getting coordinates

SetupEOffsetFBBox:
      txa                        ;add 1 to offset to properly address
      clc                        ;the enemy object memory locations
      adc #$01
      tax
      ldy #$01                   ;load 1 as offset here, same reason
      jsr BoundingBoxCore        ;do a sub to get the coordinates of the bounding box
      jmp CheckRightScreenBBox   ;jump to handle offscreen coordinates of bounding box

MoveBoundBoxOffscreen:
      txa                            ;multiply offset by 4
      asl
      asl
      tay                            ;use as offset here
      lda #$ff
      sta EnemyBoundingBoxCoord,y    ;load value into four locations here and leave
      sta EnemyBoundingBoxCoord+1,y
      sta EnemyBoundingBoxCoord+2,y
      sta EnemyBoundingBoxCoord+3,y
      rts

BoundingBoxCore:
      stx $00                     ;save offset here
      lda SprObject_Rel_YPos,y    ;store object coordinates relative to screen
      sta $02                     ;vertically and horizontally, respectively
      lda SprObject_Rel_XPos,y
      sta $01
      txa                         ;multiply offset by four and save to stack
      asl
      asl
      pha
      tay                         ;use as offset for Y, X is left alone
      lda SprObj_BoundBoxCtrl,x   ;load value here to be used as offset for X
      asl                         ;multiply that by four and use as X
      asl
      tax
      lda $01                     ;add the first number in the bounding box data to the
      clc                         ;relative horizontal coordinate using enemy object offset
      adc BoundBoxCtrlData,x      ;and store somewhere using same offset * 4
      sta BoundingBox_UL_Corner,y ;store here
      lda $01
      clc
      adc BoundBoxCtrlData+2,x    ;add the third number in the bounding box data to the
      sta BoundingBox_LR_Corner,y ;relative horizontal coordinate and store
      inx                         ;increment both offsets
      iny
      lda $02                     ;add the second number to the relative vertical coordinate
      clc                         ;using incremented offset and store using the other
      adc BoundBoxCtrlData,x      ;incremented offset
      sta BoundingBox_UL_Corner,y
      lda $02
      clc
      adc BoundBoxCtrlData+2,x    ;add the fourth number to the relative vertical coordinate
      sta BoundingBox_LR_Corner,y ;and store
      pla                         ;get original offset loaded into $00 * y from stack
      tay                         ;use as Y
      ldx $00                     ;get original offset and use as X again
      rts

CheckRightScreenBBox:
       lda ScreenLeft_X_Pos       ;add 128 pixels to left side of screen
       clc                        ;and store as horizontal coordinate of middle
       adc #$80
       sta $02
       lda ScreenLeft_PageLoc     ;add carry to page location of left side of screen
       adc #$00                   ;and store as page location of middle
       sta $01
       lda SprObject_X_Position,x ;get horizontal coordinate
       cmp $02                    ;compare against middle horizontal coordinate
       lda SprObject_PageLoc,x    ;get page location
       sbc $01                    ;subtract from middle page location
       bcc CheckLeftScreenBBox    ;if object is on the left side of the screen, branch
       lda BoundingBox_DR_XPos,y  ;check right-side edge of bounding box for offscreen
       bmi NoOfs                  ;coordinates, branch if still on the screen
       lda #$ff                   ;load offscreen value here to use on one or both horizontal sides
       ldx BoundingBox_UL_XPos,y  ;check left-side edge of bounding box for offscreen
       bmi SORte                  ;coordinates, and branch if still on the screen
       sta BoundingBox_UL_XPos,y  ;store offscreen value for left side
SORte: sta BoundingBox_DR_XPos,y  ;store offscreen value for right side
NoOfs: ldx ObjectOffset           ;get object offset and leave
       rts

CheckLeftScreenBBox:
        lda BoundingBox_UL_XPos,y  ;check left-side edge of bounding box for offscreen
        bpl NoOfs2                 ;coordinates, and branch if still on the screen
        cmp #$a0                   ;check to see if left-side edge is in the middle of the
        bcc NoOfs2                 ;screen or really offscreen, and branch if still on
        lda #$00
        ldx BoundingBox_DR_XPos,y  ;check right-side edge of bounding box for offscreen
        bpl SOLft                  ;coordinates, branch if still onscreen
        sta BoundingBox_DR_XPos,y  ;store offscreen value for right side
SOLft:  sta BoundingBox_UL_XPos,y  ;store offscreen value for left side
NoOfs2: ldx ObjectOffset           ;get object offset and leave
        rts

;-------------------------------------------------------------------------------------
;$06 - second object's offset
;$07 - counter

PlayerCollisionCore:
      ldx #$00     ;initialize X to use player's bounding box for comparison

SprObjectCollisionCore:
      sty $06      ;save contents of Y here
      lda #$01
      sta $07      ;save value 1 here as counter, compare horizontal coordinates first

CollisionCoreLoop:
      lda BoundingBox_UL_Corner,y  ;compare left/top coordinates
      cmp BoundingBox_UL_Corner,x  ;of first and second objects' bounding boxes
      bcs FirstBoxGreater          ;if first left/top => second, branch
      cmp BoundingBox_LR_Corner,x  ;otherwise compare to right/bottom of second
      bcc SecondBoxVerticalChk     ;if first left/top < second right/bottom, branch elsewhere
      beq CollisionFound           ;if somehow equal, collision, thus branch
      lda BoundingBox_LR_Corner,y  ;if somehow greater, check to see if bottom of
      cmp BoundingBox_UL_Corner,y  ;first object's bounding box is greater than its top
      bcc CollisionFound           ;if somehow less, vertical wrap collision, thus branch
      cmp BoundingBox_UL_Corner,x  ;otherwise compare bottom of first bounding box to the top
      bcs CollisionFound           ;of second box, and if equal or greater, collision, thus branch
      ldy $06                      ;otherwise return with carry clear and Y = $0006
      rts                          ;note horizontal wrapping never occurs

SecondBoxVerticalChk:
      lda BoundingBox_LR_Corner,x  ;check to see if the vertical bottom of the box
      cmp BoundingBox_UL_Corner,x  ;is greater than the vertical top
      bcc CollisionFound           ;if somehow less, vertical wrap collision, thus branch
      lda BoundingBox_LR_Corner,y  ;otherwise compare horizontal right or vertical bottom
      cmp BoundingBox_UL_Corner,x  ;of first box with horizontal left or vertical top of second box
      bcs CollisionFound           ;if equal or greater, collision, thus branch
      ldy $06                      ;otherwise return with carry clear and Y = $0006
      rts

FirstBoxGreater:
      cmp BoundingBox_UL_Corner,x  ;compare first and second box horizontal left/vertical top again
      beq CollisionFound           ;if first coordinate = second, collision, thus branch
      cmp BoundingBox_LR_Corner,x  ;if not, compare with second object right or bottom edge
      bcc CollisionFound           ;if left/top of first less than or equal to right/bottom of second
      beq CollisionFound           ;then collision, thus branch
      cmp BoundingBox_LR_Corner,y  ;otherwise check to see if top of first box is greater than bottom
      bcc NoCollisionFound         ;if less than or equal, no collision, branch to end
      beq NoCollisionFound
      lda BoundingBox_LR_Corner,y  ;otherwise compare bottom of first to top of second
      cmp BoundingBox_UL_Corner,x  ;if bottom of first is greater than top of second, vertical wrap
      bcs CollisionFound           ;collision, and branch, otherwise, proceed onwards here

NoCollisionFound:
      clc          ;clear carry, then load value set earlier, then leave
      ldy $06      ;like previous ones, if horizontal coordinates do not collide, we do
      rts          ;not bother checking vertical ones, because what's the point?

CollisionFound:
      inx                    ;increment offsets on both objects to check
      iny                    ;the vertical coordinates
      dec $07                ;decrement counter to reflect this
      bpl CollisionCoreLoop  ;if counter not expired, branch to loop
      sec                    ;otherwise we already did both sets, therefore collision, so set carry
      ldy $06                ;load original value set here earlier, then leave
      rts

;-------------------------------------------------------------------------------------
;$02 - modified y coordinate
;$03 - stores metatile involved in block buffer collisions
;$04 - comes in with offset to block buffer adder data, goes out with low nybble x/y coordinate
;$05 - modified x coordinate
;$06-$07 - block buffer address

BlockBufferChk_Enemy:
      pha        ;save contents of A to stack
      txa
      clc        ;add 1 to X to run sub with enemy offset in mind
      adc #$01
      tax
      pla        ;pull A from stack and jump elsewhere
      jmp BBChk_E

ResidualMiscObjectCode:
      txa
      clc           ;supposedly used once to set offset for
      adc #$0d      ;miscellaneous objects
      tax
      ldy #$1b      ;supposedly used once to set offset for block buffer data
      jmp ResJmpM   ;probably used in early stages to do misc to bg collision detection

BlockBufferChk_FBall:
         ldy #$1a                  ;set offset for block buffer adder data
         txa
         clc
         adc #$07                  ;add seven bytes to use
         tax
ResJmpM: lda #$00                  ;set A to return vertical coordinate
BBChk_E: jsr BlockBufferCollision  ;do collision detection subroutine for sprite object
         ldx ObjectOffset          ;get object offset
         cmp #$00                  ;check to see if object bumped into anything
         rts

BlockBufferAdderData:
      .db $00, $07, $0e

BlockBuffer_X_Adder:
      .db $08, $03, $0c, $02, $02, $0d, $0d, $08
      .db $03, $0c, $02, $02, $0d, $0d, $08, $03
      .db $0c, $02, $02, $0d, $0d, $08, $00, $10
      .db $04, $14, $04, $04

BlockBuffer_Y_Adder:
      .db $04, $20, $20, $08, $18, $08, $18, $02
      .db $20, $20, $08, $18, $08, $18, $12, $20
      .db $20, $18, $18, $18, $18, $18, $14, $14
      .db $06, $06, $08, $10

BlockBufferColli_Feet:
       iny            ;if branched here, increment to next set of adders

BlockBufferColli_Head:
       lda #$00       ;set flag to return vertical coordinate
       .db $2c        ;BIT instruction opcode

BlockBufferColli_Side:
       lda #$01       ;set flag to return horizontal coordinate
       ldx #$00       ;set offset for player object

BlockBufferCollision:
       pha                         ;save contents of A to stack
       sty $04                     ;save contents of Y here
       lda BlockBuffer_X_Adder,y   ;add horizontal coordinate
       clc                         ;of object to value obtained using Y as offset
       adc SprObject_X_Position,x
       sta $05                     ;store here
       lda SprObject_PageLoc,x
       adc #$00                    ;add carry to page location
       and #$01                    ;get LSB, mask out all other bits
       lsr                         ;move to carry
       ora $05                     ;get stored value
       ror                         ;rotate carry to MSB of A
       lsr                         ;and effectively move high nybble to
       lsr                         ;lower, LSB which became MSB will be
       lsr                         ;d4 at this point
       jsr GetBlockBufferAddr      ;get address of block buffer into $06, $07
       ldy $04                     ;get old contents of Y
       lda SprObject_Y_Position,x  ;get vertical coordinate of object
       clc
       adc BlockBuffer_Y_Adder,y   ;add it to value obtained using Y as offset
       and #%11110000              ;mask out low nybble
       sec
       sbc #$20                    ;subtract 32 pixels for the status bar
       sta $02                     ;store result here
       tay                         ;use as offset for block buffer
       lda ($06),y                 ;check current content of block buffer
       sta $03                     ;and store here
       ldy $04                     ;get old contents of Y again
       pla                         ;pull A from stack
       bne RetXC                   ;if A = 1, branch
       lda SprObject_Y_Position,x  ;if A = 0, load vertical coordinate
       jmp RetYC                   ;and jump
RetXC: lda SprObject_X_Position,x  ;otherwise load horizontal coordinate
RetYC: and #%00001111              ;and mask out high nybble
       sta $04                     ;store masked out result here
       lda $03                     ;get saved content of block buffer
       rts                         ;and leave

;-------------------------------------------------------------------------------------

;unused byte
      .db $ff

;-------------------------------------------------------------------------------------
;$00 - offset to vine Y coordinate adder
;$02 - offset to sprite data

VineYPosAdder:
      .db $00, $30

DrawVine:
         sty $00                    ;save offset here
         lda Enemy_Rel_YPos         ;get relative vertical coordinate
         clc
         adc VineYPosAdder,y        ;add value using offset in Y to get value
         ldx VineObjOffset,y        ;get offset to vine
         ldy Enemy_SprDataOffset,x  ;get sprite data offset
         sty $02                    ;store sprite data offset here
         jsr SixSpriteStacker       ;stack six sprites on top of each other vertically
         lda Enemy_Rel_XPos         ;get relative horizontal coordinate
         sta Sprite_X_Position,y    ;store in first, third and fifth sprites
         sta Sprite_X_Position+8,y
         sta Sprite_X_Position+16,y
         clc
         adc #$06                   ;add six pixels to second, fourth and sixth sprites
         sta Sprite_X_Position+4,y  ;to give characteristic staggered vine shape to
         sta Sprite_X_Position+12,y ;our vertical stack of sprites
         sta Sprite_X_Position+20,y
         lda #%00100001             ;set bg priority and palette attribute bits
         sta Sprite_Attributes,y    ;set in first, third and fifth sprites
         sta Sprite_Attributes+8,y
         sta Sprite_Attributes+16,y
         ora #%01000000             ;additionally, set horizontal flip bit
         sta Sprite_Attributes+4,y  ;for second, fourth and sixth sprites
         sta Sprite_Attributes+12,y
         sta Sprite_Attributes+20,y
         ldx #$05                   ;set tiles for six sprites
VineTL:  lda #$e1                   ;set tile number for sprite
         sta Sprite_Tilenumber,y
         iny                        ;move offset to next sprite data
         iny
         iny
         iny
         dex                        ;move onto next sprite
         bpl VineTL                 ;loop until all sprites are done
         ldy $02                    ;get original offset
         lda $00                    ;get offset to vine adding data
         bne SkpVTop                ;if offset not zero, skip this part
         lda #$e0
         sta Sprite_Tilenumber,y    ;set other tile number for top of vine
SkpVTop: ldx #$00                   ;start with the first sprite again
ChkFTop: lda VineStart_Y_Position   ;get original starting vertical coordinate
         sec
         sbc Sprite_Y_Position,y    ;subtract top-most sprite's Y coordinate
         cmp #$64                   ;if two coordinates are less than 100/$64 pixels
         bcc NextVSp                ;apart, skip this to leave sprite alone
         lda #$f8
         sta Sprite_Y_Position,y    ;otherwise move sprite offscreen
NextVSp: iny                        ;move offset to next OAM data
         iny
         iny
         iny
         inx                        ;move onto next sprite
         cpx #$06                   ;do this until all sprites are checked
         bne ChkFTop
         ldy $00                    ;return offset set earlier
         rts

SixSpriteStacker:
       ldx #$06           ;do six sprites
StkLp: sta Sprite_Data,y  ;store X or Y coordinate into OAM data
       clc
       adc #$08           ;add eight pixels
       iny
       iny                ;move offset four bytes forward
       iny
       iny
       dex                ;do another sprite
       bne StkLp          ;do this until all sprites are done
       ldy $02            ;get saved OAM data offset and leave
       rts

;-------------------------------------------------------------------------------------

FirstSprXPos:
      .db $04, $00, $04, $00

FirstSprYPos:
      .db $00, $04, $00, $04

SecondSprXPos:
      .db $00, $08, $00, $08

SecondSprYPos:
      .db $08, $00, $08, $00

FirstSprTilenum:
      .db $80, $82, $81, $83

SecondSprTilenum:
      .db $81, $83, $80, $82

HammerSprAttrib:
      .db $03, $03, $c3, $c3

DrawHammer:
            ldy Misc_SprDataOffset,x    ;get misc object OAM data offset
            lda TimerControl
            bne ForceHPose              ;if master timer control set, skip this part
            lda Misc_State,x            ;otherwise get hammer's state
            and #%01111111              ;mask out d7
            cmp #$01                    ;check to see if set to 1 yet
            beq GetHPose                ;if so, branch
ForceHPose: ldx #$00                    ;reset offset here
            beq RenderH                 ;do unconditional branch to rendering part
GetHPose:   lda FrameCounter            ;get frame counter
            lsr                         ;move d3-d2 to d1-d0
            lsr
            and #%00000011              ;mask out all but d1-d0 (changes every four frames)
            tax                         ;use as timing offset
RenderH:    lda Misc_Rel_YPos           ;get relative vertical coordinate
            clc
            adc FirstSprYPos,x          ;add first sprite vertical adder based on offset
            sta Sprite_Y_Position,y     ;store as sprite Y coordinate for first sprite
            clc
            adc SecondSprYPos,x         ;add second sprite vertical adder based on offset
            sta Sprite_Y_Position+4,y   ;store as sprite Y coordinate for second sprite
            lda Misc_Rel_XPos           ;get relative horizontal coordinate
            clc
            adc FirstSprXPos,x          ;add first sprite horizontal adder based on offset
            sta Sprite_X_Position,y     ;store as sprite X coordinate for first sprite
            clc
            adc SecondSprXPos,x         ;add second sprite horizontal adder based on offset
            sta Sprite_X_Position+4,y   ;store as sprite X coordinate for second sprite
            lda FirstSprTilenum,x
            sta Sprite_Tilenumber,y     ;get and store tile number of first sprite
            lda SecondSprTilenum,x
            sta Sprite_Tilenumber+4,y   ;get and store tile number of second sprite
            lda HammerSprAttrib,x
            sta Sprite_Attributes,y     ;get and store attribute bytes for both
            sta Sprite_Attributes+4,y   ;note in this case they use the same data
            ldx ObjectOffset            ;get misc object offset
            lda Misc_OffscreenBits
            and #%11111100              ;check offscreen bits
            beq NoHOffscr               ;if all bits clear, leave object alone
            lda #$00
            sta Misc_State,x            ;otherwise nullify misc object state
            lda #$f8
            jsr DumpTwoSpr              ;do sub to move hammer sprites offscreen
NoHOffscr:  rts                         ;leave

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold tile numbers ($01 addressed in draw floatey number part)
;$02 - used to hold Y coordinate for floatey number
;$03 - residual byte used for flip (but value set here affects nothing)
;$04 - attribute byte for floatey number
;$05 - used as X coordinate for floatey number

FlagpoleScoreNumTiles:
      .db $f9, $50
      .db $f7, $50
      .db $fa, $fb
      .db $f8, $fb
      .db $f6, $fb

FlagpoleGfxHandler:
      ldy Enemy_SprDataOffset,x      ;get sprite data offset for flagpole flag
      lda Enemy_Rel_XPos             ;get relative horizontal coordinate
      sta Sprite_X_Position,y        ;store as X coordinate for first sprite
      clc
      adc #$08                       ;add eight pixels and store
      sta Sprite_X_Position+4,y      ;as X coordinate for second and third sprites
      sta Sprite_X_Position+8,y
      clc
      adc #$0c                       ;add twelve more pixels and
      sta $05                        ;store here to be used later by floatey number
      lda Enemy_Y_Position,x         ;get vertical coordinate
      jsr DumpTwoSpr                 ;and do sub to dump into first and second sprites
      adc #$08                       ;add eight pixels
      sta Sprite_Y_Position+8,y      ;and store into third sprite
      lda FlagpoleFNum_Y_Pos         ;get vertical coordinate for floatey number
      sta $02                        ;store it here
      lda #$01
      sta $03                        ;set value for flip which will not be used, and
      sta $04                        ;attribute byte for floatey number
      sta Sprite_Attributes,y        ;set attribute bytes for all three sprites
      sta Sprite_Attributes+4,y
      sta Sprite_Attributes+8,y
      lda #$7e
      sta Sprite_Tilenumber,y        ;put triangle shaped tile
      sta Sprite_Tilenumber+8,y      ;into first and third sprites
      lda #$7f
      sta Sprite_Tilenumber+4,y      ;put skull tile into second sprite
      lda FlagpoleCollisionYPos      ;get vertical coordinate at time of collision
      beq ChkFlagOffscreen           ;if zero, branch ahead
      tya
      clc                            ;add 12 bytes to sprite data offset
      adc #$0c
      tay                            ;put back in Y
      lda FlagpoleScore              ;get offset used to award points for touching flagpole
      asl                            ;multiply by 2 to get proper offset here
      tax
      lda FlagpoleScoreNumTiles,x    ;get appropriate tile data
      sta $00
      lda FlagpoleScoreNumTiles+1,x
      jsr DrawOneSpriteRow           ;use it to render floatey number

ChkFlagOffscreen:
      ldx ObjectOffset               ;get object offset for flag
      ldy Enemy_SprDataOffset,x      ;get OAM data offset
      lda Enemy_OffscreenBits        ;get offscreen bits
      and #%00001110                 ;mask out all but d3-d1
      beq ExitDumpSpr                ;if none of these bits set, branch to leave

;-------------------------------------------------------------------------------------

MoveSixSpritesOffscreen:
      lda #$f8                  ;set offscreen coordinate if jumping here

DumpSixSpr:
      sta Sprite_Data+20,y      ;dump A contents
      sta Sprite_Data+16,y      ;into third row sprites

DumpFourSpr:
      sta Sprite_Data+12,y      ;into second row sprites

DumpThreeSpr:
      sta Sprite_Data+8,y

DumpTwoSpr:
      sta Sprite_Data+4,y       ;and into first row sprites
      sta Sprite_Data,y

ExitDumpSpr:
      rts

;-------------------------------------------------------------------------------------

DrawLargePlatform:
      ldy Enemy_SprDataOffset,x   ;get OAM data offset
      sty $02                     ;store here
      iny                         ;add 3 to it for offset
      iny                         ;to X coordinate
      iny
      lda Enemy_Rel_XPos          ;get horizontal relative coordinate
      jsr SixSpriteStacker        ;store X coordinates using A as base, stack horizontally
      ldx ObjectOffset
      lda Enemy_Y_Position,x      ;get vertical coordinate
      jsr DumpFourSpr             ;dump into first four sprites as Y coordinate
      ldy AreaType
      cpy #$03                    ;check for castle-type level
      beq ShrinkPlatform
      ldy SecondaryHardMode       ;check for secondary hard mode flag set
      beq SetLast2Platform        ;branch if not set elsewhere

ShrinkPlatform:
      lda #$f8                    ;load offscreen coordinate if flag set or castle-type level

SetLast2Platform:
      ldy Enemy_SprDataOffset,x   ;get OAM data offset
      sta Sprite_Y_Position+16,y  ;store vertical coordinate or offscreen
      sta Sprite_Y_Position+20,y  ;coordinate into last two sprites as Y coordinate
      lda #$5b                    ;load default tile for platform (girder)
      ldx CloudTypeOverride
      beq SetPlatformTilenum      ;if cloud level override flag not set, use
      lda #$75                    ;otherwise load other tile for platform (puff)

SetPlatformTilenum:
        ldx ObjectOffset            ;get enemy object buffer offset
        iny                         ;increment Y for tile offset
        jsr DumpSixSpr              ;dump tile number into all six sprites
        lda #$02                    ;set palette controls
        iny                         ;increment Y for sprite attributes
        jsr DumpSixSpr              ;dump attributes into all six sprites
        inx                         ;increment X for enemy objects
        jsr GetXOffscreenBits       ;get offscreen bits again
        dex
        ldy Enemy_SprDataOffset,x   ;get OAM data offset
        asl                         ;rotate d7 into carry, save remaining
        pha                         ;bits to the stack
        bcc SChk2
        lda #$f8                    ;if d7 was set, move first sprite offscreen
        sta Sprite_Y_Position,y
SChk2:  pla                         ;get bits from stack
        asl                         ;rotate d6 into carry
        pha                         ;save to stack
        bcc SChk3
        lda #$f8                    ;if d6 was set, move second sprite offscreen
        sta Sprite_Y_Position+4,y
SChk3:  pla                         ;get bits from stack
        asl                         ;rotate d5 into carry
        pha                         ;save to stack
        bcc SChk4
        lda #$f8                    ;if d5 was set, move third sprite offscreen
        sta Sprite_Y_Position+8,y
SChk4:  pla                         ;get bits from stack
        asl                         ;rotate d4 into carry
        pha                         ;save to stack
        bcc SChk5
        lda #$f8                    ;if d4 was set, move fourth sprite offscreen
        sta Sprite_Y_Position+12,y
SChk5:  pla                         ;get bits from stack
        asl                         ;rotate d3 into carry
        pha                         ;save to stack
        bcc SChk6
        lda #$f8                    ;if d3 was set, move fifth sprite offscreen
        sta Sprite_Y_Position+16,y
SChk6:  pla                         ;get bits from stack
        asl                         ;rotate d2 into carry
        bcc SLChk                   ;save to stack
        lda #$f8
        sta Sprite_Y_Position+20,y  ;if d2 was set, move sixth sprite offscreen
SLChk:  lda Enemy_OffscreenBits     ;check d7 of offscreen bits
        asl                         ;and if d7 is not set, skip sub
        bcc ExDLPl
        jsr MoveSixSpritesOffscreen ;otherwise branch to move all sprites offscreen
ExDLPl: rts

;-------------------------------------------------------------------------------------

DrawFloateyNumber_Coin:
          lda FrameCounter          ;get frame counter
          lsr                       ;divide by 2
          bcs NotRsNum              ;branch if d0 not set to raise number every other frame
          dec Misc_Y_Position,x     ;otherwise, decrement vertical coordinate
NotRsNum: lda Misc_Y_Position,x     ;get vertical coordinate
          jsr DumpTwoSpr            ;dump into both sprites
          lda Misc_Rel_XPos         ;get relative horizontal coordinate
          sta Sprite_X_Position,y   ;store as X coordinate for first sprite
          clc
          adc #$08                  ;add eight pixels
          sta Sprite_X_Position+4,y ;store as X coordinate for second sprite
          lda #$02
          sta Sprite_Attributes,y   ;store attribute byte in both sprites
          sta Sprite_Attributes+4,y
          lda #$f7
          sta Sprite_Tilenumber,y   ;put tile numbers into both sprites
          lda #$fb                  ;that resemble "200"
          sta Sprite_Tilenumber+4,y
          jmp ExJCGfx               ;then jump to leave (why not an rts here instead?)

JumpingCoinTiles:
      .db $60, $61, $62, $63

JCoinGfxHandler:
         ldy Misc_SprDataOffset,x    ;get coin/floatey number's OAM data offset
         lda Misc_State,x            ;get state of misc object
         cmp #$02                    ;if 2 or greater,
         bcs DrawFloateyNumber_Coin  ;branch to draw floatey number
         lda Misc_Y_Position,x       ;store vertical coordinate as
         sta Sprite_Y_Position,y     ;Y coordinate for first sprite
         clc
         adc #$08                    ;add eight pixels
         sta Sprite_Y_Position+4,y   ;store as Y coordinate for second sprite
         lda Misc_Rel_XPos           ;get relative horizontal coordinate
         sta Sprite_X_Position,y
         sta Sprite_X_Position+4,y   ;store as X coordinate for first and second sprites
         lda FrameCounter            ;get frame counter
         lsr                         ;divide by 2 to alter every other frame
         and #%00000011              ;mask out d2-d1
         tax                         ;use as graphical offset
         lda JumpingCoinTiles,x      ;load tile number
         iny                         ;increment OAM data offset to write tile numbers
         jsr DumpTwoSpr              ;do sub to dump tile number into both sprites
         dey                         ;decrement to get old offset
         lda #$02
         sta Sprite_Attributes,y     ;set attribute byte in first sprite
         lda #$82
         sta Sprite_Attributes+4,y   ;set attribute byte with vertical flip in second sprite
         ldx ObjectOffset            ;get misc object offset
ExJCGfx: rts                         ;leave

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold tiles for drawing the power-up, $00 also used to hold power-up type
;$02 - used to hold bottom row Y position
;$03 - used to hold flip control (not used here)
;$04 - used to hold sprite attributes
;$05 - used to hold X position
;$07 - counter

;tiles arranged in top left, right, bottom left, right order
PowerUpGfxTable:
      .db $76, $77, $78, $79 ;regular mushroom
      .db $d6, $d6, $d9, $d9 ;fire flower
      .db $8d, $8d, $e4, $e4 ;star
      .db $76, $77, $78, $79 ;1-up mushroom

PowerUpAttributes:
      .db $02, $01, $02, $01

DrawPowerUp:
      ldy Enemy_SprDataOffset+5  ;get power-up's sprite data offset
      lda Enemy_Rel_YPos         ;get relative vertical coordinate
      clc
      adc #$08                   ;add eight pixels
      sta $02                    ;store result here
      lda Enemy_Rel_XPos         ;get relative horizontal coordinate
      sta $05                    ;store here
      ldx PowerUpType            ;get power-up type
      lda PowerUpAttributes,x    ;get attribute data for power-up type
      ora Enemy_SprAttrib+5      ;add background priority bit if set
      sta $04                    ;store attributes here
      txa
      pha                        ;save power-up type to the stack
      asl
      asl                        ;multiply by four to get proper offset
      tax                        ;use as X
      lda #$01
      sta $07                    ;set counter here to draw two rows of sprite object
      sta $03                    ;init d1 of flip control

PUpDrawLoop:
        lda PowerUpGfxTable,x      ;load left tile of power-up object
        sta $00
        lda PowerUpGfxTable+1,x    ;load right tile
        jsr DrawOneSpriteRow       ;branch to draw one row of our power-up object
        dec $07                    ;decrement counter
        bpl PUpDrawLoop            ;branch until two rows are drawn
        ldy Enemy_SprDataOffset+5  ;get sprite data offset again
        pla                        ;pull saved power-up type from the stack
        beq PUpOfs                 ;if regular mushroom, branch, do not change colors or flip
        cmp #$03
        beq PUpOfs                 ;if 1-up mushroom, branch, do not change colors or flip
        sta $00                    ;store power-up type here now
        lda FrameCounter           ;get frame counter
        lsr                        ;divide by 2 to change colors every two frames
        and #%00000011             ;mask out all but d1 and d0 (previously d2 and d1)
        ora Enemy_SprAttrib+5      ;add background priority bit if any set
        sta Sprite_Attributes,y    ;set as new palette bits for top left and
        sta Sprite_Attributes+4,y  ;top right sprites for fire flower and star
        ldx $00
        dex                        ;check power-up type for fire flower
        beq FlipPUpRightSide       ;if found, skip this part
        sta Sprite_Attributes+8,y  ;otherwise set new palette bits  for bottom left
        sta Sprite_Attributes+12,y ;and bottom right sprites as well for star only

FlipPUpRightSide:
        lda Sprite_Attributes+4,y
        ora #%01000000             ;set horizontal flip bit for top right sprite
        sta Sprite_Attributes+4,y
        lda Sprite_Attributes+12,y
        ora #%01000000             ;set horizontal flip bit for bottom right sprite
        sta Sprite_Attributes+12,y ;note these are only done for fire flower and star power-ups
PUpOfs: jmp SprObjectOffscrChk     ;jump to check to see if power-up is offscreen at all, then leave

;-------------------------------------------------------------------------------------
;$00-$01 - used in DrawEnemyObjRow to hold sprite tile numbers
;$02 - used to store Y position
;$03 - used to store moving direction, used to flip enemies horizontally
;$04 - used to store enemy's sprite attributes
;$05 - used to store X position
;$eb - used to hold sprite data offset
;$ec - used to hold either altered enemy state or special value used in gfx handler as condition
;$ed - used to hold enemy state from buffer
;$ef - used to hold enemy code used in gfx handler (may or may not resemble Enemy_ID values)

;tiles arranged in top left, right, middle left, right, bottom left, right order
EnemyGraphicsTable:
      .db $fc, $fc, $aa, $ab, $ac, $ad  ;buzzy beetle frame 1
      .db $fc, $fc, $ae, $af, $b0, $b1  ;             frame 2
      .db $fc, $a5, $a6, $a7, $a8, $a9  ;koopa troopa frame 1
      .db $fc, $a0, $a1, $a2, $a3, $a4  ;             frame 2
      .db $69, $a5, $6a, $a7, $a8, $a9  ;koopa paratroopa frame 1
      .db $6b, $a0, $6c, $a2, $a3, $a4  ;                 frame 2
      .db $fc, $fc, $96, $97, $98, $99  ;spiny frame 1
      .db $fc, $fc, $9a, $9b, $9c, $9d  ;      frame 2
      .db $fc, $fc, $8f, $8e, $8e, $8f  ;spiny's egg frame 1
      .db $fc, $fc, $95, $94, $94, $95  ;            frame 2
      .db $fc, $fc, $dc, $dc, $df, $df  ;bloober frame 1
      .db $dc, $dc, $dd, $dd, $de, $de  ;        frame 2
      .db $fc, $fc, $b2, $b3, $b4, $b5  ;cheep-cheep frame 1
      .db $fc, $fc, $b6, $b3, $b7, $b5  ;            frame 2
      .db $fc, $fc, $70, $71, $72, $73  ;goomba
      .db $fc, $fc, $6e, $6e, $6f, $6f  ;koopa shell frame 1 (upside-down)
      .db $fc, $fc, $6d, $6d, $6f, $6f  ;            frame 2
      .db $fc, $fc, $6f, $6f, $6e, $6e  ;koopa shell frame 1 (rightsideup)
      .db $fc, $fc, $6f, $6f, $6d, $6d  ;            frame 2
      .db $fc, $fc, $f4, $f4, $f5, $f5  ;buzzy beetle shell frame 1 (rightsideup)
      .db $fc, $fc, $f4, $f4, $f5, $f5  ;                   frame 2
      .db $fc, $fc, $f5, $f5, $f4, $f4  ;buzzy beetle shell frame 1 (upside-down)
      .db $fc, $fc, $f5, $f5, $f4, $f4  ;                   frame 2
      .db $fc, $fc, $fc, $fc, $ef, $ef  ;defeated goomba
      .db $b9, $b8, $bb, $ba, $bc, $bc  ;lakitu frame 1
      .db $fc, $fc, $bd, $bd, $bc, $bc  ;       frame 2
      .db $7a, $7b, $da, $db, $d8, $d8  ;princess
      .db $cd, $cd, $ce, $ce, $cf, $cf  ;mushroom retainer
      .db $7d, $7c, $d1, $8c, $d3, $d2  ;hammer bro frame 1
      .db $7d, $7c, $89, $88, $8b, $8a  ;           frame 2
      .db $d5, $d4, $e3, $e2, $d3, $d2  ;           frame 3
      .db $d5, $d4, $e3, $e2, $8b, $8a  ;           frame 4
      .db $e5, $e5, $e6, $e6, $eb, $eb  ;piranha plant frame 1
      .db $ec, $ec, $ed, $ed, $ee, $ee  ;              frame 2
      .db $fc, $fc, $d0, $d0, $d7, $d7  ;podoboo
      .db $bf, $be, $c1, $c0, $c2, $fc  ;bowser front frame 1
      .db $c4, $c3, $c6, $c5, $c8, $c7  ;bowser rear frame 1
      .db $bf, $be, $ca, $c9, $c2, $fc  ;       front frame 2
      .db $c4, $c3, $c6, $c5, $cc, $cb  ;       rear frame 2
      .db $fc, $fc, $e8, $e7, $ea, $e9  ;bullet bill
      .db $f2, $f2, $f3, $f3, $f2, $f2  ;jumpspring frame 1
      .db $f1, $f1, $f1, $f1, $fc, $fc  ;           frame 2
      .db $f0, $f0, $fc, $fc, $fc, $fc  ;           frame 3

EnemyGfxTableOffsets:
      .db $0c, $0c, $00, $0c, $0c, $a8, $54, $3c
      .db $ea, $18, $48, $48, $cc, $c0, $18, $18
      .db $18, $90, $24, $ff, $48, $9c, $d2, $d8
      .db $f0, $f6, $fc

EnemyAttributeData:
      .db $01, $02, $03, $02, $01, $01, $03, $03
      .db $03, $01, $01, $02, $02, $21, $01, $02
      .db $01, $01, $02, $ff, $02, $02, $01, $01
      .db $02, $02, $02

EnemyAnimTimingBMask:
      .db $08, $18

JumpspringFrameOffsets:
      .db $18, $19, $1a, $19, $18

EnemyGfxHandler:
      lda Enemy_Y_Position,x      ;get enemy object vertical position
      sta $02
      lda Enemy_Rel_XPos          ;get enemy object horizontal position
      sta $05                     ;relative to screen
      ldy Enemy_SprDataOffset,x
      sty $eb                     ;get sprite data offset
      lda #$00
      sta VerticalFlipFlag        ;initialize vertical flip flag by default
      lda Enemy_MovingDir,x
      sta $03                     ;get enemy object moving direction
      lda Enemy_SprAttrib,x
      sta $04                     ;get enemy object sprite attributes
      lda Enemy_ID,x
      cmp #PiranhaPlant           ;is enemy object piranha plant?
      bne CheckForRetainerObj     ;if not, branch
      ldy PiranhaPlant_Y_Speed,x
      bmi CheckForRetainerObj     ;if piranha plant moving upwards, branch
      ldy EnemyFrameTimer,x
      beq CheckForRetainerObj     ;if timer for movement expired, branch
      rts                         ;if all conditions fail, leave

CheckForRetainerObj:
      lda Enemy_State,x           ;store enemy state
      sta $ed
      and #%00011111              ;nullify all but 5 LSB and use as Y
      tay
      lda Enemy_ID,x              ;check for mushroom retainer/princess object
      cmp #RetainerObject
      bne CheckForBulletBillCV    ;if not found, branch
      ldy #$00                    ;if found, nullify saved state in Y
      lda #$01                    ;set value that will not be used
      sta $03
      lda #$15                    ;set value $15 as code for mushroom retainer/princess object

CheckForBulletBillCV:
       cmp #BulletBill_CannonVar   ;otherwise check for bullet bill object
       bne CheckForJumpspring      ;if not found, branch again
       dec $02                     ;decrement saved vertical position
       lda #$03
       ldy EnemyFrameTimer,x       ;get timer for enemy object
       beq SBBAt                   ;if expired, do not set priority bit
       ora #%00100000              ;otherwise do so
SBBAt: sta $04                     ;set new sprite attributes
       ldy #$00                    ;nullify saved enemy state both in Y and in
       sty $ed                     ;memory location here
       lda #$08                    ;set specific value to unconditionally branch once

CheckForJumpspring:
      cmp #JumpspringObject        ;check for jumpspring object
      bne CheckForPodoboo
      ldy #$03                     ;set enemy state -2 MSB here for jumpspring object
      ldx JumpspringAnimCtrl       ;get current frame number for jumpspring object
      lda JumpspringFrameOffsets,x ;load data using frame number as offset

CheckForPodoboo:
      sta $ef                 ;store saved enemy object value here
      sty $ec                 ;and Y here (enemy state -2 MSB if not changed)
      ldx ObjectOffset        ;get enemy object offset
      cmp #$0c                ;check for podoboo object
      bne CheckBowserGfxFlag  ;branch if not found
      lda Enemy_Y_Speed,x     ;if moving upwards, branch
      bmi CheckBowserGfxFlag
      inc VerticalFlipFlag    ;otherwise, set flag for vertical flip

CheckBowserGfxFlag:
             lda BowserGfxFlag   ;if not drawing bowser at all, skip to something else
             beq CheckForGoomba
             ldy #$16            ;if set to 1, draw bowser's front
             cmp #$01
             beq SBwsrGfxOfs
             iny                 ;otherwise draw bowser's rear
SBwsrGfxOfs: sty $ef

CheckForGoomba:
          ldy $ef               ;check value for goomba object
          cpy #Goomba
          bne CheckBowserFront  ;branch if not found
          lda Enemy_State,x
          cmp #$02              ;check for defeated state
          bcc GmbaAnim          ;if not defeated, go ahead and animate
          ldx #$04              ;if defeated, write new value here
          stx $ec
GmbaAnim: and #%00100000        ;check for d5 set in enemy object state
          ora TimerControl      ;or timer disable flag set
          bne CheckBowserFront  ;if either condition true, do not animate goomba
          lda FrameCounter
          and #%00001000        ;check for every eighth frame
          bne CheckBowserFront
          lda $03
          eor #%00000011        ;invert bits to flip horizontally every eight frames
          sta $03               ;leave alone otherwise

CheckBowserFront:
             lda EnemyAttributeData,y    ;load sprite attribute using enemy object
             ora $04                     ;as offset, and add to bits already loaded
             sta $04
             lda EnemyGfxTableOffsets,y  ;load value based on enemy object as offset
             tax                         ;save as X
             ldy $ec                     ;get previously saved value
             lda BowserGfxFlag
             beq CheckForSpiny           ;if not drawing bowser object at all, skip all of this
             cmp #$01
             bne CheckBowserRear         ;if not drawing front part, branch to draw the rear part
             lda BowserBodyControls      ;check bowser's body control bits
             bpl ChkFrontSte             ;branch if d7 not set (control's bowser's mouth)
             ldx #$de                    ;otherwise load offset for second frame
ChkFrontSte: lda $ed                     ;check saved enemy state
             and #%00100000              ;if bowser not defeated, do not set flag
             beq DrawBowser

FlipBowserOver:
      stx VerticalFlipFlag  ;set vertical flip flag to nonzero

DrawBowser:
      jmp DrawEnemyObject   ;draw bowser's graphics now

CheckBowserRear:
            lda BowserBodyControls  ;check bowser's body control bits
            and #$01
            beq ChkRearSte          ;branch if d0 not set (control's bowser's feet)
            ldx #$e4                ;otherwise load offset for second frame
ChkRearSte: lda $ed                 ;check saved enemy state
            and #%00100000          ;if bowser not defeated, do not set flag
            beq DrawBowser
            lda $02                 ;subtract 16 pixels from
            sec                     ;saved vertical coordinate
            sbc #$10
            sta $02
            jmp FlipBowserOver      ;jump to set vertical flip flag

CheckForSpiny:
        cpx #$24               ;check if value loaded is for spiny
        bne CheckForLakitu     ;if not found, branch
        cpy #$05               ;if enemy state set to $05, do this,
        bne NotEgg             ;otherwise branch
        ldx #$30               ;set to spiny egg offset
        lda #$02
        sta $03                ;set enemy direction to reverse sprites horizontally
        lda #$05
        sta $ec                ;set enemy state
NotEgg: jmp CheckForHammerBro  ;skip a big chunk of this if we found spiny but not in egg

CheckForLakitu:
        cpx #$90                  ;check value for lakitu's offset loaded
        bne CheckUpsideDownShell  ;branch if not loaded
        lda $ed
        and #%00100000            ;check for d5 set in enemy state
        bne NoLAFr                ;branch if set
        lda FrenzyEnemyTimer
        cmp #$10                  ;check timer to see if we've reached a certain range
        bcs NoLAFr                ;branch if not
        ldx #$96                  ;if d6 not set and timer in range, load alt frame for lakitu
NoLAFr: jmp CheckDefeatedState    ;skip this next part if we found lakitu but alt frame not needed

CheckUpsideDownShell:
      lda $ef                    ;check for enemy object => $04
      cmp #$04
      bcs CheckRightSideUpShell  ;branch if true
      cpy #$02
      bcc CheckRightSideUpShell  ;branch if enemy state < $02
      ldx #$5a                   ;set for upside-down koopa shell by default
      ldy $ef
      cpy #BuzzyBeetle           ;check for buzzy beetle object
      bne CheckRightSideUpShell
      ldx #$7e                   ;set for upside-down buzzy beetle shell if found
      inc $02                    ;increment vertical position by one pixel

CheckRightSideUpShell:
      lda $ec                ;check for value set here
      cmp #$04               ;if enemy state < $02, do not change to shell, if
      bne CheckForHammerBro  ;enemy state => $02 but not = $04, leave shell upside-down
      ldx #$72               ;set right-side up buzzy beetle shell by default
      inc $02                ;increment saved vertical position by one pixel
      ldy $ef
      cpy #BuzzyBeetle       ;check for buzzy beetle object
      beq CheckForDefdGoomba ;branch if found
      ldx #$66               ;change to right-side up koopa shell if not found
      inc $02                ;and increment saved vertical position again

CheckForDefdGoomba:
      cpy #Goomba            ;check for goomba object (necessary if previously
      bne CheckForHammerBro  ;failed buzzy beetle object test)
      ldx #$54               ;load for regular goomba
      lda $ed                ;note that this only gets performed if enemy state => $02
      and #%00100000         ;check saved enemy state for d5 set
      bne CheckForHammerBro  ;branch if set
      ldx #$8a               ;load offset for defeated goomba
      dec $02                ;set different value and decrement saved vertical position

CheckForHammerBro:
      ldy ObjectOffset
      lda $ef                  ;check for hammer bro object
      cmp #HammerBro
      bne CheckForBloober      ;branch if not found
      lda $ed
      beq CheckToAnimateEnemy  ;branch if not in normal enemy state
      and #%00001000
      beq CheckDefeatedState   ;if d3 not set, branch further away
      ldx #$b4                 ;otherwise load offset for different frame
      bne CheckToAnimateEnemy  ;unconditional branch

CheckForBloober:
      cpx #$48                 ;check for cheep-cheep offset loaded
      beq CheckToAnimateEnemy  ;branch if found
      lda EnemyIntervalTimer,y
      cmp #$05
      bcs CheckDefeatedState   ;branch if some timer is above a certain point
      cpx #$3c                 ;check for bloober offset loaded
      bne CheckToAnimateEnemy  ;branch if not found this time
      cmp #$01
      beq CheckDefeatedState   ;branch if timer is set to certain point
      inc $02                  ;increment saved vertical coordinate three pixels
      inc $02
      inc $02
      jmp CheckAnimationStop   ;and do something else

CheckToAnimateEnemy:
      lda $ef                  ;check for specific enemy objects
      cmp #Goomba
      beq CheckDefeatedState   ;branch if goomba
      cmp #$08
      beq CheckDefeatedState   ;branch if bullet bill (note both variants use $08 here)
      cmp #Podoboo
      beq CheckDefeatedState   ;branch if podoboo
      cmp #$18                 ;branch if => $18
      bcs CheckDefeatedState
      ldy #$00
      cmp #$15                 ;check for mushroom retainer/princess object
      bne CheckForSecondFrame  ;which uses different code here, branch if not found
      iny                      ;residual instruction
      lda WorldNumber          ;are we on world 8?
      cmp #World8
      bcs CheckDefeatedState   ;if so, leave the offset alone (use princess)
      ldx #$a2                 ;otherwise, set for mushroom retainer object instead
      lda #$03                 ;set alternate state here
      sta $ec
      bne CheckDefeatedState   ;unconditional branch

CheckForSecondFrame:
      lda FrameCounter            ;load frame counter
      and EnemyAnimTimingBMask,y  ;mask it (partly residual, one byte not ever used)
      bne CheckDefeatedState      ;branch if timing is off

CheckAnimationStop:
      lda $ed                 ;check saved enemy state
      and #%10100000          ;for d7 or d5, or check for timers stopped
      ora TimerControl
      bne CheckDefeatedState  ;if either condition true, branch
      txa
      clc
      adc #$06                ;add $06 to current enemy offset
      tax                     ;to animate various enemy objects

CheckDefeatedState:
      lda $ed               ;check saved enemy state
      and #%00100000        ;for d5 set
      beq DrawEnemyObject   ;branch if not set
      lda $ef
      cmp #$04              ;check for saved enemy object => $04
      bcc DrawEnemyObject   ;branch if less
      ldy #$01
      sty VerticalFlipFlag  ;set vertical flip flag
      dey
      sty $ec               ;init saved value here

DrawEnemyObject:
      ldy $eb                    ;load sprite data offset
      jsr DrawEnemyObjRow        ;draw six tiles of data
      jsr DrawEnemyObjRow        ;into sprite data
      jsr DrawEnemyObjRow
      ldx ObjectOffset           ;get enemy object offset
      ldy Enemy_SprDataOffset,x  ;get sprite data offset
      lda $ef
      cmp #$08                   ;get saved enemy object and check
      bne CheckForVerticalFlip   ;for bullet bill, branch if not found

SkipToOffScrChk:
      jmp SprObjectOffscrChk     ;jump if found

CheckForVerticalFlip:
      lda VerticalFlipFlag       ;check if vertical flip flag is set here
      beq CheckForESymmetry      ;branch if not
      lda Sprite_Attributes,y    ;get attributes of first sprite we dealt with
      ora #%10000000             ;set bit for vertical flip
      iny
      iny                        ;increment two bytes so that we store the vertical flip
      jsr DumpSixSpr             ;in attribute bytes of enemy obj sprite data
      dey
      dey                        ;now go back to the Y coordinate offset
      tya
      tax                        ;give offset to X
      lda $ef
      cmp #HammerBro             ;check saved enemy object for hammer bro
      beq FlipEnemyVertically
      cmp #Lakitu                ;check saved enemy object for lakitu
      beq FlipEnemyVertically    ;branch for hammer bro or lakitu
      cmp #$15
      bcs FlipEnemyVertically    ;also branch if enemy object => $15
      txa
      clc
      adc #$08                   ;if not selected objects or => $15, set
      tax                        ;offset in X for next row

FlipEnemyVertically:
      lda Sprite_Tilenumber,x     ;load first or second row tiles
      pha                         ;and save tiles to the stack
      lda Sprite_Tilenumber+4,x
      pha
      lda Sprite_Tilenumber+16,y  ;exchange third row tiles
      sta Sprite_Tilenumber,x     ;with first or second row tiles
      lda Sprite_Tilenumber+20,y
      sta Sprite_Tilenumber+4,x
      pla                         ;pull first or second row tiles from stack
      sta Sprite_Tilenumber+20,y  ;and save in third row
      pla
      sta Sprite_Tilenumber+16,y

CheckForESymmetry:
        lda BowserGfxFlag           ;are we drawing bowser at all?
        bne SkipToOffScrChk         ;branch if so
        lda $ef
        ldx $ec                     ;get alternate enemy state
        cmp #$05                    ;check for hammer bro object
        bne ContES
        jmp SprObjectOffscrChk      ;jump if found
ContES: cmp #Bloober                ;check for bloober object
        beq MirrorEnemyGfx
        cmp #PiranhaPlant           ;check for piranha plant object
        beq MirrorEnemyGfx
        cmp #Podoboo                ;check for podoboo object
        beq MirrorEnemyGfx          ;branch if either of three are found
        cmp #Spiny                  ;check for spiny object
        bne ESRtnr                  ;branch closer if not found
        cpx #$05                    ;check spiny's state
        bne CheckToMirrorLakitu     ;branch if not an egg, otherwise
ESRtnr: cmp #$15                    ;check for princess/mushroom retainer object
        bne SpnySC
        lda #$42                    ;set horizontal flip on bottom right sprite
        sta Sprite_Attributes+20,y  ;note that palette bits were already set earlier
SpnySC: cpx #$02                    ;if alternate enemy state set to 1 or 0, branch
        bcc CheckToMirrorLakitu

MirrorEnemyGfx:
        lda BowserGfxFlag           ;if enemy object is bowser, skip all of this
        bne CheckToMirrorLakitu
        lda Sprite_Attributes,y     ;load attribute bits of first sprite
        and #%10100011
        sta Sprite_Attributes,y     ;save vertical flip, priority, and palette bits
        sta Sprite_Attributes+8,y   ;in left sprite column of enemy object OAM data
        sta Sprite_Attributes+16,y
        ora #%01000000              ;set horizontal flip
        cpx #$05                    ;check for state used by spiny's egg
        bne EggExc                  ;if alternate state not set to $05, branch
        ora #%10000000              ;otherwise set vertical flip
EggExc: sta Sprite_Attributes+4,y   ;set bits of right sprite column
        sta Sprite_Attributes+12,y  ;of enemy object sprite data
        sta Sprite_Attributes+20,y
        cpx #$04                    ;check alternate enemy state
        bne CheckToMirrorLakitu     ;branch if not $04
        lda Sprite_Attributes+8,y   ;get second row left sprite attributes
        ora #%10000000
        sta Sprite_Attributes+8,y   ;store bits with vertical flip in
        sta Sprite_Attributes+16,y  ;second and third row left sprites
        ora #%01000000
        sta Sprite_Attributes+12,y  ;store with horizontal and vertical flip in
        sta Sprite_Attributes+20,y  ;second and third row right sprites

CheckToMirrorLakitu:
        lda $ef                     ;check for lakitu enemy object
        cmp #Lakitu
        bne CheckToMirrorJSpring    ;branch if not found
        lda VerticalFlipFlag
        bne NVFLak                  ;branch if vertical flip flag not set
        lda Sprite_Attributes+16,y  ;save vertical flip and palette bits
        and #%10000001              ;in third row left sprite
        sta Sprite_Attributes+16,y
        lda Sprite_Attributes+20,y  ;set horizontal flip and palette bits
        ora #%01000001              ;in third row right sprite
        sta Sprite_Attributes+20,y
        ldx FrenzyEnemyTimer        ;check timer
        cpx #$10
        bcs SprObjectOffscrChk      ;branch if timer has not reached a certain range
        sta Sprite_Attributes+12,y  ;otherwise set same for second row right sprite
        and #%10000001
        sta Sprite_Attributes+8,y   ;preserve vertical flip and palette bits for left sprite
        bcc SprObjectOffscrChk      ;unconditional branch
NVFLak: lda Sprite_Attributes,y     ;get first row left sprite attributes
        and #%10000001
        sta Sprite_Attributes,y     ;save vertical flip and palette bits
        lda Sprite_Attributes+4,y   ;get first row right sprite attributes
        ora #%01000001              ;set horizontal flip and palette bits
        sta Sprite_Attributes+4,y   ;note that vertical flip is left as-is

CheckToMirrorJSpring:
      lda $ef                     ;check for jumpspring object (any frame)
      cmp #$18
      bcc SprObjectOffscrChk      ;branch if not jumpspring object at all
      lda #$82
      sta Sprite_Attributes+8,y   ;set vertical flip and palette bits of
      sta Sprite_Attributes+16,y  ;second and third row left sprites
      ora #%01000000
      sta Sprite_Attributes+12,y  ;set, in addition to those, horizontal flip
      sta Sprite_Attributes+20,y  ;for second and third row right sprites

SprObjectOffscrChk:
         ldx ObjectOffset          ;get enemy buffer offset
         lda Enemy_OffscreenBits   ;check offscreen information
         lsr
         lsr                       ;shift three times to the right
         lsr                       ;which puts d2 into carry
         pha                       ;save to stack
         bcc LcChk                 ;branch if not set
         lda #$04                  ;set for right column sprites
         jsr MoveESprColOffscreen  ;and move them offscreen
LcChk:   pla                       ;get from stack
         lsr                       ;move d3 to carry
         pha                       ;save to stack
         bcc Row3C                 ;branch if not set
         lda #$00                  ;set for left column sprites,
         jsr MoveESprColOffscreen  ;move them offscreen
Row3C:   pla                       ;get from stack again
         lsr                       ;move d5 to carry this time
         lsr
         pha                       ;save to stack again
         bcc Row23C                ;branch if carry not set
         lda #$10                  ;set for third row of sprites
         jsr MoveESprRowOffscreen  ;and move them offscreen
Row23C:  pla                       ;get from stack
         lsr                       ;move d6 into carry
         pha                       ;save to stack
         bcc AllRowC
         lda #$08                  ;set for second and third rows
         jsr MoveESprRowOffscreen  ;move them offscreen
AllRowC: pla                       ;get from stack once more
         lsr                       ;move d7 into carry
         bcc ExEGHandler
         jsr MoveESprRowOffscreen  ;move all sprites offscreen (A should be 0 by now)
         lda Enemy_ID,x
         cmp #Podoboo              ;check enemy identifier for podoboo
         beq ExEGHandler           ;skip this part if found, we do not want to erase podoboo!
         lda Enemy_Y_HighPos,x     ;check high byte of vertical position
         cmp #$02                  ;if not yet past the bottom of the screen, branch
         bne ExEGHandler
         jsr EraseEnemyObject      ;what it says

ExEGHandler:
      rts

DrawEnemyObjRow:
      lda EnemyGraphicsTable,x    ;load two tiles of enemy graphics
      sta $00
      lda EnemyGraphicsTable+1,x

DrawOneSpriteRow:
      sta $01
      jmp DrawSpriteObject        ;draw them

MoveESprRowOffscreen:
      clc                         ;add A to enemy object OAM data offset
      adc Enemy_SprDataOffset,x
      tay                         ;use as offset
      lda #$f8
      jmp DumpTwoSpr              ;move first row of sprites offscreen

MoveESprColOffscreen:
      clc                         ;add A to enemy object OAM data offset
      adc Enemy_SprDataOffset,x
      tay                         ;use as offset
      jsr MoveColOffscreen        ;move first and second row sprites in column offscreen
      sta Sprite_Data+16,y        ;move third row sprite in column offscreen
      rts

;-------------------------------------------------------------------------------------
;$00-$01 - tile numbers
;$02 - relative Y position
;$03 - horizontal flip flag (not used here)
;$04 - attributes
;$05 - relative X position

DefaultBlockObjTiles:
      .db $85, $85, $86, $86             ;brick w/ line (these are sprite tiles, not BG!)

DrawBlock:
           lda Block_Rel_YPos            ;get relative vertical coordinate of block object
           sta $02                       ;store here
           lda Block_Rel_XPos            ;get relative horizontal coordinate of block object
           sta $05                       ;store here
           lda #$03
           sta $04                       ;set attribute byte here
           lsr
           sta $03                       ;set horizontal flip bit here (will not be used)
           ldy Block_SprDataOffset,x     ;get sprite data offset
           ldx #$00                      ;reset X for use as offset to tile data
DBlkLoop:  lda DefaultBlockObjTiles,x    ;get left tile number
           sta $00                       ;set here
           lda DefaultBlockObjTiles+1,x  ;get right tile number
           jsr DrawOneSpriteRow          ;do sub to write tile numbers to first row of sprites
           cpx #$04                      ;check incremented offset
           bne DBlkLoop                  ;and loop back until all four sprites are done
           ldx ObjectOffset              ;get block object offset
           ldy Block_SprDataOffset,x     ;get sprite data offset
           lda AreaType
           cmp #$01                      ;check for ground level type area
           beq ChkRep                    ;if found, branch to next part
           lda #$86
           sta Sprite_Tilenumber,y       ;otherwise remove brick tiles with lines
           sta Sprite_Tilenumber+4,y     ;and replace then with lineless brick tiles
ChkRep:    lda Block_Metatile,x          ;check replacement metatile
           cmp #$c4                      ;if not used block metatile, then
           bne BlkOffscr                 ;branch ahead to use current graphics
           lda #$87                      ;set A for used block tile
           iny                           ;increment Y to write to tile bytes
           jsr DumpFourSpr               ;do sub to dump into all four sprites
           dey                           ;return Y to original offset
           lda #$03                      ;set palette bits
           ldx AreaType
           dex                           ;check for ground level type area again
           beq SetBFlip                  ;if found, use current palette bits
           lsr                           ;otherwise set to $01
SetBFlip:  ldx ObjectOffset              ;put block object offset back in X
           sta Sprite_Attributes,y       ;store attribute byte as-is in first sprite
           ora #%01000000
           sta Sprite_Attributes+4,y     ;set horizontal flip bit for second sprite
           ora #%10000000
           sta Sprite_Attributes+12,y    ;set both flip bits for fourth sprite
           and #%10000011
           sta Sprite_Attributes+8,y     ;set vertical flip bit for third sprite
BlkOffscr: lda Block_OffscreenBits       ;get offscreen bits for block object
           pha                           ;save to stack
           and #%00000100                ;check to see if d2 in offscreen bits are set
           beq PullOfsB                  ;if not set, branch, otherwise move sprites offscreen
           lda #$f8                      ;move offscreen two OAMs
           sta Sprite_Y_Position+4,y     ;on the right side
           sta Sprite_Y_Position+12,y
PullOfsB:  pla                           ;pull offscreen bits from stack
ChkLeftCo: and #%00001000                ;check to see if d3 in offscreen bits are set
           beq ExDBlk                    ;if not set, branch, otherwise move sprites offscreen

MoveColOffscreen:
        lda #$f8                   ;move offscreen two OAMs
        sta Sprite_Y_Position,y    ;on the left side (or two rows of enemy on either side
        sta Sprite_Y_Position+8,y  ;if branched here from enemy graphics handler)
ExDBlk: rts

;-------------------------------------------------------------------------------------
;$00 - used to hold palette bits for attribute byte or relative X position

DrawBrickChunks:
         lda #$02                   ;set palette bits here
         sta $00
         lda #$75                   ;set tile number for ball (something residual, likely)
         ldy GameEngineSubroutine
         cpy #$05                   ;if end-of-level routine running,
         beq DChunks                ;use palette and tile number assigned
         lda #$03                   ;otherwise set different palette bits
         sta $00
         lda #$84                   ;and set tile number for brick chunks
DChunks: ldy Block_SprDataOffset,x  ;get OAM data offset
         iny                        ;increment to start with tile bytes in OAM
         jsr DumpFourSpr            ;do sub to dump tile number into all four sprites
         lda FrameCounter           ;get frame counter
         asl
         asl
         asl                        ;move low nybble to high
         asl
         and #$c0                   ;get what was originally d3-d2 of low nybble
         ora $00                    ;add palette bits
         iny                        ;increment offset for attribute bytes
         jsr DumpFourSpr            ;do sub to dump attribute data into all four sprites
         dey
         dey                        ;decrement offset to Y coordinate
         lda Block_Rel_YPos         ;get first block object's relative vertical coordinate
         jsr DumpTwoSpr             ;do sub to dump current Y coordinate into two sprites
         lda Block_Rel_XPos         ;get first block object's relative horizontal coordinate
         sta Sprite_X_Position,y    ;save into X coordinate of first sprite
         lda Block_Orig_XPos,x      ;get original horizontal coordinate
         sec
         sbc ScreenLeft_X_Pos       ;subtract coordinate of left side from original coordinate
         sta $00                    ;store result as relative horizontal coordinate of original
         sec
         sbc Block_Rel_XPos         ;get difference of relative positions of original - current
         adc $00                    ;add original relative position to result
         adc #$06                   ;plus 6 pixels to position second brick chunk correctly
         sta Sprite_X_Position+4,y  ;save into X coordinate of second sprite
         lda Block_Rel_YPos+1       ;get second block object's relative vertical coordinate
         sta Sprite_Y_Position+8,y
         sta Sprite_Y_Position+12,y ;dump into Y coordinates of third and fourth sprites
         lda Block_Rel_XPos+1       ;get second block object's relative horizontal coordinate
         sta Sprite_X_Position+8,y  ;save into X coordinate of third sprite
         lda $00                    ;use original relative horizontal position
         sec
         sbc Block_Rel_XPos+1       ;get difference of relative positions of original - current
         adc $00                    ;add original relative position to result
         adc #$06                   ;plus 6 pixels to position fourth brick chunk correctly
         sta Sprite_X_Position+12,y ;save into X coordinate of fourth sprite
         lda Block_OffscreenBits    ;get offscreen bits for block object
         jsr ChkLeftCo              ;do sub to move left half of sprites offscreen if necessary
         lda Block_OffscreenBits    ;get offscreen bits again
         asl                        ;shift d7 into carry
         bcc ChnkOfs                ;if d7 not set, branch to last part
         lda #$f8
         jsr DumpTwoSpr             ;otherwise move top sprites offscreen
ChnkOfs: lda $00                    ;if relative position on left side of screen,
         bpl ExBCDr                 ;go ahead and leave
         lda Sprite_X_Position,y    ;otherwise compare left-side X coordinate
         cmp Sprite_X_Position+4,y  ;to right-side X coordinate
         bcc ExBCDr                 ;branch to leave if less
         lda #$f8                   ;otherwise move right half of sprites offscreen
         sta Sprite_Y_Position+4,y
         sta Sprite_Y_Position+12,y
ExBCDr:  rts                        ;leave

;-------------------------------------------------------------------------------------

DrawFireball:
      ldy FBall_SprDataOffset,x  ;get fireball's sprite data offset
      lda Fireball_Rel_YPos      ;get relative vertical coordinate
      sta Sprite_Y_Position,y    ;store as sprite Y coordinate
      lda Fireball_Rel_XPos      ;get relative horizontal coordinate
      sta Sprite_X_Position,y    ;store as sprite X coordinate, then do shared code

DrawFirebar:
       lda FrameCounter         ;get frame counter
       lsr                      ;divide by four
       lsr
       pha                      ;save result to stack
       and #$01                 ;mask out all but last bit
       eor #$64                 ;set either tile $64 or $65 as fireball tile
       sta Sprite_Tilenumber,y  ;thus tile changes every four frames
       pla                      ;get from stack
       lsr                      ;divide by four again
       lsr
       lda #$02                 ;load value $02 to set palette in attrib byte
       bcc FireA                ;if last bit shifted out was not set, skip this
       ora #%11000000           ;otherwise flip both ways every eight frames
FireA: sta Sprite_Attributes,y  ;store attribute byte and leave
       rts

;-------------------------------------------------------------------------------------

ExplosionTiles:
      .db $68, $67, $66

DrawExplosion_Fireball:
      ldy Alt_SprDataOffset,x  ;get OAM data offset of alternate sort for fireball's explosion
      lda Fireball_State,x     ;load fireball state
      inc Fireball_State,x     ;increment state for next frame
      lsr                      ;divide by 2
      and #%00000111           ;mask out all but d3-d1
      cmp #$03                 ;check to see if time to kill fireball
      bcs KillFireBall         ;branch if so, otherwise continue to draw explosion

DrawExplosion_Fireworks:
      tax                         ;use whatever's in A for offset
      lda ExplosionTiles,x        ;get tile number using offset
      iny                         ;increment Y (contains sprite data offset)
      jsr DumpFourSpr             ;and dump into tile number part of sprite data
      dey                         ;decrement Y so we have the proper offset again
      ldx ObjectOffset            ;return enemy object buffer offset to X
      lda Fireball_Rel_YPos       ;get relative vertical coordinate
      sec                         ;subtract four pixels vertically
      sbc #$04                    ;for first and third sprites
      sta Sprite_Y_Position,y
      sta Sprite_Y_Position+8,y
      clc                         ;add eight pixels vertically
      adc #$08                    ;for second and fourth sprites
      sta Sprite_Y_Position+4,y
      sta Sprite_Y_Position+12,y
      lda Fireball_Rel_XPos       ;get relative horizontal coordinate
      sec                         ;subtract four pixels horizontally
      sbc #$04                    ;for first and second sprites
      sta Sprite_X_Position,y
      sta Sprite_X_Position+4,y
      clc                         ;add eight pixels horizontally
      adc #$08                    ;for third and fourth sprites
      sta Sprite_X_Position+8,y
      sta Sprite_X_Position+12,y
      lda #$02                    ;set palette attributes for all sprites, but
      sta Sprite_Attributes,y     ;set no flip at all for first sprite
      lda #$82
      sta Sprite_Attributes+4,y   ;set vertical flip for second sprite
      lda #$42
      sta Sprite_Attributes+8,y   ;set horizontal flip for third sprite
      lda #$c2
      sta Sprite_Attributes+12,y  ;set both flips for fourth sprite
      rts                         ;we are done

KillFireBall:
      lda #$00                    ;clear fireball state to kill it
      sta Fireball_State,x
      rts

;-------------------------------------------------------------------------------------

DrawSmallPlatform:
       ldy Enemy_SprDataOffset,x   ;get OAM data offset
       lda #$5b                    ;load tile number for small platforms
       iny                         ;increment offset for tile numbers
       jsr DumpSixSpr              ;dump tile number into all six sprites
       iny                         ;increment offset for attributes
       lda #$02                    ;load palette controls
       jsr DumpSixSpr              ;dump attributes into all six sprites
       dey                         ;decrement for original offset
       dey
       lda Enemy_Rel_XPos          ;get relative horizontal coordinate
       sta Sprite_X_Position,y
       sta Sprite_X_Position+12,y  ;dump as X coordinate into first and fourth sprites
       clc
       adc #$08                    ;add eight pixels
       sta Sprite_X_Position+4,y   ;dump into second and fifth sprites
       sta Sprite_X_Position+16,y
       clc
       adc #$08                    ;add eight more pixels
       sta Sprite_X_Position+8,y   ;dump into third and sixth sprites
       sta Sprite_X_Position+20,y
       lda Enemy_Y_Position,x      ;get vertical coordinate
       tax
       pha                         ;save to stack
       cpx #$20                    ;if vertical coordinate below status bar,
       bcs TopSP                   ;do not mess with it
       lda #$f8                    ;otherwise move first three sprites offscreen
TopSP: jsr DumpThreeSpr            ;dump vertical coordinate into Y coordinates
       pla                         ;pull from stack
       clc
       adc #$80                    ;add 128 pixels
       tax
       cpx #$20                    ;if below status bar (taking wrap into account)
       bcs BotSP                   ;then do not change altered coordinate
       lda #$f8                    ;otherwise move last three sprites offscreen
BotSP: sta Sprite_Y_Position+12,y  ;dump vertical coordinate + 128 pixels
       sta Sprite_Y_Position+16,y  ;into Y coordinates
       sta Sprite_Y_Position+20,y
       lda Enemy_OffscreenBits     ;get offscreen bits
       pha                         ;save to stack
       and #%00001000              ;check d3
       beq SOfs
       lda #$f8                    ;if d3 was set, move first and
       sta Sprite_Y_Position,y     ;fourth sprites offscreen
       sta Sprite_Y_Position+12,y
SOfs:  pla                         ;move out and back into stack
       pha
       and #%00000100              ;check d2
       beq SOfs2
       lda #$f8                    ;if d2 was set, move second and
       sta Sprite_Y_Position+4,y   ;fifth sprites offscreen
       sta Sprite_Y_Position+16,y
SOfs2: pla                         ;get from stack
       and #%00000010              ;check d1
       beq ExSPl
       lda #$f8                    ;if d1 was set, move third and
       sta Sprite_Y_Position+8,y   ;sixth sprites offscreen
       sta Sprite_Y_Position+20,y
ExSPl: ldx ObjectOffset            ;get enemy object offset and leave
       rts

;-------------------------------------------------------------------------------------

DrawBubble:
        ldy Player_Y_HighPos        ;if player's vertical high position
        dey                         ;not within screen, skip all of this
        bne ExDBub
        lda Bubble_OffscreenBits    ;check air bubble's offscreen bits
        and #%00001000
        bne ExDBub                  ;if bit set, branch to leave
        ldy Bubble_SprDataOffset,x  ;get air bubble's OAM data offset
        lda Bubble_Rel_XPos         ;get relative horizontal coordinate
        sta Sprite_X_Position,y     ;store as X coordinate here
        lda Bubble_Rel_YPos         ;get relative vertical coordinate
        sta Sprite_Y_Position,y     ;store as Y coordinate here
        lda #$74
        sta Sprite_Tilenumber,y     ;put air bubble tile into OAM data
        lda #$02
        sta Sprite_Attributes,y     ;set attribute byte
ExDBub: rts                         ;leave

;-------------------------------------------------------------------------------------
;$00 - used to store player's vertical offscreen bits

PlayerGfxTblOffsets:
      .db $20, $28, $c8, $18, $00, $40, $50, $58
      .db $80, $88, $b8, $78, $60, $a0, $b0, $b8

;tiles arranged in order, 2 tiles per row, top to bottom

PlayerGraphicsTable:
;big player table
      .db $00, $01, $02, $03, $04, $05, $06, $07 ;walking frame 1
      .db $08, $09, $0a, $0b, $0c, $0d, $0e, $0f ;        frame 2
      .db $10, $11, $12, $13, $14, $15, $16, $17 ;        frame 3
      .db $18, $19, $1a, $1b, $1c, $1d, $1e, $1f ;skidding
      .db $20, $21, $22, $23, $24, $25, $26, $27 ;jumping
      .db $08, $09, $28, $29, $2a, $2b, $2c, $2d ;swimming frame 1
      .db $08, $09, $0a, $0b, $0c, $30, $2c, $2d ;         frame 2
      .db $08, $09, $0a, $0b, $2e, $2f, $2c, $2d ;         frame 3
      .db $08, $09, $28, $29, $2a, $2b, $5c, $5d ;climbing frame 1
      .db $08, $09, $0a, $0b, $0c, $0d, $5e, $5f ;         frame 2
      .db $fc, $fc, $08, $09, $58, $59, $5a, $5a ;crouching
      .db $08, $09, $28, $29, $2a, $2b, $0e, $0f ;fireball throwing

;small player table
      .db $fc, $fc, $fc, $fc, $32, $33, $34, $35 ;walking frame 1
      .db $fc, $fc, $fc, $fc, $36, $37, $38, $39 ;        frame 2
      .db $fc, $fc, $fc, $fc, $3a, $37, $3b, $3c ;        frame 3
      .db $fc, $fc, $fc, $fc, $3d, $3e, $3f, $40 ;skidding
      .db $fc, $fc, $fc, $fc, $32, $41, $42, $43 ;jumping
      .db $fc, $fc, $fc, $fc, $32, $33, $44, $45 ;swimming frame 1
      .db $fc, $fc, $fc, $fc, $32, $33, $44, $47 ;         frame 2
      .db $fc, $fc, $fc, $fc, $32, $33, $48, $49 ;         frame 3
      .db $fc, $fc, $fc, $fc, $32, $33, $90, $91 ;climbing frame 1
      .db $fc, $fc, $fc, $fc, $3a, $37, $92, $93 ;         frame 2
      .db $fc, $fc, $fc, $fc, $9e, $9e, $9f, $9f ;killed

;used by both player sizes
      .db $fc, $fc, $fc, $fc, $3a, $37, $4f, $4f ;small player standing
      .db $fc, $fc, $00, $01, $4c, $4d, $4e, $4e ;intermediate grow frame
      .db $00, $01, $4c, $4d, $4a, $4a, $4b, $4b ;big player standing

SwimKickTileNum:
      .db $31, $46

PlayerGfxHandler:
        lda InjuryTimer             ;if player's injured invincibility timer
        beq CntPl                   ;not set, skip checkpoint and continue code
        lda FrameCounter
        lsr                         ;otherwise check frame counter and branch
        bcs ExPGH                   ;to leave on every other frame (when d0 is set)
CntPl:  lda GameEngineSubroutine    ;if executing specific game engine routine,
        cmp #$0b                    ;branch ahead to some other part
        beq PlayerKilled
        lda PlayerChangeSizeFlag    ;if grow/shrink flag set
        bne DoChangeSize            ;then branch to some other code
        ldy SwimmingFlag            ;if swimming flag set, branch to
        beq FindPlayerAction        ;different part, do not return
        lda Player_State
        cmp #$00                    ;if player status normal,
        beq FindPlayerAction        ;branch and do not return
        jsr FindPlayerAction        ;otherwise jump and return
        lda FrameCounter
        and #%00000100              ;check frame counter for d2 set (8 frames every
        bne ExPGH                   ;eighth frame), and branch if set to leave
        tax                         ;initialize X to zero
        ldy Player_SprDataOffset    ;get player sprite data offset
        lda PlayerFacingDir         ;get player's facing direction
        lsr
        bcs SwimKT                  ;if player facing to the right, use current offset
        iny
        iny                         ;otherwise move to next OAM data
        iny
        iny
SwimKT: lda PlayerSize              ;check player's size
        beq BigKTS                  ;if big, use first tile
        lda Sprite_Tilenumber+24,y  ;check tile number of seventh/eighth sprite
        cmp SwimTileRepOffset       ;against tile number in player graphics table
        beq ExPGH                   ;if spr7/spr8 tile number = value, branch to leave
        inx                         ;otherwise increment X for second tile
BigKTS: lda SwimKickTileNum,x       ;overwrite tile number in sprite 7/8
        sta Sprite_Tilenumber+24,y  ;to animate player's feet when swimming
ExPGH:  rts                         ;then leave

FindPlayerAction:
      jsr ProcessPlayerAction       ;find proper offset to graphics table by player's actions
      jmp PlayerGfxProcessing       ;draw player, then process for fireball throwing

DoChangeSize:
      jsr HandleChangeSize          ;find proper offset to graphics table for grow/shrink
      jmp PlayerGfxProcessing       ;draw player, then process for fireball throwing

PlayerKilled:
      ldy #$0e                      ;load offset for player killed
      lda PlayerGfxTblOffsets,y     ;get offset to graphics table

PlayerGfxProcessing:
       sta PlayerGfxOffset           ;store offset to graphics table here
       lda #$04
       jsr RenderPlayerSub           ;draw player based on offset loaded
       jsr ChkForPlayerAttrib        ;set horizontal flip bits as necessary
       lda FireballThrowingTimer
       beq PlayerOffscreenChk        ;if fireball throw timer not set, skip to the end
       ldy #$00                      ;set value to initialize by default
       lda PlayerAnimTimer           ;get animation frame timer
       cmp FireballThrowingTimer     ;compare to fireball throw timer
       sty FireballThrowingTimer     ;initialize fireball throw timer
       bcs PlayerOffscreenChk        ;if animation frame timer => fireball throw timer skip to end
       sta FireballThrowingTimer     ;otherwise store animation timer into fireball throw timer
       ldy #$07                      ;load offset for throwing
       lda PlayerGfxTblOffsets,y     ;get offset to graphics table
       sta PlayerGfxOffset           ;store it for use later
       ldy #$04                      ;set to update four sprite rows by default
       lda Player_X_Speed
       ora Left_Right_Buttons        ;check for horizontal speed or left/right button press
       beq SUpdR                     ;if no speed or button press, branch using set value in Y
       dey                           ;otherwise set to update only three sprite rows
SUpdR: tya                           ;save in A for use
       jsr RenderPlayerSub           ;in sub, draw player object again

PlayerOffscreenChk:
           lda Player_OffscreenBits      ;get player's offscreen bits
           lsr
           lsr                           ;move vertical bits to low nybble
           lsr
           lsr
           sta $00                       ;store here
           ldx #$03                      ;check all four rows of player sprites
           lda Player_SprDataOffset      ;get player's sprite data offset
           clc
           adc #$18                      ;add 24 bytes to start at bottom row
           tay                           ;set as offset here
PROfsLoop: lda #$f8                      ;load offscreen Y coordinate just in case
           lsr $00                       ;shift bit into carry
           bcc NPROffscr                 ;if bit not set, skip, do not move sprites
           jsr DumpTwoSpr                ;otherwise dump offscreen Y coordinate into sprite data
NPROffscr: tya
           sec                           ;subtract eight bytes to do
           sbc #$08                      ;next row up
           tay
           dex                           ;decrement row counter
           bpl PROfsLoop                 ;do this until all sprite rows are checked
           rts                           ;then we are done!

;-------------------------------------------------------------------------------------

IntermediatePlayerData:
        .db $58, $01, $00, $60, $ff, $04

DrawPlayer_Intermediate:
          ldx #$05                       ;store data into zero page memory
PIntLoop: lda IntermediatePlayerData,x   ;load data to display player as he always
          sta $02,x                      ;appears on world/lives display
          dex
          bpl PIntLoop                   ;do this until all data is loaded
          ldx #$b8                       ;load offset for small standing
          ldy #$04                       ;load sprite data offset
          jsr DrawPlayerLoop             ;draw player accordingly
          lda Sprite_Attributes+36       ;get empty sprite attributes
          ora #%01000000                 ;set horizontal flip bit for bottom-right sprite
          sta Sprite_Attributes+32       ;store and leave
          rts

;-------------------------------------------------------------------------------------
;$00-$01 - used to hold tile numbers, $00 also used to hold upper extent of animation frames
;$02 - vertical position
;$03 - facing direction, used as horizontal flip control
;$04 - attributes
;$05 - horizontal position
;$07 - number of rows to draw
;these also used in IntermediatePlayerData

RenderPlayerSub:
        sta $07                      ;store number of rows of sprites to draw
        lda Player_Rel_XPos
        sta Player_Pos_ForScroll     ;store player's relative horizontal position
        sta $05                      ;store it here also
        lda Player_Rel_YPos
        sta $02                      ;store player's vertical position
        lda PlayerFacingDir
        sta $03                      ;store player's facing direction
        lda Player_SprAttrib
        sta $04                      ;store player's sprite attributes
        ldx PlayerGfxOffset          ;load graphics table offset
        ldy Player_SprDataOffset     ;get player's sprite data offset

DrawPlayerLoop:
        lda PlayerGraphicsTable,x    ;load player's left side
        sta $00
        lda PlayerGraphicsTable+1,x  ;now load right side
        jsr DrawOneSpriteRow
        dec $07                      ;decrement rows of sprites to draw
        bne DrawPlayerLoop           ;do this until all rows are drawn
        rts

ProcessPlayerAction:
        lda Player_State      ;get player's state
        cmp #$03
        beq ActionClimbing    ;if climbing, branch here
        cmp #$02
        beq ActionFalling     ;if falling, branch here
        cmp #$01
        bne ProcOnGroundActs  ;if not jumping, branch here
        lda SwimmingFlag
        bne ActionSwimming    ;if swimming flag set, branch elsewhere
        ldy #$06              ;load offset for crouching
        lda CrouchingFlag     ;get crouching flag
        bne NonAnimatedActs   ;if set, branch to get offset for graphics table
        ldy #$00              ;otherwise load offset for jumping
        jmp NonAnimatedActs   ;go to get offset to graphics table

ProcOnGroundActs:
        ldy #$06                   ;load offset for crouching
        lda CrouchingFlag          ;get crouching flag
        bne NonAnimatedActs        ;if set, branch to get offset for graphics table
        ldy #$02                   ;load offset for standing
        lda Player_X_Speed         ;check player's horizontal speed
        ora Left_Right_Buttons     ;and left/right controller bits
        beq NonAnimatedActs        ;if no speed or buttons pressed, use standing offset
        lda Player_XSpeedAbsolute  ;load walking/running speed
        cmp #$09
        bcc ActionWalkRun          ;if less than a certain amount, branch, too slow to skid
        lda Player_MovingDir       ;otherwise check to see if moving direction
        and PlayerFacingDir        ;and facing direction are the same
        bne ActionWalkRun          ;if moving direction = facing direction, branch, don't skid
        iny                        ;otherwise increment to skid offset ($03)

NonAnimatedActs:
        jsr GetGfxOffsetAdder      ;do a sub here to get offset adder for graphics table
        lda #$00
        sta PlayerAnimCtrl         ;initialize animation frame control
        lda PlayerGfxTblOffsets,y  ;load offset to graphics table using size as offset
        rts

ActionFalling:
        ldy #$04                  ;load offset for walking/running
        jsr GetGfxOffsetAdder     ;get offset to graphics table
        jmp GetCurrentAnimOffset  ;execute instructions for falling state

ActionWalkRun:
        ldy #$04               ;load offset for walking/running
        jsr GetGfxOffsetAdder  ;get offset to graphics table
        jmp FourFrameExtent    ;execute instructions for normal state

ActionClimbing:
        ldy #$05               ;load offset for climbing
        lda Player_Y_Speed     ;check player's vertical speed
        beq NonAnimatedActs    ;if no speed, branch, use offset as-is
        jsr GetGfxOffsetAdder  ;otherwise get offset for graphics table
        jmp ThreeFrameExtent   ;then skip ahead to more code

ActionSwimming:
        ldy #$01               ;load offset for swimming
        jsr GetGfxOffsetAdder
        lda JumpSwimTimer      ;check jump/swim timer
        ora PlayerAnimCtrl     ;and animation frame control
        bne FourFrameExtent    ;if any one of these set, branch ahead
        lda A_B_Buttons
        asl                    ;check for A button pressed
        bcs FourFrameExtent    ;branch to same place if A button pressed

GetCurrentAnimOffset:
        lda PlayerAnimCtrl         ;get animation frame control
        jmp GetOffsetFromAnimCtrl  ;jump to get proper offset to graphics table

FourFrameExtent:
        lda #$03              ;load upper extent for frame control
        jmp AnimationControl  ;jump to get offset and animate player object

ThreeFrameExtent:
        lda #$02              ;load upper extent for frame control for climbing

AnimationControl:
          sta $00                   ;store upper extent here
          jsr GetCurrentAnimOffset  ;get proper offset to graphics table
          pha                       ;save offset to stack
          lda PlayerAnimTimer       ;load animation frame timer
          bne ExAnimC               ;branch if not expired
          lda PlayerAnimTimerSet    ;get animation frame timer amount
          sta PlayerAnimTimer       ;and set timer accordingly
          lda PlayerAnimCtrl
          clc                       ;add one to animation frame control
          adc #$01
          cmp $00                   ;compare to upper extent
          bcc SetAnimC              ;if frame control + 1 < upper extent, use as next
          lda #$00                  ;otherwise initialize frame control
SetAnimC: sta PlayerAnimCtrl        ;store as new animation frame control
ExAnimC:  pla                       ;get offset to graphics table from stack and leave
          rts

GetGfxOffsetAdder:
        lda PlayerSize  ;get player's size
        beq SzOfs       ;if player big, use current offset as-is
        tya             ;for big player
        clc             ;otherwise add eight bytes to offset
        adc #$08        ;for small player
        tay
SzOfs:  rts             ;go back

ChangeSizeOffsetAdder:
        .db $00, $01, $00, $01, $00, $01, $02, $00, $01, $02
        .db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00

HandleChangeSize:
         ldy PlayerAnimCtrl           ;get animation frame control
         lda FrameCounter
         and #%00000011               ;get frame counter and execute this code every
         bne GorSLog                  ;fourth frame, otherwise branch ahead
         iny                          ;increment frame control
         cpy #$0a                     ;check for preset upper extent
         bcc CSzNext                  ;if not there yet, skip ahead to use
         ldy #$00                     ;otherwise initialize both grow/shrink flag
         sty PlayerChangeSizeFlag     ;and animation frame control
CSzNext: sty PlayerAnimCtrl           ;store proper frame control
GorSLog: lda PlayerSize               ;get player's size
         bne ShrinkPlayer             ;if player small, skip ahead to next part
         lda ChangeSizeOffsetAdder,y  ;get offset adder based on frame control as offset
         ldy #$0f                     ;load offset for player growing

GetOffsetFromAnimCtrl:
        asl                        ;multiply animation frame control
        asl                        ;by eight to get proper amount
        asl                        ;to add to our offset
        adc PlayerGfxTblOffsets,y  ;add to offset to graphics table
        rts                        ;and return with result in A

ShrinkPlayer:
        tya                          ;add ten bytes to frame control as offset
        clc
        adc #$0a                     ;this thing apparently uses two of the swimming frames
        tax                          ;to draw the player shrinking
        ldy #$09                     ;load offset for small player swimming
        lda ChangeSizeOffsetAdder,x  ;get what would normally be offset adder
        bne ShrPlF                   ;and branch to use offset if nonzero
        ldy #$01                     ;otherwise load offset for big player swimming
ShrPlF: lda PlayerGfxTblOffsets,y    ;get offset to graphics table based on offset loaded
        rts                          ;and leave

ChkForPlayerAttrib:
           ldy Player_SprDataOffset    ;get sprite data offset
           lda GameEngineSubroutine
           cmp #$0b                    ;if executing specific game engine routine,
           beq KilledAtt               ;branch to change third and fourth row OAM attributes
           lda PlayerGfxOffset         ;get graphics table offset
           cmp #$50
           beq C_S_IGAtt               ;if crouch offset, either standing offset,
           cmp #$b8                    ;or intermediate growing offset,
           beq C_S_IGAtt               ;go ahead and execute code to change
           cmp #$c0                    ;fourth row OAM attributes only
           beq C_S_IGAtt
           cmp #$c8
           bne ExPlyrAt                ;if none of these, branch to leave
KilledAtt: lda Sprite_Attributes+16,y
           and #%00111111              ;mask out horizontal and vertical flip bits
           sta Sprite_Attributes+16,y  ;for third row sprites and save
           lda Sprite_Attributes+20,y
           and #%00111111
           ora #%01000000              ;set horizontal flip bit for second
           sta Sprite_Attributes+20,y  ;sprite in the third row
C_S_IGAtt: lda Sprite_Attributes+24,y
           and #%00111111              ;mask out horizontal and vertical flip bits
           sta Sprite_Attributes+24,y  ;for fourth row sprites and save
           lda Sprite_Attributes+28,y
           and #%00111111
           ora #%01000000              ;set horizontal flip bit for second
           sta Sprite_Attributes+28,y  ;sprite in the fourth row
ExPlyrAt:  rts                         ;leave

;-------------------------------------------------------------------------------------
;$00 - used in adding to get proper offset

RelativePlayerPosition:
        ldx #$00      ;set offsets for relative cooordinates
        ldy #$00      ;routine to correspond to player object
        jmp RelWOfs   ;get the coordinates

RelativeBubblePosition:
        ldy #$01                ;set for air bubble offsets
        jsr GetProperObjOffset  ;modify X to get proper air bubble offset
        ldy #$03
        jmp RelWOfs             ;get the coordinates

RelativeFireballPosition:
         ldy #$00                    ;set for fireball offsets
         jsr GetProperObjOffset      ;modify X to get proper fireball offset
         ldy #$02
RelWOfs: jsr GetObjRelativePosition  ;get the coordinates
         ldx ObjectOffset            ;return original offset
         rts                         ;leave

RelativeMiscPosition:
        ldy #$02                ;set for misc object offsets
        jsr GetProperObjOffset  ;modify X to get proper misc object offset
        ldy #$06
        jmp RelWOfs             ;get the coordinates

RelativeEnemyPosition:
        lda #$01                     ;get coordinates of enemy object
        ldy #$01                     ;relative to the screen
        jmp VariableObjOfsRelPos

RelativeBlockPosition:
        lda #$09                     ;get coordinates of one block object
        ldy #$04                     ;relative to the screen
        jsr VariableObjOfsRelPos
        inx                          ;adjust offset for other block object if any
        inx
        lda #$09
        iny                          ;adjust other and get coordinates for other one

VariableObjOfsRelPos:
        stx $00                     ;store value to add to A here
        clc
        adc $00                     ;add A to value stored
        tax                         ;use as enemy offset
        jsr GetObjRelativePosition
        ldx ObjectOffset            ;reload old object offset and leave
        rts

GetObjRelativePosition:
        lda SprObject_Y_Position,x  ;load vertical coordinate low
        sta SprObject_Rel_YPos,y    ;store here
        lda SprObject_X_Position,x  ;load horizontal coordinate
        sec                         ;subtract left edge coordinate
        sbc ScreenLeft_X_Pos
        sta SprObject_Rel_XPos,y    ;store result here
        rts

;-------------------------------------------------------------------------------------
;$00 - used as temp variable to hold offscreen bits

GetPlayerOffscreenBits:
        ldx #$00                 ;set offsets for player-specific variables
        ldy #$00                 ;and get offscreen information about player
        jmp GetOffScreenBitsSet

GetFireballOffscreenBits:
        ldy #$00                 ;set for fireball offsets
        jsr GetProperObjOffset   ;modify X to get proper fireball offset
        ldy #$02                 ;set other offset for fireball's offscreen bits
        jmp GetOffScreenBitsSet  ;and get offscreen information about fireball

GetBubbleOffscreenBits:
        ldy #$01                 ;set for air bubble offsets
        jsr GetProperObjOffset   ;modify X to get proper air bubble offset
        ldy #$03                 ;set other offset for airbubble's offscreen bits
        jmp GetOffScreenBitsSet  ;and get offscreen information about air bubble

GetMiscOffscreenBits:
        ldy #$02                 ;set for misc object offsets
        jsr GetProperObjOffset   ;modify X to get proper misc object offset
        ldy #$06                 ;set other offset for misc object's offscreen bits
        jmp GetOffScreenBitsSet  ;and get offscreen information about misc object

ObjOffsetData:
        .db $07, $16, $0d

GetProperObjOffset:
        txa                  ;move offset to A
        clc
        adc ObjOffsetData,y  ;add amount of bytes to offset depending on setting in Y
        tax                  ;put back in X and leave
        rts

GetEnemyOffscreenBits:
        lda #$01                 ;set A to add 1 byte in order to get enemy offset
        ldy #$01                 ;set Y to put offscreen bits in Enemy_OffscreenBits
        jmp SetOffscrBitsOffset

GetBlockOffscreenBits:
        lda #$09       ;set A to add 9 bytes in order to get block obj offset
        ldy #$04       ;set Y to put offscreen bits in Block_OffscreenBits

SetOffscrBitsOffset:
        stx $00
        clc           ;add contents of X to A to get
        adc $00       ;appropriate offset, then give back to X
        tax

GetOffScreenBitsSet:
        tya                         ;save offscreen bits offset to stack for now
        pha
        jsr RunOffscrBitsSubs
        asl                         ;move low nybble to high nybble
        asl
        asl
        asl
        ora $00                     ;mask together with previously saved low nybble
        sta $00                     ;store both here
        pla                         ;get offscreen bits offset from stack
        tay
        lda $00                     ;get value here and store elsewhere
        sta SprObject_OffscrBits,y
        ldx ObjectOffset
        rts

RunOffscrBitsSubs:
        jsr GetXOffscreenBits  ;do subroutine here
        lsr                    ;move high nybble to low
        lsr
        lsr
        lsr
        sta $00                ;store here
        jmp GetYOffscreenBits

;--------------------------------
;(these apply to these three subsections)
;$04 - used to store proper offset
;$05 - used as adder in DividePDiff
;$06 - used to store preset value used to compare to pixel difference in $07
;$07 - used to store difference between coordinates of object and screen edges

XOffscreenBitsData:
        .db $7f, $3f, $1f, $0f, $07, $03, $01, $00
        .db $80, $c0, $e0, $f0, $f8, $fc, $fe, $ff

DefaultXOnscreenOfs:
        .db $07, $0f, $07

GetXOffscreenBits:
          stx $04                     ;save position in buffer to here
          ldy #$01                    ;start with right side of screen
XOfsLoop: lda ScreenEdge_X_Pos,y      ;get pixel coordinate of edge
          sec                         ;get difference between pixel coordinate of edge
          sbc SprObject_X_Position,x  ;and pixel coordinate of object position
          sta $07                     ;store here
          lda ScreenEdge_PageLoc,y    ;get page location of edge
          sbc SprObject_PageLoc,x     ;subtract from page location of object position
          ldx DefaultXOnscreenOfs,y   ;load offset value here
          cmp #$00
          bmi XLdBData                ;if beyond right edge or in front of left edge, branch
          ldx DefaultXOnscreenOfs+1,y ;if not, load alternate offset value here
          cmp #$01
          bpl XLdBData                ;if one page or more to the left of either edge, branch
          lda #$38                    ;if no branching, load value here and store
          sta $06
          lda #$08                    ;load some other value and execute subroutine
          jsr DividePDiff
XLdBData: lda XOffscreenBitsData,x    ;get bits here
          ldx $04                     ;reobtain position in buffer
          cmp #$00                    ;if bits not zero, branch to leave
          bne ExXOfsBS
          dey                         ;otherwise, do left side of screen now
          bpl XOfsLoop                ;branch if not already done with left side
ExXOfsBS: rts

;--------------------------------

YOffscreenBitsData:
        .db $00, $08, $0c, $0e
        .db $0f, $07, $03, $01
        .db $00

DefaultYOnscreenOfs:
        .db $04, $00, $04

HighPosUnitData:
        .db $ff, $00

GetYOffscreenBits:
          stx $04                      ;save position in buffer to here
          ldy #$01                     ;start with top of screen
YOfsLoop: lda HighPosUnitData,y        ;load coordinate for edge of vertical unit
          sec
          sbc SprObject_Y_Position,x   ;subtract from vertical coordinate of object
          sta $07                      ;store here
          lda #$01                     ;subtract one from vertical high byte of object
          sbc SprObject_Y_HighPos,x
          ldx DefaultYOnscreenOfs,y    ;load offset value here
          cmp #$00
          bmi YLdBData                 ;if under top of the screen or beyond bottom, branch
          ldx DefaultYOnscreenOfs+1,y  ;if not, load alternate offset value here
          cmp #$01
          bpl YLdBData                 ;if one vertical unit or more above the screen, branch
          lda #$20                     ;if no branching, load value here and store
          sta $06
          lda #$04                     ;load some other value and execute subroutine
          jsr DividePDiff
YLdBData: lda YOffscreenBitsData,x     ;get offscreen data bits using offset
          ldx $04                      ;reobtain position in buffer
          cmp #$00
          bne ExYOfsBS                 ;if bits not zero, branch to leave
          dey                          ;otherwise, do bottom of the screen now
          bpl YOfsLoop
ExYOfsBS: rts

;--------------------------------

DividePDiff:
          sta $05       ;store current value in A here
          lda $07       ;get pixel difference
          cmp $06       ;compare to preset value
          bcs ExDivPD   ;if pixel difference >= preset value, branch
          lsr           ;divide by eight
          lsr
          lsr
          and #$07      ;mask out all but 3 LSB
          cpy #$01      ;right side of the screen or top?
          bcs SetOscrO  ;if so, branch, use difference / 8 as offset
          adc $05       ;if not, add value to difference / 8
SetOscrO: tax           ;use as offset
ExDivPD:  rts           ;leave

;-------------------------------------------------------------------------------------
;$00-$01 - tile numbers
;$02 - Y coordinate
;$03 - flip control
;$04 - sprite attributes
;$05 - X coordinate

DrawSpriteObject:
         lda $03                    ;get saved flip control bits
         lsr
         lsr                        ;move d1 into carry
         lda $00
         bcc NoHFlip                ;if d1 not set, branch
         sta Sprite_Tilenumber+4,y  ;store first tile into second sprite
         lda $01                    ;and second into first sprite
         sta Sprite_Tilenumber,y
         lda #$40                   ;activate horizontal flip OAM attribute
         bne SetHFAt                ;and unconditionally branch
NoHFlip: sta Sprite_Tilenumber,y    ;store first tile into first sprite
         lda $01                    ;and second into second sprite
         sta Sprite_Tilenumber+4,y
         lda #$00                   ;clear bit for horizontal flip
SetHFAt: ora $04                    ;add other OAM attributes if necessary
         sta Sprite_Attributes,y    ;store sprite attributes
         sta Sprite_Attributes+4,y
         lda $02                    ;now the y coordinates
         sta Sprite_Y_Position,y    ;note because they are
         sta Sprite_Y_Position+4,y  ;side by side, they are the same
         lda $05
         sta Sprite_X_Position,y    ;store x coordinate, then
         clc                        ;add 8 pixels and store another to
         adc #$08                   ;put them side by side
         sta Sprite_X_Position+4,y
         lda $02                    ;add eight pixels to the next y
         clc                        ;coordinate
         adc #$08
         sta $02
         tya                        ;add eight to the offset in Y to
         clc                        ;move to the next two sprites
         adc #$08
         tay
         inx                        ;increment offset to return it to the
         inx                        ;routine that called this subroutine
         rts

;-------------------------------------------------------------------------------------

;unused space
        .db $ff, $ff, $ff, $ff, $ff, $ff

;-------------------------------------------------------------------------------------

SoundEngine:
         lda OperMode              ;are we in title screen mode?
         bne SndOn
         sta SND_MASTERCTRL_REG    ;if so, disable sound and leave
         rts
SndOn:   lda #$ff
         sta JOYPAD_PORT2          ;disable irqs and set frame counter mode???
         lda #$0f
         sta SND_MASTERCTRL_REG    ;enable first four channels
         lda PauseModeFlag         ;is sound already in pause mode?
         bne InPause
         lda PauseSoundQueue       ;if not, check pause sfx queue
         cmp #$01
         bne RunSoundSubroutines   ;if queue is empty, skip pause mode routine
InPause: lda PauseSoundBuffer      ;check pause sfx buffer
         bne ContPau
         lda PauseSoundQueue       ;check pause queue
         beq SkipSoundSubroutines
         sta PauseSoundBuffer      ;if queue full, store in buffer and activate
         sta PauseModeFlag         ;pause mode to interrupt game sounds
         lda #$00                  ;disable sound and clear sfx buffers
         sta SND_MASTERCTRL_REG
         sta Square1SoundBuffer
         sta Square2SoundBuffer
         sta NoiseSoundBuffer
         lda #$0f
         sta SND_MASTERCTRL_REG    ;enable sound again
         lda #$2a                  ;store length of sound in pause counter
         sta Squ1_SfxLenCounter
PTone1F: lda #$44                  ;play first tone
         bne PTRegC                ;unconditional branch
ContPau: lda Squ1_SfxLenCounter    ;check pause length left
         cmp #$24                  ;time to play second?
         beq PTone2F
         cmp #$1e                  ;time to play first again?
         beq PTone1F
         cmp #$18                  ;time to play second again?
         bne DecPauC               ;only load regs during times, otherwise skip
PTone2F: lda #$64                  ;store reg contents and play the pause sfx
PTRegC:  ldx #$84
         ldy #$7f
         jsr PlaySqu1Sfx
DecPauC: dec Squ1_SfxLenCounter    ;decrement pause sfx counter
         bne SkipSoundSubroutines
         lda #$00                  ;disable sound if in pause mode and
         sta SND_MASTERCTRL_REG    ;not currently playing the pause sfx
         lda PauseSoundBuffer      ;if no longer playing pause sfx, check to see
         cmp #$02                  ;if we need to be playing sound again
         bne SkipPIn
         lda #$00                  ;clear pause mode to allow game sounds again
         sta PauseModeFlag
SkipPIn: lda #$00                  ;clear pause sfx buffer
         sta PauseSoundBuffer
         beq SkipSoundSubroutines

RunSoundSubroutines:
         jsr Square1SfxHandler  ;play sfx on square channel 1
         jsr Square2SfxHandler  ; ''  ''  '' square channel 2
         jsr NoiseSfxHandler    ; ''  ''  '' noise channel
         jsr MusicHandler       ;play music on all channels
         lda #$00               ;clear the music queues
         sta AreaMusicQueue
         sta EventMusicQueue

SkipSoundSubroutines:
          lda #$00               ;clear the sound effects queues
          sta Square1SoundQueue
          sta Square2SoundQueue
          sta NoiseSoundQueue
          sta PauseSoundQueue
          ldy DAC_Counter        ;load some sort of counter
          lda AreaMusicBuffer
          and #%00000011         ;check for specific music
          beq NoIncDAC
          inc DAC_Counter        ;increment and check counter
          cpy #$30
          bcc StrWave            ;if not there yet, just store it
NoIncDAC: tya
          beq StrWave            ;if we are at zero, do not decrement
          dec DAC_Counter        ;decrement counter
StrWave:  sty SND_DELTA_REG+1    ;store into DMC load register (??)
          rts                    ;we are done here

;--------------------------------

Dump_Squ1_Regs:
      sty SND_SQUARE1_REG+1  ;dump the contents of X and Y into square 1's control regs
      stx SND_SQUARE1_REG
      rts

PlaySqu1Sfx:
      jsr Dump_Squ1_Regs     ;do sub to set ctrl regs for square 1, then set frequency regs

SetFreq_Squ1:
      ldx #$00               ;set frequency reg offset for square 1 sound channel

Dump_Freq_Regs:
        tay
        lda FreqRegLookupTbl+1,y  ;use previous contents of A for sound reg offset
        beq NoTone                ;if zero, then do not load
        sta SND_REGISTER+2,x      ;first byte goes into LSB of frequency divider
        lda FreqRegLookupTbl,y    ;second byte goes into 3 MSB plus extra bit for
        ora #%00001000            ;length counter
        sta SND_REGISTER+3,x
NoTone: rts

Dump_Sq2_Regs:
      stx SND_SQUARE2_REG    ;dump the contents of X and Y into square 2's control regs
      sty SND_SQUARE2_REG+1
      rts

PlaySqu2Sfx:
      jsr Dump_Sq2_Regs      ;do sub to set ctrl regs for square 2, then set frequency regs

SetFreq_Squ2:
      ldx #$04               ;set frequency reg offset for square 2 sound channel
      bne Dump_Freq_Regs     ;unconditional branch

SetFreq_Tri:
      ldx #$08               ;set frequency reg offset for triangle sound channel
      bne Dump_Freq_Regs     ;unconditional branch

;--------------------------------

SwimStompEnvelopeData:
      .db $9f, $9b, $98, $96, $95, $94, $92, $90
      .db $90, $9a, $97, $95, $93, $92

PlayFlagpoleSlide:
       lda #$40               ;store length of flagpole sound
       sta Squ1_SfxLenCounter
       lda #$62               ;load part of reg contents for flagpole sound
       jsr SetFreq_Squ1
       ldx #$99               ;now load the rest
       bne FPS2nd

PlaySmallJump:
       lda #$26               ;branch here for small mario jumping sound
       bne JumpRegContents

PlayBigJump:
       lda #$18               ;branch here for big mario jumping sound

JumpRegContents:
       ldx #$82               ;note that small and big jump borrow each others' reg contents
       ldy #$a7               ;anyway, this loads the first part of mario's jumping sound
       jsr PlaySqu1Sfx
       lda #$28               ;store length of sfx for both jumping sounds
       sta Squ1_SfxLenCounter ;then continue on here

ContinueSndJump:
          lda Squ1_SfxLenCounter ;jumping sounds seem to be composed of three parts
          cmp #$25               ;check for time to play second part yet
          bne N2Prt
          ldx #$5f               ;load second part
          ldy #$f6
          bne DmpJpFPS           ;unconditional branch
N2Prt:    cmp #$20               ;check for third part
          bne DecJpFPS
          ldx #$48               ;load third part
FPS2nd:   ldy #$bc               ;the flagpole slide sound shares part of third part
DmpJpFPS: jsr Dump_Squ1_Regs
          bne DecJpFPS           ;unconditional branch outta here

PlayFireballThrow:
        lda #$05
        ldy #$99                 ;load reg contents for fireball throw sound
        bne Fthrow               ;unconditional branch

PlayBump:
          lda #$0a                ;load length of sfx and reg contents for bump sound
          ldy #$93
Fthrow:   ldx #$9e                ;the fireball sound shares reg contents with the bump sound
          sta Squ1_SfxLenCounter
          lda #$0c                ;load offset for bump sound
          jsr PlaySqu1Sfx

ContinueBumpThrow:
          lda Squ1_SfxLenCounter  ;check for second part of bump sound
          cmp #$06
          bne DecJpFPS
          lda #$bb                ;load second part directly
          sta SND_SQUARE1_REG+1
DecJpFPS: bne BranchToDecLength1  ;unconditional branch


Square1SfxHandler:
       ldy Square1SoundQueue   ;check for sfx in queue
       beq CheckSfx1Buffer
       sty Square1SoundBuffer  ;if found, put in buffer
       bmi PlaySmallJump       ;small jump
       lsr Square1SoundQueue
       bcs PlayBigJump         ;big jump
       lsr Square1SoundQueue
       bcs PlayBump            ;bump
       lsr Square1SoundQueue
       bcs PlaySwimStomp       ;swim/stomp
       lsr Square1SoundQueue
       bcs PlaySmackEnemy      ;smack enemy
       lsr Square1SoundQueue
       bcs PlayPipeDownInj     ;pipedown/injury
       lsr Square1SoundQueue
       bcs PlayFireballThrow   ;fireball throw
       lsr Square1SoundQueue
       bcs PlayFlagpoleSlide   ;slide flagpole

CheckSfx1Buffer:
       lda Square1SoundBuffer   ;check for sfx in buffer
       beq ExS1H                ;if not found, exit sub
       bmi ContinueSndJump      ;small mario jump
       lsr
       bcs ContinueSndJump      ;big mario jump
       lsr
       bcs ContinueBumpThrow    ;bump
       lsr
       bcs ContinueSwimStomp    ;swim/stomp
       lsr
       bcs ContinueSmackEnemy   ;smack enemy
       lsr
       bcs ContinuePipeDownInj  ;pipedown/injury
       lsr
       bcs ContinueBumpThrow    ;fireball throw
       lsr
       bcs DecrementSfx1Length  ;slide flagpole
ExS1H: rts

PlaySwimStomp:
      lda #$0e               ;store length of swim/stomp sound
      sta Squ1_SfxLenCounter
      ldy #$9c               ;store reg contents for swim/stomp sound
      ldx #$9e
      lda #$26
      jsr PlaySqu1Sfx

ContinueSwimStomp:
      ldy Squ1_SfxLenCounter        ;look up reg contents in data section based on
      lda SwimStompEnvelopeData-1,y ;length of sound left, used to control sound's
      sta SND_SQUARE1_REG           ;envelope
      cpy #$06
      bne BranchToDecLength1
      lda #$9e                      ;when the length counts down to a certain point, put this
      sta SND_SQUARE1_REG+2         ;directly into the LSB of square 1's frequency divider

BranchToDecLength1:
      bne DecrementSfx1Length  ;unconditional branch (regardless of how we got here)

PlaySmackEnemy:
      lda #$0e                 ;store length of smack enemy sound
      ldy #$cb
      ldx #$9f
      sta Squ1_SfxLenCounter
      lda #$28                 ;store reg contents for smack enemy sound
      jsr PlaySqu1Sfx
      bne DecrementSfx1Length  ;unconditional branch

ContinueSmackEnemy:
        ldy Squ1_SfxLenCounter  ;check about halfway through
        cpy #$08
        bne SmSpc
        lda #$a0                ;if we're at the about-halfway point, make the second tone
        sta SND_SQUARE1_REG+2   ;in the smack enemy sound
        lda #$9f
        bne SmTick
SmSpc:  lda #$90                ;this creates spaces in the sound, giving it its distinct noise
SmTick: sta SND_SQUARE1_REG

DecrementSfx1Length:
      dec Squ1_SfxLenCounter    ;decrement length of sfx
      bne ExSfx1

StopSquare1Sfx:
        ldx #$00                ;if end of sfx reached, clear buffer
        stx $f1                 ;and stop making the sfx
        ldx #$0e
        stx SND_MASTERCTRL_REG
        ldx #$0f
        stx SND_MASTERCTRL_REG
ExSfx1: rts

PlayPipeDownInj:
      lda #$2f                ;load length of pipedown sound
      sta Squ1_SfxLenCounter

ContinuePipeDownInj:
         lda Squ1_SfxLenCounter  ;some bitwise logic, forces the regs
         lsr                     ;to be written to only during six specific times
         bcs NoPDwnL             ;during which d3 must be set and d1-0 must be clear
         lsr
         bcs NoPDwnL
         and #%00000010
         beq NoPDwnL
         ldy #$91                ;and this is where it actually gets written in
         ldx #$9a
         lda #$44
         jsr PlaySqu1Sfx
NoPDwnL: jmp DecrementSfx1Length

;--------------------------------

ExtraLifeFreqData:
      .db $58, $02, $54, $56, $4e, $44

PowerUpGrabFreqData:
      .db $4c, $52, $4c, $48, $3e, $36, $3e, $36, $30
      .db $28, $4a, $50, $4a, $64, $3c, $32, $3c, $32
      .db $2c, $24, $3a, $64, $3a, $34, $2c, $22, $2c

;residual frequency data
      .db $22, $1c, $14

PUp_VGrow_FreqData:
      .db $14, $04, $22, $24, $16, $04, $24, $26 ;used by both
      .db $18, $04, $26, $28, $1a, $04, $28, $2a
      .db $1c, $04, $2a, $2c, $1e, $04, $2c, $2e ;used by vinegrow
      .db $20, $04, $2e, $30, $22, $04, $30, $32

PlayCoinGrab:
        lda #$35             ;load length of coin grab sound
        ldx #$8d             ;and part of reg contents
        bne CGrab_TTickRegL

PlayTimerTick:
        lda #$06             ;load length of timer tick sound
        ldx #$98             ;and part of reg contents

CGrab_TTickRegL:
        sta Squ2_SfxLenCounter
        ldy #$7f                ;load the rest of reg contents
        lda #$42                ;of coin grab and timer tick sound
        jsr PlaySqu2Sfx

ContinueCGrabTTick:
        lda Squ2_SfxLenCounter  ;check for time to play second tone yet
        cmp #$30                ;timer tick sound also executes this, not sure why
        bne N2Tone
        lda #$54                ;if so, load the tone directly into the reg
        sta SND_SQUARE2_REG+2
N2Tone: bne DecrementSfx2Length

PlayBlast:
        lda #$20                ;load length of fireworks/gunfire sound
        sta Squ2_SfxLenCounter
        ldy #$94                ;load reg contents of fireworks/gunfire sound
        lda #$5e
        bne SBlasJ

ContinueBlast:
        lda Squ2_SfxLenCounter  ;check for time to play second part
        cmp #$18
        bne DecrementSfx2Length
        ldy #$93                ;load second part reg contents then
        lda #$18
SBlasJ: bne BlstSJp             ;unconditional branch to load rest of reg contents

PlayPowerUpGrab:
        lda #$36                    ;load length of power-up grab sound
        sta Squ2_SfxLenCounter

ContinuePowerUpGrab:
        lda Squ2_SfxLenCounter      ;load frequency reg based on length left over
        lsr                         ;divide by 2
        bcs DecrementSfx2Length     ;alter frequency every other frame
        tay
        lda PowerUpGrabFreqData-1,y ;use length left over / 2 for frequency offset
        ldx #$5d                    ;store reg contents of power-up grab sound
        ldy #$7f

LoadSqu2Regs:
        jsr PlaySqu2Sfx

DecrementSfx2Length:
        dec Squ2_SfxLenCounter   ;decrement length of sfx
        bne ExSfx2

EmptySfx2Buffer:
        ldx #$00                ;initialize square 2's sound effects buffer
        stx Square2SoundBuffer

StopSquare2Sfx:
        ldx #$0d                ;stop playing the sfx
        stx SND_MASTERCTRL_REG
        ldx #$0f
        stx SND_MASTERCTRL_REG
ExSfx2: rts

Square2SfxHandler:
        lda Square2SoundBuffer ;special handling for the 1-up sound to keep it
        and #Sfx_ExtraLife     ;from being interrupted by other sounds on square 2
        bne ContinueExtraLife
        ldy Square2SoundQueue  ;check for sfx in queue
        beq CheckSfx2Buffer
        sty Square2SoundBuffer ;if found, put in buffer and check for the following
        bmi PlayBowserFall     ;bowser fall
        lsr Square2SoundQueue
        bcs PlayCoinGrab       ;coin grab
        lsr Square2SoundQueue
        bcs PlayGrowPowerUp    ;power-up reveal
        lsr Square2SoundQueue
        bcs PlayGrowVine       ;vine grow
        lsr Square2SoundQueue
        bcs PlayBlast          ;fireworks/gunfire
        lsr Square2SoundQueue
        bcs PlayTimerTick      ;timer tick
        lsr Square2SoundQueue
        bcs PlayPowerUpGrab    ;power-up grab
        lsr Square2SoundQueue
        bcs PlayExtraLife      ;1-up

CheckSfx2Buffer:
        lda Square2SoundBuffer   ;check for sfx in buffer
        beq ExS2H                ;if not found, exit sub
        bmi ContinueBowserFall   ;bowser fall
        lsr
        bcs Cont_CGrab_TTick     ;coin grab
        lsr
        bcs ContinueGrowItems    ;power-up reveal
        lsr
        bcs ContinueGrowItems    ;vine grow
        lsr
        bcs ContinueBlast        ;fireworks/gunfire
        lsr
        bcs Cont_CGrab_TTick     ;timer tick
        lsr
        bcs ContinuePowerUpGrab  ;power-up grab
        lsr
        bcs ContinueExtraLife    ;1-up
ExS2H:  rts

Cont_CGrab_TTick:
        jmp ContinueCGrabTTick

JumpToDecLength2:
        jmp DecrementSfx2Length

PlayBowserFall:
         lda #$38                ;load length of bowser defeat sound
         sta Squ2_SfxLenCounter
         ldy #$c4                ;load contents of reg for bowser defeat sound
         lda #$18
BlstSJp: bne PBFRegs

ContinueBowserFall:
          lda Squ2_SfxLenCounter   ;check for almost near the end
          cmp #$08
          bne DecrementSfx2Length
          ldy #$a4                 ;if so, load the rest of reg contents for bowser defeat sound
          lda #$5a
PBFRegs:  ldx #$9f                 ;the fireworks/gunfire sound shares part of reg contents here
EL_LRegs: bne LoadSqu2Regs         ;this is an unconditional branch outta here

PlayExtraLife:
        lda #$30                  ;load length of 1-up sound
        sta Squ2_SfxLenCounter

ContinueExtraLife:
          lda Squ2_SfxLenCounter
          ldx #$03                  ;load new tones only every eight frames
DivLLoop: lsr
          bcs JumpToDecLength2      ;if any bits set here, branch to dec the length
          dex
          bne DivLLoop              ;do this until all bits checked, if none set, continue
          tay
          lda ExtraLifeFreqData-1,y ;load our reg contents
          ldx #$82
          ldy #$7f
          bne EL_LRegs              ;unconditional branch

PlayGrowPowerUp:
        lda #$10                ;load length of power-up reveal sound
        bne GrowItemRegs

PlayGrowVine:
        lda #$20                ;load length of vine grow sound

GrowItemRegs:
        sta Squ2_SfxLenCounter
        lda #$7f                  ;load contents of reg for both sounds directly
        sta SND_SQUARE2_REG+1
        lda #$00                  ;start secondary counter for both sounds
        sta Sfx_SecondaryCounter

ContinueGrowItems:
        inc Sfx_SecondaryCounter  ;increment secondary counter for both sounds
        lda Sfx_SecondaryCounter  ;this sound doesn't decrement the usual counter
        lsr                       ;divide by 2 to get the offset
        tay
        cpy Squ2_SfxLenCounter    ;have we reached the end yet?
        beq StopGrowItems         ;if so, branch to jump, and stop playing sounds
        lda #$9d                  ;load contents of other reg directly
        sta SND_SQUARE2_REG
        lda PUp_VGrow_FreqData,y  ;use secondary counter / 2 as offset for frequency regs
        jsr SetFreq_Squ2
        rts

StopGrowItems:
        jmp EmptySfx2Buffer       ;branch to stop playing sounds

;--------------------------------

BrickShatterFreqData:
        .db $01, $0e, $0e, $0d, $0b, $06, $0c, $0f
        .db $0a, $09, $03, $0d, $08, $0d, $06, $0c

PlayBrickShatter:
        lda #$20                 ;load length of brick shatter sound
        sta Noise_SfxLenCounter

ContinueBrickShatter:
        lda Noise_SfxLenCounter
        lsr                         ;divide by 2 and check for bit set to use offset
        bcc DecrementSfx3Length
        tay
        ldx BrickShatterFreqData,y  ;load reg contents of brick shatter sound
        lda BrickShatterEnvData,y

PlayNoiseSfx:
        sta SND_NOISE_REG        ;play the sfx
        stx SND_NOISE_REG+2
        lda #$18
        sta SND_NOISE_REG+3

DecrementSfx3Length:
        dec Noise_SfxLenCounter  ;decrement length of sfx
        bne ExSfx3
        lda #$f0                 ;if done, stop playing the sfx
        sta SND_NOISE_REG
        lda #$00
        sta NoiseSoundBuffer
ExSfx3: rts

NoiseSfxHandler:
        ldy NoiseSoundQueue   ;check for sfx in queue
        beq CheckNoiseBuffer
        sty NoiseSoundBuffer  ;if found, put in buffer
        lsr NoiseSoundQueue
        bcs PlayBrickShatter  ;brick shatter
        lsr NoiseSoundQueue
        bcs PlayBowserFlame   ;bowser flame

CheckNoiseBuffer:
        lda NoiseSoundBuffer      ;check for sfx in buffer
        beq ExNH                  ;if not found, exit sub
        lsr
        bcs ContinueBrickShatter  ;brick shatter
        lsr
        bcs ContinueBowserFlame   ;bowser flame
ExNH:   rts

PlayBowserFlame:
        lda #$40                    ;load length of bowser flame sound
        sta Noise_SfxLenCounter

ContinueBowserFlame:
        lda Noise_SfxLenCounter
        lsr
        tay
        ldx #$0f                    ;load reg contents of bowser flame sound
        lda BowserFlameEnvData-1,y
        bne PlayNoiseSfx            ;unconditional branch here

;--------------------------------

ContinueMusic:
        jmp HandleSquare2Music  ;if we have music, start with square 2 channel

MusicHandler:
        lda EventMusicQueue     ;check event music queue
        bne LoadEventMusic
        lda AreaMusicQueue      ;check area music queue
        bne LoadAreaMusic
        lda EventMusicBuffer    ;check both buffers
        ora AreaMusicBuffer
        bne ContinueMusic
        rts                     ;no music, then leave

LoadEventMusic:
           sta EventMusicBuffer      ;copy event music queue contents to buffer
           cmp #DeathMusic           ;is it death music?
           bne NoStopSfx             ;if not, jump elsewhere
           jsr StopSquare1Sfx        ;stop sfx in square 1 and 2
           jsr StopSquare2Sfx        ;but clear only square 1's sfx buffer
NoStopSfx: ldx AreaMusicBuffer
           stx AreaMusicBuffer_Alt   ;save current area music buffer to be re-obtained later
           ldy #$00
           sty NoteLengthTblAdder    ;default value for additional length byte offset
           sty AreaMusicBuffer       ;clear area music buffer
           cmp #TimeRunningOutMusic  ;is it time running out music?
           bne FindEventMusicHeader
           ldx #$08                  ;load offset to be added to length byte of header
           stx NoteLengthTblAdder
           bne FindEventMusicHeader  ;unconditional branch

LoadAreaMusic:
         cmp #$04                  ;is it underground music?
         bne NoStop1               ;no, do not stop square 1 sfx
         jsr StopSquare1Sfx
NoStop1: ldy #$10                  ;start counter used only by ground level music
GMLoopB: sty GroundMusicHeaderOfs

HandleAreaMusicLoopB:
         ldy #$00                  ;clear event music buffer
         sty EventMusicBuffer
         sta AreaMusicBuffer       ;copy area music queue contents to buffer
         cmp #$01                  ;is it ground level music?
         bne FindAreaMusicHeader
         inc GroundMusicHeaderOfs  ;increment but only if playing ground level music
         ldy GroundMusicHeaderOfs  ;is it time to loopback ground level music?
         cpy #$32
         bne LoadHeader            ;branch ahead with alternate offset
         ldy #$11
         bne GMLoopB               ;unconditional branch

FindAreaMusicHeader:
        ldy #$08                   ;load Y for offset of area music
        sty MusicOffset_Square2    ;residual instruction here

FindEventMusicHeader:
        iny                       ;increment Y pointer based on previously loaded queue contents
        lsr                       ;bit shift and increment until we find a set bit for music
        bcc FindEventMusicHeader

LoadHeader:
        lda MusicHeaderOffsetData,y  ;load offset for header
        tay
        lda MusicHeaderData,y        ;now load the header
        sta NoteLenLookupTblOfs
        lda MusicHeaderData+1,y
        sta MusicDataLow
        lda MusicHeaderData+2,y
        sta MusicDataHigh
        lda MusicHeaderData+3,y
        sta MusicOffset_Triangle
        lda MusicHeaderData+4,y
        sta MusicOffset_Square1
        lda MusicHeaderData+5,y
        sta MusicOffset_Noise
        sta NoiseDataLoopbackOfs
        lda #$01                     ;initialize music note counters
        sta Squ2_NoteLenCounter
        sta Squ1_NoteLenCounter
        sta Tri_NoteLenCounter
        sta Noise_BeatLenCounter
        lda #$00                     ;initialize music data offset for square 2
        sta MusicOffset_Square2
        sta AltRegContentFlag        ;initialize alternate control reg data used by square 1
        lda #$0b                     ;disable triangle channel and reenable it
        sta SND_MASTERCTRL_REG
        lda #$0f
        sta SND_MASTERCTRL_REG

HandleSquare2Music:
        dec Squ2_NoteLenCounter  ;decrement square 2 note length
        bne MiscSqu2MusicTasks   ;is it time for more data?  if not, branch to end tasks
        ldy MusicOffset_Square2  ;increment square 2 music offset and fetch data
        inc MusicOffset_Square2
        lda (MusicData),y
        beq EndOfMusicData       ;if zero, the data is a null terminator
        bpl Squ2NoteHandler      ;if non-negative, data is a note
        bne Squ2LengthHandler    ;otherwise it is length data

EndOfMusicData:
        lda EventMusicBuffer     ;check secondary buffer for time running out music
        cmp #TimeRunningOutMusic
        bne NotTRO
        lda AreaMusicBuffer_Alt  ;load previously saved contents of primary buffer
        bne MusicLoopBack        ;and start playing the song again if there is one
NotTRO: and #VictoryMusic        ;check for victory music (the only secondary that loops)
        bne VictoryMLoopBack
        lda AreaMusicBuffer      ;check primary buffer for any music except pipe intro
        and #%01011111
        bne MusicLoopBack        ;if any area music except pipe intro, music loops
        lda #$00                 ;clear primary and secondary buffers and initialize
        sta AreaMusicBuffer      ;control regs of square and triangle channels
        sta EventMusicBuffer
        sta SND_TRIANGLE_REG
        lda #$90
        sta SND_SQUARE1_REG
        sta SND_SQUARE2_REG
        rts

MusicLoopBack:
        jmp HandleAreaMusicLoopB

VictoryMLoopBack:
        jmp LoadEventMusic

Squ2LengthHandler:
        jsr ProcessLengthData    ;store length of note
        sta Squ2_NoteLenBuffer
        ldy MusicOffset_Square2  ;fetch another byte (MUST NOT BE LENGTH BYTE!)
        inc MusicOffset_Square2
        lda (MusicData),y

Squ2NoteHandler:
          ldx Square2SoundBuffer     ;is there a sound playing on this channel?
          bne SkipFqL1
          jsr SetFreq_Squ2           ;no, then play the note
          beq Rest                   ;check to see if note is rest
          jsr LoadControlRegs        ;if not, load control regs for square 2
Rest:     sta Squ2_EnvelopeDataCtrl  ;save contents of A
          jsr Dump_Sq2_Regs          ;dump X and Y into square 2 control regs
SkipFqL1: lda Squ2_NoteLenBuffer     ;save length in square 2 note counter
          sta Squ2_NoteLenCounter

MiscSqu2MusicTasks:
           lda Square2SoundBuffer     ;is there a sound playing on square 2?
           bne HandleSquare1Music
           lda EventMusicBuffer       ;check for death music or d4 set on secondary buffer
           and #%10010001             ;note that regs for death music or d4 are loaded by default
           bne HandleSquare1Music
           ldy Squ2_EnvelopeDataCtrl  ;check for contents saved from LoadControlRegs
           beq NoDecEnv1
           dec Squ2_EnvelopeDataCtrl  ;decrement unless already zero
NoDecEnv1: jsr LoadEnvelopeData       ;do a load of envelope data to replace default
           sta SND_SQUARE2_REG        ;based on offset set by first load unless playing
           ldx #$7f                   ;death music or d4 set on secondary buffer
           stx SND_SQUARE2_REG+1

HandleSquare1Music:
        ldy MusicOffset_Square1    ;is there a nonzero offset here?
        beq HandleTriangleMusic    ;if not, skip ahead to the triangle channel
        dec Squ1_NoteLenCounter    ;decrement square 1 note length
        bne MiscSqu1MusicTasks     ;is it time for more data?

FetchSqu1MusicData:
        ldy MusicOffset_Square1    ;increment square 1 music offset and fetch data
        inc MusicOffset_Square1
        lda (MusicData),y
        bne Squ1NoteHandler        ;if nonzero, then skip this part
        lda #$83
        sta SND_SQUARE1_REG        ;store some data into control regs for square 1
        lda #$94                   ;and fetch another byte of data, used to give
        sta SND_SQUARE1_REG+1      ;death music its unique sound
        sta AltRegContentFlag
        bne FetchSqu1MusicData     ;unconditional branch

Squ1NoteHandler:
           jsr AlternateLengthHandler
           sta Squ1_NoteLenCounter    ;save contents of A in square 1 note counter
           ldy Square1SoundBuffer     ;is there a sound playing on square 1?
           bne HandleTriangleMusic
           txa
           and #%00111110             ;change saved data to appropriate note format
           jsr SetFreq_Squ1           ;play the note
           beq SkipCtrlL
           jsr LoadControlRegs
SkipCtrlL: sta Squ1_EnvelopeDataCtrl  ;save envelope offset
           jsr Dump_Squ1_Regs

MiscSqu1MusicTasks:
              lda Square1SoundBuffer     ;is there a sound playing on square 1?
              bne HandleTriangleMusic
              lda EventMusicBuffer       ;check for death music or d4 set on secondary buffer
              and #%10010001
              bne DeathMAltReg
              ldy Squ1_EnvelopeDataCtrl  ;check saved envelope offset
              beq NoDecEnv2
              dec Squ1_EnvelopeDataCtrl  ;decrement unless already zero
NoDecEnv2:    jsr LoadEnvelopeData       ;do a load of envelope data
              sta SND_SQUARE1_REG        ;based on offset set by first load
DeathMAltReg: lda AltRegContentFlag      ;check for alternate control reg data
              bne DoAltLoad
              lda #$7f                   ;load this value if zero, the alternate value
DoAltLoad:    sta SND_SQUARE1_REG+1      ;if nonzero, and let's move on

HandleTriangleMusic:
        lda MusicOffset_Triangle
        dec Tri_NoteLenCounter    ;decrement triangle note length
        bne HandleNoiseMusic      ;is it time for more data?
        ldy MusicOffset_Triangle  ;increment square 1 music offset and fetch data
        inc MusicOffset_Triangle
        lda (MusicData),y
        beq LoadTriCtrlReg        ;if zero, skip all this and move on to noise
        bpl TriNoteHandler        ;if non-negative, data is note
        jsr ProcessLengthData     ;otherwise, it is length data
        sta Tri_NoteLenBuffer     ;save contents of A
        lda #$1f
        sta SND_TRIANGLE_REG      ;load some default data for triangle control reg
        ldy MusicOffset_Triangle  ;fetch another byte
        inc MusicOffset_Triangle
        lda (MusicData),y
        beq LoadTriCtrlReg        ;check once more for nonzero data

TriNoteHandler:
          jsr SetFreq_Tri
          ldx Tri_NoteLenBuffer   ;save length in triangle note counter
          stx Tri_NoteLenCounter
          lda EventMusicBuffer
          and #%01101110          ;check for death music or d4 set on secondary buffer
          bne NotDOrD4            ;if playing any other secondary, skip primary buffer check
          lda AreaMusicBuffer     ;check primary buffer for water or castle level music
          and #%00001010
          beq HandleNoiseMusic    ;if playing any other primary, or death or d4, go on to noise routine
NotDOrD4: txa                     ;if playing water or castle music or any secondary
          cmp #$12                ;besides death music or d4 set, check length of note
          bcs LongN
          lda EventMusicBuffer    ;check for win castle music again if not playing a long note
          and #EndOfCastleMusic
          beq MediN
          lda #$0f                ;load value $0f if playing the win castle music and playing a short
          bne LoadTriCtrlReg      ;note, load value $1f if playing water or castle level music or any
MediN:    lda #$1f                ;secondary besides death and d4 except win castle or win castle and playing
          bne LoadTriCtrlReg      ;a short note, and load value $ff if playing a long note on water, castle
LongN:    lda #$ff                ;or any secondary (including win castle) except death and d4

LoadTriCtrlReg:
        sta SND_TRIANGLE_REG      ;save final contents of A into control reg for triangle

HandleNoiseMusic:
        lda AreaMusicBuffer       ;check if playing underground or castle music
        and #%11110011
        beq ExitMusicHandler      ;if so, skip the noise routine
        dec Noise_BeatLenCounter  ;decrement noise beat length
        bne ExitMusicHandler      ;is it time for more data?

FetchNoiseBeatData:
        ldy MusicOffset_Noise       ;increment noise beat offset and fetch data
        inc MusicOffset_Noise
        lda (MusicData),y           ;get noise beat data, if nonzero, branch to handle
        bne NoiseBeatHandler
        lda NoiseDataLoopbackOfs    ;if data is zero, reload original noise beat offset
        sta MusicOffset_Noise       ;and loopback next time around
        bne FetchNoiseBeatData      ;unconditional branch

NoiseBeatHandler:
        jsr AlternateLengthHandler
        sta Noise_BeatLenCounter    ;store length in noise beat counter
        txa
        and #%00111110              ;reload data and erase length bits
        beq SilentBeat              ;if no beat data, silence
        cmp #$30                    ;check the beat data and play the appropriate
        beq LongBeat                ;noise accordingly
        cmp #$20
        beq StrongBeat
        and #%00010000
        beq SilentBeat
        lda #$1c        ;short beat data
        ldx #$03
        ldy #$18
        bne PlayBeat

StrongBeat:
        lda #$1c        ;strong beat data
        ldx #$0c
        ldy #$18
        bne PlayBeat

LongBeat:
        lda #$1c        ;long beat data
        ldx #$03
        ldy #$58
        bne PlayBeat

SilentBeat:
        lda #$10        ;silence

PlayBeat:
        sta SND_NOISE_REG    ;load beat data into noise regs
        stx SND_NOISE_REG+2
        sty SND_NOISE_REG+3

ExitMusicHandler:
        rts

AlternateLengthHandler:
        tax            ;save a copy of original byte into X
        ror            ;save LSB from original byte into carry
        txa            ;reload original byte and rotate three times
        rol            ;turning xx00000x into 00000xxx, with the
        rol            ;bit in carry as the MSB here
        rol

ProcessLengthData:
        and #%00000111              ;clear all but the three LSBs
        clc
        adc $f0                     ;add offset loaded from first header byte
        adc NoteLengthTblAdder      ;add extra if time running out music
        tay
        lda MusicLengthLookupTbl,y  ;load length
        rts

LoadControlRegs:
           lda EventMusicBuffer  ;check secondary buffer for win castle music
           and #EndOfCastleMusic
           beq NotECstlM
           lda #$04              ;this value is only used for win castle music
           bne AllMus            ;unconditional branch
NotECstlM: lda AreaMusicBuffer
           and #%01111101        ;check primary buffer for water music
           beq WaterMus
           lda #$08              ;this is the default value for all other music
           bne AllMus
WaterMus:  lda #$28              ;this value is used for water music and all other event music
AllMus:    ldx #$82              ;load contents of other sound regs for square 2
           ldy #$7f
           rts

LoadEnvelopeData:
        lda EventMusicBuffer           ;check secondary buffer for win castle music
        and #EndOfCastleMusic
        beq LoadUsualEnvData
        lda EndOfCastleMusicEnvData,y  ;load data from offset for win castle music
        rts

LoadUsualEnvData:
        lda AreaMusicBuffer            ;check primary buffer for water music
        and #%01111101
        beq LoadWaterEventMusEnvData
        lda AreaMusicEnvData,y         ;load default data from offset for all other music
        rts

LoadWaterEventMusEnvData:
        lda WaterEventMusEnvData,y     ;load data from offset for water music and all other event music
        rts

;--------------------------------

;music header offsets

MusicHeaderData:
      .db DeathMusHdr-MHD           ;event music
      .db GameOverMusHdr-MHD
      .db VictoryMusHdr-MHD
      .db WinCastleMusHdr-MHD
      .db GameOverMusHdr-MHD
      .db EndOfLevelMusHdr-MHD
      .db TimeRunningOutHdr-MHD
      .db SilenceHdr-MHD

      .db GroundLevelPart1Hdr-MHD   ;area music
      .db WaterMusHdr-MHD
      .db UndergroundMusHdr-MHD
      .db CastleMusHdr-MHD
      .db Star_CloudHdr-MHD
      .db GroundLevelLeadInHdr-MHD
      .db Star_CloudHdr-MHD
      .db SilenceHdr-MHD

      .db GroundLevelLeadInHdr-MHD  ;ground level music layout
      .db GroundLevelPart1Hdr-MHD, GroundLevelPart1Hdr-MHD
      .db GroundLevelPart2AHdr-MHD, GroundLevelPart2BHdr-MHD, GroundLevelPart2AHdr-MHD, GroundLevelPart2CHdr-MHD
      .db GroundLevelPart2AHdr-MHD, GroundLevelPart2BHdr-MHD, GroundLevelPart2AHdr-MHD, GroundLevelPart2CHdr-MHD
      .db GroundLevelPart3AHdr-MHD, GroundLevelPart3BHdr-MHD, GroundLevelPart3AHdr-MHD, GroundLevelLeadInHdr-MHD
      .db GroundLevelPart1Hdr-MHD, GroundLevelPart1Hdr-MHD
      .db GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD
      .db GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD
      .db GroundLevelPart3AHdr-MHD, GroundLevelPart3BHdr-MHD, GroundLevelPart3AHdr-MHD, GroundLevelLeadInHdr-MHD
      .db GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD

;music headers
;header format is as follows:
;1 byte - length byte offset
;2 bytes -  music data address
;1 byte - triangle data offset
;1 byte - square 1 data offset
;1 byte - noise data offset (not used by secondary music)

TimeRunningOutHdr:    .db $08, <TimeRunOutMusData, >TimeRunOutMusData, $27, $18
Star_CloudHdr:        .db $20, <Star_CloudMData, >Star_CloudMData, $2e, $1a, $40
EndOfLevelMusHdr:     .db $20, <WinLevelMusData, >WinLevelMusData, $3d, $21
ResidualHeaderData:   .db $20, $c4, $fc, $3f, $1d
UndergroundMusHdr:    .db $18, <UndergroundMusData, >UndergroundMusData, $00, $00
SilenceHdr:           .db $08, <SilenceData, >SilenceData, $00
CastleMusHdr:         .db $00, <CastleMusData, >CastleMusData, $93, $62
VictoryMusHdr:        .db $10, <VictoryMusData, >VictoryMusData, $24, $14
GameOverMusHdr:       .db $18, <GameOverMusData, >GameOverMusData, $1e, $14
WaterMusHdr:          .db $08, <WaterMusData, >WaterMusData, $a0, $70, $68
WinCastleMusHdr:      .db $08, <EndOfCastleMusData, >EndOfCastleMusData, $4c, $24
GroundLevelPart1Hdr:  .db $18, <GroundM_P1Data, >GroundM_P1Data, $2d, $1c, $b8
GroundLevelPart2AHdr: .db $18, <GroundM_P2AData, >GroundM_P2AData, $20, $12, $70
GroundLevelPart2BHdr: .db $18, <GroundM_P2BData, >GroundM_P2BData, $1b, $10, $44
GroundLevelPart2CHdr: .db $18, <GroundM_P2CData, >GroundM_P2CData, $11, $0a, $1c
GroundLevelPart3AHdr: .db $18, <GroundM_P3AData, >GroundM_P3AData, $2d, $10, $58
GroundLevelPart3BHdr: .db $18, <GroundM_P3BData, >GroundM_P3BData, $14, $0d, $3f
GroundLevelLeadInHdr: .db $18, <GroundMLdInData, >GroundMLdInData, $15, $0d, $21
GroundLevelPart4AHdr: .db $18, <GroundM_P4AData, >GroundM_P4AData, $18, $10, $7a
GroundLevelPart4BHdr: .db $18, <GroundM_P4BData, >GroundM_P4BData, $19, $0f, $54
GroundLevelPart4CHdr: .db $18, <GroundM_P4CData, >GroundM_P4CData, $1e, $12, $2b
DeathMusHdr:          .db $18, <DeathMusData, >DeathMusData, $1e, $0f, $2d

;--------------------------------

;MUSIC DATA
;square 2/triangle format
;d7 - length byte flag (0-note, 1-length)
;if d7 is set to 0 and d6-d0 is nonzero:
;d6-d0 - note offset in frequency look-up table (must be even)
;if d7 is set to 1:
;d6-d3 - unused
;d2-d0 - length offset in length look-up table
;value of $00 in square 2 data is used as null terminator, affects all sound channels
;value of $00 in triangle data causes routine to skip note

;square 1 format
;d7-d6, d0 - length offset in length look-up table (bit order is d0,d7,d6)
;d5-d1 - note offset in frequency look-up table
;value of $00 in square 1 data is flag alternate control reg data to be loaded

;noise format
;d7-d6, d0 - length offset in length look-up table (bit order is d0,d7,d6)
;d5-d4 - beat type (0 - rest, 1 - short, 2 - strong, 3 - long)
;d3-d1 - unused
;value of $00 in noise data is used as null terminator, affects only noise

;all music data is organized into sections (unless otherwise stated):
;square 2, square 1, triangle, noise

Star_CloudMData:
      .db $84, $2c, $2c, $2c, $82, $04, $2c, $04, $85, $2c, $84, $2c, $2c
      .db $2a, $2a, $2a, $82, $04, $2a, $04, $85, $2a, $84, $2a, $2a, $00

      .db $1f, $1f, $1f, $98, $1f, $1f, $98, $9e, $98, $1f
      .db $1d, $1d, $1d, $94, $1d, $1d, $94, $9c, $94, $1d

      .db $86, $18, $85, $26, $30, $84, $04, $26, $30
      .db $86, $14, $85, $22, $2c, $84, $04, $22, $2c

      .db $21, $d0, $c4, $d0, $31, $d0, $c4, $d0, $00

GroundM_P1Data:
      .db $85, $2c, $22, $1c, $84, $26, $2a, $82, $28, $26, $04
      .db $87, $22, $34, $3a, $82, $40, $04, $36, $84, $3a, $34
      .db $82, $2c, $30, $85, $2a

SilenceData:
      .db $00

      .db $5d, $55, $4d, $15, $19, $96, $15, $d5, $e3, $eb
      .db $2d, $a6, $2b, $27, $9c, $9e, $59

      .db $85, $22, $1c, $14, $84, $1e, $22, $82, $20, $1e, $04, $87
      .db $1c, $2c, $34, $82, $36, $04, $30, $34, $04, $2c, $04, $26
      .db $2a, $85, $22

GroundM_P2AData:
      .db $84, $04, $82, $3a, $38, $36, $32, $04, $34
      .db $04, $24, $26, $2c, $04, $26, $2c, $30, $00

      .db $05, $b4, $b2, $b0, $2b, $ac, $84
      .db $9c, $9e, $a2, $84, $94, $9c, $9e

      .db $85, $14, $22, $84, $2c, $85, $1e
      .db $82, $2c, $84, $2c, $1e

GroundM_P2BData:
      .db $84, $04, $82, $3a, $38, $36, $32, $04, $34
      .db $04, $64, $04, $64, $86, $64, $00

      .db $05, $b4, $b2, $b0, $2b, $ac, $84
      .db $37, $b6, $b6, $45

      .db $85, $14, $1c, $82, $22, $84, $2c
      .db $4e, $82, $4e, $84, $4e, $22

GroundM_P2CData:
      .db $84, $04, $85, $32, $85, $30, $86, $2c, $04, $00

      .db $05, $a4, $05, $9e, $05, $9d, $85

      .db $84, $14, $85, $24, $28, $2c, $82
      .db $22, $84, $22, $14

      .db $21, $d0, $c4, $d0, $31, $d0, $c4, $d0, $00

GroundM_P3AData:
      .db $82, $2c, $84, $2c, $2c, $82, $2c, $30
      .db $04, $34, $2c, $04, $26, $86, $22, $00

      .db $a4, $25, $25, $a4, $29, $a2, $1d, $9c, $95

GroundM_P3BData:
      .db $82, $2c, $2c, $04, $2c, $04, $2c, $30, $85, $34, $04, $04, $00

      .db $a4, $25, $25, $a4, $a8, $63, $04

;triangle data used by both sections of third part
      .db $85, $0e, $1a, $84, $24, $85, $22, $14, $84, $0c

GroundMLdInData:
      .db $82, $34, $84, $34, $34, $82, $2c, $84, $34, $86, $3a, $04, $00

      .db $a0, $21, $21, $a0, $21, $2b, $05, $a3

      .db $82, $18, $84, $18, $18, $82, $18, $18, $04, $86, $3a, $22

;noise data used by lead-in and third part sections
      .db $31, $90, $31, $90, $31, $71, $31, $90, $90, $90, $00

GroundM_P4AData:
      .db $82, $34, $84, $2c, $85, $22, $84, $24
      .db $82, $26, $36, $04, $36, $86, $26, $00

      .db $ac, $27, $5d, $1d, $9e, $2d, $ac, $9f

      .db $85, $14, $82, $20, $84, $22, $2c
      .db $1e, $1e, $82, $2c, $2c, $1e, $04

GroundM_P4BData:
      .db $87, $2a, $40, $40, $40, $3a, $36
      .db $82, $34, $2c, $04, $26, $86, $22, $00

      .db $e3, $f7, $f7, $f7, $f5, $f1, $ac, $27, $9e, $9d

      .db $85, $18, $82, $1e, $84, $22, $2a
      .db $22, $22, $82, $2c, $2c, $22, $04

DeathMusData:
      .db $86, $04 ;death music share data with fourth part c of ground level music

GroundM_P4CData:
      .db $82, $2a, $36, $04, $36, $87, $36, $34, $30, $86, $2c, $04, $00

      .db $00, $68, $6a, $6c, $45 ;death music only

      .db $a2, $31, $b0, $f1, $ed, $eb, $a2, $1d, $9c, $95

      .db $86, $04 ;death music only

      .db $85, $22, $82, $22, $87, $22, $26, $2a, $84, $2c, $22, $86, $14

;noise data used by fourth part sections
      .db $51, $90, $31, $11, $00

CastleMusData:
      .db $80, $22, $28, $22, $26, $22, $24, $22, $26
      .db $22, $28, $22, $2a, $22, $28, $22, $26
      .db $22, $28, $22, $26, $22, $24, $22, $26
      .db $22, $28, $22, $2a, $22, $28, $22, $26
      .db $20, $26, $20, $24, $20, $26, $20, $28
      .db $20, $26, $20, $28, $20, $26, $20, $24
      .db $20, $26, $20, $24, $20, $26, $20, $28
      .db $20, $26, $20, $28, $20, $26, $20, $24
      .db $28, $30, $28, $32, $28, $30, $28, $2e
      .db $28, $30, $28, $2e, $28, $2c, $28, $2e
      .db $28, $30, $28, $32, $28, $30, $28, $2e
      .db $28, $30, $28, $2e, $28, $2c, $28, $2e, $00

      .db $04, $70, $6e, $6c, $6e, $70, $72, $70, $6e
      .db $70, $6e, $6c, $6e, $70, $72, $70, $6e
      .db $6e, $6c, $6e, $70, $6e, $70, $6e, $6c
      .db $6e, $6c, $6e, $70, $6e, $70, $6e, $6c
      .db $76, $78, $76, $74, $76, $74, $72, $74
      .db $76, $78, $76, $74, $76, $74, $72, $74

      .db $84, $1a, $83, $18, $20, $84, $1e, $83, $1c, $28
      .db $26, $1c, $1a, $1c

GameOverMusData:
      .db $82, $2c, $04, $04, $22, $04, $04, $84, $1c, $87
      .db $26, $2a, $26, $84, $24, $28, $24, $80, $22, $00

      .db $9c, $05, $94, $05, $0d, $9f, $1e, $9c, $98, $9d

      .db $82, $22, $04, $04, $1c, $04, $04, $84, $14
      .db $86, $1e, $80, $16, $80, $14

TimeRunOutMusData:
      .db $81, $1c, $30, $04, $30, $30, $04, $1e, $32, $04, $32, $32
      .db $04, $20, $34, $04, $34, $34, $04, $36, $04, $84, $36, $00

      .db $46, $a4, $64, $a4, $48, $a6, $66, $a6, $4a, $a8, $68, $a8
      .db $6a, $44, $2b

      .db $81, $2a, $42, $04, $42, $42, $04, $2c, $64, $04, $64, $64
      .db $04, $2e, $46, $04, $46, $46, $04, $22, $04, $84, $22

WinLevelMusData:
      .db $87, $04, $06, $0c, $14, $1c, $22, $86, $2c, $22
      .db $87, $04, $60, $0e, $14, $1a, $24, $86, $2c, $24
      .db $87, $04, $08, $10, $18, $1e, $28, $86, $30, $30
      .db $80, $64, $00

      .db $cd, $d5, $dd, $e3, $ed, $f5, $bb, $b5, $cf, $d5
      .db $db, $e5, $ed, $f3, $bd, $b3, $d1, $d9, $df, $e9
      .db $f1, $f7, $bf, $ff, $ff, $ff, $34
      .db $00 ;unused byte

      .db $86, $04, $87, $14, $1c, $22, $86, $34, $84, $2c
      .db $04, $04, $04, $87, $14, $1a, $24, $86, $32, $84
      .db $2c, $04, $86, $04, $87, $18, $1e, $28, $86, $36
      .db $87, $30, $30, $30, $80, $2c

;square 2 and triangle use the same data, square 1 is unused
UndergroundMusData:
      .db $82, $14, $2c, $62, $26, $10, $28, $80, $04
      .db $82, $14, $2c, $62, $26, $10, $28, $80, $04
      .db $82, $08, $1e, $5e, $18, $60, $1a, $80, $04
      .db $82, $08, $1e, $5e, $18, $60, $1a, $86, $04
      .db $83, $1a, $18, $16, $84, $14, $1a, $18, $0e, $0c
      .db $16, $83, $14, $20, $1e, $1c, $28, $26, $87
      .db $24, $1a, $12, $10, $62, $0e, $80, $04, $04
      .db $00

;noise data directly follows square 2 here unlike in other songs
WaterMusData:
      .db $82, $18, $1c, $20, $22, $26, $28
      .db $81, $2a, $2a, $2a, $04, $2a, $04, $83, $2a, $82, $22
      .db $86, $34, $32, $34, $81, $04, $22, $26, $2a, $2c, $30
      .db $86, $34, $83, $32, $82, $36, $84, $34, $85, $04, $81, $22
      .db $86, $30, $2e, $30, $81, $04, $22, $26, $2a, $2c, $2e
      .db $86, $30, $83, $22, $82, $36, $84, $34, $85, $04, $81, $22
      .db $86, $3a, $3a, $3a, $82, $3a, $81, $40, $82, $04, $81, $3a
      .db $86, $36, $36, $36, $82, $36, $81, $3a, $82, $04, $81, $36
      .db $86, $34, $82, $26, $2a, $36
      .db $81, $34, $34, $85, $34, $81, $2a, $86, $2c, $00

      .db $84, $90, $b0, $84, $50, $50, $b0, $00

      .db $98, $96, $94, $92, $94, $96, $58, $58, $58, $44
      .db $5c, $44, $9f, $a3, $a1, $a3, $85, $a3, $e0, $a6
      .db $23, $c4, $9f, $9d, $9f, $85, $9f, $d2, $a6, $23
      .db $c4, $b5, $b1, $af, $85, $b1, $af, $ad, $85, $95
      .db $9e, $a2, $aa, $6a, $6a, $6b, $5e, $9d

      .db $84, $04, $04, $82, $22, $86, $22
      .db $82, $14, $22, $2c, $12, $22, $2a, $14, $22, $2c
      .db $1c, $22, $2c, $14, $22, $2c, $12, $22, $2a, $14
      .db $22, $2c, $1c, $22, $2c, $18, $22, $2a, $16, $20
      .db $28, $18, $22, $2a, $12, $22, $2a, $18, $22, $2a
      .db $12, $22, $2a, $14, $22, $2c, $0c, $22, $2c, $14, $22, $34, $12
      .db $22, $30, $10, $22, $2e, $16, $22, $34, $18, $26
      .db $36, $16, $26, $36, $14, $26, $36, $12, $22, $36
      .db $5c, $22, $34, $0c, $22, $22, $81, $1e, $1e, $85, $1e
      .db $81, $12, $86, $14

EndOfCastleMusData:
      .db $81, $2c, $22, $1c, $2c, $22, $1c, $85, $2c, $04
      .db $81, $2e, $24, $1e, $2e, $24, $1e, $85, $2e, $04
      .db $81, $32, $28, $22, $32, $28, $22, $85, $32
      .db $87, $36, $36, $36, $84, $3a, $00

      .db $5c, $54, $4c, $5c, $54, $4c
      .db $5c, $1c, $1c, $5c, $5c, $5c, $5c
      .db $5e, $56, $4e, $5e, $56, $4e
      .db $5e, $1e, $1e, $5e, $5e, $5e, $5e
      .db $62, $5a, $50, $62, $5a, $50
      .db $62, $22, $22, $62, $e7, $e7, $e7, $2b

      .db $86, $14, $81, $14, $80, $14, $14, $81, $14, $14, $14, $14
      .db $86, $16, $81, $16, $80, $16, $16, $81, $16, $16, $16, $16
      .db $81, $28, $22, $1a, $28, $22, $1a, $28, $80, $28, $28
      .db $81, $28, $87, $2c, $2c, $2c, $84, $30

VictoryMusData:
      .db $83, $04, $84, $0c, $83, $62, $10, $84, $12
      .db $83, $1c, $22, $1e, $22, $26, $18, $1e, $04, $1c, $00

      .db $e3, $e1, $e3, $1d, $de, $e0, $23
      .db $ec, $75, $74, $f0, $f4, $f6, $ea, $31, $2d

      .db $83, $12, $14, $04, $18, $1a, $1c, $14
      .db $26, $22, $1e, $1c, $18, $1e, $22, $0c, $14

;unused space
      .db $ff, $ff, $ff

FreqRegLookupTbl:
      .db $00, $88, $00, $2f, $00, $00
      .db $02, $a6, $02, $80, $02, $5c, $02, $3a
      .db $02, $1a, $01, $df, $01, $c4, $01, $ab
      .db $01, $93, $01, $7c, $01, $67, $01, $53
      .db $01, $40, $01, $2e, $01, $1d, $01, $0d
      .db $00, $fe, $00, $ef, $00, $e2, $00, $d5
      .db $00, $c9, $00, $be, $00, $b3, $00, $a9
      .db $00, $a0, $00, $97, $00, $8e, $00, $86
      .db $00, $77, $00, $7e, $00, $71, $00, $54
      .db $00, $64, $00, $5f, $00, $59, $00, $50
      .db $00, $47, $00, $43, $00, $3b, $00, $35
      .db $00, $2a, $00, $23, $04, $75, $03, $57
      .db $02, $f9, $02, $cf, $01, $fc, $00, $6a

MusicLengthLookupTbl:
      .db $05, $0a, $14, $28, $50, $1e, $3c, $02
      .db $04, $08, $10, $20, $40, $18, $30, $0c
      .db $03, $06, $0c, $18, $30, $12, $24, $08
      .db $36, $03, $09, $06, $12, $1b, $24, $0c
      .db $24, $02, $06, $04, $0c, $12, $18, $08
      .db $12, $01, $03, $02, $06, $09, $0c, $04

EndOfCastleMusicEnvData:
      .db $98, $99, $9a, $9b

AreaMusicEnvData:
      .db $90, $94, $94, $95, $95, $96, $97, $98

WaterEventMusEnvData:
      .db $90, $91, $92, $92, $93, $93, $93, $94
      .db $94, $94, $94, $94, $94, $95, $95, $95
      .db $95, $95, $95, $96, $96, $96, $96, $96
      .db $96, $96, $96, $96, $96, $96, $96, $96
      .db $96, $96, $96, $96, $95, $95, $94, $93

BowserFlameEnvData:
      .db $15, $16, $16, $17, $17, $18, $19, $19
      .db $1a, $1a, $1c, $1d, $1d, $1e, $1e, $1f
      .db $1f, $1f, $1f, $1e, $1d, $1c, $1e, $1f
      .db $1f, $1e, $1d, $1c, $1a, $18, $16, $14

BrickShatterEnvData:
      .db $15, $16, $16, $17, $17, $18, $19, $19
      .db $1a, $1a, $1c, $1d, $1d, $1e, $1e, $1f

;-------------------------------------------------------------------------------------
;INTERRUPT VECTORS

      .dw NonMaskableInterrupt
      .dw Start
      .dw $fff0  ;unused
