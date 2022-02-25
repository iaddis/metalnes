; Tests for APU clock jitter. Also tests basic timing of frame irq flag
; since it's needed to determine jitter.

.include "shell.inc"

; Returns current jitter in A. Takes an even number of clocks.
get_jitter:
	delay 3         ; make routine an even number of clocks
	setb SNDMODE,$40        ; clear frame irq flag
	setb SNDMODE,$00        ; begin mode 0, frame irq enabled
	delay 29827
	lda SNDCHN      ; read at 29831
	and #$40
	rts

main:   set_test 2,"Frame irq is set too soon"
	setb SNDMODE,$40        ; clear frame irq flag
	setb SNDMODE,$00        ; begin mode 0, frame irq enabled
	delay 29826
	lda SNDCHN      ; read at 29830
	and #$40
	jne test_failed
	
	set_test 3,"Frame irq is set too late"
	setb SNDMODE,$40        ; clear frame irq flag
	setb SNDMODE,$00        ; begin mode 0, frame irq enabled
	delay 29828
	lda SNDCHN      ; read at 29832
	and #$40
	jeq test_failed
	
	set_test 4,"Even jitter not handled properly"
	jsr get_jitter
	sta <temp
	delay 3         ; keep on even clocks
	jsr get_jitter
	cmp <temp
	jne test_failed
	
	set_test 5,"Odd jitter not handled properly"
	jsr get_jitter
	sta <temp
	jsr get_jitter  ; occurs on odd clock
	cmp <temp
	jeq test_failed
	
	jmp tests_passed
