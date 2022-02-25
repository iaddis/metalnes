; iNES header

; iNES identifier
.byte "NES",$1a 

; Number of PRG-ROM blocks
.byte $01

; Number of CHR-ROM blocks
.byte $01

; ROM control bytes: Horizontal mirroring, no SRAM
; or trainer, Mapper #0
.byte $00, $00

; Filler
.byte $00,$00,$00,$00,$00,$00,$00,$00

; PRG-ROM
.include "tutorprg.asm"

; CHR-ROM
.include "tutorchr.asm"