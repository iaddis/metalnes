; Verifies timing of length counter clocks in both modes

.include "apu_shell.inc"

main:   test_main_chans test_chan
	jmp tests_passed

.macro test len,clk,mode,time
	jsr sync_apu
	delay 3
	setb {$4003,x},len
	setb SNDMODE,clk*$C0    ; optionally clock length
	lda #mode
	sta SNDMODE     ; begin mode
	delay time-4
	lda SNDCHN      ; read at time
	and chan_bit
.endmacro

test_chan:
	set_test 2,"First length of mode 0 is too soon"
	test len_2,1,0,14915
	jeq chan_failed
	
	set_test 3,"First length of mode 0 is too late"
	test len_2,1,0,14916
	jne chan_failed
	
	set_test 4,"Second length of mode 0 is too soon"
	test len_2,0,0,29831
	jeq chan_failed
	
	set_test 5,"Second length of mode 0 is too late"
	test len_2,0,0,29832
	jne chan_failed
	
	set_test 6,"Third length of mode 0 is too soon"
	test len_4,1,0,44745
	jeq chan_failed
	
	set_test 7,"Third length of mode 0 is too late"
	test len_4,1,0,44746
	jne chan_failed
	
	
	set_test 8,"First length of mode 1 is too soon"
	test len_2,0,$80,14915
	jeq chan_failed
	
	set_test 9,"First length of mode 1 is too late"
	test len_2,0,$80,14916
	jne chan_failed
	
	set_test 10,"Second length of mode 1 is too soon"
	test len_4,1,$80,37283
	jeq chan_failed
	
	set_test 11,"Second length of mode 1 is too late"
	test len_4,1,$80,37284
	jne chan_failed
	
	set_test 12,"Third length of mode 1 is too soon"
	test len_4,0,$80,52197
	jeq chan_failed
	
	set_test 13,"Third length of mode 1 is too late"
	test len_4,0,$80,52198
	jne chan_failed
	
	rts
