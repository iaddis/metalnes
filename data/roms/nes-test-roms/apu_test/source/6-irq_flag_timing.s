; Frame interrupt flag is set three times in a row 29831 clocks after
; writing $00 to $4017.

.include "shell.inc"
.include "sync_apu.s"

main:   set_test 2,"Flag first set too soon"
	jsr sync_apu
	lda #0          ; begin mode 0
	sta SNDMODE
	delay 29826
	lda SNDCHN      ; at 29830 flag should be clear
	and #$40
	jne test_failed
	
	set_test 3,"Flag first set too late"
	jsr sync_apu
	lda #0          ; begin mode 0
	sta SNDMODE
	delay 29827
	lda SNDCHN      ; at 29831 flag should be set
	and #$40
	jeq test_failed
	
	set_test 4,"Flag last set too soon"
	jsr sync_apu
	lda #0          ; begin mode 0
	sta SNDMODE
	delay 29828
	lda SNDCHN      ; at 29832 read and clear flag
	lda SNDCHN      ; flag should have been set again
	and #$40
	jeq test_failed
	
	set_test 5,"Flag last set too late "
	jsr sync_apu
	lda #0          ; begin mode 0
	sta SNDMODE
	delay 29829
	lda SNDCHN      ; at 29833 read and clear flag
	lda SNDCHN      ; flag should't have been set again
	and #$40
	jne test_failed
	
	jmp tests_passed
