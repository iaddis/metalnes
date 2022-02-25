; Reports internal error and exits program
internal_error:
	init_cpu_regs
	print_str newline,"Internal error"
	lda #255
	jmp exit

.import __NVRAM_LOAD__, __NVRAM_SIZE__

.macro fill_ram_ Begin, End
	; Simpler to count from negative size up to 0,
	; and adjust address downward to compensate
	; for initial low byte in Y index
	.local Neg_size
	Neg_size = (Begin) - (End)
	ldxy #(Begin) - <Neg_size
	sty addr
	stx addr+1
	ldxy #Neg_size
:   sta (addr),y
	iny
	bne :-
	inc addr+1
	inx
	bne :-
.endmacro

; Clears 0 through ($100+S), $200 through __NVRAM_LOAD__-1, and
; __NVRAM_LOAD__+__NVRAM_SIZE__ through $7FF
clear_ram:
	lda #0
	
	bss_begin = $200
	
	fill_ram_ bss_begin,__NVRAM_LOAD__
	fill_ram_ __NVRAM_LOAD__+__NVRAM_SIZE__,$800
	
	; Zero-page
	tax
:   sta 0,x
	inx
	bne :-
	
	; Stack below S
	tsx
	inx
:   dex
	sta $100,x
	bne :-
	
	rts


nv_res unused_nv_var ; to avoid size=0

; Clears nvram
clear_nvram:
	lda #0
	fill_ram_ __NVRAM_LOAD__,__NVRAM_LOAD__+__NVRAM_SIZE__
	rts


; Prints filename and newline, if available, otherwise nothing.
; Preserved: A, X, Y
print_filename:
	.ifdef FILENAME_KNOWN
		pha
		jsr print_newline
		setw addr,filename
		jsr print_str_addr
		jsr print_newline
		pla
	.endif
	rts
	
.pushseg
.segment "RODATA"
	; Filename terminated with zero byte.
	filename:
		.ifdef FILENAME_KNOWN
			.incbin "ram:nes_temp"
		.endif
		.byte 0
.popseg


;**** ROM-specific ****
.ifndef BUILD_NSF

.include "ppu.s"

avoid_silent_nsf:
play_byte:
	rts

; Disables interrupts and loops forever
.ifndef CUSTOM_FOREVER
forever:
	sei
	lda #0
	sta PPUCTRL
:   beq :-
	.res $10,$EA    ; room for code to run loader
.endif


; Default NMI
.ifndef CUSTOM_NMI
	zp_byte nmi_count
	zp_byte flags_from_nmi
	zp_byte pclo_from_nmi
	
	nmi:    ; Record flags and PC low byte from stack
		pla
		sta flags_from_nmi
		pla
		sta pclo_from_nmi
		pha
		lda flags_from_nmi
		pha
		inc nmi_count
		rti
	
	; Waits for NMI. Must be using NMI handler that increments
	; nmi_count, with NMI enabled.
	; Preserved: X, Y
	wait_nmi:
		lda nmi_count
	:   cmp nmi_count
		beq :-
		rts
.endif


; Default IRQ
.ifndef CUSTOM_IRQ
	zp_byte flags_from_irq
	zp_byte pclo_from_irq
	zp_byte irq_count
	
	irq:    ; Record flags and PC low byte from stack
		pla
		sta flags_from_irq
		pla
		sta pclo_from_irq
		pha
		lda flags_from_irq
		pha
		inc irq_count
		bit SNDCHN  ; clear frame IRQ flag
		rti
	
.endif

.endif


; Reports A in binary as high and low tones, with
; leading low tone for reference. Omits leading
; zeroes. Doesn't hang if no APU is present.
; Preserved: A, X, Y
play_hex:
	pha
	
	; Make low reference beep
	clc
	jsr @beep
	
	; Remove high zero bits
	sec
:   rol a
	bcc :-
	
	; Play remaining bits
	beq @zero
:   jsr @beep
	asl a
	bne :-
@zero:

	delay_msec 300
	pla
	rts

; Plays low/high beep based on carry
; Preserved: A, X, Y
@beep:
	pha
	
	; Set up square
	lda #1
	sta SNDCHN
	sta $4001
	sta $4003
	adc #$FE    ; period=$100 if carry, $1FF if none
	sta $4002
	
	; Fade volume
	lda #$0F
:   ora #$30
	sta $4000
	delay_msec 8
	sec
	sbc #$31
	bpl :-
	
	; Silence
	setb SNDCHN,0
	delay_msec 160
	
	pla
	rts
