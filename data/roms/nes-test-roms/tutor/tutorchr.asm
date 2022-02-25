; CHR-ROM file for the NES 101 tutorial
; Kinda sorta copyright Michael Martin, 2001,2.
; More honestly copyright Commodore Business Machines 1982.

; The first 4K block (256 characters) is where our backgrounds come from.
; These were extracted from the Commodore 64's character ROM, and modified
; to match the NES' character definition schemas.  The background is color
; 2 on the palette, and the letterforms themselves color 3.  The characters
; are given tile numbers that correspond to their ASCII codes, to simplify
; the creation of the data files.

; The first 20 character locations are blank.
.dsb $0200
.byte $00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 32
.byte $18,$18,$18,$18,$00,$00,$18,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 33
.byte $66,$66,$66,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 34
.byte $66,$66,$FF,$66,$FF,$66,$66,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 35
.byte $18,$3E,$60,$3C,$06,$7C,$18,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 36
.byte $62,$66,$0C,$18,$30,$66,$46,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 37
.byte $3C,$66,$3C,$38,$67,$66,$3F,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 38
.byte $06,$0C,$18,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 39
.byte $0C,$18,$30,$30,$30,$18,$0C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 40
.byte $30,$18,$0C,$0C,$0C,$18,$30,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 41
.byte $00,$66,$3C,$FF,$3C,$66,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 42
.byte $00,$18,$18,$7E,$18,$18,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 43
.byte $00,$00,$00,$00,$00,$18,$18,$30,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 44
.byte $00,$00,$00,$7E,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 45
.byte $00,$00,$00,$00,$00,$18,$18,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 46
.byte $00,$03,$06,$0C,$18,$30,$60,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 47
.byte $3C,$66,$6E,$76,$66,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 48
.byte $18,$18,$38,$18,$18,$18,$7E,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 49
.byte $3C,$66,$06,$0C,$30,$60,$7E,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 50
.byte $3C,$66,$06,$1C,$06,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 51
.byte $06,$0E,$1E,$66,$7F,$06,$06,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 52
.byte $7E,$60,$7C,$06,$06,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 53
.byte $3C,$66,$60,$7C,$66,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 54
.byte $7E,$66,$0C,$18,$18,$18,$18,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 55
.byte $3C,$66,$66,$3C,$66,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 56
.byte $3C,$66,$66,$3E,$06,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 57
.byte $00,$00,$18,$00,$00,$18,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 58
.byte $00,$00,$18,$00,$00,$18,$18,$30,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 59
.byte $0E,$18,$30,$60,$30,$18,$0E,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 60
.byte $00,$00,$7E,$00,$7E,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 61
.byte $70,$18,$0C,$06,$0C,$18,$70,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 62
.byte $3C,$66,$06,$0C,$18,$00,$18,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 63
.byte $3C,$66,$6E,$6E,$60,$62,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 64
.byte $18,$3C,$66,$7E,$66,$66,$66,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 65
.byte $7C,$66,$66,$7C,$66,$66,$7C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 66
.byte $3C,$66,$60,$60,$60,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 67
.byte $78,$6C,$66,$66,$66,$6C,$78,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 68
.byte $7E,$60,$60,$78,$60,$60,$7E,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 69
.byte $7E,$60,$60,$78,$60,$60,$60,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 70
.byte $3C,$66,$60,$6E,$66,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 71
.byte $66,$66,$66,$7E,$66,$66,$66,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 72
.byte $3C,$18,$18,$18,$18,$18,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 73
.byte $1E,$0C,$0C,$0C,$0C,$6C,$38,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 74
.byte $66,$6C,$78,$70,$78,$6C,$66,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 75
.byte $60,$60,$60,$60,$60,$60,$7E,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 76
.byte $63,$77,$7F,$6B,$63,$63,$63,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 77
.byte $66,$76,$7E,$7E,$6E,$66,$66,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 78
.byte $3C,$66,$66,$66,$66,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 79
.byte $7C,$66,$66,$7C,$60,$60,$60,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 80
.byte $3C,$66,$66,$66,$66,$3C,$0E,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 81
.byte $7C,$66,$66,$7C,$78,$6C,$66,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 82
.byte $3C,$66,$60,$3C,$06,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 83
.byte $7E,$18,$18,$18,$18,$18,$18,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 84
.byte $66,$66,$66,$66,$66,$66,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 85
.byte $66,$66,$66,$66,$66,$3C,$18,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 86
.byte $63,$63,$63,$6B,$7F,$77,$63,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 87
.byte $66,$66,$3C,$18,$3C,$66,$66,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 88
.byte $66,$66,$66,$3C,$18,$18,$18,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 89
.byte $7E,$06,$0C,$18,$30,$60,$7E,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 90
.byte $3C,$30,$30,$30,$30,$30,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 91
.byte $0C,$12,$30,$7C,$30,$62,$FC,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 92
.byte $3C,$0C,$0C,$0C,$0C,$0C,$3C,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 93
.byte $00,$18,$3C,$7E,$18,$18,$18,$18,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 94
.byte $00,$10,$30,$7F,$7F,$30,$10,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; Character 95

; Fill the rest of the first CHR-ROM block with zeroes.
.align $1000

; Here begins the second 4K block.  The sprites (all one of them) get their data
; from this page.

.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; Character 0: Blank
.byte $18,$24,$66,$99,$99,$66,$24,$18,$00,$18,$18,$66,$66,$18,$18,$00 ; Character 1: Diamond sprite

; Fill the rest of the CHR-ROM block with zeroes, giving us exactly 8K of data, which
; is what we want and need.
.align $1000
