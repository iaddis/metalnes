; Tests NMI occurrence when enabled near time
; VBL flag is cleared.
;
; Enables NMI one PPU clock later on each line.
; Prints whether NMI occurred.
;
; 00 N
; 01 N
; 02 N
; 03 N
; 04 N
; 05 -
; 06 -
; 07 -
; 08 -

CUSTOM_NMI=1
.include "shell.inc"
.include "sync_vbl.s"
	
zp_byte nmi_count

nmi:    inc nmi_count
	rti

main:   jsr console_hide
	loop_n_times test,9
	check_crc $91410411
	jmp tests_passed        
	
test:   jsr print_a
	jsr disable_rendering
	jsr sync_vbl_delay
	delay 29742+2287
	
	lda #0
	sta <nmi_count
	lda #$80
	sta $2000
	nop
	nop
	lda #0
	sta $2000
	
	lda nmi_count
	print_cc bne,'N','-'
	jsr print_newline
	rts

