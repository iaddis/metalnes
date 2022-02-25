; Common routines and runtime

; Detect inclusion loops (otherwise ca65 goes crazy)
.ifdef SHELL_INCLUDED
	.error "shell.s included twice"
	.end
.endif
SHELL_INCLUDED = 1

; Number of clocks delay before reset is jumped to
.ifndef DEVCART_DELAY
	DEVCART_DELAY = 0
.endif

;**** Special globals ****

; Temporary variables that ANY routine might modify, so
; only use them between routine calls.
temp   = <$A
temp2  = <$B
temp3  = <$C
addr   = <$E

.segment "NVRAM"
	; Beginning of variables not cleared at startup
	nvram_begin:

;****  Code segment setup ****

.ifndef NOT_FOR_DEVCART
	; Move code to $E000
	.segment "DMC"
		.res $6000
.endif

; Devcart corrupts byte at $E000 when powering off
.code
	nop

; Goes after all other read-only data, to avoid trailing zeroes
; from getting stripped off by devcart loader.
.segment "ROEND"
	.byte $FF

; Cause support code to go AFTER user code, so that
; changes to support code don't move user code around.
.segment "CODE2"

	; Any user code which runs off end might end up here,
	; so catch that mistake.
	nop ; in case there was three-byte opcode before this
	nop
	jmp internal_error

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
	
	.ifndef BUILD_NSF
		ldx #0
		stx PPUCTRL
	.endif
	
	jsr report_result
	jmp post_exit


; Reports final result code in A
; Preserved: A
report_result:
	pha
	jsr :+
	jsr play_byte
	pla
	jmp set_final_result

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
.segment "STRINGS"
	; Filename terminated with zero byte.
	filename:
		.ifdef FILENAME_KNOWN
			.incbin "ram:rom.nes"
		.endif
		.byte 0
.popseg


;**** NSF-specific ****

.ifdef BUILD_NSF
bss_res nsf_activity,1

; Call periodically where there would otherwise be silence,
; so that NSF build won't be cut short in NSF player that
; detects silence.
; Preserved: A, X, Y
avoid_silent_nsf:
	pha
	lda nsf_activity
	clc
	adc #4
	sta nsf_activity
	sta $4011
	pla
	rts


init_wait_vbl:
wait_vbl_optional:
;wait_vbl: ; undefined so assembler error results if called
	rts


.ifndef CUSTOM_IRQ
	irq:
.endif
nmi:
	jmp internal_error

;**** ROM-specific ****
.else ; .ifndef BUILD_NSF

.include "ppu.s"


avoid_silent_nsf:
play_byte:
	rts


; Disables interrupts and loops forever
.ifndef CUSTOM_FOREVER
forever:
	sei
	lda #0
	sta PPUCTRL
:   beq :-
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
