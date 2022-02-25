; Verifies square DACs and non-linear mixing
;
; Plays two square waves in all totals from 0 to 31.
; Cancels this to silence with inverse wave generated
; using DMC DAC.

.include "vol_shell.inc"

test_main:
	setb $4001,$7F  ; disable sweep
	setb $4005,$7F
	setb $4002,0    ; period = 0
	setb $4003,0
	setb $4006,0
	setb $4007,0
	delay 5000      ; allow period to settle in
	setb $4015,$03
	
	ldx #$6F        ; period = 896*2
	ldy #$00
	stx $4002
	stx $4006
	sty $4003
	sty $4007
	delay 175
	
	extra = 27-1
	ldx #-1
	ldy #0
	jmp @first

@1:     delay extra
@2:     lda dmc,x
	sta $4011
	delay 896-4-2
	lda #127
	sta $4011
	delay 896-4-5-extra-4
	dey
	bne @1
@first: inx
	lda sq1,x       ; update square volumes
	sta $4000
	lda sq2,x
	sta $4004
	ldy #80
	lda dmc,x
	bne @2

	rts
	
.align 256
dmc:
.byte $7F,$7B,$77,$77,$74,$74,$70,$70,$70,$6D,$6D,$6D,$6A,$6A,$6A,$6A
.byte $67,$67,$67,$67,$64,$64,$64,$64,$64,$61,$61,$61,$61,$61,$5E,$5E
.byte $5E,$5E,$5E,$5E,$5C,$5C,$5C,$5C,$5C,$5C,$59,$59,$59,$59,$59,$59
.byte $59,$57,$57,$57,$57,$57,$57,$57,$54,$54,$54,$54,$54,$54,$54,$54
.byte $52,$52,$52,$52,$52,$52,$52,$52,$50,$50,$50,$50,$50,$50,$50,$50
.byte $4E,$4E,$4E,$4E,$4E,$4E,$4E,$4C,$4C,$4C,$4C,$4C,$4C,$4C,$4A,$4A
.byte $4A,$4A,$4A,$4A,$48,$48,$48,$48,$48,$48,$46,$46,$46,$46,$46,$44
.byte $44,$44,$44,$44,$42,$42,$42,$42,$41,$41,$41,$41,$3F,$3F,$3F,$3E
.byte $3E,$3E,$3C,$3C,$3B,$3B,$39,$38,$00

.align 256
sq1:
.byte $B0,$B0,$B0,$B1,$B0,$B1,$B0,$B1,$B2,$B0,$B1,$B2,$B0,$B1,$B2,$B3
.byte $B0,$B1,$B2,$B3,$B0,$B1,$B2,$B3,$B4,$B0,$B1,$B2,$B3,$B4,$B0,$B1
.byte $B2,$B3,$B4,$B5,$B0,$B1,$B2,$B3,$B4,$B5,$B0,$B1,$B2,$B3,$B4,$B5
.byte $B6,$B0,$B1,$B2,$B3,$B4,$B5,$B6,$B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7
.byte $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8
.byte $B2,$B3,$B4,$B5,$B6,$B7,$B8,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$B4,$B5
.byte $B6,$B7,$B8,$B9,$B5,$B6,$B7,$B8,$B9,$BA,$B6,$B7,$B8,$B9,$BA,$B7
.byte $B8,$B9,$BA,$BB,$B8,$B9,$BA,$BB,$B9,$BA,$BB,$BC,$BA,$BB,$BC,$BB
.byte $BC,$BD,$BC,$BD,$BD,$BE,$BE,$BF

.align 256
sq2:
.byte $B0,$B1,$B2,$B1,$B3,$B2,$B4,$B3,$B2,$B5,$B4,$B3,$B6,$B5,$B4,$B3
.byte $B7,$B6,$B5,$B4,$B8,$B7,$B6,$B5,$B4,$B9,$B8,$B7,$B6,$B5,$BA,$B9
.byte $B8,$B7,$B6,$B5,$BB,$BA,$B9,$B8,$B7,$B6,$BC,$BB,$BA,$B9,$B8,$B7
.byte $B6,$BD,$BC,$BB,$BA,$B9,$B8,$B7,$BE,$BD,$BC,$BB,$BA,$B9,$B8,$B7
.byte $BF,$BE,$BD,$BC,$BB,$BA,$B9,$B8,$BF,$BE,$BD,$BC,$BB,$BA,$B9,$B8
.byte $BF,$BE,$BD,$BC,$BB,$BA,$B9,$BF,$BE,$BD,$BC,$BB,$BA,$B9,$BF,$BE
.byte $BD,$BC,$BB,$BA,$BF,$BE,$BD,$BC,$BB,$BA,$BF,$BE,$BD,$BC,$BB,$BF
.byte $BE,$BD,$BC,$BB,$BF,$BE,$BD,$BC,$BF,$BE,$BD,$BC,$BF,$BE,$BD,$BF
.byte $BE,$BD,$BF,$BE,$BF,$BE,$BF,$BF


