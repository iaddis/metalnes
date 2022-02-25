; Keeps track of number of times reset, and prompts user.

power_flag_value = $42

nv_res power_flag_
nv_res num_resets_

; Out: A = number of times NES has been reset since turned on
; Preserved: X, Y
num_resets:
	lda power_flag_
	cmp #power_flag_value
	bne :+
	lda num_resets_
	rts
:       lda #0
	rts


; Prompts user to press reset after message disappears,
; then hides message, increments reset count, and asks
; emulator to reset NES.
; Preserved: X, Y
prompt_to_reset:
	print_str {newline,newline,"Press RESET"}
	
	; Add "again" if this isn't first requested reset
	jsr num_resets
	beq :+
	print_str " again"
:       
	print_str newline,newline
	
	jsr inc_reset_count
	
	; Show message
	jsr console_show
	
	rts


; Increments reset count and marks it as valid
; Preserved: X, Y
inc_reset_count:
	jsr num_resets
	clc
	adc #1
	bcc :+
	lda #$FF        ; don't wrap around
:       sta num_resets_
	
	setb power_flag_,power_flag_value
	
	; Tell emulator that NES should be reset now
	lda #$81
	jsr set_final_result
	
	rts


; Waits in infinite loop for reset
; Preserved: A, X, Y, flags
wait_reset:
	jmp wait_reset
