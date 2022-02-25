CUSTOM_IRQ = 1
CUSTOM_MAPPER = 4 ; MMC3
.include "shell.inc"

r_set_reload    = $C000
r_clear_counter = $C001
r_disable_irq   = $E000
r_enable_irq    = $E001


; Sets things for MMC3 tests
begin_mmc3_tests:
	delay_msec 200
	setb SNDMODE,$C0        ; disable frame irq
	setb PPUMASK,0          ; disable PPU
	setb PPUCTRL,0
	set_ppuaddr 0
	
	lda #1
	jsr set_reload
	jsr clear_counter
	ldx #0
	jsr clock_counter_x
	jsr clear_counter
	ldx #0
	jsr clock_counter_x
	jsr clear_irq
	rts


; Begins a test by loading X into scanline counter, first
; ensuring that pathological behavior won't occur
begin_counter_test:
	jsr clock_counter       ; avoid pathological reload behavior
	jsr clock_counter
	txa
	jsr set_reload
	jsr clear_counter
	jsr clear_irq
	rts


; Fails if MMC3 IRQ is set
should_be_clear:
	jsr get_pending
	jne test_failed
	jsr clear_irq
	rts


; Fails if MMC3 IRQ is clear, then clears it
should_be_set:
	jsr get_pending
	jeq test_failed
	jsr clear_irq
	rts


set_reload:
	sta r_set_reload
	rts


clear_counter:
	setb r_clear_counter,123
	rts


disable_irq:
	setb r_disable_irq,123
	rts


; Disables then re-enables IRQ
clear_irq:
	setb r_disable_irq,123
enable_irq:
	setb r_enable_irq,123
	rts


; Clock counter X times
; Preserved: A, Y
clock_counter_x:
:       jsr clock_counter
	dex
	bne :-
	rts


; Clocks counter once
; Preserved: A, X, Y
clock_counter:
	pha
	lda #0
	sta PPUADDR
	sta PPUADDR
	lda #$10
	sta PPUADDR
	sta PPUADDR
	lda #0
	sta PPUADDR
	sta PPUADDR
	pla
	rts


; Determines state of MMC3 IRQ flag, and acknowledges it
; Out: A = 0 if clear, 1 if set
;      flags based on value of A
; Preserved: X, Y
get_pending:
	setb irq_flag,1
	cli
	nop
	; If IRQ was pending, it will occur here
	; and shift irq_flag left
	sei
	nop
	lda irq_flag
	lsr a
	rts

zp_byte irq_flag

irq:    asl irq_flag
	sta r_disable_irq
	rti
