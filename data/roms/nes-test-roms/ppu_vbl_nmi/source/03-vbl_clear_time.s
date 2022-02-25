; Tests time VBL flag is cleared.
;
; Reads $2002 and prints VBL flag.
; Test is run one PPU clock later each line,
; around the time the flag is cleared.
;
; 00 V
; 01 V
; 02 V
; 03 V
; 04 V
; 05 V
; 06 -
; 07 -
; 08 -

.include "shell.inc"
.include "sync_vbl.s"
	
main:   jsr console_hide
	loop_n_times test,9
	check_crc $E8ADB5BB
	jmp tests_passed        
	
test:   jsr print_a
	jsr disable_rendering
	jsr sync_vbl_delay
	delay 29763
	delay 2273
	lda $2002
	print_cc bmi,'V','-'
	jsr print_newline
	rts
