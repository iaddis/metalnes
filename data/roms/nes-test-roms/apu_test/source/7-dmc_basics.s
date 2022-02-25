; Verifies basic DMC operation

.include "apu_shell.inc"

; Delays n DMC sample bytes, assuming DMC is running at maximum rate
.macro delay_dmc n
	delay 54*8 * (n)
.endmacro

main:
	; Setup
	setb chan_bit,$10       ; so should_be_* will work
	setb $4012,<((dmc_sample-$C000)/$40)
	setb $4010,$0F
	delay 428*9
	
	set_test 2,"DMC isn't working well enough to test further"
	setb SNDCHN,$00
	setb $4013,1            ; length = 17 bytes
	setb SNDCHN,$10         ; start DMC
	delay_dmc 10
	jsr should_be_playing
	delay_dmc 10
	jsr should_be_silent

	set_test 3,"Starting DMC should reload length from $4013"
	setb SNDCHN,$00
	setb $4013,1
	setb SNDCHN,$10
	delay_dmc 20
	setb SNDCHN,$00
	setb SNDCHN,$10         ; length should be 17 again
	delay_dmc 10
	jsr should_be_playing
	delay_dmc 10
	jsr should_be_silent
	
	set_test 4,"Writing $10 to $4015 should restart DMC if previous sample finished"
	setb SNDCHN,$10
	delay_dmc 20            ; allow sample to finish
	setb SNDCHN,$10         ; start another
	jsr should_be_playing

	set_test 5,"Writing $10 to $4015 should not affect DMC if previous sample is still playing"
	setb SNDCHN,$10
	delay_dmc 10
	setb SNDCHN,$10         ; previous sample still playing, so this is ignored
	jsr should_be_playing
	delay_dmc 10
	jsr should_be_silent

	set_test 6,"Writing $00 to $4015 should stop current sample"
	setb SNDCHN,$10
	delay_dmc 10
	setb SNDCHN,$00         ; stops sample immediately
	jsr should_be_silent
	
	set_test 7,"Changing $4013 shouldn't affect current sample length"
	setb SNDCHN,$10         ; start 17-byte sample
	setb $4013,2            ; length of next sample = 33 bytes
	delay_dmc 20
	setb SNDCHN,$10         ; start 33-byte sample
	setb $4013,1            ; length of next sample = 17 bytes
	delay_dmc 30
	jsr should_be_playing
	delay_dmc 6
	jsr should_be_silent
	
	set_test 8,"Shouldn't set DMC IRQ flag when flag is disabled"
	setb $4010,$0F
	setb SNDCHN,$10         ; start 17-byte sample
	delay_dmc 20
	lda $4015
	jmi test_failed
	
	set_test 9,"Should set IRQ flag when enabled and sample ends"
	setb $4010,$8F
	setb SNDCHN,$10         ; start 17-byte sample
	lda $4015
	jmi test_failed
	delay_dmc 20
	lda $4015
	jpl test_failed
	
	set_test 10,"Reading IRQ flag shouldn't clear it"
	lda $4015
	jpl test_failed
	
	set_test 11,"Writing to $4015 should clear IRQ flag"
	setb SNDCHN,$10
	lda $4015
	jmi test_failed
	setb SNDCHN,0
	
	set_test 12,"Disabling IRQ flag should clear it"
	setb SNDCHN,$10
	delay_dmc 20
	lda $4015
	jpl test_failed
	setb $4010,$0F  ; should clear IRQ flag
	setb $4010,$8F  ; shouldn't change it
	lda $4015
	jmi test_failed
	
	set_test 13,"Looped sample shouldn't end until $00 is written to $4015"
	setb $4010,$4F
	setb SNDCHN,$10
	delay_dmc 100
	jsr should_be_playing
	setb SNDCHN,$00
	jsr should_be_silent
	
	set_test 14,"Looped sample shouldn't ever set IRQ flag"
	setb $4010,$CF
	setb SNDCHN,$10
	delay_dmc 100
	lda $4015
	jmi test_failed
	setb SNDCHN,$00
	lda $4015
	jmi test_failed
	
	set_test 15,"Clearing loop flag and then setting again shouldn't stop loop"
	setb $4010,$CF
	setb SNDCHN,$10
	delay_dmc 17*3 + 10
	setb $4010,$8F
	setb $4010,$CF
	delay_dmc 100
	jsr should_be_playing
	setb SNDCHN,$00
	
	set_test 16,"Clearing loop flag should end sample once it reaches end"
	setb $4010,$CF
	setb SNDCHN,$10
	delay_dmc 17*3 + 10
	setb $4010,$8F
	lda $4015
	jmi test_failed
	jsr should_be_playing
	delay_dmc 10
	lda $4015
	jpl test_failed
	jsr should_be_silent
	
	set_test 17,"Looped sample should reload length from $4013 each time it reaches end"
	setb $4010,$CF
	setb SNDCHN,$10
	delay_dmc 17*3 + 10
	setb $4013,2
	delay_dmc 10
	setb $4010,$8F
	delay_dmc 23
	lda $4015
	jmi test_failed
	jsr should_be_playing
	delay_dmc 10
	lda $4015
	jpl test_failed
	jsr should_be_silent
	
	set_test 18,"$4013=0 should give 1-byte sample"
	setb $4010,$8F
	setb $4013,0
	setb SNDCHN,$10
	delay_dmc 4
	jsr should_be_silent
	
	set_test 19,"There should be a one-byte buffer that's filled immediately if empty"
	setb $4013,1
	setb SNDCHN,$10
	lda #$10
:       and $4015
	bne :-
	delay_dmc 4
	delay 30
	setb $4013,0
	setb SNDCHN,$10
	lda $4015
	and #$90
	cmp #$80
	jne test_failed
	setb SNDCHN,$10
	jsr should_be_playing
	delay_dmc 4
	jsr should_be_silent
	
	jmp tests_passed

; Silent DMC sample so tests won't make any noise
.align $40
dmc_sample:
	.res 33,$00
