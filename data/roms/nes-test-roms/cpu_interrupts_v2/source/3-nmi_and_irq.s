; NMI behavior when it interrupts IRQ vectoring.
;
; Result when run:
; NMI IRQ
; 23  00 NMI occurs before LDA #1
; 21  00 NMI occurs after LDA #1 (Z flag clear)
; 21  00
; 20  00 NMI occurs after CLC, interrupting IRQ
; 20  00
; 20  00
; 20  00
; 20  00
; 20  00
; 20  00 Same result for 7 clocks before IRQ is vectored
; 25  20 IRQ occurs, then NMI occurs after SEC in IRQ handler
; 25  20

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
	bit SNDCHN
	rti

test:   ; Run test code, with decreasing delay after
	; after synchronizing with NMI, causing NMI
	; to occur later each time.
	eor #$FF
	clc
	adc #1+12
	jsr sync_vbl
	jsr delay_a_25_clocks
	
	delay 29678

	; Reset APU frame sequencer and enable IRQ
	lda #0
	sta SNDMODE
	
	delay 29805
	
	; Enable NMI and IRQ
	lda #PPUCTRL_NMI
	sta PPUCTRL
	lda SNDCHN      ; clear IRQ
	cli
	
	; Clear interrupt flags
	lda #0
	sta nmi_flag
	sta irq_flag
	
	clv
	sec
	; Z and C set, others clear
	
; NMI occurs here first,
	lda #1          ; clear Z flag
; then here for two clocks,
	clc             ; clear C flag
; then here.
	
; IRQ always occurs here.
	nop
	
	; Read interrupt flags
	ldx nmi_flag
	ldy irq_flag
	
	; Disable interrupts
	sei
	setb PPUCTRL,0
	
	; Print result
	jsr print_x
	jsr print_space
	jsr print_y
	jsr print_newline
	rts

main:   jsr console_hide
	print_str {"NMI BRK",newline}
	jsr reset_crc
	loop_n_times test,12
	check_crc $B7B2ED22
	jmp tests_passed
