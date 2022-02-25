; Builds program as iNES ROM

; Default is 16K PRG and 8K CHR ROM, NROM (0)

.if 0 ; Options to set before .include "shell.inc":
CHR_RAM=1       ; Use CHR-RAM instead of CHR-ROM
CART_WRAM=1     ; Use mapper that supports 8K WRAM in cart
CUSTOM_MAPPER=n ; Specify mapper number
.endif

.ifndef CUSTOM_MAPPER
	.ifdef CART_WRAM
		CUSTOM_MAPPER = 2 ; UNROM
	.else
		CUSTOM_MAPPER = 0 ; NROM
	.endif
.endif

;;;; iNES header
.ifndef CUSTOM_HEADER
	.segment "HEADER"
		.byte $4E,$45,$53,26 ; "NES" EOF
		
		.ifdef CHR_RAM
			.byte 2,0 ; 32K PRG, CHR RAM
		.else
			.byte 2,1 ; 32K PRG, 8K CHR
		.endif
		
		.byte CUSTOM_MAPPER*$10+$01 ; vertical mirroring
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

; Move code to $C000
.segment "DMC"
	.res $4000

.include "shell.s"

std_reset:
	lda #0
	sta PPUCTRL
	sta PPUMASK
	jmp run_shell

init_runtime:
	.ifdef CHR_RAM
		load_ascii_chr
	.endif
	rts

post_exit:
	jsr set_final_result
	jmp forever

; This helps devcart recover after running test.
; It is never executed by test ROM.
.segment "LOADER"
	.incbin "devcart.bin"

.code
