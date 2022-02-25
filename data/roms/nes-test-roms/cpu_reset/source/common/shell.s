; Common routines and runtime

; Detect inclusion loops (otherwise ca65 goes crazy)
.ifdef SHELL_INCLUDED
	.error "shell.s included twice"
	.end
.endif
SHELL_INCLUDED = 1

; Temporary variables that ANY routine might modify, so
; only use them between routine calls.
temp   = <$A
temp2  = <$B
temp3  = <$C
addr   = <$E
ptr = addr

; Move code to $E200 ($200 bytes for text output in devcarts
; where WRAM is mirrored to $E000)
.segment "CODE"
	.res $2200
	
; Put shell code after user code, so user code is in more
; consistent environment
.segment "CODE2"

	; Any user code which runs off end might end up here,
	; so catch that mistake.
	nop ; in case there was three-byte opcode before this
	nop
	jmp internal_error

;**** Common routines ****

.include "macros.inc"
.include "neshw.inc"
.include "delay.s"
.include "print.s"
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
	
	ldx #0
	stx SNDCHN
	.ifndef BUILD_NSF
		stx PPUCTRL
	.endif
	
	jsr report_result
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

.macro fill_ram_ Begin, End
	.local Neg_size
	Neg_size = (Begin) - (End)
	ldxy #(Begin) - <Neg_size
	sty addr
	stx addr+1
	ldxy #Neg_size
:   sta (addr),y
	iny
	bne :-
	inc addr+1
	inx
	bne :-
.endmacro

; Clears 0 through ($100+S), $200 through __NVRAM_LOAD__-1, and
; __NVRAM_LOAD__+__NVRAM_SIZE__ through $7FF
clear_ram:
	lda #0
	
	bss_begin = $200
	
	fill_ram_ bss_begin,__NVRAM_LOAD__
	fill_ram_ __NVRAM_LOAD__+__NVRAM_SIZE__,$800
	
	; Zero-page
	tax
:   sta 0,x
	inx
	bne :-
	
	; Stack below S
	tsx
	inx
:   dex
	sta $100,x
	bne :-
	
	rts


nv_res unused_nv_var ; to avoid size=0

; Clears nvram
clear_nvram:
	lda #0
	fill_ram_ __NVRAM_LOAD__,__NVRAM_LOAD__+__NVRAM_SIZE__
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


; Reports A in binary as high and low tones, with
; leading low tone for reference. Omits leading
; zeroes. Doesn't hang if no APU is present.
; Preserved: A, X, Y
play_hex:
	pha
	
	; Make low reference beep
	clc
	jsr @beep
	
	; Remove high zero bits
	sec
:   rol a
	bcc :-
	
	; Play remaining bits
	beq @zero
:   jsr @beep
	asl a
	bne :-
@zero:

	delay_msec 300
	pla
	rts

; Plays low/high beep based on carry
; Preserved: A, X, Y
@beep:
	pha
	
	; Set up square
	lda #1
	sta SNDCHN
	sta $4001
	sta $4003
	adc #$FE    ; period=$100 if carry, $1FF if none
	sta $4002
	
	; Fade volume
	lda #$0F
:   ora #$30
	sta $4000
	delay_msec 8
	sec
	sbc #$31
	bpl :-
	
	; Silence
	sta SNDCHN
	delay_msec 160
	
	pla
	rts
