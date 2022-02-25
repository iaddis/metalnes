; Shell that sets up testing framework and calls main

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

; Move code from $C000 to $E200, to accommodate my devcarts
.ifndef LARGER_ROM_HACK
.segment "CODE"
	.res $2200
.endif
	
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

;**** Shell core ****

.ifndef CUSTOM_RESET
	reset:
		sei
		jmp std_reset
.endif


; Sets up hardware then runs main
run_shell:
	init_cpu_regs
	jsr init_shell
	set_test $FF
	jmp run_main


; Initializes shell without affecting current set_test values
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
	
	; Clear APU registers
	lda #0
	sta $4015
	ldx #$13
:   sta $4000,x
	dex
	bpl :-
	
	; CPU registers
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
	sta temp
	init_cpu_regs
	setb SNDCHN,0
	lda temp
	
	jsr report_result
	pha
	jsr check_ppu_region
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

.include "shell_misc.s"

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
