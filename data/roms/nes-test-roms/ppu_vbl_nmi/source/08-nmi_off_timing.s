; Tests NMI occurrence when disabled near time
; VBL flag is set.
;
; Disables NMI one PPU clock later on each line.
; Prints whether NMI occurred.
;
; 03 -
; 04 -
; 05 -
; 06 -
; 07 N
; 08 N
; 09 N
; 0A N
; 0B N
; 0C N

CUSTOM_NMI=1
.include "shell.inc"
.include "sync_vbl.s"
	
zp_byte nmi_count

nmi:    inc nmi_count
	rti

main:   jsr console_hide
	for_loop test,3,12,+1
	check_crc $ACB2102D
	jmp tests_passed        
	
test:   jsr print_a
	jsr disable_rendering
	jsr sync_vbl_delay
	delay 29746
	
	lda #0
	sta <nmi_count
	lda #$80
	sta $2000
	nop
	nop
	lda #0
	sta $2000
	nop
	nop
	
	lda nmi_count
	print_cc bne,'N','-'
	jsr print_newline
	rts

