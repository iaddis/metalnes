; Tests normal read_joy operation for each button.
; Runs DMC while testing, to be sure it doesn't
; affect anything.

.include "shell.inc"
.include "read_joy.inc"

zp_byte button

dmc_rate = 15 ; 0 to 15

main:   ; Start DMC
	lda #$40+dmc_rate
	sta $4010
	lda #$FF
	sta $4012
	sta $4013
	lda #0
	sta $4015
	lda #$10
	sta $4015
	
	print_str {"Press indicated buttons",newline,newline}
	
	; First string
	lda #<names
	sta addr
	lda #>names
	sta addr+1
	
	lda #$01
	sta button
@loop:  jsr print_str_addr
	jsr print_newline
	jsr print_newline
	
	; Wait for button press
:       jsr read_joy
	beq :-
	
	; Be sure nothing but correct button
	cmp button
	jne test_failed
	
	; Wait for button to be released
:       jsr read_joy
	bne :-
	delay_msec 50   ; debounce
	
	asl button
	bcc @loop
	
	jmp tests_passed

names:  .byte "A",0
	.byte "B",0
	.byte "Select",0
	.byte "Start",0
	.byte "Up",0
	.byte "Down",0
	.byte "Left",0
	.byte "Right",0
