; Startup code for cc65 and Shiru's NES library
; based on code by Groepaz/Hitmen <groepaz@gmx.net>, Ullrich von Bassewitz <uz@cc65.org>


NES_MAPPER				=0	;mapper number
NES_PRG_BANKS			=3	;number of 16K PRG banks, change to 2 for NROM256
NES_CHR_BANKS			=1	;number of 8K CHR banks
NES_MIRRORING			=0	;0 horizontal, 1 vertical, 8 four screen

FT_DPCM_OFF				=$ff00	;samples offset, $c000 or higher, 64-byte steps
FT_SFX_STREAMS			=4	;number of sound effects played at once, can be 4 or less (faster)

.define FT_DPCM_ENABLE 	0	;zero to exclude all the DMC code
.define FT_SFX_ENABLE  	1	;zero to exclude all the sound effects code

.define SPEED_FIX		1	;zero if you want to handle PAL/NTSC speed difference by yourself


    .export _exit,__STARTUP__:absolute=1
	.import initlib,push0,popa,popax,_main,zerobss,copydata

; Linker generated symbols
	.import __RAM_START__   ,__RAM_SIZE__
	.import __ROM0_START__  ,__ROM0_SIZE__
	.import __STARTUP_LOAD__,__STARTUP_RUN__,__STARTUP_SIZE__
	.import	__CODE_LOAD__   ,__CODE_RUN__   ,__CODE_SIZE__
	.import	__RODATA_LOAD__ ,__RODATA_RUN__ ,__RODATA_SIZE__

    .include "zeropage.inc"


PPU_CTRL	=$2000
PPU_MASK	=$2001
PPU_STATUS	=$2002
PPU_OAM_ADDR=$2003
PPU_OAM_DATA=$2004
PPU_SCROLL	=$2005
PPU_ADDR	=$2006
PPU_DATA	=$2007
PPU_OAM_DMA	=$4014
PPU_FRAMECNT=$4017
DMC_FREQ	=$4010
CTRL_PORT1	=$4016
CTRL_PORT2	=$4017

OAM_BUF		=$0200
PAL_BUF		=$01c0

FRAMECNT1	=$00
FRAMECNT2	=$01
NTSCMODE	=$02
VRAMUPDATE	=$03
PAD_STATE	=$04	;2 bytes, one per controller
PAD_STATEP	=$06	;2 bytes
PAD_STATET	=$08	;2 bytes
FT_TEMP		=$0a	;7 bytes in zeropage
SCROLL_X	=$11
SCROLL_Y	=$12
PPU_CTRL_VAR=$13
PPU_MASK_VAR=$14
NAME_UPD_ADR=$15	;word
NAME_UPD_LEN=$17
PAL_PTR		=$18	;word
RAND_SEED	=$1a	;word

TEMP		=$1c

PAD_BUF		=TEMP+1

PTR			=TEMP	;word
LEN			=TEMP+2	;word
NEXTSPR		=TEMP+4
SCRX		=TEMP+5
SCRY		=TEMP+6
SRC			=TEMP+7	;word
DST			=TEMP+9	;word

RLE_LOW		=TEMP
RLE_HIGH	=TEMP+1
RLE_TAG		=TEMP+2
RLE_BYTE	=TEMP+3


FT_BASE_ADR		=$0100	;page in RAM, should be $xx00
FT_DPCM_PTR		=(FT_DPCM_OFF&$3fff)>>6

.define FT_THREAD      1;undefine if you call sound effects in the same thread as sound update



.segment "HEADER"

    .byte $4e,$45,$53,$1a
	.byte NES_PRG_BANKS
	.byte NES_CHR_BANKS
	.byte NES_MIRRORING|(NES_MAPPER<<4)
	.byte NES_MAPPER&$f0
	.res 8,0


.segment "STARTUP"

start:
_exit:

    sei
    ldx #$ff
    txs
    inx
    stx PPU_MASK
    stx DMC_FREQ
    stx PPU_CTRL		;no NMI

    bit PPU_STATUS
@1:
    bit PPU_STATUS
    bpl @1

    txa
@clearRAM:
    sta $000,x
    sta $100,x
    sta $200,x
    sta $300,x
    sta $400,x
    sta $500,x
    sta $600,x
    sta $700,x
    inx
    bne @clearRAM

@clearVRAM:
	lda #$20
	sta PPU_ADDR
	txa
	sta PPU_ADDR
	ldy #$10
@3:
	sta PPU_DATA
	inx
	bne @3
	dey
	bne @3

	lda #4
	jsr _pal_bright
	lda #0
	jsr _pal_clear
	jsr _oam_clear

    bit PPU_STATUS
@2:
    bit PPU_STATUS
    bpl @2

    jsr	zerobss
	jsr	copydata

    lda #<(__RAM_START__+__RAM_SIZE__)
    sta	sp
    lda	#>(__RAM_START__+__RAM_SIZE__)
    sta	sp+1            ; Set argument stack ptr

	jsr	initlib

	lda #%10000000
	sta <PPU_CTRL_VAR
	sta PPU_CTRL		;enable NMI
	lda #%00000110
	sta <PPU_MASK_VAR

	lda <FRAMECNT1
@wait:
	cmp <FRAMECNT1
	beq @wait

	ldx #52				;blargg's code
	ldy #24
@detectNTSC:
	dex
	bne @detectNTSC
	dey
	bne @detectNTSC

	lda PPU_STATUS
	and #$80
	sta <NTSCMODE

	jsr _ppu_off

	lda <NTSCMODE
	jsr FamiToneInit

	.if(FT_DPCM_ENABLE)
	ldx #<music_dpcm
	ldy #>music_dpcm
	jsr FamiToneSampleInit
	.endif

	.if(FT_SFX_ENABLE)
	ldx #<sounds_data
	ldy #>sounds_data
	jsr FamiToneSfxInit
	.endif

	.if(!SPEED_FIX)
	lda #0
	sta <NTSCMODE
	.endif

	lda #$fd
	sta <RAND_SEED
	sta <RAND_SEED+1

	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL

	jmp _main			;no parameters

	.include "neslib.s"

.segment "RODATA"

	.include "music.s"

	.if(FT_SFX_ENABLE)
sounds_data:
	.include "sounds.s"
	.endif

.segment "SAMPLES"

	;.incbin "music_dpcm.bin"

.segment "VECTORS"

    .word nmi	;$fffa vblank nmi
    .word start	;$fffc reset
   	.word irq	;$fffe irq / brk


.segment "CHARS"

	.incbin "tileset.chr"

.segment "PADDING"
	.res 2048,0