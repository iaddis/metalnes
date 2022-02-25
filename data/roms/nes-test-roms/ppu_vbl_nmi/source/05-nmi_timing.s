; Tests NMI timing.
;
; Prints which instruction NMI occurred
; after. Test is run one PPU clock later
; each line.
;
; 00 4
; 01 4
; 02 4
; 03 3
; 04 3
; 05 3
; 06 3
; 07 3
; 08 3
; 09 2

CUSTOM_NMI=1
.include "shell.inc"
.include "sync_vbl.s"

zp_byte nmi_data

nmi:    stx nmi_data
	rti

main:   jsr console_hide
	loop_n_times test,10
	check_crc $A6CCB10A
	jmp tests_passed

test:   jsr print_a
	jsr disable_rendering
	jsr sync_vbl_delay
	delay 29749+29781
	lda #$FF
	sta nmi_data
	ldx #0
	lda #$80
	sta $2000
landing:
	; NMI occurs after one of these
	; instructions and prints X
	ldx #1
	ldx #2
	ldx #3
	ldx #4
	ldx #5
	
	lda #0
	sta $2000
	lda nmi_data
	jsr print_dec
	jsr print_newline
	rts
