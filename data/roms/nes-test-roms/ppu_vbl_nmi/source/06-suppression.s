; Tests behavior when $2002 is read near time
; VBL flag is set.
;
; Reads $2002 one PPU clock later each time.
; Prints whether VBL flag read back as set, and
; whether NMI occurred.
;
; 00 - N
; 01 - N
; 02 - N
; 03 - N        ; normal behavior
; 04 - -        ; flag never set, no NMI
; 05 V -        ; flag read back as set, but no NMI
; 06 V -
; 07 V N        ; normal behavior
; 08 V N
; 09 V N

CUSTOM_NMI=1
.include "shell.inc"
.include "sync_vbl.s"
	
zp_byte nmi_count

nmi:    inc nmi_count
	rti

main:   jsr console_hide
	loop_n_times test,10
	check_crc $A6816580
	jmp tests_passed        
	
test:   jsr print_a
	jsr disable_rendering
	jsr sync_vbl_delay
	delay 29748
	
	lda #0
	sta <nmi_count
	lda #$80
	sta $2000
	
	nop
	nop
	lda PPUSTATUS
	nop
	nop
	
	ldx #0
	stx $2000
	ldx nmi_count
	
	and #$80
	print_cc bne,'V','-'
	
	jsr print_space

	cpx #0
	print_cc bne,'N','-'
	
	jsr print_newline
	rts

