; NMI behavior when it interrupts BRK. Occasionally fails on
; NES due to PPU-CPU synchronization.
;
; Result when run:
; NMI BRK --
; 27  36  00 NMI before CLC
; 26  36  00 NMI after CLC
; 26  36  00 
; 36  00  00 NMI interrupting BRK, with B bit set on stack
; 36  00  00 
; 36  00  00 
; 36  00  00 
; 36  00  00 
; 27  36  00 NMI after SEC at beginning of IRQ handler
; 27  36  00 

CUSTOM_IRQ=1
CUSTOM_NMI=1
.include "shell.inc"
.include "sync_vbl.s"

zp_byte irq_flag ; IRQ sets this to saved flags on stack
zp_byte irq_temp

zp_byte nmi_flag ; NMI sets this to saved flags on stack
zp_byte nmi_temp

nmi:                    ; 7
	sta <nmi_temp   ; 3
	pla             ; 4
	pha             ; 3
	sta <nmi_flag   ; 3
	lda <nmi_temp   ; 3
	lda <nmi_temp   ; 3 to keep clock count even
	bit SNDCHN      ; 4
	rti             ; 6

irq:    sec
	sta <irq_temp
	pla
	pha
	sta <irq_flag
	lda <irq_temp
	rti

test:
	; Run test with variable delay after NMI sync
	eor #$FF
	clc
	adc #1+10
	pha
	jsr sync_vbl
	setb PPUCTRL,PPUCTRL_NMI
	pla
	jsr delay_a_25_clocks
	
	delay 29709
	
	; Clear flags
	clv
	sec
	ldx #0
	stx nmi_flag
	stx irq_flag
	nop
	nop
; NMI occurs here on first clock,
	clc
; here for second two clocks,
	
	; BRK that might get ignored
	brk
	inx             ; BRK skips byte after it
; interrupts BRK for 5 clocks,
; and occurs after SEC in BRK handler for last 2 clocks.
	sec
	nop
	nop
	
	; Get flags after test
	lda nmi_flag
	ldy irq_flag
	
	; Disable NMI and IRQ
	pha
	sei
	lda #0
	sta PPUCTRL
	pla
	
	; Print result
	ora #$02
	jsr print_a
	jsr print_space
	jsr print_y
	jsr print_space
	jsr print_x     ; should be 0
	jsr print_newline
	
	rts

main:   jsr console_hide
	print_str {"NMI BRK 00",newline}
	jsr reset_crc
	loop_n_times test,10
	check_crc $B0D44BB7
	jmp tests_passed
