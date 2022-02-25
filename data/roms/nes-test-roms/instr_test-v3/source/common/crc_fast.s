; Fast table-based CRC-32

; Initializes fast CRC tables and resets checksum.
; Preserved: Y
init_crc_fast = reset_crc

; Updates checksum with byte from A
; Preserved: X, Y
; Time: 54 clocks
update_crc_fast:
	stx checksum_temp

; Updates checksum with byte from A
; Preserved: Y
; Time: 42 clocks
.macro update_crc_fast
	eor checksum
	tax
	lda checksum+1
	eor checksum_t0,x
	sta checksum
	lda checksum+2
	eor checksum_t1,x
	sta checksum+1
	lda checksum+3
	eor checksum_t2,x
	sta checksum+2
	lda checksum_t3,x
	sta checksum+3
.endmacro

	update_crc_fast
	ldx checksum_temp
	rts

.pushseg
.segment "RODATA"
.align 256
checksum_t0:
	.byte $8D,$1B,$A1,$37,$94,$02,$B8,$2E,$BF,$29,$93,$05,$A6,$30,$8A,$1C
	.byte $E9,$7F,$C5,$53,$F0,$66,$DC,$4A,$DB,$4D,$F7,$61,$C2,$54,$EE,$78
	.byte $45,$D3,$69,$FF,$5C,$CA,$70,$E6,$77,$E1,$5B,$CD,$6E,$F8,$42,$D4
	.byte $21,$B7,$0D,$9B,$38,$AE,$14,$82,$13,$85,$3F,$A9,$0A,$9C,$26,$B0
	.byte $1D,$8B,$31,$A7,$04,$92,$28,$BE,$2F,$B9,$03,$95,$36,$A0,$1A,$8C
	.byte $79,$EF,$55,$C3,$60,$F6,$4C,$DA,$4B,$DD,$67,$F1,$52,$C4,$7E,$E8
	.byte $D5,$43,$F9,$6F,$CC,$5A,$E0,$76,$E7,$71,$CB,$5D,$FE,$68,$D2,$44
	.byte $B1,$27,$9D,$0B,$A8,$3E,$84,$12,$83,$15,$AF,$39,$9A,$0C,$B6,$20
	.byte $AD,$3B,$81,$17,$B4,$22,$98,$0E,$9F,$09,$B3,$25,$86,$10,$AA,$3C
	.byte $C9,$5F,$E5,$73,$D0,$46,$FC,$6A,$FB,$6D,$D7,$41,$E2,$74,$CE,$58
	.byte $65,$F3,$49,$DF,$7C,$EA,$50,$C6,$57,$C1,$7B,$ED,$4E,$D8,$62,$F4
	.byte $01,$97,$2D,$BB,$18,$8E,$34,$A2,$33,$A5,$1F,$89,$2A,$BC,$06,$90
	.byte $3D,$AB,$11,$87,$24,$B2,$08,$9E,$0F,$99,$23,$B5,$16,$80,$3A,$AC
	.byte $59,$CF,$75,$E3,$40,$D6,$6C,$FA,$6B,$FD,$47,$D1,$72,$E4,$5E,$C8
	.byte $F5,$63,$D9,$4F,$EC,$7A,$C0,$56,$C7,$51,$EB,$7D,$DE,$48,$F2,$64
	.byte $91,$07,$BD,$2B,$88,$1E,$A4,$32,$A3,$35,$8F,$19,$BA,$2C,$96,$00

checksum_t1:
	.byte $EF,$DF,$8E,$BE,$2B,$1B,$4A,$7A,$67,$57,$06,$36,$A3,$93,$C2,$F2
	.byte $FF,$CF,$9E,$AE,$3B,$0B,$5A,$6A,$77,$47,$16,$26,$B3,$83,$D2,$E2
	.byte $CF,$FF,$AE,$9E,$0B,$3B,$6A,$5A,$47,$77,$26,$16,$83,$B3,$E2,$D2
	.byte $DF,$EF,$BE,$8E,$1B,$2B,$7A,$4A,$57,$67,$36,$06,$93,$A3,$F2,$C2
	.byte $AE,$9E,$CF,$FF,$6A,$5A,$0B,$3B,$26,$16,$47,$77,$E2,$D2,$83,$B3
	.byte $BE,$8E,$DF,$EF,$7A,$4A,$1B,$2B,$36,$06,$57,$67,$F2,$C2,$93,$A3
	.byte $8E,$BE,$EF,$DF,$4A,$7A,$2B,$1B,$06,$36,$67,$57,$C2,$F2,$A3,$93
	.byte $9E,$AE,$FF,$CF,$5A,$6A,$3B,$0B,$16,$26,$77,$47,$D2,$E2,$B3,$83
	.byte $6C,$5C,$0D,$3D,$A8,$98,$C9,$F9,$E4,$D4,$85,$B5,$20,$10,$41,$71
	.byte $7C,$4C,$1D,$2D,$B8,$88,$D9,$E9,$F4,$C4,$95,$A5,$30,$00,$51,$61
	.byte $4C,$7C,$2D,$1D,$88,$B8,$E9,$D9,$C4,$F4,$A5,$95,$00,$30,$61,$51
	.byte $5C,$6C,$3D,$0D,$98,$A8,$F9,$C9,$D4,$E4,$B5,$85,$10,$20,$71,$41
	.byte $2D,$1D,$4C,$7C,$E9,$D9,$88,$B8,$A5,$95,$C4,$F4,$61,$51,$00,$30
	.byte $3D,$0D,$5C,$6C,$F9,$C9,$98,$A8,$B5,$85,$D4,$E4,$71,$41,$10,$20
	.byte $0D,$3D,$6C,$5C,$C9,$F9,$A8,$98,$85,$B5,$E4,$D4,$41,$71,$20,$10
	.byte $1D,$2D,$7C,$4C,$D9,$E9,$B8,$88,$95,$A5,$F4,$C4,$51,$61,$30,$00

checksum_t2:
	.byte $02,$05,$0C,$0B,$6F,$68,$61,$66,$D9,$DE,$D7,$D0,$B4,$B3,$BA,$BD
	.byte $B5,$B2,$BB,$BC,$D8,$DF,$D6,$D1,$6E,$69,$60,$67,$03,$04,$0D,$0A
	.byte $6C,$6B,$62,$65,$01,$06,$0F,$08,$B7,$B0,$B9,$BE,$DA,$DD,$D4,$D3
	.byte $DB,$DC,$D5,$D2,$B6,$B1,$B8,$BF,$00,$07,$0E,$09,$6D,$6A,$63,$64
	.byte $DE,$D9,$D0,$D7,$B3,$B4,$BD,$BA,$05,$02,$0B,$0C,$68,$6F,$66,$61
	.byte $69,$6E,$67,$60,$04,$03,$0A,$0D,$B2,$B5,$BC,$BB,$DF,$D8,$D1,$D6
	.byte $B0,$B7,$BE,$B9,$DD,$DA,$D3,$D4,$6B,$6C,$65,$62,$06,$01,$08,$0F
	.byte $07,$00,$09,$0E,$6A,$6D,$64,$63,$DC,$DB,$D2,$D5,$B1,$B6,$BF,$B8
	.byte $BA,$BD,$B4,$B3,$D7,$D0,$D9,$DE,$61,$66,$6F,$68,$0C,$0B,$02,$05
	.byte $0D,$0A,$03,$04,$60,$67,$6E,$69,$D6,$D1,$D8,$DF,$BB,$BC,$B5,$B2
	.byte $D4,$D3,$DA,$DD,$B9,$BE,$B7,$B0,$0F,$08,$01,$06,$62,$65,$6C,$6B
	.byte $63,$64,$6D,$6A,$0E,$09,$00,$07,$B8,$BF,$B6,$B1,$D5,$D2,$DB,$DC
	.byte $66,$61,$68,$6F,$0B,$0C,$05,$02,$BD,$BA,$B3,$B4,$D0,$D7,$DE,$D9
	.byte $D1,$D6,$DF,$D8,$BC,$BB,$B2,$B5,$0A,$0D,$04,$03,$67,$60,$69,$6E
	.byte $08,$0F,$06,$01,$65,$62,$6B,$6C,$D3,$D4,$DD,$DA,$BE,$B9,$B0,$B7
	.byte $BF,$B8,$B1,$B6,$D2,$D5,$DC,$DB,$64,$63,$6A,$6D,$09,$0E,$07,$00

checksum_t3:
	.byte $D2,$A5,$3C,$4B,$D5,$A2,$3B,$4C,$DC,$AB,$32,$45,$DB,$AC,$35,$42
	.byte $CF,$B8,$21,$56,$C8,$BF,$26,$51,$C1,$B6,$2F,$58,$C6,$B1,$28,$5F
	.byte $E9,$9E,$07,$70,$EE,$99,$00,$77,$E7,$90,$09,$7E,$E0,$97,$0E,$79
	.byte $F4,$83,$1A,$6D,$F3,$84,$1D,$6A,$FA,$8D,$14,$63,$FD,$8A,$13,$64
	.byte $A4,$D3,$4A,$3D,$A3,$D4,$4D,$3A,$AA,$DD,$44,$33,$AD,$DA,$43,$34
	.byte $B9,$CE,$57,$20,$BE,$C9,$50,$27,$B7,$C0,$59,$2E,$B0,$C7,$5E,$29
	.byte $9F,$E8,$71,$06,$98,$EF,$76,$01,$91,$E6,$7F,$08,$96,$E1,$78,$0F
	.byte $82,$F5,$6C,$1B,$85,$F2,$6B,$1C,$8C,$FB,$62,$15,$8B,$FC,$65,$12
	.byte $3F,$48,$D1,$A6,$38,$4F,$D6,$A1,$31,$46,$DF,$A8,$36,$41,$D8,$AF
	.byte $22,$55,$CC,$BB,$25,$52,$CB,$BC,$2C,$5B,$C2,$B5,$2B,$5C,$C5,$B2
	.byte $04,$73,$EA,$9D,$03,$74,$ED,$9A,$0A,$7D,$E4,$93,$0D,$7A,$E3,$94
	.byte $19,$6E,$F7,$80,$1E,$69,$F0,$87,$17,$60,$F9,$8E,$10,$67,$FE,$89
	.byte $49,$3E,$A7,$D0,$4E,$39,$A0,$D7,$47,$30,$A9,$DE,$40,$37,$AE,$D9
	.byte $54,$23,$BA,$CD,$53,$24,$BD,$CA,$5A,$2D,$B4,$C3,$5D,$2A,$B3,$C4
	.byte $72,$05,$9C,$EB,$75,$02,$9B,$EC,$7C,$0B,$92,$E5,$7B,$0C,$95,$E2
	.byte $6F,$18,$81,$F6,$68,$1F,$86,$F1,$61,$16,$8F,$F8,$66,$11,$88,$FF
.popseg
