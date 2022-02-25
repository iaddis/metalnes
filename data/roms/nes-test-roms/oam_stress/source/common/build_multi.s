; Builds program as bank for multi-test MMC1 ROM

; Define these so that error will occur if already defined
; by program
CUSTOM_MAPPER = 1   ; MMC1
CHR_RAM = 1

.ifndef BANK_COUNT
	BANK_COUNT = 16
.endif

.segment "VECTORS"
	.word -1, -1
	.word reset
	.word nmi, multi_reset, irq

;;;; CHR-RAM
.define CHARS "CHARS_PRG"
.segment CHARS
	ascii_chr:

.segment "CHARS_PRG_ASCII"
	.align $200
		.incbin "ascii.chr"
	ascii_chr_end:

;;;; Shell
NEED_CONSOLE = 1
.include "shell.s"

std_reset:
	lda #0
	sta PPUCTRL
	sta PPUMASK
	jmp run_shell

init_runtime:
	load_ascii_chr
	rts

nv_res cur_bank

.macro write_mmc1 Addr
:   sta Addr
	lsr a
	cmp #$40 >> 5
	bne :-
.endmacro

; Copies and executes following code (256 bytes max)
; from RAM at $700
.macro exec_in_ram
	ldx #0
:   lda @source,x
	sta @dest,x
	inx
	bne :-
	jmp @dest
@source = *
.org $700
@dest:
.endmacro

multi_reset:
	exec_in_ram
	
	; 16K PRG, upper bank switchable, and reset shift reg first
	lda #$4A << 1
	write_mmc1 $8000
	
	; Select first bank and execute
	lda #$40
	write_mmc1 $E000
	setb cur_bank,0
	jmp ($FFF8)
.reloc

post_exit:
	cmp #0
	beq @passed
	
	; Print which test number failed
	print_str newline,"While running test "
	ldx cur_bank
	inx
	txa
	jsr print_dec
	print_str {" of ",.sprintf("%d", BANK_COUNT),newline,newline,newline}
	
	setb final_result,1
:   jmp :-

@passed:
	exec_in_ram

	; 16K PRG, upper bank switchable, and reset shift reg first
	lda #$4A << 1
	write_mmc1 $8000
	
	; Next bank
	inc cur_bank
	lda cur_bank
	cmp #BANK_COUNT
	bne @run_bank
	jsr console_init ; clear screen
	print_str {"All ",.sprintf("%d",BANK_COUNT)," tests passed",newline,newline,newline}
	
	setb final_result,0
:   jmp :-
	
@run_bank:
	ora #$40
	write_mmc1 $E000
	jmp ($FFF8)

.reloc
