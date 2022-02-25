; Program shell with text console. Included before user code.

; Detect inclusion loops (otherwise ca65 goes crazy)
.ifdef SHELL_INC
	.error "File included twice"
	.end
.endif
SHELL_INC = 1


; ******************************************* Prefix

.segment "CODE2"

; Temporary variables that ANY routine might modify, so
; only use them between routine calls.
temp   = <$A
temp2  = <$B
temp3  = <$C
addr   = <$E

; RAM that isn't cleared by init routine
nv_ram = $7F0

; Macros and constants
.include "macros.inc"
.include "nes.inc"

; Interrupt handlers are wrapped with these
.define BEGIN_NMI nmi:
.define END_NMI

.define BEGIN_IRQ irq:
.define END_IRQ

; Set undefined flags to 0, allowing simpler .if statements
SET_DEFAULT BUILD_NSF,0
SET_DEFAULT BUILD_MULTI,0
SET_DEFAULT BUILD_DEVCART,0

; Number of clocks devcart takes to jump to user reset
SET_DEFAULT DEVCART_DELAY,0


; ******************************************* Libraries

.include "delay.s"
.include "print.s"
.include "crc.s"
.include "testing.s"

.if !BUILD_MULTI
	.include "serial.s"
.endif

; Sets up environment, calls main, then exits with code 0
run_main:
	; Initialize libraries
	jsr init_crc
	
	; Establish consistent environment before
	; running main
	jsr wait_vbl
	lda #PPUMASK_BG0
	sta PPUMASK
	delay 2370+24
	lda #$34
	pha
	lda #0
	sta SNDMODE
	tax
	tay
	clc
	clv
	plp
	
	jsr main
	
	; Default to silent exit if main returns
	lda #0
	; FALL THROUGH

; Exits program and prints result code if non-zero
exit:
	; Reset stack
	ldx #$FF
	txs
	
	; Disable interrupts
	sei
	pha
	jsr nmi_off
	pla
	
	jmp exit_

; Reports internal error and exits program
internal_error:
	print_str "Internal error"
	lda #1
	jmp exit


.if BUILD_NSF || BUILD_MULTI || BUILD_DEVCART
	console_init:
	console_show:
	console_hide:
	console_print:
	console_flush:
		rts
.else
	.include "console.s"
.endif


; ******************************************* Single Test

.if !BUILD_MULTI

print_char_:
	jsr console_print
	jmp serial_write

; Reset handler
.ifndef CUSTOM_RESET
	reset = std_reset
.endif

.macro init_nes
	sei
	cld
	ldx #$FF
	txs
	
	.if !BUILD_NSF
	; Init PPU
	lda #0
	sta PPUCTRL
	sta PPUMASK
	.endif

	; Clear RAM
	lda #0
	ldx #7      ; last page
	ldy #<nv_ram    ; offset in last page+1
	sta <0
@clear_page:
	stx <1
:   dey
	sta (0),y
	bne :-
	dex
	bpl @clear_page
	
	.if !BUILD_NSF
	; Let PPU initialize
:   bit PPUSTATUS
	bpl :-
:   bit PPUSTATUS
	bpl :-
	.endif
.endmacro

std_reset:
	init_nes
	
.if BUILD_DEVCART
	delay_msec 55
.endif

.ifdef CHR_RAM
	; Load ASCII font into CHR RAM
	jsr wait_vbl
	ldy #0
	sty PPUADDR
	sty PPUADDR
	ldx #<@ascii
	stx addr
	ldx #>@ascii
@page:
	stx addr+1
:   lda (addr),y
	sta PPUDATA
	iny
	bne :-
	inx
	cpx #>@ascii_end
	bne @page
	
.pushseg
.rodata
@ascii:
	.incbin "ascii.chr"
@ascii_end:
.popseg
.endif
	
	jsr console_init
	jsr serial_init
	jmp run_main


; Exit handler
exit_:
	; 0: ""
	cmp #1
	jlt exit2
	
	; 1: "Failed"
	bne :+
	print_str {newline,"Failed"}
	jmp exit2
	
	; n: "Error n"
:   pha
	print_str {newline,"Error "}
	jsr print_dec
	pla
	
exit2:
.if !BUILD_DEVCART
	; Be sure output is visible
	pha
	print_str {newline,newline,newline}
	jsr console_show
	pla
	
	; Report audibly as well
	jsr beep_bits
.else
	; Tell host to stop capturing serial
	lda #$1A
	jsr serial_write
	delay_msec 400
.endif

	; Clear nv_ram
	lda #0
	ldx #<nv_ram
:   sta nv_ram&$FF00,x
	inx
	bne :-
	
	jmp forever


; ******************************************* Building multi
.else

; These hook into the code that runs each test in sequence
exit_       = $BFD2
print_char_ = $BFD5
std_reset_  = $BFD8

.pushseg
.segment "VECTORS"
	.word 0,0,0, nmi, reset, irq
.segment "HOOKS"
SET_DEFAULT MULTI_TYPE,$56
	.byte MULTI_TYPE,0
	.word filename,run_main
	.res 5
reset:
	; Reset MMC1, map shell to $8000, then run it

	; write $80 to reset shift register,
	; then write $08 to reg 0
	lda #$90
:   sta $8000
	lsr a
	cmp #$02
	bne :-
	
	jmp std_reset_
.popseg

CUSTOM_HEADER=1

.endif


; ******************************************* Building ROM
.if !BUILD_NSF

; iNES data
.ifndef CUSTOM_HEADER
.pushseg
.segment "HEADER"
	.byte "NES",26
.ifdef CHR_RAM
	.byte 2,0 ; 32K PRG, CHR RAM
	.byte $01 ; UNROM, vertical mirroring
.else
	.byte 2,1 ; 32K PRG, 8K CHR
	.byte $31 ; CNROM, vertical mirroring
.segment "CHARS"
	.incbin "ascii.chr"
	.align $2000
.endif
.segment "VECTORS"
	.word 0,0,0, nmi, reset, irq
.popseg
.endif


; ******************************************* Building NSF
.else

; Reports byte A to user by printing it in hex and
; reporting its bits via sound.
; Preserved: A, X, Y
report_value:
	jsr print_a
	jmp beep_bits

; Try to affect registers/flags in a similar way
nmi_off:
	lda #0
	rts

wait_vbl:
	bit wait_vbl+2
nsf_play:
	rts

forever:
	jmp forever

.pushseg
.segment "HEADER"
	.byte "NESM",26,1,1,1
	.word $E000,reset,nsf_play
.segment "VECTORS"
	.word 0,0,0,internal_error,internal_error,internal_error
.popseg

.endif


; ******************************************* Running on NES
.if !BUILD_NSF

; Reports byte A to user by printing it in hex.
; Preserved: A, X, Y
report_value = print_a

; Clears VBL flag then waits for it to be set. Due to
; PPU quirk, this could take almost TWO frames.
; Preserved: A, X, Y
.align 16 ; to avoid branch cross
wait_vbl:
	bit PPUSTATUS
:   bit PPUSTATUS
	bpl :-
	rts

; Turns NMI off
; Preserved: X, Y
nmi_off:
	lda #0
	sta PPUCTRL
	rts

; Disables interrupts and loops forever
forever:
	sei
	lda #0
	sta PPUCTRL
	jmp forever

; Default NMI
.if (!.defined(nmi)) && (!.defined(CUSTOM_NMI))
zp_byte nmi_count

BEGIN_NMI
	inc nmi_count
	rti
END_NMI

; Waits for NMI
; Preserved: X, Y
wait_nmi:
	lda nmi_count
:   cmp nmi_count
	beq :-
	rts
.endif

; Default IRQ
.if (!.defined(irq)) && (!.defined(CUSTOM_IRQ))
BEGIN_IRQ
	bit SNDCHN  ; clear APU IRQ flag
	rti
END_IRQ
.endif

.endif


; Prints filename and newline, if available, otherwise
; does nothing.
; Preserved: A, X, Y
.if .defined(FILENAME_KNOWN) && (!BUILD_DEVCART)
print_filename:
	jsr print_newline
	;print_str {newline,"Test:"}
	lda #<filename
	sta addr
	lda #>filename
	sta addr+1
	jsr print_str_addr
	jsr print_newline
	rts

.pushseg
.segment "STRINGS"
; Filename terminated with zero byte, or just zero byte
; if filename isn't available.
filename:
	.incbin "ram:rom.nes"
	.byte 0
.popseg
.else
print_filename:
	rts

filename:
	.byte 0
.endif


; User code goes in main code segment
.segment "CODE"
	nop
