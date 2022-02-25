; Verifies basic operation of frame irq flag

.include "shell.inc"

should_be_clear:
	lda $4015
	and #$40
	jne test_failed
	rts

should_be_set:
	lda $4015
	and #$40
	jeq test_failed
	rts

main:
	set_test 2,"Flag shouldn't be set in $4017 mode $40"
	setb $4017,$40
	delay_msec 20
	jsr should_be_clear
	
	set_test 3,"Flag shouldn't be set in $4017 mode $80"
	setb $4017,$80
	delay_msec 20
	jsr should_be_clear
	
	set_test 4,"Flag should be set in $4017 mode $00"
	setb $4017,0
	delay_msec 20
	jsr should_be_set
	
	set_test 5,"Reading flag should clear it"
	setb $4017,0
	delay_msec 20
	jsr should_be_set
	jsr should_be_clear
	
	set_test 6,"Writing $00 or $80 to $4017 shouldn't affect flag"
	setb $4017,0
	delay_msec 20
	setb $4017,0
	setb $4017,$80
	jsr should_be_set
	
	set_test 7,"Writing $40 or $C0 to $4017 should clear flag"
	setb $4017,0
	delay_msec 20
	setb $4017,$40
	setb $4017,0
	jsr should_be_clear
	
	jmp tests_passed
