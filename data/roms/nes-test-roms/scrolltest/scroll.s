;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บSplit screen multidirection scrolling with MMC1 mapper                       บ
;บWritten by Cadaver, 1-2/2000                                                 บ
;บFixed to work on Nintendulator by Cadaver, 1/2004, added NTSC detection      บ
;บMore stuff maybe to follow..                                                 บ
;บ                                                                             บ
;บUse freely, but at your own risk!                                            บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

                processor 6502
                org $c000

CTRL_A          = 1
CTRL_B          = 2
CTRL_SELECT     = 4
CTRL_START      = 8
CTRL_UP         = 16
CTRL_DOWN       = 32
CTRL_LEFT       = 64
CTRL_RIGHT      = 128

SCRSIZEX        = 32
SCRSIZEY        = 30
SCROLL_LEFT     = 1
SCROLL_RIGHT    = 2
SCROLL_UP       = 4
SCROLL_DOWN     = 8
SPLITPOINT      = $c0
PPU0VALUE       = $80

nmicount        = $00
mapptrlo        = $01
mapptrhi        = $02
blockx          = $03
blocky          = $04
scrollx         = $05
scrolly         = $06
scrollsx        = $07
scrollsy        = $08
rawscrollx      = $09
rawscrolly      = $0a
screenshift     = $0b
srclo           = $0c
srchi           = $0d
destlo          = $0e
desthi          = $0f
mcharlo         = $10
mcharhi         = $11
mcharunder      = $12
temp1           = $13
temp2           = $14
temp3           = $15
temp4           = $16
temp5           = $17
temp6           = $18
temp7           = $19
temp8           = $1a
temp9           = $1b
controldelay    = $1c
control         = $1d
ntscflag        = $1e
ntscdelay       = $1f


COLORBUF        = $680
HORIZBUF        = $6c0
btmrowlo        = $6de
btmrowhi        = $6df
VERTBUF         = $6e0
SPRBUF          = $700

start:          sei                             ;Forbid interrupts
                ldx #$ff
                txs
                jsr setupppu
                jsr setupmapper
                jsr clearsprites
                jsr detectntsc
                jsr waitvblank
                jsr loadchars
                jsr loadpalette
                jsr setnametable
                jsr resetscroll
                lda #<mapdata
                sta mapptrlo
                lda #>mapdata
                sta mapptrhi
                lda #$00                        ;Set initial speed
                sta scrollsx
                sta scrollsy
                sta controldelay

mainloop:       jsr waitvblank
                jsr erasemagicchar
                jsr scrollaction
                jsr drawmagicchar
                jsr setgamescreen
                jsr setsprites

                lda ntscdelay                   ;Handle NTSC delay
                sec
                sbc ntscflag
                bcs ml_nontscdelay
                lda #$05
ml_nontscdelay: sta ntscdelay
                bcc ml_skip

                jsr readcontroller
                jsr steering
                jsr scrolllogic
ml_skip:        jsr setpanel
mainloop2:      jmp mainloop

readcontroller: lda #$01
                sta $4016
                lda #$00
                sta $4016
                sta control
                ldx #$08
readcloop:      lda $4016
                ror
                lda control
                ror
                sta control
                dex
                bne readcloop
                rts

steering:       inc controldelay
                lda controldelay
                and #$03
                beq steering2
                rts
steering2:      lda control
                and #CTRL_UP
                beq steering3
                lda scrollsy
                cmp #-8
                beq steering3
                dec scrollsy
steering3:      lda control
                and #CTRL_DOWN
                beq steering4
                lda scrollsy
                cmp #8
                beq steering4
                inc scrollsy
steering4:      lda control
                and #CTRL_LEFT
                beq steering5
                lda scrollsx
                cmp #-8
                beq steering5
                dec scrollsx
steering5:      lda control
                and #CTRL_RIGHT
                beq steering6
                lda scrollsx
                cmp #8
                beq steering6
                inc scrollsx
steering6:      lda control
                and #CTRL_A+CTRL_B
                beq steering7
                lda #$00
                sta scrollsx
                sta scrollsy
steering7:      rts

resetscroll:    lda #$00
                sta scrollx
                sta scrolly
                sta scrollsx
                sta scrollsy
                sta rawscrollx
                sta rawscrolly
                sta blockx
                sta blocky
                sta screenshift
                ldx #$07                        ;Calculate 7 * MAPSIZEX
                lda #$00                        ;to help scrolling
                sta btmrowlo
                sta btmrowhi
rscr_loop1:     lda btmrowlo
                clc
                adc mapsizex
                sta btmrowlo
                lda btmrowhi
                adc mapsizex+1
                sta btmrowhi
                dex
                bne rscr_loop1
                ldx #$3f
rscr_loop2:     lda #$00                        ;Clear color buffer
                sta COLORBUF,x
                dex
                bpl rscr_loop2
                lda #$ff                        ;Reset magic char
                sta mcharlo
                sta mcharhi
                lda #SPLITPOINT-1               ;Set sprite0 for screen
                sta SPRBUF                      ;split
                lda #$ff
                sta SPRBUF+1
                lda #$00
                sta SPRBUF+2
                lda #$f8
                sta SPRBUF+3
                rts

erasemagicchar: lda mcharhi
                bmi emc_noneed
                sta $2006
                lda mcharlo
                sta $2006
                lda mcharunder
                sta $2007
emc_noneed:     lda #$ff
                sta mcharhi
                sta mcharlo
                rts

drawmagicchar:  lda rawscrolly
                clc
                adc #(SPLITPOINT/8)+2
                cmp #SCRSIZEY
                bcc dmc_posok
                sbc #SCRSIZEY
dmc_posok:      asl
                tax
                lda scract_rowtbl+1,x
                sta mcharhi
                lda scrollx
                and #$07
                cmp #$01
                lda rawscrollx
                adc #SCRSIZEX-2
                and #SCRSIZEX-1
                ora scract_rowtbl,x
                sta mcharlo
                lda mcharhi
                sta $2006
                lda mcharlo
                sta $2006
                lda $2007                       ;First read is rubbish
                lda $2007
                sta mcharunder
                lda mcharhi
                sta $2006
                lda mcharlo
                sta $2006
                lda #$ff
                sta $2007
                rts

;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บSCROLLLOGIC                                                                  บ
;บ                                                                             บ
;บUpdates scrolling position, block & map pointers and draws the new graphics  บ
;บto the horizontal and vertical buffers for the SCROLLACTION routine.         บ
;บ                                                                             บ
;บParameters: -                                                                บ
;บReturns:    -                                                                บ
;บDestroys:   A,X,Y                                                            บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

scrolllogic:    lda #$00
                sta screenshift
                lda scrollx
                lsr
                lsr
                lsr
                sta temp1                       ;Temp1 = old raw x scrolling
                lda scrolly
                lsr
                lsr
                lsr
                sta temp2                       ;Temp2 = old raw y scrolling
                lda scrollx
                clc
                adc scrollsx
                sta scrollx
                lsr
                lsr
                lsr
                sta rawscrollx                  ;New raw x scrolling
                lda scrollsy
                clc
                adc scrolly
                cmp #$f0
                bcc scrlog_notover
                ldx scrollsy
                bmi scrlog_overneg
                sec
                sbc #$f0
                jmp scrlog_notover
scrlog_overneg: sec
                sbc #$10
scrlog_notover: sta scrolly
                lsr
                lsr
                lsr
                sta rawscrolly                  ;new raw y scrolling
                lda temp1                       ;Any shifting in X-dir?
                cmp rawscrollx
                beq scrlog_xshiftok
                lda scrollsx
                bmi scrlog_xshiftneg
                lda #SCROLL_RIGHT
                sta screenshift
                inc blockx
                lda blockx
                cmp #$04
                bne scrlog_xshiftok
                lda #$00
                sta blockx
                inc mapptrlo
                bne scrlog_xshiftok
                inc mapptrhi
                jmp scrlog_xshiftok
scrlog_xshiftneg:
                lda #SCROLL_LEFT
                sta screenshift
                dec blockx
                bpl scrlog_xshiftok
                lda #$03
                sta blockx
                dec mapptrlo
                lda mapptrlo
                cmp #$ff
                bne scrlog_xshiftok
                dec mapptrhi
scrlog_xshiftok:
                lda temp2                       ;Any shifting in Y-dir?
                cmp rawscrolly
                beq scrlog_yshiftok
                lda scrollsy
                bmi scrlog_yshiftneg
                lda #SCROLL_DOWN
                ora screenshift
                sta screenshift
                inc blocky
                lda blocky
                cmp #$04
                bne scrlog_yshiftok
                lda #$00
                sta blocky
                lda mapptrlo
                clc
                adc mapsizex
                sta mapptrlo
                lda mapptrhi
                adc mapsizex+1
                sta mapptrhi
                jmp scrlog_yshiftok
scrlog_yshiftneg:
                lda #SCROLL_UP
                ora screenshift
                sta screenshift
                dec blocky
                bpl scrlog_yshiftok
                lda #$03
                sta blocky
                lda mapptrlo
                sec
                sbc mapsizex
                sta mapptrlo
                lda mapptrhi
                sbc mapsizex+1
                sta mapptrhi
scrlog_yshiftok:lda screenshift
                asl
                tax
                lda scrlog_jumptbl,x
                sta temp1
                lda scrlog_jumptbl+1,x
                sta temp2
                jmp (temp1)

scrlog_jumptbl: dc.w scrlog_shno    ;0
                dc.w scrlog_shleft  ;1
                dc.w scrlog_shright ;2
                dc.w scrlog_shno    ;3
                dc.w scrlog_shup    ;4
                dc.w scrlog_shupleft ;5
                dc.w scrlog_shupright ;6
                dc.w scrlog_shno    ;7
                dc.w scrlog_shdown  ;8
                dc.w scrlog_shdownleft ;9
                dc.w scrlog_shdownright ;10

scrlog_shno:    rts
scrlog_shleft:  jmp scrlog_doleft
scrlog_shright: jmp scrlog_doright
scrlog_shup:    jmp scrlog_doup
scrlog_shdown:  jmp scrlog_dodown
scrlog_shupleft:jsr scrlog_doleft
                jmp scrlog_doup
scrlog_shupright:jsr scrlog_doright
                jmp scrlog_doup
scrlog_shdownleft:jsr scrlog_doleft
                jmp scrlog_dodown
scrlog_shdownright:jsr scrlog_doright
                jmp scrlog_dodown

scrlog_doleft:  lda mapptrlo            ;Calc. map pointer
                sta srclo
                lda mapptrhi
                sta srchi
                lda #SCRSIZEY
                sta temp1               ;Chars to do
                lda rawscrollx          ;Position onscreen where drawing
                sta temp6               ;happens (to help coloring)
                ldx rawscrolly          ;Pointer within screen
                lda blocky              ;Calc. starting blockindex
                asl
                asl
                adc blockx
scrlog_doleftnb:sta temp2               ;Index within block
                ldy #$00                ;Get block from map
                lda (srclo),y
                tay
                lda blocktbllo,y
                sta destlo
                lda blocktblhi,y
                sta desthi
                lda blockdata,y         ;Color
                sta temp5
                ldy temp2
scrlog_doleftloop:
                lda (destlo),y
                sta HORIZBUF,x
                jsr scrlog_xcolor
                inx
                cpx #SCRSIZEY
                bcc scrlog_doleftno1
                ldx #$00
scrlog_doleftno1:
                dec temp1
                beq scrlog_doleftrdy
                tya
                clc
                adc #$04
                tay
                cmp #$10
                bcc scrlog_doleftloop
                lda srclo
                clc
                adc mapsizex
                sta srclo
                lda srchi
                adc mapsizex+1
                sta srchi
                lda blockx
                jmp scrlog_doleftnb
scrlog_doleftrdy:rts

scrlog_doright: lda mapptrlo
                clc
                adc #$07
                sta srclo
                lda mapptrhi
                adc #$00
                sta srchi
                lda rawscrollx
                clc
                adc #SCRSIZEX-1
                and #SCRSIZEX-1
                sta temp6
                lda #SCRSIZEY
                sta temp1               ;Chars to do
                lda blockx
                clc
                adc #$03
                cmp #$04
                bcc scrlog_dorightno2
                and #$03
                pha
                inc srclo
                bne scrlog_dorightno3
                inc srchi
scrlog_dorightno3:pla
scrlog_dorightno2:sta temp3
                ldx rawscrolly          ;Pointer within screen
                lda blocky
                asl
                asl
                clc
                adc temp3
scrlog_dorightnb:sta temp2               ;Pointer within block
                ldy #$00                ;Get block from map
                lda (srclo),y
                tay
                lda blocktbllo,y
                sta destlo
                lda blocktblhi,y
                sta desthi
                lda blockdata,y         ;Color
                sta temp5
                ldy temp2
scrlog_dorightloop:
                lda (destlo),y
                sta HORIZBUF,x
                jsr scrlog_xcolor
                inx
                cpx #SCRSIZEY
                bcc scrlog_dorightno1
                ldx #$00
scrlog_dorightno1:
                dec temp1
                beq scrlog_dorightrdy
                tya
                clc
                adc #$04
                tay
                cmp #$10
                bcc scrlog_dorightloop
                lda srclo
                clc
                adc mapsizex
                sta srclo
                lda srchi
                adc mapsizex+1
                sta srchi
                lda temp3
                jmp scrlog_dorightnb
scrlog_dorightrdy:rts

scrlog_doup:    lda mapptrlo
                sta srclo
                lda mapptrhi
                sta srchi
                lda #SCRSIZEX
                sta temp1               ;Chars to do
                lda rawscrolly
                sta temp6
                ldx rawscrollx          ;Pointer within screen
                lda blocky
                asl
                asl
                sta temp3
                adc blockx
scrlog_doupnb:  sta temp2               ;Pointer within block
                ldy #$00                ;Get block from map
                lda (srclo),y
                tay
                lda blocktbllo,y
                sta destlo
                lda blocktblhi,y
                sta desthi
                lda blockdata,y         ;Color
                sta temp5
                ldy temp2
scrlog_douploop:lda (destlo),y
                sta VERTBUF,x
                jsr scrlog_ycolor
                inx
                txa
                and #SCRSIZEX-1
                tax
                dec temp1
                beq scrlog_douprdy
                iny
                tya
                and #$03
                bne scrlog_douploop
                inc srclo
                bne scrlog_doupno2
                inc srchi
scrlog_doupno2: lda temp3
                jmp scrlog_doupnb
scrlog_douprdy: rts

scrlog_dodown:  lda mapptrlo
                clc
                adc btmrowlo
                sta srclo
                lda mapptrhi
                adc btmrowhi
                sta srchi
                lda #SCRSIZEX
                sta temp1               ;Chars to do
                lda rawscrolly
                clc
                adc #SCRSIZEY-1
                cmp #SCRSIZEY
                bcc scrlog_dodownok1
                sbc #SCRSIZEY
scrlog_dodownok1:
                sta temp6
                ldx rawscrollx          ;Pointer within screen
                lda blocky
                clc
                adc #$01
                cmp #$04
                bcc scrlog_dodownno3
                and #$03
                pha
                lda srclo
                clc
                adc mapsizex
                sta srclo
                lda srchi
                adc mapsizex+1
                sta srchi
                pla
scrlog_dodownno3:
                asl
                asl
                sta temp3
                adc blockx
scrlog_dodownnb:sta temp2               ;Pointer within block
                ldy #$00                ;Get block from map
                lda (srclo),y
                tay
                lda blocktbllo,y
                sta destlo
                lda blocktblhi,y
                sta desthi
                lda blockdata,y         ;Color
                sta temp5
                ldy temp2
scrlog_dodownloop:lda (destlo),y
                sta VERTBUF,x
                jsr scrlog_ycolor
                inx
                txa
                and #SCRSIZEX-1
                tax
                dec temp1
                beq scrlog_dodownrdy
                iny
                tya
                and #$03
                bne scrlog_dodownloop
                inc srclo
                bne scrlog_dodownno2
                inc srchi
scrlog_dodownno2:lda temp3
                jmp scrlog_dodownnb
scrlog_dodownrdy:rts

;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บSCRLOG_XCOLOR                                                                บ
;บSCRLOG_YCOLOR                                                                บ
;บ                                                                             บ
;บSubroutines to color the blocks (not so simple :-))                          บ
;บ                                                                             บ
;บParameters: Temp5 = Block color byte                                         บ
;บ            Temp6 = Position (X for xcolor, Y for ycolor)                    บ
;บ            X     = Position in the other axis                               บ
;บ            Y     = Position within the block                                บ
;บReturns:    -                                                                บ
;บDestroys:   A                                                                บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

scrlog_xcolor:  txa
                and #$01
                beq scrlog_xcolorok
                rts
scrlog_xcolorok:tya
                and #$02                ;Right part of block?
                bne scrlog_xcolor0
                lda temp5
                jmp scrlog_xcolor1
scrlog_xcolor0: lda temp5
                lsr
                lsr
scrlog_xcolor1: cpy #$08                ;Lower part of block?
                bcc scrlog_xcolor2
                lsr
                lsr
                lsr
                lsr
scrlog_xcolor2: and #$03
                sta temp7               ;Color now in temp7
                txa
                asl
                and #$f8
                sta temp8               ;Position, where to draw
                lda temp6
                lsr
                lsr
                clc
                adc temp8
                sta temp8               ;Byteposition is ready in temp8
                sty temp9               ;Store Y
                txa                     ;Check Y-fineposition
                and #$02
                bne scrlog_xcolor5      ;Lower part
scrlog_xcolor3: lda temp6               ;Check X-fineposition
                and #$02
                bne scrlog_xcolor4      ;Right part
                ldy temp8
                lda COLORBUF,y
                and #%11111100
                ora temp7
                sta COLORBUF,y
                ldy temp9               ;Get Y back
                rts
scrlog_xcolor4: ldy temp7
                lda scrlog_mul4tbl,y
                sta temp7
                ldy temp8
                lda COLORBUF,y
                and #%11110011
                ora temp7
                sta COLORBUF,y
                ldy temp9
                rts
scrlog_xcolor5: lda temp6
                and #$02
                bne scrlog_xcolor6
                ldy temp7
                lda scrlog_mul16tbl,y
                sta temp7
                ldy temp8
                lda COLORBUF,y
                and #%11001111
                ora temp7
                sta COLORBUF,y
                ldy temp9
                rts
scrlog_xcolor6: ldy temp7
                lda scrlog_mul64tbl,y
                sta temp7
                ldy temp8
                lda COLORBUF,y
                and #%00111111
                ora temp7
                sta COLORBUF,y
                ldy temp9
                rts

scrlog_ycolor:  txa
                and #$01
                beq scrlog_ycolorok
                rts
scrlog_ycolorok:tya
                and #$02                ;Right part of block?
                bne scrlog_ycolor0
                lda temp5
                jmp scrlog_ycolor1
scrlog_ycolor0: lda temp5
                lsr
                lsr
scrlog_ycolor1: cpy #$08                ;Lower part of block?
                bcc scrlog_ycolor2
                lsr
                lsr
                lsr
                lsr
scrlog_ycolor2: and #$03
                sta temp7               ;Color now in temp7
                lda temp6
                asl
                and #$f8
                sta temp8               ;Position, where to draw
                txa
                lsr
                lsr
                clc
                adc temp8
                sta temp8               ;Byteposition is ready in temp8
                sty temp9               ;Store Y
                lda temp6               ;Check Y-fineposition
                and #$02
                bne scrlog_ycolor5      ;Lower part
scrlog_ycolor3: txa                     ;Check X-fineposition
                and #$02
                bne scrlog_ycolor4      ;Right part
                ldy temp8
                lda COLORBUF,y
                and #%11111100
                ora temp7
                sta COLORBUF,y
                ldy temp9               ;Get Y back
                rts
scrlog_ycolor4: ldy temp7
                lda scrlog_mul4tbl,y
                sta temp7
                ldy temp8
                lda COLORBUF,y
                and #%11110011
                ora temp7
                sta COLORBUF,y
                ldy temp9
                rts
scrlog_ycolor5: txa
                and #$02
                bne scrlog_ycolor6
                ldy temp7
                lda scrlog_mul16tbl,y
                sta temp7
                ldy temp8
                lda COLORBUF,y
                and #%11001111
                ora temp7
                sta COLORBUF,y
                ldy temp9
                rts
scrlog_ycolor6: ldy temp7
                lda scrlog_mul64tbl,y
                sta temp7
                ldy temp8
                lda COLORBUF,y
                and #%00111111
                ora temp7
                sta COLORBUF,y
                ldy temp9
                rts

scrlog_mul4tbl: dc.b 0,4,8,12
scrlog_mul16tbl:dc.b 0,16,32,48
scrlog_mul64tbl:dc.b 0,64,128,192

;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บSCROLLACTION                                                                 บ
;บ                                                                             บ
;บBlits the horizontal & vertical buffers to PPU memory and also updates       บ
;บattribute table. To be called during vblank. Also, RESETSCROLL or SCROLLLOGICบ
;บmust be called before calling this.                                          บ
;บ                                                                             บ
;บParameters: -                                                                บ
;บReturns:    -                                                                บ
;บDestroys:   A,X,Y                                                            บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

scrollaction:   lda $2002
                lda screenshift
                asl
                tax
                lda scract_jumptbl,x
                sta temp1
                lda scract_jumptbl+1,x
                sta temp2
                jmp (temp1)

scract_jumptbl: dc.w scract_done    ;0
                dc.w scract_doleft  ;1
                dc.w scract_doright ;2
                dc.w scract_done    ;3
                dc.w scract_doup    ;4
                dc.w scract_doupleft ;5
                dc.w scract_doupright ;6
                dc.w scract_done    ;7
                dc.w scract_dodown  ;8
                dc.w scract_dodownleft ;9
                dc.w scract_dodownright ;10

scract_doupleft:jsr scract_doleft
                jmp scract_doup

scract_doupright:jsr scract_doright
                jmp scract_doup

scract_dodownleft:jsr scract_doleft
                jmp scract_dodown

scract_dodownright:jsr scract_doright
                jmp scract_dodown

scract_doleft:  lda #$20
                sta $2006
                lda rawscrollx
                and #$1f
                sta $2006
                jsr scract_horizshift
                lda rawscrollx
                lsr
                lsr
                tax
scract_doleftattr:
N               SET 0
                REPEAT 8
                lda #$23
                sta $2006
                txa
                ora #$c0+N
                sta $2006
                lda COLORBUF+N,x
                sta $2007
N               SET N+8
                REPEND
scract_done:    rts

scract_doright: lda #$20
                sta $2006
                lda rawscrollx
                clc
                adc #SCRSIZEX-1
                and #$1f
                sta $2006
                jsr scract_horizshift
                lda rawscrollx
                clc
                adc #$1f
                and #$1f
                lsr
                lsr
                tax
                jmp scract_doleftattr

scract_doup:    lda rawscrolly
                asl
                tax
                lda scract_rowtbl+1,x
                sta $2006
                lda scract_rowtbl,x
                sta $2006
                jsr scract_vertshift
                lda #$23
                sta $2006
                lda rawscrolly
                asl
                and #$f8
                tax
                ora #$c0
                sta $2006
scract_doupattr:
N               SET 0
                REPEAT 8
                lda COLORBUF+N,x
                sta $2007
N               SET N+1
                REPEND
                rts

scract_dodown:  lda rawscrolly
                clc
                adc #SCRSIZEY-1
                cmp #SCRSIZEY
                bcc scract_dodownok1
                sbc #SCRSIZEY
scract_dodownok1:
                sta temp1
                asl
                tax
                lda scract_rowtbl+1,x
                sta $2006
                lda scract_rowtbl,x
                sta $2006
                jsr scract_vertshift
                lda #$23
                sta $2006
                lda temp1
                asl
                and #$f8
                tax
                ora #$c0
                sta $2006
                jmp scract_doupattr

scract_horizshift:
                lda #PPU0VALUE+4         ;Vertical increment
                sta $2000
N               SET 0
                REPEAT SCRSIZEY
                lda HORIZBUF+N
                sta $2007
N               SET N+1
                REPEND
                lda #PPU0VALUE           ;Normal increment
                sta $2000
                rts

scract_vertshift:
N               SET 0
                REPEAT SCRSIZEX
                lda VERTBUF+N
                sta $2007
N               SET N+1
                REPEND
                rts

scract_rowtbl:
N               SET $2000
                REPEAT SCRSIZEY
                dc.w N
N               SET N+32
                REPEND

setgamescreen:  lda #$00
                sta $2006
                sta $2006
                lda scrollx
                sec
                sbc #$08
                sta $2005
                lda scrolly
                clc
                adc #$10
                cmp #SCRSIZEY*8
                bcc setgame_ok
                sbc #SCRSIZEY*8
setgame_ok:     sta $2005
                lda #$1c                        ;Turn on onescreen mirror
                jsr write8000
                lda #$18                        ;BG & sprites on, clipping
                sta $2001
                lda #$00                        ;Assume no shifting on next fr.
                sta screenshift
                rts

setpanel:       bit $2002                       ;Wait if sprite hit still on
                bvs setpanel
                ldx nmicount
setpanel_wait:  cpx nmicount                    ;Check if vblank occurs before
                bne setpanel_toolong            ;spritehit (something went
                bit $2002                       ;wrong)
                bvc setpanel_wait
                lda #$00                        ;Blank screen
                sta $2001
                lda #$1e                        ;Turn off onescreen mirror
                jsr write8000
                lda #$00
                ldy #$04                        ;Set scrolling & display pos.
                sta $2005
                sta $2005
                sty $2006
                sta $2006
                lda #$0a
                sta $2001                       ;Just BG on, no sprites, no clip
setpanel_toolong:
                rts

setsprites:     lda #>SPRBUF                    ;Start sprite DMA
                sta $4014
                rts

clearsprites:   ldx #$00
clrspr_loop:    lda #$f0
                sta SPRBUF,x
                lda #$00
                sta SPRBUF+1,x
                lda #$00
                sta SPRBUF+2,x
                lda #$f8
                sta SPRBUF+3,x
                inx
                inx
                inx
                inx
                bne clrspr_loop
                rts

setnametable:   lda #$1e                        ;Turn off onescreen mirror
                jsr write8000
                lda #PPU0VALUE                  ;Normal increment
                sta $2000
                lda #$20                        ;Address $2000
                sta $2006
                lda #$00
                sta $2006
                ldx #$00
                ldy #$00
setntbl_loop1:  lda #$00                        ;Wipe both nametables
                sta $2007
                inx
                bne setntbl_loop1
                iny
                cpy #$08
                bcc setntbl_loop1
                ldx #$00
                lda #$24                        ;Address $2400
                sta $2006
                lda #$00
                sta $2006
                lda ntscflag
                bne setntbl_loop3

setntbl_loop2:  lda paneltext,x                 ;Now write text to the
                and #$3f                        ;second nametable
                sta $2007
                inx
                cpx #6*32
                bcc setntbl_loop2
                rts
setntbl_loop3:  lda paneltext2,x                ;Now write text to the
                and #$3f                        ;second nametable
                sta $2007
                inx
                cpx #6*32
                bcc setntbl_loop3
                rts

loadpalette:    lda #$3f
                sta $2006
                lda #$00
                sta $2006
                ldx #$00
loadpalette2:   lda palette,x
                sta $2007
                inx
                cpx #$20
                bne loadpalette2
                rts

loadchars:      lda #$00
                sta $2006
                sta $2006
                lda #<chardata
                sta srclo
                lda #>chardata
                sta srchi
                ldy #$00
                ldx #$10
loadchars2:     lda (srclo),y
                sta $2007
                iny
                bne loadchars2
                inc srchi
                dex
                bne loadchars2
                rts

detectntsc:     lda #$01
                sta ntscflag              ;Assume NTSC
                sta ntscdelay
                jsr waitvblank
                lda #$00
                sta temp1
                sta temp2
                lda nmicount
dntsc_loop:     cmp nmicount
                bne dntsc_over
                inc temp1
                bne dntsc_loop
                inc temp2
                bne dntsc_loop
dntsc_over:     asl temp1
                lda temp2
                rol
                cmp #$12
                bcc dntsc_nopal
                dec ntscflag
dntsc_nopal:    rts


setupppu:       lda #PPU0VALUE          ;Blank screen, leave NMI's on
                sta $2000
                lda #$00
                sta $2001
                rts

setupmapper:    lda #$1e
write8000:      pha                     ;Write to MMC 1 mapper
                lda #$80                ;First reset
                sta $8000               ;Then 5 bits of data
                pla
                sta $8000
                lsr
                sta $8000
                lsr
                sta $8000
                lsr
                sta $8000
                lsr
                sta $8000
                rts

waitvblank:     lda nmicount
waitvblank2:    cmp nmicount
                beq waitvblank2
                lda #$00                        ;Blank screen, with clipping
                sta $2001
                lda $2002
                lda #$1e                        ;Turn off onescreen mirror
                jmp write8000

nmi:            inc nmicount
irq:            rti

paneltext:      dc.b    "                                "
                dc.b $1d,"MULTIDIRECTIONAL SCROLLING TEST"
                dc.b $1e,"RUNNING IN PAL, 50HZ REFRESH   "
                dc.b $1f
                ds.b 30,$3c
                dc.b $3e
                dc.b "                                "
                dc.b "                                "
                dc.b "                                "

paneltext2:     dc.b    "                                "
                dc.b $1d,"MULTIDIRECTIONAL SCROLLING TEST"
                dc.b $1e,"RUNNING IN NTSC, 60HZ REFRESH  "
                dc.b $1f
                ds.b 30,$3c
                dc.b $3e
                dc.b "                                "
                dc.b "                                "
                dc.b "                                "


blocktbllo:
N               SET blockdata+512
                REPEAT 128
                dc.b N
N               SET N+16
                REPEND

blocktblhi:
N               SET blockdata+512
                REPEAT 128
                dc.b N/256
N               SET N+16
                REPEND

palette:        incbin scrtest.pal
                incbin scrtest.pal

blockdata:      incbin scrtest.blk

map:            incbin scrtest.map
mapsizex        = map+0
mapsizey        = map+2
mapdata         = map+4

chardata:       incbin scrtest.chr

                org $fffa

                dc.w nmi
                dc.w start
                dc.w irq

