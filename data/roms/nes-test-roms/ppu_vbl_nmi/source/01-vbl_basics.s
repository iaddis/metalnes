; Tests basic VBL operation and VBL period.

.include "shell.inc"

main:   set_test 2,"VBL period is way off"
	jsr wait_vbl
	delay 30111
	lda $2002
	jpl test_failed
	
	set_test 3,"Reading VBL flag should clear it"
	lda $2002
	jmi test_failed
	
	set_test 4,"Writing $2002 shouldn't affect VBL flag"
	jsr wait_vbl
	delay 30111
	sta $2002
	lda $2002
	jpl test_failed
	
	set_test 5,"$2002 should be mirrored at $200A"
	jsr wait_vbl
	delay 30111
	lda $200A
	jpl test_failed
	lda $200A
	jmi test_failed
	
	set_test 6,"$2002 should be mirrored every 8 bytes up to $2FFA"
	jsr wait_vbl
	delay 30111
	lda $2FFA
	jpl test_failed
	lda $2FFA
	jmi test_failed
	
	delay_msec 1000
	
	lda #0          ; BG off
	sta $2001
	
	; Delay 60 frames after VBL, then read VBL flag
	jsr wait_vbl
	delay 29780*60+60/3
	ldx $2002
	delay 5
	lda $2002
	
	set_test 7,"VBL period is too short with BG off"
	cpx #0
	jmi test_failed
	
	set_test 8,"VBL period is too long with BG off"
	cmp #0
	jpl test_failed
	
	jmp tests_passed
