; Builds program as iNES ROM

; Default is 32K PRG and 8K CHR ROM, NROM (0)
; CHR_RAM selects UNROM (2)
; CART_WRAM selects MMC1 (1)

.if 0 ; Options to set before .include "shell.inc":
CHR_RAM = 1     ; Use CHR-RAM instead of CHR-ROM
CART_WRAM = 1   ; Use mapper that supports 8K WRAM in cart
MAPPER = n      ; Specify mapper number
.endif

.ifndef MAPPER
	.ifdef CART_WRAM
		MAPPER = 1 ; MMC1
	.elseif .defined(CHR_RAM)
		MAPPER = 2 ; UNROM
	.else
		MAPPER = 0 ; NROM
	.endif
.endif

.ifndef V_MIRRORING
	V_MIRRORING = 1 ; since text console needs it
.endif

;;;; iNES header
.ifndef CUSTOM_HEADER
	.segment "HEADER"
		.byte "NES",$1A
		
		.ifdef CHR_RAM
			.byte 2,0 ; 32K PRG, CHR RAM
		.else
			.byte 2,1 ; 32K PRG, 8K CHR
		.endif
		
		.byte MAPPER*$10 + V_MIRRORING
.endif

.ifndef CUSTOM_VECTORS
	.segment "VECTORS"
		.word -1,-1,-1, nmi, reset, irq
.endif

;;;; CHR-RAM/ROM
.ifdef CHR_RAM
	.define CHARS "CHARS_PRG"
	.segment CHARS
		ascii_chr:
	
	.segment "CHARS_PRG_ASCII"
		.align $200
			.incbin "ascii.chr"
		ascii_chr_end:
.else
	.define CHARS "CHARS"
	.segment "CHARS_ASCII"
		.align $200
		.incbin "ascii.chr"
		.res $1800
.endif

.segment CHARS
	.res $10,0

;;;; Shell
.ifndef NEED_CONSOLE
	NEED_CONSOLE=1
.endif

.ifndef LARGER_ROM_HACK
.segment "CODE"
	.res $4000
.endif

.include "shell.s"

std_reset:
.if MAPPER = 1
	; Some writes to odd addresses to work
	; with my Ultima devcart
	lda #$80
	sta $8001
	
	; Vertical mirroring, 8K CHR, WRAM enabled, all 32K mapped
	lda #$0E<<1 ; $0E
:   lsr a
	sta $8000   ; 0E 07 03 01 00
	bne :-
	
	lda #04     ; $00
:   sta $A001   ; 04 08 10 20 40
	asl a
	bpl :-
	
	lda #$05    ; $01
:   sta $C001   ; 05 0A 14 28 50
	asl a
	bpl :-
	
	lda #04     ; $00
:   sta $E000   ; 04 08 10 20 40
	asl a
	bpl :-
	
.endif
	
	lda #0
	sta PPUCTRL
	sta PPUMASK
	jmp run_shell

init_runtime:
	.ifdef CHR_RAM
		load_chr_ram
	.endif
	rts

post_exit:
	jsr set_final_result
	jsr play_hex
	jmp forever

; Standard NES bootloader to help with devcart.
; It is never executed by test ROM.
.segment "LOADER"
	.incbin "bootloader.bin"

.code
.align 256
