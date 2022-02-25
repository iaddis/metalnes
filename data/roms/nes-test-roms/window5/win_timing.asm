.ramsection "TimingVars" SLOT 0

FractionTiming  db
ScanlineCount   db
Temp        db
.ends

;X = $f8 = 248
;Y = $7f = 127
;Pixel = 341*Y + X = 43555
;N1 = (Pixel + 290) / 3 = 14615 (NTSC)
;N2 = (Pixel * 5 + 1444) / 16 = 13701.18 = 13701 (PAL)
.section "Win_Timing" ALIGN $100 FREE
Effect
.ifdef PAL
	lda #255            ;8 cycles (6 for jsr)
.else
	lda #85*2           ;8 cycles (6 for jsr)
.endif
	sta FractionTiming  ;11
	lda #$ff            ;13
	sta ScanlineCount   ;16

.ifdef PAL 
    DELAY 13666
.else 
    DELAY 14580

.endif

TimedCode
						;   Best
	jmp RAMTimedCode    ;   337
_timedLoop
	lda FractionTiming  ;   5
	clc                 ;   11
.ifndef PAL
	adc #$aa            ;   15
.else   adc #$90
.endif  sta FractionTiming  ;   24
	bcs +                   ;   33
+   inc ScanlineCount       ;   48 (add 3 cycles each 3 frames here, to compensate the effect)
	ldx ScanlineCount.w     ;   57
	lda ColorTable.w,X      ;   69
	bmi _noColorWrite       ;   75
	sta RAMTimedCode+3.w    ;   87  Write color
	lda PPUAdrLTable.w,X    ;   99
	sta RAMTimedCode+24.w   ;   111
	lda PPUAdrHTable.w,X    ;   123
	sta RAMTimedCode+5.w    ;   135
.ifndef PAL
	pha
	pla
.endif
	jmp TimedCode       ;   186 (one less than previous frame)

_noColorWrite               ;   78
	nop
	nop
	cmp #$ff                ;   84
	beq _windowColorEnd ;   90
	;lda #$00
	;sta $2005
	;sta $2005

	ldx #12                 ;   132
-   dex                     ;   (12*15=180 cycles -> 126+180=306)
	bne -                   ;   303 (3 less because the branch didn't happen last time)
.ifndef PAL
	pha
	pla
.endif  ldx FractionTiming
	ldx FractionTiming
	jmp _timedLoop          ;   339

_windowColorEnd             ;   93
	ldx #7
-   dex
	bne -
	bit $2002
	ldx #$3f
	stx $2006.w
	lda #$00
	ldx #$0f
	ldy #$1e
	sta $2001
	sta $2006
	stx $2007.w
	sty $2001.w
	lda ScanlineCount
	tax
	and #$03
	tay
	lda PPUAdrHTable.w,Y
	ora #$01
	sta $2006.w
	lda PPUAdrLTable.w,X
	sta $2006.w
	lda ScrollH
	sta $2005
	lda M2000
	sta $2000
	rts


;HBlank writes :

;$2006:=$3f, $00
;$2001:=$00
;$2007:=$xx = 3
;$2006:=$xx, $xx = 5, 27
;$2001:=$1e         Best        Worst

VeryTimedCode
	lda #$3f    ;   187
	ldx #$00    ;   193
	ldy #$00    ;   199
	bit $2002.w ;   205
	sta $2006.w ;   217
	lda #$00    ;   229
	sta $2001.w ;   235     214
	sta $2006.w ;   247     226
				;   *** Begining of actual HBlank (on best case)
	sty $2006.w ;   259     238
	lda #$00    ;   271     250 ; rewritten
				; Begining of the actual HBlank in worst case (glitches !)
	ldy #$1e    ;   277     256
	stx $2007.w ;   283     262
	sta $2006.w ;   295     274
	sty $2001.w ;   307     286
.ifdef PAL
	lda #4      ;   319     298
.else
	lda #4      ;   319     298
.endif
	sta $2005.w ;   325     304
	jmp _timedLoop  ;   337     316
.ends

.section "TuningTables" ALIGN $100 FREE
ColorTable
	.db $2c, $3c, $2c, $3c, $f9, $f0, $f9, $fe
	.db $2c, $2c, $3c, $31, $21, $21, $31, $21

	.db $31, $21, $11, $21, $f8, $f0, $f8, $fe
	.db $21, $11, $21, $22, $12, $22, $12, $12

	.db $22, $13, $23, $13, $f7, $f0, $f7, $fe
	.db $14, $04, $14, $04, $f7, $f0, $f7, $fe
	.db $ff

PPUAdrHTable
	.db $02, $12, $22, $32, $02, $12, $22, $32
	.db $02, $12, $22, $32, $02, $12, $22, $32
	.db $02, $12, $22, $32, $02, $12, $22, $32
	.db $02, $12, $22, $32, $02, $12, $22, $32
	.db $02, $12, $22, $32, $02, $12, $22, $32
	.db $02, $12, $22, $32, $02, $12, $22, $32
	.db $02, $12, $22, $32, $02, $12, $22, $32
	.db $02, $12, $22, $32, $02, $12, $22, $32

PPUAdrLTable
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $20, $20, $20, $20, $20, $20, $20, $20
	.db $40, $40, $40, $40, $40, $40, $40, $40
	.db $60, $60, $60, $60, $60, $60, $60, $60
	.db $80, $80, $80, $80, $80, $80, $80, $80
	.db $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0
.ends