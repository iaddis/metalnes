; Builds program as iNES ROM

.if 0 ; Options to set before .include "shell.inc":
CHR_RAM=1   ; Use CHR-RAM instead of CHR-ROM
CART_WRAM=1 ; Use mapper that supports 8K WRAM in cart
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
		.byte "NES",26
		
		.ifdef CHR_RAM
			.byte 2,0 ; 32K PRG, CHR RAM
		.else
			.byte 2,1 ; 32K PRG, 8K CHR
		.endif
		
		.byte CUSTOM_MAPPER*$10+$01 ; vertical mirroring
.endif

.ifndef CUSTOM_VECTORS
	.segment "VECTORS"
		.word 0,0,0, nmi, reset, irq
.endif

;;;; CHR-RAM/ROM
.ifdef CHR_RAM
	.rodata
		ascii_chr:
			.incbin "ascii.chr"
		ascii_chr_end:
.else
	.segment "CHARS"
		.incbin "ascii.chr"
		.align $2000
.endif

;;;; Shell
.ifndef NEED_CONSOLE
	NEED_CONSOLE=1
.endif

.include "shell.s"

std_reset:
	lda #0
	sta PPUCTRL
	sta PPUMASK
	jmp run_shell

init_runtime:
	.ifdef CHR_RAM
		; Load ASCII font into CHR RAM
		ldy #0
		sty PPUADDR
		sty PPUADDR
		ldx #<ascii_chr
		stx addr
		ldx #>ascii_chr
	@page:
		stx addr+1
	:   lda (addr),y
		sta PPUDATA
		iny
		bne :-
		inx
		cpx #>ascii_chr_end
		bne @page
	.endif
	rts

post_exit:
	jsr clear_nvram
	jmp forever

; User code goes in main code segment
.code
