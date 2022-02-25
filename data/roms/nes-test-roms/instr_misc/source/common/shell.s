; Common routines and runtime

; Detect inclusion loops (otherwise ca65 goes crazy)
.ifdef SHELL_INCLUDED
	.error "shell.s included twice"
	.end
.endif
SHELL_INCLUDED = 1

;**** Special globals ****

; Temporary variables that ANY routine might modify, so
; only use them between routine calls.
temp   = <$A
temp2  = <$B
temp3  = <$C
addr   = <$E
ptr = addr

.segment "NVRAM"
	; Beginning of variables not cleared at startup
	nvram_begin:

;****  Code segment setup ****

.segment "RODATA"
	; Any user code which runs off end might end up here,
	; so catch that mistake.
	nop ; in case there was three-byte opcode before this
	nop
	jmp internal_error

; Move code to $E200 ($200 bytes for text output)
.segment "DMC"
	.res $2200

; Devcart corrupts byte at $E000 when powering off
.segment "CODE"
	nop

;**** Common routines ****

.include "macros.inc"
.include "neshw.inc"
.include "print.s"
.include "delay.s"
.include "crc.s"
.include "testing.s"

.ifdef NEED_CONSOLE
	.include "console.s"
.else
	; Stubs so code doesn't have to care whether
	; console exists
	console_init:
	console_show:
	console_hide:
	console_print:
	console_flush:
		rts
.endif

.ifndef CUSTOM_PRINT
	.include "text_out.s"
	
	print_char_:
		jsr write_text_out
		jmp console_print
	
	stop_capture:
		rts
	
.endif
	
;**** Shell core ****

.ifndef CUSTOM_RESET
	reset:
		sei
		jmp std_reset
.endif


; Sets up hardware then runs main
run_shell:
	sei
	cld     ; unnecessary on NES, but might help on clone
	ldx #$FF
	txs
	jsr init_shell
	set_test $FF
	jmp run_main


; Initializes shell
init_shell:
	jsr clear_ram
	jsr init_wait_vbl     ; waits for VBL once here,
	jsr wait_vbl_optional ; so only need to wait once more
	jsr init_text_out
	jsr init_testing
	jsr init_runtime
	jsr console_init
	rts


; Runs main in consistent PPU/APU environment, then exits
; with code 0
run_main:
	jsr pre_main
	jsr main
	lda #0
	jmp exit


; Sets up environment for main to run in
pre_main:

.ifndef BUILD_NSF
	jsr disable_rendering
	setb PPUCTRL,0
	jsr clear_palette
	jsr clear_nametable
	jsr clear_nametable2
	jsr clear_oam
.endif
	
	lda #$34
	pha
	lda #0
	tax
	tay
	jsr wait_vbl_optional
	plp
	sta SNDMODE
	rts


.ifndef CUSTOM_EXIT
	exit:
.endif

; Reports result and ends program
std_exit:
	sei
	cld
	ldx #$FF
	txs
	pha
	
	setb SNDCHN,0
	.ifndef BUILD_NSF
		setb PPUCTRL,0
	.endif
	
	pla
	pha
	jsr report_result
	;jsr clear_nvram ; TODO: was this needed for anything?
	pla
	jmp post_exit


; Reports final result code in A
report_result:
	jsr :+
	jmp play_byte

:   jsr print_newline
	jsr console_show
	
	; 0: ""
	cmp #1
	bge :+
	rts
:
	; 1: "Failed"
	bne :+
	print_str {"Failed",newline}
	rts
	
	; n: "Failed #n"
:   print_str "Failed #"
	jsr print_dec
	jsr print_newline
	rts

;**** Other routines ****

; Reports internal error and exits program
internal_error:
	print_str newline,"Internal error"
	lda #255
	jmp exit


.import __NVRAM_LOAD__, __NVRAM_SIZE__

; Clears $0-($100+S) and nv_ram_end-$7FF
clear_ram:
	lda #0
	
	; Main pages
	tax
:   sta 0,x
	sta $300,x
	sta $400,x
	sta $500,x
	sta $600,x
	sta $700,x
	inx
	bne :-
	
	; Stack except that above stack pointer
	tsx
	inx
:   dex
	sta $100,x
	bne :-
	
	; BSS except nvram
	ldx #<__NVRAM_SIZE__
:   sta __NVRAM_LOAD__,x
	inx
	bne :-
	
	rts


; Clears nvram
clear_nvram:
	ldx #<__NVRAM_SIZE__
	beq @empty
	lda #0
:   dex
	sta __NVRAM_LOAD__,x
	bne :-
@empty:
	rts


; Prints filename and newline, if available, otherwise nothing.
; Preserved: A, X, Y
print_filename:
	.ifdef FILENAME_KNOWN
		pha
		jsr print_newline
		setw addr,filename
		jsr print_str_addr
		jsr print_newline
		pla
	.endif
	rts
	
.pushseg
.segment "RODATA"
	; Filename terminated with zero byte.
	filename:
		.ifdef FILENAME_KNOWN
			.incbin "ram:nes_temp"
		.endif
		.byte 0
.popseg


;**** ROM-specific ****
.ifndef BUILD_NSF

.include "ppu.s"

avoid_silent_nsf:
play_byte:
	rts

; Loads ASCII font into CHR RAM
.macro load_ascii_chr
	bit PPUSTATUS
	setb PPUADDR,$00
	setb PPUADDR,$00
	setb addr,<ascii_chr
	ldx #>ascii_chr
	ldy #0
@page:
	stx addr+1
:   lda (addr),y
	sta PPUDATA
	iny
	bne :-
	inx
	cpx #>ascii_chr_end
	bne @page
.endmacro

; Disables interrupts and loops forever
.ifndef CUSTOM_FOREVER
forever:
	sei
	lda #0
	sta PPUCTRL
:   beq :-
	.res $10,$EA    ; room for code to run loader
.endif


; Default NMI
.ifndef CUSTOM_NMI
	zp_byte nmi_count
	
	nmi:
		inc nmi_count
		rti
	
	; Waits for NMI. Must be using NMI handler that increments
	; nmi_count, with NMI enabled.
	; Preserved: X, Y
	wait_nmi:
		lda nmi_count
	:   cmp nmi_count
		beq :-
		rts
.endif


; Default IRQ
.ifndef CUSTOM_IRQ
	irq:
		bit SNDCHN  ; clear APU IRQ flag
		rti
.endif

.endif
